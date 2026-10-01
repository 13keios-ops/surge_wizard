part of 'balanced_auto_v4.dart';

List<BalancedIntentV4> _wizardCandidates(
  CombatEngineV4 engine,
  CombatUnitV4 actor,
  List<CombatUnitV4> enemies,
) {
  final out = <BalancedIntentV4>[];
  final hpRatio = actor.hp / actor.stats.maxHp;
  final adjacent = enemies
      .where((e) => actor.anchor.distanceTo(e.anchor) <= 1)
      .length;

  if (actor.barrierTotal < 8 && (hpRatio < 0.30 || adjacent >= 2)) {
    out.add(BalancedIntentV4(
      kind: BalancedIntentKindV4.wizardShield,
      score: 18 + (1 - hpRatio) * 32 + adjacent * 7 -
          _surgeChance(actor, 1) * 10,
      targetId: actor.id,
      targetHex: actor.anchor,
    ));
  }

  for (final target in enemies) {
    final distance = actor.anchor.distanceTo(target.anchor);
    if (distance <= SpellCatalogV4.fireBolt.range && actor.mp >= 6) {
      final expected = _expectedSpellDamage(
        attacker: actor,
        target: target,
        basePower: 11,
        damageType: DamageTypeV4.fire,
        cover: engine.board.providesCover(target.anchor),
      );
      out.add(BalancedIntentV4(
        kind: BalancedIntentKindV4.wizardFireBolt,
        score: _damageScore(expected, target.hp) - 7 -
            _surgeChance(actor, 1) * 12,
        targetId: target.id,
        targetHex: target.anchor,
      ));
    }

    if (distance <= SpellCatalogV4.arcaneDart.range) {
      final expected = _expectedSpellDamage(
        attacker: actor,
        target: target,
        basePower: 7,
        damageType: DamageTypeV4.arcane,
        cover: engine.board.providesCover(target.anchor),
      );
      out.add(BalancedIntentV4(
        kind: BalancedIntentKindV4.wizardDart,
        score: _damageScore(expected, target.hp) - 2.5 -
            _surgeChance(actor, 0) * 8,
        targetId: target.id,
        targetHex: target.anchor,
      ));
    }

    if (distance <= SpellCatalogV4.arcaneBind.range && actor.mp >= 6) {
      final chance = _checkChance(
        actor.primaryModifier + actor.mastery + 1,
        target.stats.fortitude,
      );
      final base = target.controlProfile == ControlProfileV4.boss
          ? 13.0
          : 21.0;
      out.add(BalancedIntentV4(
        kind: BalancedIntentKindV4.wizardBind,
        score: chance * base - 7 - _surgeChance(actor, 1) * 10,
        targetId: target.id,
        targetHex: target.anchor,
      ));
    }
  }

  if (actor.mp >= SpellCatalogV4.fireball.manaCost) {
    for (final center in enemies) {
      if (actor.anchor.distanceTo(center.anchor) > 5) continue;
      final hexes = const TargetResolverV4().resolveHexes(
        spell: SpellCatalogV4.fireball,
        caster: actor,
        target: center.anchor,
        board: engine.board,
      );
      final affected = enemies
          .where((e) => e.occupiedHexes.any(hexes.contains))
          .toList(growable: false);
      if (affected.length < 2) continue;

      var score = 0.0;
      for (final target in affected) {
        final expected = _expectedSpellDamage(
          attacker: actor,
          target: target,
          basePower: 16,
          damageType: DamageTypeV4.fire,
          cover: false,
        );
        score += _damageScore(expected, target.hp);
      }
      score += (affected.length - 1) * 6 - 15 -
          _surgeChance(actor, 2) * 18;
      out.add(BalancedIntentV4(
        kind: BalancedIntentKindV4.wizardFireball,
        score: score,
        targetId: center.id,
        targetHex: center.anchor,
      ));
    }
  }
  return out;
}

List<BalancedIntentV4> _kaelCandidates(
  CombatEngineV4 engine,
  CombatUnitV4 actor,
  List<CombatUnitV4> enemies,
) {
  final out = <BalancedIntentV4>[];
  final hpRatio = actor.hp / actor.stats.maxHp;
  final adjacent = enemies
      .where((e) => actor.anchor.distanceTo(e.anchor) <= 1)
      .toList(growable: false);

  if (!actor.has(StatusTypeV4.guarded) &&
      hpRatio < 0.35 &&
      adjacent.isNotEmpty) {
    out.add(BalancedIntentV4(
      kind: BalancedIntentKindV4.kaelGuard,
      score: 12 + (1 - hpRatio) * 30 + adjacent.length * 7,
      targetId: actor.id,
    ));
  }

  for (final target in enemies) {
    final distance = actor.anchor.distanceTo(target.anchor);
    if (distance <= 1) {
      final quick = _expectedBasicDamage(
        actor,
        target,
        skillPower: 0,
        accuracy: 1,
      );
      final heavy = _expectedBasicDamage(
        actor,
        target,
        skillPower: 5,
        accuracy: -1,
      );
      out.add(BalancedIntentV4(
        kind: BalancedIntentKindV4.kaelQuick,
        score: _damageScore(quick, target.hp) - 2.7,
        targetId: target.id,
      ));
      out.add(BalancedIntentV4(
        kind: BalancedIntentKindV4.kaelHeavy,
        score: _damageScore(heavy, target.hp) - 4,
        targetId: target.id,
      ));
    } else if (distance <= 3) {
      final cluster = enemies
          .where((e) => e.anchor.distanceTo(target.anchor) <= 2)
          .length;
      if (cluster >= 3) {
        final chance = _checkChance(
          actor.primaryModifier + actor.mastery,
          target.stats.brace,
        );
        out.add(BalancedIntentV4(
          kind: BalancedIntentKindV4.kaelPull,
          score: chance * (8 + cluster * 3),
          targetId: target.id,
        ));
      }
    }
  }
  return out;
}
