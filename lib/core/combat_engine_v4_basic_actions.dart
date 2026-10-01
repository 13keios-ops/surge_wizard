part of 'combat_engine_v4.dart';

extension CombatEngineV4BasicActions on CombatEngineV4 {
  AttackResultV4 basicAttack({
    required String attackerId,
    required String targetId,
    int baseDelay = 100,
    int accuracyBonus = 0,
    int skillPower = 0,
    int skillAccuracy = 0,
    int range = 1,
    bool ranged = false,
    DamageTypeV4 damageType = DamageTypeV4.physical,
  }) {
    final attacker = unit(attackerId);
    final target = unit(targetId);

    if (!_canAct(attacker)) {
      throw StateError('${attacker.id} is not the active actor');
    }
    if (target.isKo || target.team == attacker.team) {
      throw StateError('invalid target');
    }
    if (attacker.anchor.distanceTo(target.anchor) > range) {
      throw StateError('target out of range');
    }

    final dice = rng.roll3d6();
    final natural = dice.fold<int>(0, (a, b) => a + b);
    var attackBonus = attacker.primaryModifier +
        attacker.mastery +
        skillAccuracy +
        accuracyBonus;

    if (target.has(StatusTypeV4.exposed)) attackBonus += 2;

    final coverBonus =
        ranged && board.providesCover(target.anchor) ? 2 : 0;
    final defense = target.stats.evasion + coverBonus;
    attackBonus += target.incomingAccuracyBonus;
    final total = natural + attackBonus;
    final hit = natural == 18 || (natural != 3 && total >= defense);
    final critical = hit && natural == 18;

    var damage = 0;
    if (hit) {
      final raw = attacker.weaponPower +
          skillPower +
          attacker.primaryModifier * 2 +
          attacker.secondaryModifier;

      damage = _rollDamage(raw, critical: critical);
      damage = _mitigate(target, damage, damageType);

      if (attacker.has(StatusTypeV4.weakened)) {
        final weakened = attacker.status(StatusTypeV4.weakened)!;
        final ratio = weakened.potency == 0 ? 0.20 : weakened.potency / 100;
        damage = math.max(1, (damage * (1 - ratio)).round());
      }

      _dealFinalDamage(
        sourceId: attacker.id,
        target: target,
        amount: damage,
        kind: 'attack',
      );
    }

    log.add(CombatEventV4(
      time: timeline.now,
      kind: hit ? (critical ? 'critical' : 'hit') : 'miss',
      actorId: attacker.id,
      targetId: target.id,
      value: damage,
      dice: dice,
      message: '$total vs $defense',
    ));

    finishActivation(baseDelay: baseDelay);

    return AttackResultV4(
      hit: hit,
      critical: critical,
      damage: damage,
      dice: dice,
      total: total,
      targetDefense: defense,
    );
  }

  EffectResultV4 applyEffect({
    required String casterId,
    required String targetId,
    required StatusTypeV4 status,
    required DefenseV4 defense,
    required int duration,
    int potency = 0,
    int tickPower = 0,
    int effectAccuracy = 0,
    int baseDelay = 100,
  }) {
    final caster = unit(casterId);
    final target = unit(targetId);

    if (!_canAct(caster)) {
      throw StateError('${caster.id} is not the active actor');
    }

    final dice = rng.roll3d6();
    final natural = dice.fold<int>(0, (a, b) => a + b);
    var bonus =
        caster.primaryModifier + caster.mastery + effectAccuracy;

    if (caster.has(StatusTypeV4.disrupted)) {
      bonus -= caster.status(StatusTypeV4.disrupted)!.potency == 0
          ? 2
          : caster.status(StatusTypeV4.disrupted)!.potency;
    }
    if (target.has(StatusTypeV4.exposed)) bonus += 2;

    final targetDefense = target.stats.defense(defense);
    final total = natural + bonus;
    final success =
        natural == 18 || (natural != 3 && total >= targetDefense);

    String? converted;
    if (success && !target.immunities.contains(status)) {
      converted = bossConversionV4(target, status);
      if (converted == 'STAGGER_40') {
        timeline.push(target, 40);
      } else {
        applyStatusV4(
          target: target,
          type: status,
          duration: duration,
          potency: potency,
          tickPower: tickPower,
          sourceId: caster.id,
        );
      }
    }

    log.add(CombatEventV4(
      time: timeline.now,
      kind: success ? 'effect_success' : 'effect_fail',
      actorId: caster.id,
      targetId: target.id,
      dice: dice,
      message: converted ?? '${status.name}: $total vs $targetDefense',
    ));

    finishActivation(baseDelay: baseDelay);

    return EffectResultV4(
      success: success,
      dice: dice,
      total: total,
      targetDefense: targetDefense,
      convertedTo: converted,
    );
  }

  void grantBarrier({
    required String casterId,
    required String targetId,
    required int amount,
    int duration = 2,
    int baseDelay = 95,
  }) {
    final caster = unit(casterId);
    final target = unit(targetId);

    if (!_canAct(caster)) {
      throw StateError('${caster.id} is not the active actor');
    }

    final maxBarrier = (target.stats.maxHp * 0.5).floor();
    final allowed = math.max(0, maxBarrier - target.barrierTotal);
    final actual = math.min(amount, allowed);

    if (actual > 0) {
      target.barriers.add(BarrierV4(
        amount: actual,
        remainingActivations: duration,
        sourceId: caster.id,
      ));
    }

    log.add(CombatEventV4(
      time: timeline.now,
      kind: 'barrier',
      actorId: caster.id,
      targetId: target.id,
      value: actual,
    ));

    finishActivation(baseDelay: baseDelay);
  }

  void usePotion({
    required String actorId,
    required int flatHeal,
    double maxHpRatio = 0,
    int baseDelay = 90,
  }) {
    final actor = unit(actorId);
    if (!_canAct(actor)) {
      throw StateError('${actor.id} is not the active actor');
    }

    final poisonPenalty = poisonHealingPenaltyPercentV4(actor);
    final raw = flatHeal + (actor.stats.maxHp * maxHpRatio).round();
    final adjusted = (raw * (1 - poisonPenalty / 100)).round();
    final before = actor.hp;
    actor.hp = math.min(actor.stats.maxHp, actor.hp + adjusted);

    log.add(CombatEventV4(
      time: timeline.now,
      kind: 'heal',
      actorId: actor.id,
      targetId: actor.id,
      value: actor.hp - before,
    ));

    finishActivation(baseDelay: baseDelay);
  }

}
