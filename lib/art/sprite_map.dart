import 'package:flutter/material.dart';

import '../models/relic.dart';
import '../models/spell.dart';
import 'pixel_sprite.dart';
import 'sprites_characters.dart';
import 'sprites_items.dart';
import 'sprites_monsters.dart';

/// 스프라이트 + 색조 묶음
class SpriteLook {
  const SpriteLook(this.sprite, this.tint);

  final PixelSprite sprite;
  final Color tint;
}

/// 속성별 대표 색
const Map<String, Color> kElementTints = {
  'fire': Color(0xFFE8632C),
  'frost': Color(0xFF4FB6E8),
  'arcane': Color(0xFFA678D9),
  'shadow': Color(0xFF7B6AA0),
  'nature': Color(0xFF5FBF52),
};

/// 적 id → (스프라이트, 색조).
/// 같은 골격을 색으로 변주해 30종을 표현한다.
final Map<String, SpriteLook> _enemyLooks = {
  // tier 1
  'green_slime': SpriteLook(kSpriteSlime, const Color(0xFF5FBF52)),
  'cave_rat': SpriteLook(kSpriteBeast, const Color(0xFF9C7A55)),
  'goblin_scout': SpriteLook(kSpriteGoblin, const Color(0xFF7CB84F)),
  'bat_swarm': SpriteLook(kSpriteBat, const Color(0xFF8B7BB5)),
  'mushroom_sprite': SpriteLook(kSpriteMushroom, const Color(0xFFD9556B)),
  'skeleton_apprentice':
      SpriteLook(kSpriteSkeleton, const Color(0xFFD8D2BC)),
  // tier 2
  'orc_warrior': SpriteLook(kSpriteBrute, const Color(0xFF6B9E4A)),
  'wolf_pack': SpriteLook(kSpriteBeast, const Color(0xFF97A0B5)),
  'hobgoblin': SpriteLook(kSpriteGoblin, const Color(0xFFC26340)),
  'cursed_armor': SpriteLook(kSpriteKnight, const Color(0xFF7A86A3)),
  'swamp_toad': SpriteLook(kSpriteBeast, const Color(0xFF87A83F)),
  // tier 3
  'stone_gargoyle': SpriteLook(kSpriteWinged, const Color(0xFF8A8FA0)),
  'fire_elemental': SpriteLook(kSpriteSlime, const Color(0xFFE8722C)),
  'dark_cultist': SpriteLook(kSpriteRobed, const Color(0xFF6B4A8A)),
  'troll_bruiser': SpriteLook(kSpriteBrute, const Color(0xFF4FA88F)),
  'ice_witch': SpriteLook(kSpriteRobed, const Color(0xFF5FC0E0)),
  // tier 4
  'ogre_champion': SpriteLook(kSpriteBrute, const Color(0xFFC79A6B)),
  'wraith': SpriteLook(kSpriteGhost, const Color(0xFF9FC4E8)),
  'lava_golem': SpriteLook(kSpriteGolem, const Color(0xFFD9542C)),
  'vampire_knight': SpriteLook(kSpriteKnight, const Color(0xFFB03848)),
  'storm_harpy': SpriteLook(kSpriteWinged, const Color(0xFFE0B84A)),
  // tier 5
  'bone_dragon_whelp': SpriteLook(kSpriteDragon, const Color(0xFFD8D2BC)),
  'demon_gatekeeper': SpriteLook(kSpriteDemon, const Color(0xFFC4433C)),
  'shadow_assassin': SpriteLook(kSpriteRobed, const Color(0xFF554E68)),
  'plague_shaman': SpriteLook(kSpriteRobed, const Color(0xFF8FA83C)),
  'crystal_colossus': SpriteLook(kSpriteGolem, const Color(0xFF5FC8D9)),
  // 보스
  'boss_archlich': SpriteLook(kSpriteRobed, const Color(0xFF9B5FD9)),
  'boss_inferno_dragon': SpriteLook(kSpriteDragon, const Color(0xFFE8722C)),
  'boss_void_titan': SpriteLook(kSpriteGolem, const Color(0xFF6B4A9E)),
  'boss_dice_devourer': SpriteLook(kSpriteDemon, const Color(0xFFE0B84A)),
};

/// 적의 겉모습. 목록에 없으면 무난한 기본값.
SpriteLook enemyLook(String enemyId) =>
    _enemyLooks[enemyId] ??
    SpriteLook(kSpriteGoblin, const Color(0xFF8A8FA0));

/// 주문의 겉모습. 효과가 있으면 효과를 우선하고, 없으면 속성으로 정한다.
SpriteLook spellLook(Spell spell) {
  final tint = kElementTints[spell.element] ?? const Color(0xFFA678D9);
  switch (spell.effect?.type) {
    case 'shield':
      return SpriteLook(kIconShield, tint);
    case 'heal':
      return SpriteLook(kIconHeart, tint);
    case 'extra_die':
      return SpriteLook(kIconDice, tint);
    case 'check_bonus':
      return SpriteLook(kIconStar, tint);
  }
  return SpriteLook(
    switch (spell.element) {
      'frost' => kIconShard,
      'nature' => kIconLeaf,
      'arcane' => kIconStar,
      'shadow' => kIconSkull,
      _ => kIconOrb,
    },
    tint,
  );
}

/// 유물의 겉모습. 효과 종류로 아이콘을 고른다.
SpriteLook relicLook(Relic relic) {
  const rarityTints = {
    'common': Color(0xFFB8B3C4),
    'rare': Color(0xFF5FA8E0),
    'epic': Color(0xFFB86FE0),
  };
  final tint = rarityTints[relic.rarity] ?? const Color(0xFFB8B3C4);
  return SpriteLook(
    switch (relic.effect.type) {
      'check_bonus' || 'check_bonus_full' => kIconRing,
      'extra_reroll' || 'free_rerolls' => kIconHourglass,
      'reroll_ones' || 'pair_bonus_up' => kIconDice,
      'charge_gain_up' => kIconBolt,
      'max_hp_up' => kIconHeart,
      'start_shield' => kIconShield,
      'heal_after_battle' || 'heal_on_crit' => kIconPotion,
      'damage_up' => kIconSword,
      'mana_on_surge' => kIconGem,
      _ => kIconCoin,
    },
    tint,
  );
}
