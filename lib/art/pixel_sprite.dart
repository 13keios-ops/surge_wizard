import 'package:flutter/material.dart';

/// 픽셀아트 스프라이트 1장.
///
/// [rows] 는 한 줄이 한 픽셀 행이고, 글자 하나가 픽셀 하나다.
///
/// **명암 글자 (색조 tint 에서 자동 생성)** — 빛은 항상 왼쪽 위에서 온다:
///   `0` 외곽선(색조를 머금은 아주 어두운 색)
///   `1` 가장 어두운 그늘   `2` 그늘   `3` 기본색
///   `4` 밝은 면            `5` 하이라이트   `6` 가장 밝은 테두리광
///
/// **고정 글자**:
///   `.` 투명   `k` 먹선   `w` 흰색   `d` 어두운 회색   `m` 금속   `a` 밝은 금속
///   `s` 살색   `t` 살색 그늘   `b` 뼈   `n` 나무   `u` 나무 그늘
///   `y` 금색   `x` 진한 금색   `o` 주황   `r` 빨강   `g` 초록
///   `c` 하늘/얼음   `p` 보라   `e` 빛나는 눈   `f` 눈동자 안쪽
class PixelSprite {
  const PixelSprite(this.rows);

  final List<String> rows;

  /// 가장 긴 줄을 기준 폭으로 삼는다 (짧은 줄은 그릴 때 투명으로 채운다).
  int get width => rows.fold(0, (w, r) => r.length > w ? r.length : w);

  int get height => rows.length;

  /// 모든 줄의 길이가 같은지. 어긋나면 도트를 잘못 센 것이다
  /// (test/sprite_test.dart 가 검사한다).
  bool get isUniform => rows.every((r) => r.length == width);
}

/// 색조에서 파생되는 7단계 명암 + 고정색 팔레트를 만든다.
Map<String, Color> buildPalette(Color tint) {
  final hsl = HSLColor.fromColor(tint);
  // 어두운 쪽은 채도를 살짝 올려 탁해지지 않게, 밝은 쪽은 채도를 낮춘다
  Color dark(double f, [double satBoost = 0.08]) => hsl
      .withLightness((hsl.lightness * f).clamp(0.0, 1.0))
      .withSaturation((hsl.saturation + satBoost).clamp(0.0, 1.0))
      .toColor();
  Color light(double amount) => Color.lerp(tint, Colors.white, amount)!;
  return {
    '0': dark(0.22, 0.12), // 외곽선 — 검정이 아니라 색조를 머금는다
    '1': dark(0.42),
    '2': dark(0.68),
    '3': tint,
    '4': light(0.22),
    '5': light(0.45),
    '6': light(0.70),
    'k': const Color(0xFF120E1A),
    'w': const Color(0xFFF7F4EC),
    'd': const Color(0xFF39344A),
    'm': const Color(0xFF8E97AD),
    'a': const Color(0xFFCBD3E4),
    's': const Color(0xFFF0C09A),
    't': const Color(0xFFC98F6A),
    'b': const Color(0xFFEDE7D4),
    'n': const Color(0xFF8A5E39),
    'u': const Color(0xFF5E3D24),
    'y': const Color(0xFFF7CE5B),
    'x': const Color(0xFFC28A22),
    'o': const Color(0xFFF08A3C),
    'r': const Color(0xFFE2495F),
    'g': const Color(0xFF6ECB5A),
    'c': const Color(0xFF7FD8F0),
    'p': const Color(0xFFB077E8),
    'e': const Color(0xFFFFE873),
    'f': const Color(0xFFE85A3C),
  };
}

/// 스프라이트를 화면에 그린다. 픽셀이 뭉개지지 않도록 안티앨리어싱을 끈다.
class PixelSpriteView extends StatelessWidget {
  const PixelSpriteView(
    this.sprite, {
    super.key,
    this.size = 64,
    this.tint = const Color(0xFF8A7FB5),
    this.flip = false,
    this.shadow = false,
    this.flashAmount = 0,
    this.halo,
    this.extraPalette,
  });

