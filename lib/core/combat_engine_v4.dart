import 'dart:math' as math;

import 'auto_planner_v4.dart';
import 'combat_board_v4.dart';
import 'combat_state_v4.dart';
import 'hex_coord_v4.dart';
import 'seeded_rng_v4.dart';
import 'status_system_v4.dart';
import 'spell_action_v4.dart';
import 'surge_cast_resolver_v4.dart';
import 'target_resolver_v4.dart';
import 'timeline_v4.dart';

part 'combat_engine_v4_basic_actions.dart';
part 'combat_engine_v4_movement_auto.dart';
part 'combat_engine_v4_spell_cast.dart';
part 'combat_engine_v4_spell_effects.dart';
part 'combat_engine_v4_npc_actions.dart';
part 'combat_engine_v4_companion_actions.dart';


class CombatEngineV4 {
  CombatEngineV4({
    required List<CombatUnitV4> units,
    required int seed,
    CombatBoardV4? board,
  })  : units = units,
        board = board ?? CombatBoardV4(),
        rng = SeededRngV4(seed),
        timeline = TimelineV4(units) {
    for (final unit in units) {
      unit.nextActionTime = 0;
      unit.reactionAvailable = true;
    }
  }

  final List<CombatUnitV4> units;
  final CombatBoardV4 board;
  final SeededRngV4 rng;
  final TimelineV4 timeline;
  final AutoPlannerV4 autoPlanner = const AutoPlannerV4();
  final TargetResolverV4 targetResolver = const TargetResolverV4();
  final SurgeCastResolverV4 castResolver = const SurgeCastResolverV4();
  final List<CombatEventV4> log = [];
  final Map<String, Object> runtime = {};

  CombatUnitV4? activeUnit;
  bool activationOpen = false;
  bool movementUsedThisActivation = false;

  bool get battleOver =>
      units.where((u) => !u.isKo).map((u) => u.team).toSet().length <= 1;

  CombatTeamV4? get winner {
    if (!battleOver) return null;
    final living = units.where((u) => !u.isKo).toList();
    return living.isEmpty ? null : living.first.team;
  }

  CombatUnitV4 unit(String id) =>
      units.firstWhere((value) => value.id == id);

  List<CombatUnitV4> timelinePreview({int limit = 8}) =>
      timeline.ordered(limit: limit);

  CombatUnitV4? beginNextActivation() {
    if (battleOver) return null;

    final actor = timeline.nextActor();
    if (actor == null) return null;

    activeUnit = actor;
    activationOpen = true;
    movementUsedThisActivation = false;

    _activationStart(actor);
    return actor;
  }

  void _activationStart(CombatUnitV4 actor) {
    // DOT ticks before hard-control check.
    _tickDot(actor, StatusTypeV4.burning);
    _tickDot(actor, StatusTypeV4.bleeding);
    _tickDot(actor, StatusTypeV4.poisoned);

    if (actor.isKo) {
      _ko(actor);
      finishActivation(baseDelay: 100);
      return;
    }

    final stun = actor.status(StatusTypeV4.stunned);
    if (stun != null) {
      log.add(CombatEventV4(
        time: timeline.now,
        kind: 'stun_skip',
        actorId: actor.id,
        message: 'STUNNED: activation skipped',
      ));
      finishActivation(baseDelay: 100);
    }
  }

  void _tickDot(CombatUnitV4 unit, StatusTypeV4 type) {
    final status = unit.status(type);
    if (status == null || status.tickPower <= 0) return;

    final raw = status.tickPower * status.stacks;
    final damage = switch (type) {
      StatusTypeV4.burning => _mitigateMagic(
          unit,
          raw,
          DamageTypeV4.fire,
        ),
      StatusTypeV4.bleeding => raw,
      StatusTypeV4.poisoned => raw,
      _ => raw,
    };

    _dealFinalDamage(
      sourceId: status.sourceId ?? 'status',
      target: unit,
      amount: damage,
      kind: 'dot_${type.name}',
    );
  }

