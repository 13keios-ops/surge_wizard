import 'combat_engine_v4.dart';
import 'combat_state_v4.dart';
import 'hex_coord_v4.dart';
import 'vertical_slice_catalog_v4.dart';
class BoneHeapRuntimeV4 {
  int activationCount = 0;
  bool reassembled = false;
  bool fracturedCore = false;
  int summons = 0;
  Set<HexCoord> pendingSweepHexes = {};
}
abstract final class BoneHeapBehaviorV4 {
  static const String runtimeKey = 'boss_bone_heap';
  static bool handles(CombatUnitV4 actor) =>
      actor.name == 'Bone Heap';
  static void takeActivation(
    CombatEngineV4 engine,
    CombatUnitV4 boss,
  ) {
    final runtime = engine.runtime.putIfAbsent(
      runtimeKey,
      BoneHeapRuntimeV4.new,
    ) as BoneHeapRuntimeV4;
    runtime.activationCount++;
    _updateFracturedCore(engine, boss, runtime);
    if (runtime.pendingSweepHexes.isNotEmpty) {
      _resolveTelegraphedSweep(engine, boss, runtime);
      return;
    }
    if (!runtime.reassembled &&
        boss.hp <= (boss.stats.maxHp * 0.60).round()) {
      _reassemble(engine, boss, runtime);
      return;
    }
    final party = engine.units
        .where((u) => !u.isKo && u.team == CombatTeamV4.party)
        .toList(growable: false);
    if (party.isEmpty) {
      engine.finishActivation(baseDelay: 85);
      return;
    }
    final adjacent = party
        .where((u) => boss.anchor.distanceTo(u.anchor) <= 1)
        .toList(growable: false);
    final cageTarget = _cageTarget(party);
    final useCage = runtime.activationCount % 3 == 0 &&
        cageTarget != null &&
        !cageTarget.has(StatusTypeV4.rooted);
    if (runtime.fracturedCore && adjacent.isNotEmpty) {
      _telegraphBoneSweep(engine, boss, party, runtime);
      return;
    }
    if (useCage) {
      engine.applyEffect(
        casterId: boss.id,
        targetId: cageTarget.id,
        status: StatusTypeV4.rooted,
        defense: DefenseV4.fortitude,
        duration: 1,
        baseDelay: 120,
      );
      engine.log.add(CombatEventV4(
        time: engine.timeline.now,
        kind: 'bone_cage',
        actorId: boss.id,
        targetId: cageTarget.id,
      ));
      return;
    }
    if (adjacent.isNotEmpty) {
      _telegraphBoneSweep(engine, boss, party, runtime);
      return;
    }
    _boneThrow(engine, boss, party);
  }
  static void _updateFracturedCore(
    CombatEngineV4 engine,
    CombatUnitV4 boss,
    BoneHeapRuntimeV4 runtime,
  ) {
    if (runtime.fracturedCore) return;
    if (boss.hp > (boss.stats.maxHp * 0.30).round()) return;
    runtime.fracturedCore = true;
    boss.incomingAccuracyBonus = 1;
    engine.log.add(CombatEventV4(
      time: engine.timeline.now,
      kind: 'bone_heap_fractured_core',
      actorId: boss.id,
      message: 'incoming accuracy +1; Bone Sweep damage +15%',
    ));
  }
  static void _reassemble(
    CombatEngineV4 engine,
    CombatUnitV4 boss,
    BoneHeapRuntimeV4 runtime,
  ) {
    runtime.reassembled = true;
    final cap = (boss.stats.maxHp * 0.50).floor();
    final allowed = cap - boss.barrierTotal;
    final actual = allowed <= 0 ? 0 : (allowed < 25 ? allowed : 25);
    if (actual > 0) {
      boss.barriers.add(BarrierV4(
        amount: actual,
        remainingActivations: 2,
        sourceId: boss.id,
      ));
    }
    final spawn = _findSummonHex(engine, boss);
    if (spawn != null) {
      runtime.summons++;
      final add = VerticalSliceCatalogV4.enemy(
        'enemy_skeleton_apprentice',
        'bone_heap_add_${runtime.summons}',
        spawn,
      );
      add.nextActionTime = engine.timeline.now + 20;
      engine.units.add(add);
    }
    engine.log.add(CombatEventV4(
      time: engine.timeline.now,
      kind: 'bone_heap_reassemble',
      actorId: boss.id,
      value: actual,
      message: spawn == null
          ? 'Barrier $actual; no legal summon hex'
          : 'Barrier $actual; Skeleton summoned at $spawn',
    ));
    engine.finishActivation(baseDelay: 100);
    engine.timeline.push(boss, 20);
  }
  static void _boneThrow(
    CombatEngineV4 engine,
    CombatUnitV4 boss,
    List<CombatUnitV4> party,
  ) {
    final inRange = party
        .where((u) => boss.anchor.distanceTo(u.anchor) <= 5)
        .toList()
      ..sort((a, b) {
        final ra = a.hp / a.stats.maxHp;
        final rb = b.hp / b.stats.maxHp;
        final ratio = ra.compareTo(rb);
        if (ratio != 0) return ratio;
        final hp = a.hp.compareTo(b.hp);
        if (hp != 0) return hp;
        final da = boss.anchor.distanceTo(a.anchor);
        final db = boss.anchor.distanceTo(b.anchor);
        return da != db ? da.compareTo(db) : a.id.compareTo(b.id);
      });
    if (inRange.isEmpty) {
      engine.finishActivation(baseDelay: 90);
      return;
    }
    engine.basicAttack(
      attackerId: boss.id,
      targetId: inRange.first.id,
      skillAccuracy: -1, // +5 base -> documented +4
      range: 5,
      ranged: true,
      baseDelay: 90,
    );
    engine.log.add(CombatEventV4(
      time: engine.timeline.now,
      kind: 'bone_throw',
      actorId: boss.id,
      targetId: inRange.first.id,
    ));
  }
  static void _telegraphBoneSweep(
    CombatEngineV4 engine,
    CombatUnitV4 boss,
    List<CombatUnitV4> party,
    BoneHeapRuntimeV4 runtime,
  ) {
    final primary = party
        .where((u) => boss.anchor.distanceTo(u.anchor) <= 1)
        .toList()
      ..sort((a, b) {
        final hp = a.hp.compareTo(b.hp);
        if (hp != 0) return hp;
        return a.id.compareTo(b.id);
      });
    if (primary.isEmpty) {
      _boneThrow(engine, boss, party);
      return;
    }
    runtime.pendingSweepHexes = _cone3(
      engine: engine,
      boss: boss,
      primaryHex: primary.first.anchor,
    );
    engine.log.add(CombatEventV4(
      time: engine.timeline.now,
      kind: 'bone_sweep_telegraph',
      actorId: boss.id,
      message: runtime.pendingSweepHexes.join(','),
    ));
    engine.finishActivation(baseDelay: 55);
  }
  static void _resolveTelegraphedSweep(
    CombatEngineV4 engine,
    CombatUnitV4 boss,
    BoneHeapRuntimeV4 runtime,
  ) {
    final targets = engine.units
        .where((u) =>
            !u.isKo &&
            u.team == CombatTeamV4.party &&
            u.occupiedHexes.any(runtime.pendingSweepHexes.contains))
        .map((u) => u.id)
        .toList(growable: false);
    final multiplier = runtime.fracturedCore ? 1.15 : 1.0;
    runtime.pendingSweepHexes = {};
    engine.npcAttackGroup(
      attackerId: boss.id,
      targetIds: targets,
      skillPower: 3,
      baseDelay: 105,
      damageMultiplier: multiplier,
    );
    engine.log.add(CombatEventV4(
      time: engine.timeline.now,
      kind: 'bone_sweep_resolve',
      actorId: boss.id,
      message: 'targets=${targets.join(",")}',
    ));
  }
  static Set<HexCoord> _cone3({
    required CombatEngineV4 engine,
    required CombatUnitV4 boss,
    required HexCoord primaryHex,
  }) {
    final result = <HexCoord>{primaryHex};
    final sides = engine.board
        .neighbors(primaryHex)
        .where((c) => c.distanceTo(boss.anchor) <= 1)
        .toList()
      ..sort((a, b) {
        if (a.col != b.col) return a.col.compareTo(b.col);
        return a.row.compareTo(b.row);
      });
    for (final side in sides) {
      if (result.length >= 3) break;
      result.add(side);
    }
    return result;
  }
  static CombatUnitV4? _cageTarget(List<CombatUnitV4> party) {
    final candidates = party.where((u) => !u.has(StatusTypeV4.rooted)).toList()
      ..sort((a, b) {
        final wa = a.id == 'wizard' ? 0 : 1;
        final wb = b.id == 'wizard' ? 0 : 1;
        if (wa != wb) return wa.compareTo(wb);
        return a.id.compareTo(b.id);
      });
    return candidates.isEmpty ? null : candidates.first;
  }
  static HexCoord? _findSummonHex(
    CombatEngineV4 engine,
    CombatUnitV4 boss,
  ) {
    final candidates = <HexCoord>[
      for (var col = 0; col < engine.board.columns; col++)
        for (var row = 0; row < engine.board.rows; row++)
          HexCoord(col, row),
    ]..sort((a, b) {
        final da = a.distanceTo(boss.anchor);
        final db = b.distanceTo(boss.anchor);
        if (da != db) return da.compareTo(db);
        if (a.col != b.col) return a.col.compareTo(b.col);
        return a.row.compareTo(b.row);
      });
    for (final cell in candidates) {
      final distance = cell.distanceTo(boss.anchor);
      if (distance < 2 || distance > 3) continue;
      if (!engine.board.blocked(
        cell,
        units: engine.units,
      )) {
        return cell;
      }
    }
    return null;
  }
}
