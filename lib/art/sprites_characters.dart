/// 캐릭터 스프라이트 (48×48). 도형을 조합해 만들고 명암은 자동 계산된다
/// (sprite_builder.dart). 빛은 왼쪽 위에서 온다.
library;

import 'dart:math';

import 'pixel_sprite.dart';
import 'sprite_builder.dart';

const _s = 48; // 스프라이트 한 변

/// 마법사 뒷모습 — 큰 뾰족 모자, 흰 머리, 망토, 빛나는 지팡이
final PixelSprite kSpriteWizardBack = _buildWizard(back: true);

/// 마법사 앞모습 — 타이틀·결과 화면용
final PixelSprite kSpriteWizard = _buildWizard(back: false);

PixelSprite _buildWizard({required bool back}) {
  final b = SpriteBuilder(_s, _s);
  const cx = 23.0;

  // ── 몸통: 어깨를 모자챙보다 넓게 잡아야 실루엣이 삼각형으로 뭉치지 않는다
  b.ellipse(cx, 30, 14.0, 6.0); // 어깨
  b.trapezoid(cx, 30, 13.5, 46, 17); // 망토
  b.ellipse(35, 32, 4.2, 6.0); // 지팡이 잡은 팔
  b.ellipse(11, 32, 4.2, 6.0); // 반대쪽 팔
  b.shade();
  b.outline();

  // 망토 주름 — 명암 위에 어두운 선을 얹어 입체감을 준다
  for (final fx in [cx - 7.0, cx + 1.0, cx + 8.0]) {
    for (var y = 34; y <= 44; y++) {
      b.paint(fx, y, fx, y, '2');
    }
  }
  b.paint(cx - 13, 45, cx + 14, 45, '1'); // 밑단 그림자

  // ── 모자: 어깨보다 좁게 (따로 만들어 덮어야 명암이 섞이지 않는다) ──
  final hat = SpriteBuilder(_s, _s);
  hat.polygon([
    const Point(cx + 2, 1.0), // 끝이 살짝 오른쪽으로 휜다
    const Point(cx + 7, 19.0),
    const Point(cx - 7, 19.0),
  ]);
  hat.ellipse(cx, 20.5, 11, 2.8); // 챙
  hat.shade();
  hat.outline();
  _overlay(b, hat);
  // 모자 띠
  for (var x = (cx - 6).round(); x <= (cx + 6).round(); x++) {
    b.paint(x, 17, x, 18, '1');
  }

  if (back) {
    // 뒷모습: 챙 아래로 흰 머리카락이 살짝, 그 아래 옷깃
    b.ellipse(cx, 24.5, 7.5, 2.8, ch: 'w');
    b.paint(cx - 6, 23, cx - 1, 23, '6');
    b.ellipse(cx, 28, 8.5, 2.0, ch: '1'); // 옷깃 그늘
  } else {
    // 앞모습: 얼굴 + 눈 + 수염
    b.ellipse(cx, 25, 7.5, 4.2, ch: 's');
    b.paint(cx - 5, 24, cx - 3, 25, 'k');
    b.paint(cx + 3, 24, cx + 5, 25, 'k');
    b.paint(cx - 5, 24, cx - 4, 24, 'f');
    b.paint(cx + 4, 24, cx + 5, 24, 'f');
    b.ellipse(cx, 30, 7.0, 4.0, ch: 'w');
    b.paint(cx - 4, 28, cx + 4, 28, '6');
  }

  // ── 지팡이 ──
  b.rect(37, 18, 38, 46, ch: 'n');
  b.rect(37, 18, 37, 46, ch: 'u');
  // 손
  b.ellipse(36.5, 31, 2.4, 2.0, ch: 's');
  // 빛나는 보석
  b.ellipse(37.5, 15, 4.0, 4.0, ch: '0');
  b.ellipse(37.5, 15, 3.2, 3.2, ch: 'e');
  b.ellipse(36.6, 14.2, 1.4, 1.4, ch: 'w');
  return b.build();
}

