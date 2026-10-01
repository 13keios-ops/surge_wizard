import 'balanced_auto_v4.dart';
import 'boss_bone_heap_v4.dart';
import 'combat_engine_v4.dart';
import 'combat_state_v4.dart';
import 'hex_coord_v4.dart';
import 'spell_catalog_v4.dart';

class HeadlessPolicyV4 {
  const HeadlessPolicyV4();

  static const balanced = BalancedAutoPlannerV4();

  void takeActivation(CombatEngineV4 engine) {
    final actor = engine.activeUnit;
    if (actor == null || !engine.activationOpen) return;

    if (actor.team == CombatTeamV4.party) {
      _party(engine, actor);
    } else {
      _enemy(engine, actor);
    }
  }

  void _party(CombatEngineV4 engine, CombatUnitV4 actor) {
    _avoidBoneHeapSweep(engine, actor);
    if (!engine.activationOpen) return;

    var intent = balanced.choose(engine, actor);
    if (intent.kind == BalancedIntentKindV4.wait &&
        !engine.movementUsedThisActivation) {
      final enemies = _enemies(engine, actor);
      if (enemies.isNotEmpty) {
        final desired = actor.id == 'wizard' ? 5 : 1;
        _moveIntoRange(engine, actor, enemies.first, desired);
        if (!engine.activationOpen) return;
        intent = balanced.choose(engine, actor);
      }
    }

    engine.log.add(CombatEventV4(
      time: engine.timeline.now,
      kind: 'auto_choice',
      actorId: actor.id,
      targetId: intent.targetId,
      message: '${intent.kind.name}:${intent.score.toStringAsFixed(1)}',
    ));
    _executePartyIntent(engine, actor, intent);
  }

  void _executePartyIntent(
    CombatEngineV4 engine,
    CombatUnitV4 actor,
    BalancedIntentV4 intent,
  ) {
    switch (intent.kind) {
      case BalancedIntentKindV4.wizardFireball:
        engine.castSpellAction(
          casterId: actor.id,
          spell: SpellCatalogV4.fireball,
          targetHex: intent.targetHex!,
        );
        return;
      case BalancedIntentKindV4.wizardFireBolt:
        engine.castSpellAction(
          casterId: actor.id,
          spell: SpellCatalogV4.fireBolt,
          targetHex: intent.targetHex!,
        );
        return;
      case BalancedIntentKindV4.wizardDart:
        engine.castSpellAction(
          casterId: actor.id,
          spell: SpellCatalogV4.arcaneDart,
          targetHex: intent.targetHex!,
        );
        return;
      case BalancedIntentKindV4.wizardBind:
        engine.castSpellAction(
          casterId: actor.id,
          spell: SpellCatalogV4.arcaneBind,
          targetHex: intent.targetHex!,
        );
        return;
      case BalancedIntentKindV4.wizardShield:
        engine.castSpellAction(
          casterId: actor.id,
          spell: SpellCatalogV4.arcaneShield,
          targetHex: actor.anchor,
        );
        return;
      case BalancedIntentKindV4.kaelQuick:
        engine.kaelQuickSlash(targetId: intent.targetId!);
        return;
      case BalancedIntentKindV4.kaelHeavy:
        engine.kaelHeavyStrike(targetId: intent.targetId!);
        return;
      case BalancedIntentKindV4.kaelPull:
        engine.kaelHookPull(targetId: intent.targetId!);
        return;
      case BalancedIntentKindV4.kaelGuard:
        engine.kaelGuardStance();
        return;
      case BalancedIntentKindV4.neraVital:
        engine.neraVitalStrike(targetId: intent.targetId!);
        return;
      case BalancedIntentKindV4.neraExpose:
        engine.neraExposeWeakness(targetId: intent.targetId!);
        return;
      case BalancedIntentKindV4.neraSmoke:
        engine.neraSmokeStep(intent.targetHex!);
        return;
      case BalancedIntentKindV4.wait:
        engine.finishActivation(baseDelay: 85);
        return;
    }
  }