  void finishActivation({required int baseDelay}) {
    final actor = activeUnit;
    if (actor == null || !activationOpen) return;

    // Slow/Haste modify the delay produced by this activation.
    // Schedule while those statuses are still present, then decrement duration.
    timeline.schedule(actor, baseDelay);

    _decrementStatuses(actor);
    _decrementBarriers(actor);

    actor.reactionAvailable = true;
    activationOpen = false;
    movementUsedThisActivation = false;
    activeUnit = null;
  }

  void _decrementStatuses(CombatUnitV4 unit) {
    for (final status in List<StatusV4>.of(unit.statuses)) {
      status.remainingActivations -= 1;
      if (status.remainingActivations <= 0) {
        unit.statuses.remove(status);
      }
    }
  }

  void _decrementBarriers(CombatUnitV4 unit) {
    for (final barrier in List<BarrierV4>.of(unit.barriers)) {
      barrier.remainingActivations -= 1;
      if (barrier.remainingActivations <= 0 || barrier.amount <= 0) {
        unit.barriers.remove(barrier);
      }
    }
  }
  bool _canAct(CombatUnitV4 unit) =>
      activationOpen && activeUnit?.id == unit.id && !unit.isKo;

  int _rollDamage(int raw, {required bool critical}) {
    if (raw <= 0) return 0;
    final variance = 0.90 + rng.nextDouble() * 0.20;
    var value = (raw * variance).round();
    if (critical) value = (value * 1.5).round();
    return math.max(1, value);
  }

  int _mitigate(
    CombatUnitV4 target,
    int raw,
    DamageTypeV4 type,
  ) {
    var value = raw;

    final physical = type == DamageTypeV4.physical;
    value -= physical ? target.stats.armor : target.stats.magicResist;
    value = math.max(1, value);

    if (target.weaknesses.contains(type)) {
      value = (value * 1.25).round();
    } else if (target.resistances.contains(type)) {
      value = (value * 0.75).round();
    }

    return math.max(1, value);
  }

  int _mitigateMagic(
    CombatUnitV4 target,
    int raw,
    DamageTypeV4 type,
  ) {
    var value = raw - (target.stats.magicResist ~/ 2);
    value = math.max(1, value);

    if (target.weaknesses.contains(type)) {
      value = (value * 1.25).round();
    } else if (target.resistances.contains(type)) {
      value = (value * 0.75).round();
    }
    return math.max(1, value);
  }

  void _dealFinalDamage({
    required String sourceId,
    required CombatUnitV4 target,
    required int amount,
    required String kind,
  }) {
    if (amount <= 0 || target.isKo) return;

    var remaining = amount;

    final guarded = target.status(StatusTypeV4.guarded);
    if (guarded != null) {
      final ratio = guarded.potency == 0 ? 0.20 : guarded.potency / 100;
      remaining = math.max(1, (remaining * (1 - ratio)).round());
    }

    // Earliest-expiring barrier is consumed first.
    target.barriers.sort(
      (a, b) => a.remainingActivations.compareTo(b.remainingActivations),
    );

    for (final barrier in List<BarrierV4>.of(target.barriers)) {
      if (remaining <= 0) break;
      final absorbed = math.min(barrier.amount, remaining);
      barrier.amount -= absorbed;
      remaining -= absorbed;
      if (barrier.amount <= 0) target.barriers.remove(barrier);
    }

    if (remaining > 0) {
      target.hp = math.max(0, target.hp - remaining);
    }

    if (target.isKo) _ko(target);

    log.add(CombatEventV4(
      time: timeline.now,
      kind: kind,
      actorId: sourceId,
      targetId: target.id,
      value: amount,
    ));
  }

  void _ko(CombatUnitV4 unit) {
    unit.hp = 0;
    clearOnKoV4(unit);
    log.add(CombatEventV4(
      time: timeline.now,
      kind: 'ko',
      actorId: unit.id,
    ));
  }
}
