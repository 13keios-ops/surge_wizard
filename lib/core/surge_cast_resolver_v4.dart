import 'dart:math' as math;

import 'combat_state_v4.dart';
import 'seeded_rng_v4.dart';
import 'spell_action_v4.dart';

class SurgeCastResolverV4 {
  const SurgeCastResolverV4();

  CastResolutionV4 resolve({
    required SpellActionV4 spell,
    required CombatUnitV4 caster,
    required SeededRngV4 rng,
    int difficultyModifier = 0,
    int conditionPenalty = 0,
    int equipCast = 0,
    int tempCast = 0,
  }) {
    final dice = rng.roll3d6();
    final natural = dice.fold<int>(0, (a, b) => a + b);

    final masteryBonus = caster.mastery.clamp(0, 4).toInt();
    var castBonus = caster.primaryModifier +
        masteryBonus +
        equipCast +
        tempCast;

    final disrupted = caster.status(StatusTypeV4.disrupted);
    if (disrupted != null) {
      castBonus -= disrupted.potency == 0 ? 2 : disrupted.potency;
    }

    final dc = 9 +
        spell.circle +
        difficultyModifier +
        conditionPenalty;

    final total = natural + castBonus;
    final margin = total - dc;

    CastOutcomeV4 outcome;
    if (natural == 3) {
      outcome = CastOutcomeV4.surge;
    } else if (natural == 18 && margin >= 0) {
      outcome = CastOutcomeV4.perfect;
    } else if (margin >= 0) {
      outcome = CastOutcomeV4.stable;
    } else if (margin >= -3) {
      outcome = CastOutcomeV4.unstable;
    } else {
      outcome = CastOutcomeV4.surge;
    }

    var manaCost = spell.manaCost;
    var delay = spell.baseDelay;
    var damageMultiplier = 1.0;
    var effectPenalty = 0;
    var refund = 0;
    String? surgeMessage;

    if (outcome == CastOutcomeV4.unstable) {
      switch (spell.unstablePenalty) {
        case UnstablePenaltyV4.none:
          break;
        case UnstablePenaltyV4.damage75:
          damageMultiplier = 0.75;
          break;
        case UnstablePenaltyV4.effectMinus25:
          effectPenalty = -2;
          break;
        case UnstablePenaltyV4.delayPlus20:
          delay = (delay * 1.20).round();
          break;
        case UnstablePenaltyV4.manaPlus20:
          manaCost = math.max(manaCost, (manaCost * 1.20).ceil());
          break;
        case UnstablePenaltyV4.backlash:
          surgeMessage = 'unstable_backlash';
          break;
      }
    }

    if (outcome == CastOutcomeV4.perfect) {
      refund = (manaCost * 0.20).ceil();
    }

    if (outcome == CastOutcomeV4.surge) {
      surgeMessage = spell.surgeEffect.name;
    }

    return CastResolutionV4(
      outcome: outcome,
      dice: dice,
      total: total,
      dc: dc,
      margin: margin,
      finalManaCost: manaCost,
      finalDelay: delay,
      damageMultiplier: damageMultiplier,
      effectAccuracyPenalty: effectPenalty,
      perfectManaRefund: refund,
      surgeMessage: surgeMessage,
    );
  }
}
