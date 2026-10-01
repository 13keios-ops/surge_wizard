part of 'combat_engine_v4.dart';

extension CombatEngineV4MovementAuto on CombatEngineV4 {
  bool moveActiveTo(
    HexCoord destination, {
    bool forced = false,
    bool finishAfterMove = false,
    int baseDelay = 100,
  }) {
    final actor = activeUnit;
    if (actor == null || !activationOpen || actor.isKo) return false;

    if (!forced && movementUsedThisActivation) return false;
    if (!forced && actor.has(StatusTypeV4.rooted)) return false;
    if (!board.valid(destination)) return false;
    if (board.blocked(
      destination,
      units: units,
      ignoreUnitId: actor.id,
    )) {
      return false;
    }

    if (!forced) {
      final reachable = board.reachable(
        unit: actor,
        units: units,
      );
      if (!reachable.containsKey(destination)) return false;
      _resolveOpportunityOnLeave(actor, destination);
      if (actor.isKo) {
        _ko(actor);
        finishActivation(baseDelay: baseDelay);
        return true;
      }
    }

    actor.anchor = destination;
    if (!forced) movementUsedThisActivation = true;
    log.add(CombatEventV4(
      time: timeline.now,
      kind: forced ? 'forced_move' : 'move',
      actorId: actor.id,
      message: destination.toString(),
    ));

    if (finishAfterMove) {
      finishActivation(baseDelay: baseDelay);
    }
    return true;
  }

  void _resolveOpportunityOnLeave(
    CombatUnitV4 mover,
    HexCoord destination,
  ) {
    final reactors = units.where((enemy) {
      if (enemy.isKo || enemy.team == mover.team) return false;
      if (!enemy.reactionAvailable) return false;

      final wasAdjacent = board.adjacent(enemy.anchor, mover.anchor);
      final remainsAdjacent = board.adjacent(enemy.anchor, destination);
      return wasAdjacent && !remainsAdjacent;
    }).toList()
      ..sort((a, b) => b.stats.speed.compareTo(a.stats.speed));

    for (final enemy in reactors) {
      if (mover.isKo) break;
      enemy.reactionAvailable = false;
      _opportunityAttack(enemy, mover);
    }
  }

  void _opportunityAttack(
    CombatUnitV4 attacker,
    CombatUnitV4 target,
  ) {
    final dice = rng.roll3d6();
    final natural = dice.fold<int>(0, (a, b) => a + b);
    final total = natural + attacker.primaryModifier + attacker.mastery - 1;
    final hit =
        natural == 18 || (natural != 3 && total >= target.stats.evasion);

    var damage = 0;
    if (hit) {
      final raw = attacker.weaponPower +
          attacker.primaryModifier * 2 +
          attacker.secondaryModifier;
      damage = _mitigate(
        target,
        _rollDamage(raw, critical: false),
        DamageTypeV4.physical,
      );
      _dealFinalDamage(
        sourceId: attacker.id,
        target: target,
        amount: damage,
        kind: 'opportunity',
      );
    }

    log.add(CombatEventV4(
      time: timeline.now,
      kind: hit ? 'opportunity_hit' : 'opportunity_miss',
      actorId: attacker.id,
      targetId: target.id,
      value: damage,
      dice: dice,
    ));
  }



  void runAutoActivation() {
    final actor = activeUnit ?? beginNextActivation();
    if (actor == null || !activationOpen || actor.isKo) return;

    final intent = autoPlanner.choose(
      actor: actor,
      units: units,
      board: board,
    );

    switch (intent.kind) {
      case AutoIntentKindV4.attack:
        this.basicAttack(
          attackerId: actor.id,
          targetId: intent.targetId!,
          baseDelay: 100,
        );
        break;
      case AutoIntentKindV4.move:
        this.moveActiveTo(intent.destination!, baseDelay: 100);
        if (!activationOpen) break;
        final second = autoPlanner.choose(
          actor: actor,
          units: units,
          board: board,
        );
        if (second.kind == AutoIntentKindV4.attack &&
            second.targetId != null) {
          this.basicAttack(
            attackerId: actor.id,
            targetId: second.targetId!,
            baseDelay: 100,
          );
        } else {
          finishActivation(baseDelay: 100);
        }
        break;
      case AutoIntentKindV4.wait:
        finishActivation(baseDelay: 85);
        break;
    }
  }

}
