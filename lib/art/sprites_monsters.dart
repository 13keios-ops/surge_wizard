/// 캐릭터 스프라이트 2 (48×48). sprites_characters.dart 의 이어지는 부분.
library;

import 'dart:math';

import 'pixel_sprite.dart';
import 'sprite_builder.dart';

const _s = 48;

/// 갑옷 기사 — 투구 틈새, 어깨 갑주
final PixelSprite kSpriteKnight = () {
  final b = SpriteBuilder(_s, _s);
  b.trapezoid(24, 26, 11, 42, 14); // 몸통 갑옷
  b.ellipse(24, 16, 11, 11); // 투구
  b.ellipse(10, 27, 7, 6); // 어깨 갑주
  b.ellipse(38, 27, 7, 6);
  b.rect(17, 41, 22, 46);
  b.rect(26, 41, 31, 46);
  b.shade();
  b.outline();
  // 투구 틈새와 빛나는 눈
  b.paint(15, 15, 33, 18, 'k');
  b.ellipse(19, 16.5, 2.4, 1.4, ch: 'e');
  b.ellipse(29, 16.5, 2.4, 1.4, ch: 'e');
  // 투구 볏
  b.rect(23, 5, 25, 10, ch: 'r');
  b.ellipse(24, 5, 2.4, 2.4, ch: 'r');
  // 가슴 문양
  b.paint(22, 28, 26, 34, 'a');
  b.paint(23, 29, 25, 33, 'm');
  return b.build();
}();

/// 유령·원혼 — 아래가 흩어져 사라진다
final PixelSprite kSpriteGhost = () {
  final b = SpriteBuilder(_s, _s);
  b.ellipse(24, 22, 15, 15);
  b.rect(9, 22, 39, 36);
  // 아래 너덜너덜한 자락
  for (var i = 0; i < 5; i++) {
    final x = 11.0 + i * 6.5;
    b.polygon([
      Point(x - 3.2, 34.0),
      Point(x + 3.2, 34.0),
      Point(x, 42.0 - (i.isEven ? 0 : 4)),
    ]);
  }
  b.shade();
  b.outline();
  // 텅 빈 눈
  b.ellipse(18, 20, 4.0, 5.2, ch: 'k');
  b.ellipse(30, 20, 4.0, 5.2, ch: 'k');
  b.ellipse(18, 20, 1.8, 2.4, ch: 'e');
  b.ellipse(30, 20, 1.8, 2.4, ch: 'e');
  b.ellipse(24, 29, 3.0, 4.0, ch: 'k'); // 벌린 입
  return b.build();
}();

/// 골렘 — 각진 돌덩이 몸, 빛나는 눈
final PixelSprite kSpriteGolem = () {
  final b = SpriteBuilder(_s, _s);
  b.rect(11, 20, 37, 40); // 몸통
  b.rect(15, 8, 33, 21); // 머리
  b.rect(3, 22, 12, 36); // 팔
  b.rect(36, 22, 45, 36);
  b.rect(14, 40, 21, 46); // 다리
  b.rect(27, 40, 34, 46);
  b.shade();
  b.outline();
  b.paint(19, 13, 22, 15, 'e');
  b.paint(26, 13, 29, 15, 'e');
  // 몸통 균열
  b.paint(23, 22, 24, 38, '1');
  b.paint(16, 27, 23, 28, '1');
  b.paint(24, 32, 32, 33, '1');
  // 어깨 돌기
  b.ellipse(11, 21, 4, 3, ch: '5');
  b.ellipse(37, 21, 4, 3, ch: '2');
  return b.build();
}();

/// 용 — 뿔, 이빨, 펼친 날개
final PixelSprite kSpriteDragon = () {
  final b = SpriteBuilder(_s, _s);
  // 날개
  b.polygon([
    const Point(17.0, 20.0),
    const Point(1.0, 8.0),
    const Point(3.0, 24.0),
    const Point(12.0, 22.0),
    const Point(6.0, 33.0),
    const Point(18.0, 30.0),
  ]);
  b.polygon([
    const Point(31.0, 20.0),
    const Point(47.0, 8.0),
    const Point(45.0, 24.0),
    const Point(36.0, 22.0),
    const Point(42.0, 33.0),
    const Point(30.0, 30.0),
  ]);
  b.ellipse(24, 28, 10, 12); // 몸통
  b.ellipse(24, 15, 11, 9); // 머리
  // 뿔
  b.polygon([
    const Point(15.0, 10.0),
    const Point(9.0, 1.0),
    const Point(18.0, 7.0),
  ]);
  b.polygon([
    const Point(33.0, 10.0),
    const Point(39.0, 1.0),
    const Point(30.0, 7.0),
  ]);
  b.rect(20, 40, 24, 46);
  b.rect(25, 40, 29, 46);
  b.shade();
  b.outline();
  b.ellipse(19, 14, 2.6, 3.0, ch: 'e');
  b.ellipse(29, 14, 2.6, 3.0, ch: 'e');
  b.paint(18, 19, 30, 21, 'k'); // 입
  for (var i = 0; i < 5; i++) {
    b.paint(19 + i * 2.6, 19, 19 + i * 2.6, 20, 'w'); // 이빨
  }
  return b.build();
}();

