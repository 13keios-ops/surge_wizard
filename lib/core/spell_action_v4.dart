import 'combat_state_v4.dart';
import 'hex_coord_v4.dart';

enum TargetShapeV4 {
  single,
  line,
  burst7,
  cone,
  row,
  chain,
  all,
  self,
}

enum SpellCategoryV4 { attack, control, defense }

enum CastOutcomeV4 {
  stable,
  unstable,
  surge,
  perfect,
}

enum UnstablePenaltyV4 {
  none,
  damage75,
  effectMinus25,
  delayPlus20,
  manaPlus20,
  backlash,
}

enum SurgeEffectV4 {
  none,
  selfStagger20,
  selfDamage8Percent,
  centerShiftOne,
  extraHalfDamageJump,
  backlash10Percent,
}

class SpellActionV4 {
  const SpellActionV4({
    required this.id,
    required this.name,
    required this.circle,
    required this.category,
    required this.shape,
    required this.range,
    required this.baseDelay,
    required this.manaCost,
    this.basePower = 0,
    this.damageType = DamageTypeV4.arcane,
    this.effectDefense,
    this.status,
    this.statusDuration = 0,
    this.statusPotency = 0,
    this.effectAccuracy = 0,
    this.attackAccuracy = 0,
    this.maxTargets,
    this.unstablePenalty = UnstablePenaltyV4.damage75,
    this.surgeEffect = SurgeEffectV4.selfStagger20,
    this.friendlyFire = false,
    this.healing = false,
    this.barrier = 0,
    this.teleportDistance = 0,
    this.pushDistance = 0,
    this.pullDistance = 0,
  });

  final String id;
  final String name;
  final int circle;
  final SpellCategoryV4 category;
  final TargetShapeV4 shape;
  final int range;
  final int baseDelay;
  final int manaCost;

  final int basePower;
  final DamageTypeV4 damageType;

  final DefenseV4? effectDefense;
  final StatusTypeV4? status;
  final int statusDuration;
  final int statusPotency;
  final int effectAccuracy;
  final int attackAccuracy;

  final int? maxTargets;
  final UnstablePenaltyV4 unstablePenalty;
  final SurgeEffectV4 surgeEffect;

  final bool friendlyFire;
  final bool healing;
  final int barrier;
  final int teleportDistance;
  final int pushDistance;
  final int pullDistance;
}

class SpellCastPreviewV4 {
  const SpellCastPreviewV4({
    required this.spell,
    required this.casterId,
    required this.targetHex,
    required this.affectedHexes,
    required this.targetIds,
    required this.manaCost,
    required this.baseDelay,
    required this.stabilityDc,
  });

  final SpellActionV4 spell;
  final String casterId;
  final HexCoord targetHex;
  final Set<HexCoord> affectedHexes;
  final List<String> targetIds;
  final int manaCost;
  final int baseDelay;
  final int stabilityDc;
}

class CastResolutionV4 {
  const CastResolutionV4({
    required this.outcome,
    required this.dice,
    required this.total,
    required this.dc,
    required this.margin,
    required this.finalManaCost,
    required this.finalDelay,
    required this.damageMultiplier,
    required this.effectAccuracyPenalty,
    required this.perfectManaRefund,
    this.surgeMessage,
  });

  final CastOutcomeV4 outcome;
  final List<int> dice;
  final int total;
  final int dc;
  final int margin;

  final int finalManaCost;
  final int finalDelay;
  final double damageMultiplier;
  final int effectAccuracyPenalty;
  final int perfectManaRefund;
  final String? surgeMessage;
}

class SpellCastResultV4 {
  const SpellCastResultV4({
    required this.cast,
    required this.preview,
    required this.damageByTarget,
    required this.effectSuccessByTarget,
  });

  final CastResolutionV4 cast;
  final SpellCastPreviewV4 preview;
  final Map<String, int> damageByTarget;
  final Map<String, bool> effectSuccessByTarget;
}
