part of 'combat_engine_v4.dart';

extension CombatEngineV4SpellCast on CombatEngineV4 {
  SpellCastResultV4 castSpellAction({
    required String casterId,
    required SpellActionV4 spell,
    required HexCoord targetHex,
    int difficultyModifier = 0,
    int conditionPenalty = 0,
  }) {
    final caster = unit(casterId);
    if (!_canAct(caster)) {
      throw StateError('${caster.id} is not the active actor');
    }
    if (!targetResolver.inRange(
      caster: caster,
      target: targetHex,
      spell: spell,
    )) {
      throw StateError('target out of range');
    }

    final cast = castResolver.resolve(
      spell: spell,
      caster: caster,
      rng: rng,
      difficultyModifier: difficultyModifier,
      conditionPenalty: conditionPenalty,
    );

    if (caster.mp < cast.finalManaCost) {
      throw StateError('not enough mana');
    }
    caster.mp -= cast.finalManaCost;

    var resolvedTarget = targetHex;
    if (cast.outcome == CastOutcomeV4.surge &&
        spell.surgeEffect == SurgeEffectV4.centerShiftOne) {
      final neighbors = board.neighbors(targetHex);
      if (neighbors.isNotEmpty) {
        resolvedTarget = neighbors[rng.nextInt(neighbors.length)];
      }
    }

    final affectedHexes = targetResolver.resolveHexes(
      spell: spell,
      caster: caster,
      target: resolvedTarget,
      board: board,
    );
    final targets = targetResolver.resolveUnits(
      spell: spell,
      caster: caster,
      target: resolvedTarget,
      board: board,
      units: units,
    );

    final preview = SpellCastPreviewV4(
      spell: spell,
      casterId: caster.id,
      targetHex: resolvedTarget,
      affectedHexes: affectedHexes,
      targetIds: targets.map((u) => u.id).toList(growable: false),
      manaCost: cast.finalManaCost,
      baseDelay: cast.finalDelay,
      stabilityDc: cast.dc,
    );

    final damageByTarget = <String, int>{};
    final effectByTarget = <String, bool>{};

    if (spell.category == SpellCategoryV4.defense) {
      final target = targets.isEmpty ? caster : targets.first;
      if (spell.barrier > 0) {
        final amount = cast.outcome == CastOutcomeV4.unstable
            ? (spell.barrier * 0.75).round()
            : spell.barrier;
        this._grantBarrierWithoutEnding(
          source: caster,
          target: target,
          amount: amount,
          duration: 2,
        );
      }
    } else {
      for (var i = 0; i < targets.length; i++) {
        final target = targets[i];

        var directHit = true;
        var directCritical = false;

        if (spell.basePower > 0) {
          final attackDice = rng.roll3d6();
          final natural =
              attackDice.fold<int>(0, (sum, value) => sum + value);
          final attackBonus = caster.primaryModifier +
              caster.equipmentAccuracy +
              spell.attackAccuracy +
              target.incomingAccuracyBonus;

          final directCover = (spell.shape == TargetShapeV4.single ||
                  spell.shape == TargetShapeV4.line) &&
              board.providesCover(target.anchor);

          final defense =
              target.stats.evasion + (directCover ? 2 : 0);
          final total = natural + attackBonus;

          directHit =
              natural == 18 || (natural != 3 && total >= defense);
          directCritical = directHit && natural == 18;

          log.add(CombatEventV4(
            time: timeline.now,
            kind: directHit ? 'spell_hit' : 'spell_miss',
            actorId: caster.id,
            targetId: target.id,
            dice: attackDice,
            message: '$total vs $defense',
          ));

          if (directHit) {
            final raw = spell.basePower +
                caster.primaryModifier * 2 +
                caster.secondaryModifier;

            var damage =
                _rollDamage(raw, critical: directCritical);
            damage = (damage * cast.damageMultiplier).round();

            if (spell.shape == TargetShapeV4.chain && i > 0) {
              final falloff = i == 1 ? 0.90 : 0.80;
              damage = (damage * falloff).round();
            }

            damage = _mitigate(target, damage, spell.damageType);
            _dealFinalDamage(
              sourceId: caster.id,
              target: target,
              amount: damage,
              kind: 'spell_${spell.id}',
            );
            damageByTarget[target.id] = damage;
          }
        }

        if (directHit &&
            !target.isKo &&
            spell.status != null &&
            spell.effectDefense != null) {
          final success = this._resolveSpellEffectOnly(
            caster: caster,
            target: target,
            spell: spell,
            cast: cast,
          );
          effectByTarget[target.id] = success;
        }
      }
    }

    this._applySurgeAfterCast(
      caster: caster,
      spell: spell,
      cast: cast,
      targetHex: resolvedTarget,
      targets: targets,
      damageByTarget: damageByTarget,
    );

    if (cast.perfectManaRefund > 0) {
      caster.mp = math.min(
        caster.stats.maxMp,
        caster.mp + cast.perfectManaRefund,
      );
    }

    log.add(CombatEventV4(
      time: timeline.now,
      kind: 'cast_${cast.outcome.name}',
      actorId: caster.id,
      value: cast.finalManaCost,
      dice: cast.dice,
      message:
          '${spell.id} ${cast.total} vs ${cast.dc} target=${resolvedTarget.toString()}',
    ));

    finishActivation(baseDelay: cast.finalDelay);

    return SpellCastResultV4(
      cast: cast,
      preview: preview,
      damageByTarget: damageByTarget,
      effectSuccessByTarget: effectByTarget,
    );
  }

}