/// 다른 스프라이트를 이 스프라이트 위에 덮어쓴다 (투명은 건너뛴다)
void _overlay(SpriteBuilder base, SpriteBuilder top) {
  final rows = top.build().rows;
  for (var y = 0; y < rows.length; y++) {
    for (var x = 0; x < rows[y].length; x++) {
      final ch = rows[y][x];
      if (ch != '.') base.paint(x, y, x, y, ch);
    }
  }
}

/// 슬라임 — 말랑한 반구, 큰 눈 두 개
final PixelSprite kSpriteSlime = () {
  final b = SpriteBuilder(_s, _s);
  b.ellipse(24, 32, 19, 14);
  b.ellipse(24, 26, 14, 11); // 위쪽 부풀림
  b.shade();
  b.outline();
  // 눈
  for (final ex in [17.0, 31.0]) {
    b.ellipse(ex, 28, 3.4, 4.2, ch: 'k');
    b.ellipse(ex - 0.8, 26.8, 1.4, 1.6, ch: 'w');
  }
  // 표면 반짝임
  b.paint(14, 21, 17, 22, '6');
  return b.build();
}();

/// 네발짐승 — 쥐·늑대·두꺼비 공용
final PixelSprite kSpriteBeast = () {
  final b = SpriteBuilder(_s, _s);
  b.ellipse(22, 30, 16, 9); // 몸통
  b.ellipse(34, 26, 8, 7); // 머리
  b.polygon([
    const Point(31.0, 20.0),
    const Point(34.0, 12.0),
    const Point(37.0, 20.0),
  ]); // 귀
  b.polygon([
    const Point(8.0, 28.0),
    const Point(2.0, 20.0),
    const Point(10.0, 26.0),
  ]); // 꼬리
  b.rect(14, 37, 17, 43); // 다리
  b.rect(26, 37, 29, 43);
  b.shade();
  b.outline();
  b.ellipse(37, 25, 2.2, 2.4, ch: 'e');
  b.ellipse(41, 27, 2.0, 1.6, ch: 's'); // 주둥이
  return b.build();
}();

/// 박쥐 — 펼친 날개
final PixelSprite kSpriteBat = () {
  final b = SpriteBuilder(_s, _s);
  b.ellipse(24, 26, 7, 8); // 몸통
  // 날개
  b.polygon([
    const Point(18.0, 20.0),
    const Point(1.0, 14.0),
    const Point(4.0, 26.0),
    const Point(14.0, 24.0),
    const Point(6.0, 32.0),
    const Point(18.0, 31.0),
  ]);
  b.polygon([
    const Point(30.0, 20.0),
    const Point(47.0, 14.0),
    const Point(44.0, 26.0),
    const Point(34.0, 24.0),
    const Point(42.0, 32.0),
    const Point(30.0, 31.0),
  ]);
  // 귀
  b.polygon([
    const Point(19.0, 19.0),
    const Point(20.0, 12.0),
    const Point(23.0, 18.0),
  ]);
  b.polygon([
    const Point(29.0, 19.0),
    const Point(28.0, 12.0),
    const Point(25.0, 18.0),
  ]);
  b.shade();
  b.outline();
  b.ellipse(21, 25, 1.8, 2.0, ch: 'e');
  b.ellipse(27, 25, 1.8, 2.0, ch: 'e');
  return b.build();
}();

/// 버섯 정령 — 반점 있는 갓 + 얼굴 있는 기둥
final PixelSprite kSpriteMushroom = () {
  final b = SpriteBuilder(_s, _s);
  b.rect(18, 26, 30, 43, ch: SpriteBuilder.body); // 기둥
  b.ellipse(24, 43, 7, 3);
  b.ellipse(24, 20, 20, 11); // 갓
  b.shade();
  b.outline();
  // 갓 반점
  for (final s in const [
    [12.0, 17.0, 3.4],
    [30.0, 14.0, 4.0],
    [36.0, 21.0, 2.8],
    [20.0, 24.0, 2.4],
  ]) {
    b.ellipse(s[0], s[1], s[2], s[2] * 0.75, ch: 'w');
  }
  // 얼굴
  b.ellipse(21, 33, 1.8, 2.4, ch: 'k');
  b.ellipse(27, 33, 1.8, 2.4, ch: 'k');
  b.paint(22, 37, 26, 38, 'k');
  return b.build();
}();

