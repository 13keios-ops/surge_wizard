part of 'combat_engine_v4.dart';

extension CombatEngineV4CompanionActions on CombatEngineV4 {
  AttackResultV4 kaelQuickSlash({
    required String targetId,
  }) =>
      this.basicAttack(
        attackerId: 'kael',
        targetId: targetId,
        accuracyBonus: 1,
        baseDelay: 90,
      );

  AttackResultV4 kaelHeavyStrike({
    required String targetId,
  }) =>
      this.basicAttack(
        attackerId: 'kael',
        targetId: targetId,
        skillPower: 5,
        skillAccuracy: -1,
        baseDelay: 130,
      );

  void kaelGuardStance() {
    final kael = unit('kael');
    if (!_canAct(kael)) {
      throw StateError('kael is not the active actor');
    }

    applyStatusV4(
      target: kael,
      type: StatusTypeV4.guarded,
      duration: 2,
      potency: 20,
      sourceId: kael.id,
    );

    log.add(CombatEventV4(
      time: timeline.now,
      kind: 'kael_guard_stance',
      actorId: kael.id,
      message: 'Guarded 20%',
    ));

    finishActivation(baseDelay: 95);
  }

  bool kaelHookPull({
    required String targetId,
  }) {
    final kael = unit('kael');
    final target = unit(targetId);

    if (!_canAct(kael)) {
      throw StateError('kael is not the active actor');
    }
    if (target.isKo || target.team == kael.team) {
      throw StateError('invalid pull target');
    }
    if (kael.anchor.distanceTo(target.anchor) > 3) {
      throw StateError('pull target out of range');
    }

    final dice = rng.roll3d6();
    final natural = dice.fold<int>(0, (a, b) => a + b);
    final total = natural + kael.primaryModifier + kael.mastery;
    final defense = target.stats.brace;
    final success =
        natural == 18 || (natural != 3 && total >= defense);

    if (success) {
      final candidates = board.neighbors(target.anchor)
          .where((c) => !board.blocked(
                c,
                units: units,
                ignoreUnitId: target.id,
              ))
          .toList()
        ..sort((a, b) {
          final da = a.distanceTo(kael.anchor);
          final db = b.distanceTo(kael.anchor);
          if (da != db) return da.compareTo(db);
          if (a.col != b.col) return a.col.compareTo(b.col);
          return a.row.compareTo(b.row);
        });

      if (candidates.isNotEmpty &&
          candidates.first.distanceTo(kael.anchor) <
              target.anchor.distanceTo(kael.anchor)) {
        target.anchor = candidates.first;
      }
    }

    log.add(CombatEventV4(
      time: timeline.now,
      kind: success ? 'kael_pull_success' : 'kael_pull_fail',
      actorId: kael.id,
      targetId: target.id,
      dice: dice,
      message: '$total vs $defense',
    ));

    finishActivation(baseDelay: 110);
    return success;
  }

  AttackResultV4 neraVitalStrike({
    required String targetId,
  }) {
    final target = unit(targetId);
    final bonusPower = target.has(StatusTypeV4.exposed) ? 10 : 6;
    return basicAttack(
      attackerId: 'nera',
      targetId: targetId,
      skillPower: bonusPower,
      baseDelay: 110,
    );
  }

  EffectResultV4 neraExposeWeakness({
    required String targetId,
  }) {
    final nera = unit('nera');
    final target = unit(targetId);
    if (nera.anchor.distanceTo(target.anchor) > 3) {
      throw StateError('expose target out of range');
    }
    return this.applyEffect(
      casterId: 'nera',
      targetId: targetId,
      status: StatusTypeV4.exposed,
      defense: DefenseV4.evasion,
      duration: 2,
      effectAccuracy: 1,
      baseDelay: 90,
    );
  }

  bool neraSmokeStep(HexCoord destination) {
    final nera = unit('nera');
    if (!_canAct(nera)) {
      throw StateError('nera is not the active actor');
    }
    if (nera.anchor.distanceTo(destination) > 3) {
      throw StateError('smoke step out of range');
    }

    final moved = this.moveActiveTo(
      destination,
      forced: true,
      finishAfterMove: false,
    );
    if (!moved) return false;

    applyStatusV4(
      target: nera,
      type: StatusTypeV4.guarded,
      duration: 2,
      potency: 15,
      sourceId: nera.id,
    );

    log.add(CombatEventV4(
      time: timeline.now,
      kind: 'nera_smoke_step',
      actorId: nera.id,
      message: destination.toString(),
    ));

    finishActivation(baseDelay: 85);
    return true;
  }
}
