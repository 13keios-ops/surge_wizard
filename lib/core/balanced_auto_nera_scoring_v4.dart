part of 'balanced_auto_v4.dart';

List<BalancedIntentV4> _neraCandidates(
  CombatEngineV4 engine,
  CombatUnitV4 actor,
  List<CombatUnitV4> enemies,
) {
  final out = <BalancedIntentV4>[];
  final hpRatio = actor.hp / actor.stats.maxHp;
  final adjacent = enemies
      .where((e) => actor.anchor.distanceTo(e.anchor) <= 1)
      .length;

  if (!actor.has(StatusTypeV4.guarded) &&
      hpRatio < 0.30 &&
      adjacent >= 1) {
    final safe = _safeDestination(engine, actor, enemies);
    if (safe != null) {
      out.add(BalancedIntentV4(
        kind: BalancedIntentKindV4.neraSmoke,
        score: 20 + (1 - hpRatio) * 35 + adjacent * 6,
        targetHex: safe,
      ));
    }
  }

  for (final target in enemies) {
    final distance = actor.anchor.distanceTo(target.anchor);
    if (distance <= 1) {
      final vital = _expectedBasicDamage(
        actor,
        target,
        skillPower: target.has(StatusTypeV4.exposed) ? 10 : 6,
      );
      out.add(BalancedIntentV4(
        kind: BalancedIntentKindV4.neraVital,
        score: _damageScore(vital, target.hp) - 3.3,
        targetId: target.id,
      ));
    }
    if (distance <= 3 &&
        target.stats.maxHp >= 50 &&
        !target.has(StatusTypeV4.exposed)) {
      final chance = _checkChance(
        actor.primaryModifier + actor.mastery + 1,
        target.stats.evasion,
      );
      const priority = 6;
      out.add(BalancedIntentV4(
        kind: BalancedIntentKindV4.neraExpose,
        score: chance * (18 + priority),
        targetId: target.id,
      ));
    }
  }
  return out;
}

HexCoord? _safeDestination(
  CombatEngineV4 engine,
  CombatUnitV4 actor,
  List<CombatUnitV4> enemies,
) {
  final reachable = engine.board.reachable(
    unit: actor,
    units: engine.units,
    budget: 3,
  );
  final candidates = reachable.keys.where((c) => c != actor.anchor).toList()
    ..sort((a, b) {
      int nearest(HexCoord c) => enemies
          .map((e) => c.distanceTo(e.anchor))
          .reduce((x, y) => x < y ? x : y);
      final da = nearest(a);
      final db = nearest(b);
      if (da != db) return db.compareTo(da);
      return (reachable[a] ?? 99).compareTo(reachable[b] ?? 99);
    });
  return candidates.isEmpty ? null : candidates.first;
}

double _expectedBasicDamage(
  CombatUnitV4 actor,
  CombatUnitV4 target, {
  required int skillPower,
  int accuracy = 0,
}) {
  final chance = _checkChance(
    actor.primaryModifier + actor.mastery + accuracy,
    target.stats.evasion,
  );
  final raw = actor.weaponPower +
      skillPower +
      actor.primaryModifier * 2 +
      actor.secondaryModifier;
  final afterArmor = (raw - target.stats.armor).clamp(1, 999).toDouble();
  return chance * afterArmor;
}

double _expectedSpellDamage({
  required CombatUnitV4 attacker,
  required CombatUnitV4 target,
  required int basePower,
  required DamageTypeV4 damageType,
  required bool cover,
}) {
  final defense = target.stats.evasion + (cover ? 2 : 0);
  final chance = _checkChance(
    attacker.primaryModifier + attacker.equipmentAccuracy,
    defense,
  );
  var raw = basePower + attacker.primaryModifier * 2 + attacker.secondaryModifier;
  raw -= damageType == DamageTypeV4.physical
      ? target.stats.armor
      : target.stats.magicResist;
  var damage = raw.clamp(1, 999).toDouble();
  if (target.weaknesses.contains(damageType)) damage *= 1.25;
  if (target.resistances.contains(damageType)) damage *= 0.75;
  return chance * damage;
}

double _damageScore(double expected, int hp) {
  final kill = expected >= hp ? 28.0 : 0.0;
  return expected + kill;
}

double _checkChance(int bonus, int defense) {
  var success = 0;
  for (var a = 1; a <= 6; a++) {
    for (var b = 1; b <= 6; b++) {
      for (var c = 1; c <= 6; c++) {
        final natural = a + b + c;
        if (natural == 18 ||
            (natural != 3 && natural + bonus >= defense)) {
          success++;
        }
      }
    }
  }
  return success / 216.0;
}

double _surgeChance(CombatUnitV4 caster, int circle) {
  var surge = 0;
  final dc = 9 + circle;
  final bonus = caster.primaryModifier + caster.mastery.clamp(0, 4).toInt();
  for (var a = 1; a <= 6; a++) {
    for (var b = 1; b <= 6; b++) {
      for (var c = 1; c <= 6; c++) {
        final natural = a + b + c;
        final margin = natural + bonus - dc;
        if (natural == 3 || margin <= -4) surge++;
      }
    }
  }
  return surge / 216.0;
}