  final PixelSprite sprite;
  final double size;

  /// 스프라이트의 명암 글자에 적용할 기준 색
  final Color tint;

  /// 좌우 반전
  final bool flip;

  /// 발밑에 타원 그림자를 깐다 (땅에 서 있는 느낌)
  final bool shadow;

  /// 0~1. 1에 가까울수록 스프라이트가 하얗게 물든다 (피격 연출)
  final double flashAmount;

  /// 기본 팔레트(7단계 명암 + 고정색 18종)에 없는 색 글자를 추가로 정의한다.
  /// 손도트 스프라이트가 살색·수염 같은 부분에 더 많은 단계를 쓰고 싶을 때
  /// 쓴다. 기존 스프라이트는 이 글자들을 쓰지 않으므로 영향이 없다.
  final Map<String, Color>? extraPalette;

  /// 지정하면 실루엣 둘레에 이 색의 테를 한 겹 두른다.
  /// 배경이 복잡한 전투 무대에서 캐릭터가 묻히지 않게 하는 용도다
  /// (WORK_ORDER_GRAPHICS 1-0의 1·3번 문제).
  final Color? halo;

  @override
  Widget build(BuildContext context) {
    final h = size * sprite.height / sprite.width;
    Widget view = SizedBox(
      width: size,
      height: h,
      child: CustomPaint(
        painter: _SpritePainter(
          sprite,
          extraPalette == null
              ? buildPalette(tint)
              : {...buildPalette(tint), ...extraPalette!},
          flashAmount,
          halo,
        ),
      ),
    );
    if (flip) {
      view = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scaleByDouble(-1, 1, 1, 1),
        child: view,
      );
    }
    if (!shadow) return view;
    return SizedBox(
      width: size,
      height: h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 발밑 그림자 — 땅에 닿아 있다는 느낌을 준다
          Positioned(
            bottom: h * 0.03,
            child: Container(
              width: size * 0.58,
              height: h * 0.085,
              decoration: BoxDecoration(
                gradient: RadialGradient(colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.0),
                ]),
                borderRadius: BorderRadius.all(Radius.elliptical(size, h)),
              ),
            ),
          ),
          view,
        ],
      ),
    );
  }
}

class _SpritePainter extends CustomPainter {
  _SpritePainter(this.sprite, this.palette, this.flash, this.halo);

  final PixelSprite sprite;
  final Map<String, Color> palette;
  final double flash;
  final Color? halo;

  @override
  void paint(Canvas canvas, Size size) {
    if (sprite.width == 0) return;
    final px = size.width / sprite.width;
    final py = size.height / sprite.height;
    final paint = Paint()..isAntiAlias = false;

    // 테두리: 실루엣을 한 겹 키워 먼저 깔고 그 위에 본체를 그린다
    final halo = this.halo;
    if (halo != null) {
      final gx = px * 0.5, gy = py * 0.5;
      final haloPaint = Paint()
        ..isAntiAlias = false
        ..color = halo;
      for (var y = 0; y < sprite.rows.length; y++) {
        final row = sprite.rows[y];
        for (var x = 0; x < row.length; x++) {
          if (!palette.containsKey(row[x])) continue;
          canvas.drawRect(
            Rect.fromLTWH(x * px - gx, y * py - gy, px + gx * 2, py + gy * 2),
            haloPaint,
          );
        }
      }
    }
    for (var y = 0; y < sprite.rows.length; y++) {
      final row = sprite.rows[y];
      for (var x = 0; x < row.length; x++) {
        var color = palette[row[x]];
        if (color == null) continue; // '.' 등 투명
        if (flash > 0) color = Color.lerp(color, Colors.white, flash)!;
        paint.color = color;
        // 픽셀 사이 미세한 틈이 보이지 않도록 살짝 겹쳐 그린다
        canvas.drawRect(
          Rect.fromLTWH(x * px, y * py, px + 0.6, py + 0.6),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SpritePainter old) =>
      old.sprite != sprite ||
      old.palette != palette ||
      old.flash != flash ||
      old.halo != halo;
}