  void _enemy(CombatEngineV4 engine, CombatUnitV4 actor) {
    final targets = _enemies(engine, actor);
    if (targets.isEmpty) {
      engine.finishActivation(baseDelay: 85);
      return;
    }

    if (BoneHeapBehaviorV4.handles(actor)) {
      BoneHeapBehaviorV4.takeActivation(engine, actor);
      return;
    }

    if (actor.name == 'Skeleton Apprentice') {
      final target = targets.first;
      _moveIntoRange(engine, actor, target, 5);
      if (!engine.activationOpen) return;
      if (actor.anchor.distanceTo(target.anchor) <= 5) {
        engine.basicAttack(
          attackerId: actor.id,
          targetId: target.id,
          range: 5,
          ranged: true,
          damageType: DamageTypeV4.arcane,
          baseDelay: 100,
        );
      } else {
        engine.finishActivation(baseDelay: 100);
      }
      return;
    }

    if (actor.name == 'Goblin Scout') {
      final kael = targets.where((u) => u.id == 'kael').firstOrNull;
      final target = kael ?? targets.first;
      _moveIntoRange(engine, actor, target, 4);
      if (!engine.activationOpen) return;
      final distance = actor.anchor.distanceTo(target.anchor);
      if (distance <= 1) {
        engine.basicAttack(
          attackerId: actor.id,
          targetId: target.id,
          baseDelay: 90,
        );
      } else if (distance <= 4) {
        engine.basicAttack(
          attackerId: actor.id,
          targetId: target.id,
          skillPower: -2,
          skillAccuracy: -1,
          range: 4,
          ranged: true,
          baseDelay: 95,
        );
      } else {
        engine.finishActivation(baseDelay: 90);
      }
      return;
    }

    final target = actor.name == 'Stone Gargoyle'
        ? _rearTarget(targets)
        : (targets.where((u) => u.id == 'kael').firstOrNull ?? targets.first);
    _moveIntoRange(engine, actor, target, 1);
    if (!engine.activationOpen) return;

    if (actor.anchor.distanceTo(target.anchor) <= 1) {
      engine.basicAttack(
        attackerId: actor.id,
        targetId: target.id,
        skillPower: actor.name == 'Stone Gargoyle' ? 1 : 0,
        baseDelay: actor.name == 'Cursed Armor' ? 120 : 100,
      );
    } else {
      engine.finishActivation(baseDelay: 100);
    }
  }

  CombatUnitV4 _rearTarget(List<CombatUnitV4> targets) {
    final sorted = targets.toList()
      ..sort((a, b) {
        int weight(CombatUnitV4 u) =>
            u.id == 'wizard' ? 0 : u.id == 'nera' ? 1 : 2;
        final w = weight(a).compareTo(weight(b));
        return w != 0 ? w : a.id.compareTo(b.id);
      });
    return sorted.first;
  }

  List<CombatUnitV4> _enemies(
    CombatEngineV4 engine,
    CombatUnitV4 actor,
  ) {
    final result = engine.units
        .where((u) => !u.isKo && u.team != actor.team)
        .toList()
      ..sort((a, b) {
        final da = actor.anchor.distanceTo(a.anchor);
        final db = actor.anchor.distanceTo(b.anchor);
        if (da != db) return da.compareTo(db);
        final hp = a.hp.compareTo(b.hp);
        return hp != 0 ? hp : a.id.compareTo(b.id);
      });
    return result;
  }

  void _avoidBoneHeapSweep(
    CombatEngineV4 engine,
    CombatUnitV4 actor,
  ) {
    final runtime = engine.runtime[BoneHeapBehaviorV4.runtimeKey];
    if (runtime is! BoneHeapRuntimeV4 ||
        !runtime.pendingSweepHexes.contains(actor.anchor) ||
        actor.has(StatusTypeV4.rooted)) {
      return;
    }

    final reachable = engine.board.reachable(
      unit: actor,
      units: engine.units,
    );
    final safe = reachable.keys
        .where((c) =>
            c != actor.anchor && !runtime.pendingSweepHexes.contains(c))
        .toList()
      ..sort((a, b) {
        final cost = (reachable[a] ?? 999).compareTo(reachable[b] ?? 999);
        if (cost != 0) return cost;
        if (a.col != b.col) return a.col.compareTo(b.col);
        return a.row.compareTo(b.row);
      });
    if (safe.isNotEmpty) engine.moveActiveTo(safe.first);
  }

  void _moveIntoRange(
    CombatEngineV4 engine,
    CombatUnitV4 actor,
    CombatUnitV4 target,
    int desiredRange,
  ) {
    if (actor.has(StatusTypeV4.rooted) ||
        actor.anchor.distanceTo(target.anchor) <= desiredRange ||
        engine.movementUsedThisActivation) {
      return;
    }

    final reachable = engine.board.reachable(
      unit: actor,
      units: engine.units,
    );
    final candidates = reachable.keys.where((c) => c != actor.anchor).toList()
      ..sort((a, b) {
        final da = a.distanceTo(target.anchor);
        final db = b.distanceTo(target.anchor);
        if (da != db) return da.compareTo(db);
        return (reachable[a] ?? 999).compareTo(reachable[b] ?? 999);
      });
    if (candidates.isNotEmpty) engine.moveActiveTo(candidates.first);
  }
}

extension _FirstOrNullHeadless<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