/// 악마 — 큰 뿔과 붉은 눈
final PixelSprite kSpriteDemon = () {
  final b = SpriteBuilder(_s, _s);
  b.ellipse(24, 32, 15, 13); // 몸통
  b.ellipse(24, 17, 12, 10); // 머리
  // 큰 뿔
  b.polygon([
    const Point(14.0, 12.0),
    const Point(4.0, 0.0),
    const Point(6.0, 12.0),
    const Point(16.0, 17.0),
  ]);
  b.polygon([
    const Point(34.0, 12.0),
    const Point(44.0, 0.0),
    const Point(42.0, 12.0),
    const Point(32.0, 17.0),
  ]);
  b.ellipse(9, 32, 5, 7); // 팔
  b.ellipse(39, 32, 5, 7);
  b.rect(17, 42, 22, 46);
  b.rect(26, 42, 31, 46);
  b.shade();
  b.outline();
  b.ellipse(19, 16, 3.0, 2.6, ch: 'r');
  b.ellipse(29, 16, 3.0, 2.6, ch: 'r');
  b.paint(18, 15, 20, 15, 'k');
  b.paint(28, 15, 30, 15, 'k');
  b.paint(17, 22, 31, 24, 'k'); // 이빨 가득한 입
  for (var i = 0; i < 6; i++) {
    b.paint(18 + i * 2.4, 22, 18 + i * 2.4, 23, 'w');
  }
  return b.build();
}();

/// 로브를 쓴 자 — 마녀·신도·리치 공용. 후드 속 눈만 빛난다
final PixelSprite kSpriteRobed = () {
  final b = SpriteBuilder(_s, _s);
  b.trapezoid(24, 22, 12, 46, 17); // 로브 자락
  b.ellipse(24, 18, 13, 12); // 후드
  b.ellipse(9, 32, 5, 7); // 소매
  b.ellipse(39, 32, 5, 7);
  b.shade();
  b.outline();
  // 후드 속 그림자
  b.ellipse(24, 20, 8.5, 8, ch: 'k');
  b.ellipse(20, 19, 2.2, 2.6, ch: 'e');
  b.ellipse(28, 19, 2.2, 2.6, ch: 'e');
  // 로브 앞자락 주름
  b.paint(23, 30, 24, 45, '1');
  return b.build();
}();

/// 날개 달린 것 — 가고일·하피 공용
final PixelSprite kSpriteWinged = () {
  final b = SpriteBuilder(_s, _s);
  // 위로 솟은 날개
  b.polygon([
    const Point(18.0, 22.0),
    const Point(2.0, 4.0),
    const Point(1.0, 20.0),
    const Point(10.0, 22.0),
    const Point(4.0, 30.0),
    const Point(18.0, 30.0),
  ]);
  b.polygon([
    const Point(30.0, 22.0),
    const Point(46.0, 4.0),
    const Point(47.0, 20.0),
    const Point(38.0, 22.0),
    const Point(44.0, 30.0),
    const Point(30.0, 30.0),
  ]);
  b.ellipse(24, 28, 9, 11); // 몸통
  b.ellipse(24, 17, 9, 8); // 머리
  // 뿔
  b.polygon([
    const Point(17.0, 12.0),
    const Point(13.0, 4.0),
    const Point(21.0, 10.0),
  ]);
  b.polygon([
    const Point(31.0, 12.0),
    const Point(35.0, 4.0),
    const Point(27.0, 10.0),
  ]);
  b.rect(19, 39, 23, 46);
  b.rect(25, 39, 29, 46);
  b.shade();
  b.outline();
  b.ellipse(20, 16, 2.4, 2.8, ch: 'e');
  b.ellipse(28, 16, 2.4, 2.8, ch: 'e');
  b.paint(21, 21, 27, 22, 'k');
  return b.build();
}();
