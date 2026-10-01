part of 'combat_engine_v4.dart';

extension CombatEngineV4SpellEffects on CombatEngineV4 {
  bool _resolveSpellEffectOnly({
    required CombatUnitV4 caster,
    required CombatUnitV4 target,
    required SpellActionV4 spell,
    required CastResolutionV4 cast,
  }) {
    final defenseType = spell.effectDefense;
    final status = spell.status;
    if (defenseType == null || status == null) return false;

    final dice = rng.roll3d6();
    final natural = dice.fold<int>(0, (a, b) => a + b);

    var bonus = caster.primaryModifier +
        caster.mastery +
        spell.effectAccuracy +
        cast.effectAccuracyPenalty;

    if (caster.has(StatusTypeV4.disrupted)) {
      final disrupted = caster.status(StatusTypeV4.disrupted)!;
      bonus -= disrupted.potency == 0 ? 2 : disrupted.potency;
    }
    if (target.has(StatusTypeV4.exposed)) bonus += 2;

    final defense = target.stats.defense(defenseType);
    final total = natural + bonus;
    final success =
        natural == 18 || (natural != 3 && total >= defense);

    if (success && !target.immunities.contains(status)) {
      final converted = bossConversionV4(target, status);
      if (converted == 'STAGGER_40') {
        timeline.push(target, 40);
      } else {
        var duration = spell.statusDuration;
        if (cast.outcome == CastOutcomeV4.unstable &&
            spell.unstablePenalty == UnstablePenaltyV4.effectMinus25) {
          duration = math.max(1, (duration * 0.75).round());
        }
        applyStatusV4(
          target: target,
          type: status,
          duration: duration,
          potency: spell.statusPotency,
          tickPower: _dotTickPowerFor(spell, caster),
          sourceId: caster.id,
        );
      }
    }

    log.add(CombatEventV4(
      time: timeline.now,
      kind: success ? 'spell_effect_success' : 'spell_effect_fail',
      actorId: caster.id,
      targetId: target.id,
      dice: dice,
      message: '${status.name}: $total vs $defense',
    ));

    return success;
  }

  int _dotTickPowerFor(
    SpellActionV4 spell,
    CombatUnitV4 caster,
  ) {
    if (spell.status == StatusTypeV4.burning) {
      return math.max(2, 2 + caster.mastery);
    }
    if (spell.status == StatusTypeV4.bleeding) {
      return math.max(2, 2 + caster.mastery);
    }
    if (spell.status == StatusTypeV4.poisoned) {
      return math.max(2, 2 + caster.mastery);
    }
    return 0;
  }

  void _grantBarrierWithoutEnding({
    required CombatUnitV4 source,
    required CombatUnitV4 target,
    required int amount,
    required int duration,
  }) {
    final maxBarrier = (target.stats.maxHp * 0.5).floor();
    final allowed = math.max(0, maxBarrier - target.barrierTotal);
    final actual = math.min(amount, allowed);

    if (actual > 0) {
      target.barriers.add(BarrierV4(
        amount: actual,
        remainingActivations: duration,
        sourceId: source.id,
      ));
    }

    log.add(CombatEventV4(
      time: timeline.now,
      kind: 'spell_barrier',
      actorId: source.id,
      targetId: target.id,
      value: actual,
    ));
  }

  void _applySurgeAfterCast({
    required CombatUnitV4 caster,
    required SpellActionV4 spell,
    required CastResolutionV4 cast,
    required HexCoord targetHex,
    required List<CombatUnitV4> targets,
    required Map<String, int> damageByTarget,
  }) {
    if (cast.outcome == CastOutcomeV4.unstable &&
        spell.unstablePenalty == UnstablePenaltyV4.backlash) {
      final damage = math.max(1, (caster.stats.maxHp * 0.05).round());
      _dealFinalDamage(
        sourceId: caster.id,
        target: caster,
        amount: damage,
        kind: 'unstable_backlash',
      );
    }

    if (cast.outcome != CastOutcomeV4.surge) return;

    switch (spell.surgeEffect) {
      case SurgeEffectV4.none:
        break;
      case SurgeEffectV4.selfStagger20:
        timeline.push(caster, 20);
        break;
      case SurgeEffectV4.selfDamage8Percent:
        _dealFinalDamage(
          sourceId: caster.id,
          target: caster,
          amount: math.max(1, (caster.stats.maxHp * 0.08).round()),
          kind: 'surge_backlash',
        );
        break;
      case SurgeEffectV4.centerShiftOne:
        // Center shift was already applied before target resolution.
        break;
      case SurgeEffectV4.extraHalfDamageJump:
        final available = units
            .where((u) => !u.isKo && u.team != caster.team)
            .where((u) => !damageByTarget.containsKey(u.id))
            .toList()
          ..sort((a, b) {
            final da = targetHex.distanceTo(a.anchor);
            final db = targetHex.distanceTo(b.anchor);
            if (da != db) return da.compareTo(db);
            return a.id.compareTo(b.id);
          });

        if (available.isNotEmpty && spell.basePower > 0) {
          final target = available.first;
          final raw = ((spell.basePower +
                      caster.primaryModifier * 2 +
                      caster.secondaryModifier) *
                  0.5)
              .round();
          final damage = _mitigate(
            target,
            _rollDamage(raw, critical: false),
            spell.damageType,
          );
          _dealFinalDamage(
            sourceId: caster.id,
            target: target,
            amount: damage,
            kind: 'surge_extra_jump',
          );
          damageByTarget[target.id] = damage;
        }
        break;
      case SurgeEffectV4.backlash10Percent:
        _dealFinalDamage(
          sourceId: caster.id,
          target: caster,
          amount: math.max(1, (caster.stats.maxHp * 0.10).round()),
          kind: 'surge_backlash',
        );
        break;
    }
  }

}
