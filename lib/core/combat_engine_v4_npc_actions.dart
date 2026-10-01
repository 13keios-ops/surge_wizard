part of 'combat_engine_v4.dart';

extension CombatEngineV4NpcActions on CombatEngineV4 {
  Map<String, int> npcAttackGroup({
    required String attackerId,
    required Iterable<String> targetIds,
    int skillPower = 0,
    int skillAccuracy = 0,
    bool ranged = false,
    DamageTypeV4 damageType = DamageTypeV4.physical,
    double damageMultiplier = 1.0,
    int baseDelay = 100,
  }) {
    final attacker = unit(attackerId);
    if (!_canAct(attacker)) {
      throw StateError('${attacker.id} is not the active actor');
    }

    final result = <String, int>{};

    for (final id in targetIds) {
      final target = unit(id);
      if (target.isKo || target.team == attacker.team) continue;

      final dice = rng.roll3d6();
      final natural = dice.fold<int>(0, (a, b) => a + b);

      var attackBonus = attacker.primaryModifier +
          attacker.mastery +
          skillAccuracy +
          target.incomingAccuracyBonus;

      if (target.has(StatusTypeV4.exposed)) attackBonus += 2;

      final coverBonus =
          ranged && board.providesCover(target.anchor) ? 2 : 0;
      final defense = target.stats.evasion + coverBonus;
      final total = natural + attackBonus;
      final hit =
          natural == 18 || (natural != 3 && total >= defense);
      final critical = hit && natural == 18;

      var damage = 0;
      if (hit) {
        final raw = attacker.weaponPower +
            skillPower +
            attacker.primaryModifier * 2 +
            attacker.secondaryModifier;

        damage = _rollDamage(raw, critical: critical);
        damage = (damage * damageMultiplier).round();
        damage = _mitigate(target, damage, damageType);

        _dealFinalDamage(
          sourceId: attacker.id,
          target: target,
          amount: damage,
          kind: 'npc_group_attack',
        );
      }

      result[target.id] = damage;
      log.add(CombatEventV4(
        time: timeline.now,
        kind: hit ? 'npc_group_hit' : 'npc_group_miss',
        actorId: attacker.id,
        targetId: target.id,
        value: damage,
        dice: dice,
        message: '$total vs $defense',
      ));
    }

    finishActivation(baseDelay: baseDelay);
    return result;
  }
}
