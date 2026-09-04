/// 픽셀아트 스프라이트 검증: 모든 줄의 길이가 같고(도트를 잘못 세지 않았고),
/// 정해진 크기이며, 알 수 없는 색 글자가 없는지 확인한다.
/// 캐릭터는 sprite_builder.dart 가 도형에서 자동 생성한다.
library;

import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/art/pixel_sprite.dart';
import 'package:surge_wizard/art/sprites_characters.dart';
import 'package:surge_wizard/art/sprites_items.dart';
import 'package:surge_wizard/art/sprites_monsters.dart';

/// 캐릭터 스프라이트 (48×48)
final Map<String, PixelSprite> kCharacters = {
  'wizard': kSpriteWizard,
  'wizardBack': kSpriteWizardBack,
  'slime': kSpriteSlime,
  'beast': kSpriteBeast,
  'bat': kSpriteBat,
  'mushroom': kSpriteMushroom,
  'skeleton': kSpriteSkeleton,
  'goblin': kSpriteGoblin,
  'brute': kSpriteBrute,
  'knight': kSpriteKnight,
  'ghost': kSpriteGhost,
  'golem': kSpriteGolem,
  'dragon': kSpriteDragon,
  'demon': kSpriteDemon,
  'robed': kSpriteRobed,
  'winged': kSpriteWinged,
};

/// 아이템 스프라이트 (16×16)
const Map<String, PixelSprite> kItems = {
  'orb': kIconOrb,
  'shard': kIconShard,
  'shield': kIconShield,
  'heart': kIconHeart,
  'leaf': kIconLeaf,
  'star': kIconStar,
  'skull': kIconSkull,
  'bolt': kIconBolt,
  'dice': kIconDice,
  'coin': kIconCoin,
  'ring': kIconRing,
  'potion': kIconPotion,
  'book': kIconBook,
  'gem': kIconGem,
  'horseshoe': kIconHorseshoe,
  'hourglass': kIconHourglass,
  'sword': kIconSword,
};

void main() {
  /// 팔레트가 아는 글자 + 투명
  final known = buildPalette(const Color(0xFF888888)).keys.toSet()..add('.');

  void check(String name, PixelSprite s, int expected) {
    for (var y = 0; y < s.rows.length; y++) {
      expect(s.rows[y].length, expected,
          reason: '$name: $y번 줄이 ${s.rows[y].length}칸 (기대 $expected)');
    }
    expect(s.rows.length, expected, reason: '$name: 줄 수');
    expect(s.isUniform, isTrue, reason: name);
    for (final row in s.rows) {
      for (final ch in row.split('')) {
        expect(known.contains(ch), isTrue, reason: '$name: 모르는 글자 "$ch"');
      }
    }
  }

  group('캐릭터 스프라이트 (48×48)', () {
    kCharacters.forEach((name, sprite) {
      test(name, () => check(name, sprite, 48));
    });

    test('스프라이트가 비어 있지 않다 (도형이 실제로 그려졌다)', () {
      kCharacters.forEach((name, sprite) {
        final filled = sprite.rows
            .expand((r) => r.split(''))
            .where((c) => c != '.')
            .length;
        // 48×48 = 2304칸 중 최소 8%는 채워져야 형체가 보인다
        expect(filled, greaterThan(180), reason: '$name: 채워진 픽셀 $filled개');
      });
    });

    test('자동 명암이 여러 단계로 칠해졌다', () {
      // 명암 글자가 최소 3종류는 나와야 입체감이 있다
      for (final entry in kCharacters.entries) {
        final shades = entry.value.rows
            .expand((r) => r.split(''))
            .where((c) => '12345'.contains(c))
            .toSet();
        expect(shades.length, greaterThanOrEqualTo(3),
            reason: '${entry.key}: 명암 ${shades.length}단계뿐');
      }
    });
  });

  group('아이템 스프라이트 (16×16)', () {
    kItems.forEach((name, sprite) {
      test(name, () => check(name, sprite, 16));
    });
  });
}
