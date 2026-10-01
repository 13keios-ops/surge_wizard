import 'combat_state_v4.dart';
import 'spell_action_v4.dart';

abstract final class SpellCatalogV4 {
  static const arcaneDart = SpellActionV4(
    id: 'base.spell.arcane_dart',
    name: '비전 화살',
    circle: 0,
    category: SpellCategoryV4.attack,
    shape: TargetShapeV4.single,
    range: 5,
    baseDelay: 85,
    manaCost: 0,
    basePower: 7,
    damageType: DamageTypeV4.arcane,
    unstablePenalty: UnstablePenaltyV4.damage75,
    surgeEffect: SurgeEffectV4.selfStagger20,
  );

  static const fireBolt = SpellActionV4(
    id: 'base.spell.fire_bolt',
    name: '화염탄',
    circle: 1,
    category: SpellCategoryV4.attack,
    shape: TargetShapeV4.single,
    range: 5,
    baseDelay: 100,
    manaCost: 6,
    basePower: 11,
    damageType: DamageTypeV4.fire,
    effectDefense: DefenseV4.fortitude,
    status: StatusTypeV4.burning,
    statusDuration: 2,
    statusPotency: 1,
    unstablePenalty: UnstablePenaltyV4.damage75,
    surgeEffect: SurgeEffectV4.selfStagger20,
  );

  static const arcaneBind = SpellActionV4(
    id: 'base.spell.arcane_bind',
    name: '비전 속박',
    circle: 1,
    category: SpellCategoryV4.control,
    shape: TargetShapeV4.single,
    range: 4,
    baseDelay: 110,
    manaCost: 6,
    effectDefense: DefenseV4.fortitude,
    status: StatusTypeV4.rooted,
    statusDuration: 1,
    effectAccuracy: 1,
    unstablePenalty: UnstablePenaltyV4.effectMinus25,
    surgeEffect: SurgeEffectV4.selfStagger20,
  );

  static const arcaneShield = SpellActionV4(
    id: 'base.spell.arcane_shield',
    name: '비전 방패',
    circle: 1,
    category: SpellCategoryV4.defense,
    shape: TargetShapeV4.self,
    range: 0,
    baseDelay: 95,
    manaCost: 6,
    barrier: 17,
    unstablePenalty: UnstablePenaltyV4.delayPlus20,
    surgeEffect: SurgeEffectV4.selfStagger20,
  );

  static const fireball = SpellActionV4(
    id: 'base.spell.fireball',
    name: '화염구',
    circle: 2,
    category: SpellCategoryV4.attack,
    shape: TargetShapeV4.burst7,
    range: 5,
    baseDelay: 130,
    manaCost: 13,
    basePower: 16,
    damageType: DamageTypeV4.fire,
    effectDefense: DefenseV4.fortitude,
    status: StatusTypeV4.burning,
    statusDuration: 2,
    statusPotency: 1,
    unstablePenalty: UnstablePenaltyV4.damage75,
    surgeEffect: SurgeEffectV4.centerShiftOne,
  );

  static const iceLance = SpellActionV4(
    id: 'base.spell.ice_lance',
    name: '빙창',
    circle: 2,
    category: SpellCategoryV4.attack,
    shape: TargetShapeV4.line,
    range: 5,
    baseDelay: 120,
    manaCost: 12,
    basePower: 14,
    damageType: DamageTypeV4.frost,
    effectDefense: DefenseV4.fortitude,
    status: StatusTypeV4.slowed,
    statusDuration: 1,
    statusPotency: 20,
    unstablePenalty: UnstablePenaltyV4.damage75,
    surgeEffect: SurgeEffectV4.selfStagger20,
  );

  static const chainSpark = SpellActionV4(
    id: 'base.spell.chain_spark',
    name: '연쇄 번개',
    circle: 2,
    category: SpellCategoryV4.attack,
    shape: TargetShapeV4.chain,
    range: 5,
    baseDelay: 120,
    manaCost: 12,
    basePower: 12,
    maxTargets: 3,
    damageType: DamageTypeV4.lightning,
    unstablePenalty: UnstablePenaltyV4.damage75,
    surgeEffect: SurgeEffectV4.extraHalfDamageJump,
  );

  static const List<SpellActionV4> previewSpells = [
    arcaneDart,
    fireBolt,
    arcaneBind,
    arcaneShield,
    fireball,
    iceLance,
    chainSpark,
  ];
}