/// 해골 — 빈 눈구멍, 갈비뼈
final PixelSprite kSpriteSkeleton = () {
  final b = SpriteBuilder(_s, _s);
  b.ellipse(24, 15, 11, 10); // 두개골
  b.rect(22, 24, 26, 27); // 목
  b.ellipse(24, 32, 11, 7); // 갈비
  b.rect(18, 38, 21, 46); // 다리
  b.rect(27, 38, 30, 46);
  b.rect(9, 28, 13, 31); // 팔
  b.rect(35, 28, 39, 31);
  b.shade();
  b.outline();
  // 눈구멍·코·이빨
  b.ellipse(20, 14, 3.4, 4.0, ch: 'k');
  b.ellipse(28, 14, 3.4, 4.0, ch: 'k');
  b.ellipse(24, 19, 1.4, 1.8, ch: 'k');
  for (var i = 0; i < 5; i++) {
    b.paint(19 + i * 2.5, 22, 19 + i * 2.5, 23, 'k');
  }
  // 갈비뼈 줄
  for (var i = 0; i < 3; i++) {
    b.paint(16, 29 + i * 3, 32, 29 + i * 3, 'k');
  }
  return b.build();
}();

/// 고블린 — 뾰족 귀, 작은 몸집
final PixelSprite kSpriteGoblin = () {
  final b = SpriteBuilder(_s, _s);
  b.ellipse(24, 30, 12, 11); // 몸
  b.ellipse(24, 17, 11, 9); // 머리
  b.polygon([
    const Point(14.0, 15.0),
    const Point(3.0, 9.0),
    const Point(13.0, 21.0),
  ]); // 귀
  b.polygon([
    const Point(34.0, 15.0),
    const Point(45.0, 9.0),
    const Point(35.0, 21.0),
  ]);
  b.rect(17, 40, 21, 45); // 다리
  b.rect(27, 40, 31, 45);
  b.shade();
  b.outline();
  b.ellipse(20, 16, 2.6, 3.0, ch: 'e');
  b.ellipse(28, 16, 2.6, 3.0, ch: 'e');
  b.paint(20, 15, 21, 15, 'k');
  b.paint(27, 15, 28, 15, 'k');
  b.paint(20, 21, 28, 22, 'k'); // 입
  b.paint(21, 20, 22, 21, 'w'); // 이빨
  b.paint(26, 20, 27, 21, 'w');
  return b.build();
}();

/// 거구 — 오크·트롤·오우거 공용. 어금니와 넓은 어깨
final PixelSprite kSpriteBrute = () {
  final b = SpriteBuilder(_s, _s);
  b.ellipse(24, 33, 17, 12); // 몸통
  b.ellipse(24, 16, 13, 11); // 머리
  b.ellipse(10, 30, 6, 8); // 팔
  b.ellipse(38, 30, 6, 8);
  b.rect(16, 42, 21, 46); // 다리
  b.rect(27, 42, 32, 46);
  b.shade();
  b.outline();
  b.ellipse(19, 15, 3.0, 2.4, ch: 'e');
  b.ellipse(29, 15, 3.0, 2.4, ch: 'e');
  b.paint(18, 14, 20, 14, 'k');
  b.paint(28, 14, 30, 14, 'k');
  b.paint(18, 21, 30, 22, 'k'); // 입
  b.paint(19, 19, 21, 22, 'w'); // 어금니
  b.paint(27, 19, 29, 22, 'w');
  return b.build();
}();
