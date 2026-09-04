import 'dart:math';

import 'package:flutter/material.dart';

/// 전투 무대 배경. 겹겹이 쌓인 원근 풍경을 코드로 그린다:
/// 하늘 그라데이션 → 달 → 먼 산맥 3겹 → 안개 → 기둥 → 바닥 통로 → 발밑 어둠.
/// 위(먼 곳)가 밝아 적의 실루엣이 또렷하게 뜬다.
class StageBackdrop extends StatelessWidget {
  const StageBackdrop({super.key, required this.palette, this.time = 0});

  final BackdropPalette palette;

  /// 0~1 반복되는 시간 값 (안개·별 흔들림 애니메이션용)
  final double time;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _BackdropPainter(palette, time));
}

/// 층(테마)별 배경 색 묶음
class BackdropPalette {
  const BackdropPalette({
    required this.skyTop,
    required this.skyBottom,
    required this.mountainFar,
    required this.mountainMid,
    required this.mountainNear,
    required this.fog,
    required this.floor,
    required this.floorEdge,
    required this.pillar,
    required this.moon,
  });

  final Color skyTop;
  final Color skyBottom;
  final Color mountainFar;
  final Color mountainMid;
  final Color mountainNear;
  final Color fog;
  final Color floor;
  final Color floorEdge;
  final Color pillar;
  final Color moon;

  /// 얼어붙은 탑 하층 — 푸른 달빛
  /// 먼 곳(하늘·산·안개)은 채도를 올려 밝게, 발밑(바닥·기둥)은 어둡게 눌렀다.
  static const frost = BackdropPalette(
    skyTop: Color(0xFF1E2E63),
    skyBottom: Color(0xFF7FA3E8),
    mountainFar: Color(0xFF5A79C4),
    mountainMid: Color(0xFF3E5699),
    mountainNear: Color(0xFF283A70),
    fog: Color(0xFFC2D6FF),
    floor: Color(0xFF3E4A7A),
    floorEdge: Color(0xFF6E80BC),
    pillar: Color(0xFF23305F),
    moon: Color(0xFFF2F6FF),
  );

  /// 탑 중층 — 자줏빛 황혼
  static const arcane = BackdropPalette(
    skyTop: Color(0xFF2B1657),
    skyBottom: Color(0xFF9B6BD4),
    mountainFar: Color(0xFF7A4FC0),
    mountainMid: Color(0xFF563596),
    mountainNear: Color(0xFF321C63),
    fog: Color(0xFFE0C4FF),
    floor: Color(0xFF443474),
    floorEdge: Color(0xFF7A5FB8),
    pillar: Color(0xFF2C1A5E),
    moon: Color(0xFFFFE9C2),
  );

  /// 탑 상층 — 불타는 하늘
  static const ember = BackdropPalette(
    skyTop: Color(0xFF43132A),
    skyBottom: Color(0xFFE8894F),
    mountainFar: Color(0xFFB55A45),
    mountainMid: Color(0xFF80392F),
    mountainNear: Color(0xFF491C26),
    fog: Color(0xFFFFD9A8),
    floor: Color(0xFF5E382E),
    floorEdge: Color(0xFFA36C4E),
    pillar: Color(0xFF4A2129),
    moon: Color(0xFFFFD08A),
  );

  /// 층 번호로 테마를 고른다
  static BackdropPalette forFloor(int floor) {
    if (floor <= 4) return frost;
    if (floor <= 8) return arcane;
    return ember;
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.p, this.time);

  final BackdropPalette p;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final paint = Paint()..isAntiAlias = false;

    // ── 하늘 ──
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.skyTop, p.skyBottom],
        ).createShader(Offset.zero & size),
    );

    // ── 별 ──
    final rnd = Random(7);
    paint.color = Colors.white.withValues(alpha: 0.55);
    for (var i = 0; i < 26; i++) {
      final sx = rnd.nextDouble() * w;
      final sy = rnd.nextDouble() * h * 0.32;
      final tw = 0.5 + 0.5 * sin((time * 2 * pi) + i);
      paint.color = Colors.white.withValues(alpha: 0.25 + 0.45 * tw);
      canvas.drawRect(Rect.fromLTWH(sx, sy, 2, 2), paint);
    }

    // ── 달 (가운데를 피해 한쪽으로 비켜 둔다) ──
    final moonC = Offset(w * 0.76, h * 0.11);
    final moonR = h * 0.055;
    paint.color = p.moon.withValues(alpha: 0.16);
    canvas.drawCircle(moonC, moonR * 1.9, paint); // 달무리
    paint.color = p.moon.withValues(alpha: 0.30);
    canvas.drawCircle(moonC, moonR * 1.35, paint);
    paint.color = p.moon;
    canvas.drawCircle(moonC, moonR, paint);
    // 달 표면 크레이터
    paint.color = p.moon.withValues(alpha: 0.45);
    for (final c in const [
      Offset(-0.30, -0.25),
      Offset(0.22, 0.10),
      Offset(-0.10, 0.34),
      Offset(0.36, -0.32),
    ]) {
      canvas.drawCircle(
        moonC + Offset(c.dx * moonR * 2, c.dy * moonR * 2),
        moonR * 0.20,
        Paint()..color = p.skyTop.withValues(alpha: 0.25),
      );
    }

    // ── 먼 산맥 3겹 ──
    _mountains(canvas, size, h * 0.32, h * 0.13, p.mountainFar, 5, 11);
    _mountains(canvas, size, h * 0.38, h * 0.11, p.mountainMid, 4, 23);
    _mountains(canvas, size, h * 0.44, h * 0.09, p.mountainNear, 6, 41);

    // ── 지평선 안개 ──
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.38, w, h * 0.22),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.fog.withValues(alpha: 0.0), p.fog.withValues(alpha: 0.75)],
        ).createShader(Rect.fromLTWH(0, h * 0.38, w, h * 0.22)),
    );

    // ── 바닥 통로 (사다리꼴 원근) ──
    final floorTop = h * 0.52;
    final path = Path()
      ..moveTo(w * 0.30, floorTop)
      ..lineTo(w * 0.70, floorTop)
      ..lineTo(w * 1.18, h)
      ..lineTo(w * -0.18, h)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.floorEdge, p.floor],
        ).createShader(Rect.fromLTWH(0, floorTop, w, h - floorTop)),
    );
    // 통로 가장자리 밝은 선
    final edge = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = p.floorEdge;
    canvas.drawLine(
        Offset(w * 0.30, floorTop), Offset(w * -0.18, h), edge);
    canvas.drawLine(
        Offset(w * 0.70, floorTop), Offset(w * 1.18, h), edge);

    // 바닥 가로 이음선 (원근으로 간격이 벌어진다)
    final line = Paint()
      ..isAntiAlias = false
      ..color = Colors.black.withValues(alpha: 0.12);
    for (var i = 1; i <= 5; i++) {
      final t = pow(i / 5.5, 1.9).toDouble();
      final y = floorTop + (h - floorTop) * t;
      final half = (0.20 + 0.68 * t) * w;
      canvas.drawRect(
          Rect.fromLTWH(w / 2 - half / 2, y, half, 2), line);
    }

    // ── 기둥 (원근으로 커진다) ──
    _pillar(canvas, size, 0.13, 0.30, 0.62);
    _pillar(canvas, size, 0.87, 0.30, 0.62);
    _pillar(canvas, size, 0.24, 0.36, 0.42);
    _pillar(canvas, size, 0.76, 0.36, 0.42);

    // ── 발밑 어둠 (아래로 갈수록 어둡게) ──
    // 마법 이펙트와 마법사가 여기서 빛나야 하므로 예전보다 깊게 깐다.
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.52, w, h * 0.48),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.58),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.52, w, h * 0.48)),
    );

    // ── 떠다니는 마법 입자 (천천히 위로 흐른다) ──
    final dust = Random(99);
    for (var i = 0; i < 16; i++) {
      final bx = dust.nextDouble() * w;
      final speed = 0.4 + dust.nextDouble() * 0.6;
      // 시간에 따라 위로 흐르고 화면을 벗어나면 아래에서 다시 나온다
      final by = h * (1.0 - ((time * speed + dust.nextDouble()) % 1.0)) * 0.9;
      final s = 1.5 + dust.nextDouble() * 2.0;
      final wob = sin(time * 2 * pi * speed + i) * 4;
      canvas.drawRect(
        Rect.fromLTWH(bx + wob, by, s, s),
        Paint()
          ..color = p.fog.withValues(alpha: 0.35 + 0.35 * dust.nextDouble()),
      );
    }

    // ── 화면 가장자리 어둠(비네트) ──
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.95,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.30),
          ],
          stops: const [0.55, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  /// 톱니 모양 산맥 한 겹
  void _mountains(Canvas canvas, Size size, double baseY, double height,
      Color color, int peaks, int seed) {
    final w = size.width;
    final rnd = Random(seed);
    final path = Path()..moveTo(-w * 0.1, baseY);
    final step = w * 1.2 / peaks;
    for (var i = 0; i <= peaks; i++) {
      final x = -w * 0.1 + step * i;
      final peak = baseY - height * (0.55 + rnd.nextDouble() * 0.75);
      path
        ..lineTo(x - step * 0.28, baseY - height * 0.1)
        ..lineTo(x, peak)
        ..lineTo(x + step * 0.28, baseY - height * 0.1);
    }
    path
      ..lineTo(w * 1.1, baseY)
      ..lineTo(w * 1.1, baseY + height)
      ..lineTo(-w * 0.1, baseY + height)
      ..close();
    canvas.drawPath(path, Paint()..color = color..isAntiAlias = false);
  }

  /// 통로 양옆 기둥 하나 (윗부분이 좁은 원근 사다리꼴)
  void _pillar(Canvas canvas, Size size, double cx, double top, double bottom) {
    final w = size.width, h = size.height;
    final x = w * cx;
    final wTop = w * 0.030 * (0.5 + bottom);
    final wBot = w * 0.055 * (0.5 + bottom);
    final yTop = h * top, yBot = h * bottom;
    final body = Path()
      ..moveTo(x - wTop, yTop)
      ..lineTo(x + wTop, yTop)
      ..lineTo(x + wBot, yBot)
      ..lineTo(x - wBot, yBot)
      ..close();
    canvas.drawPath(body, Paint()..color = p.pillar..isAntiAlias = false);
    // 기둥 왼쪽 밝은 면
    final lit = Path()
      ..moveTo(x - wTop, yTop)
      ..lineTo(x - wTop * 0.3, yTop)
      ..lineTo(x - wBot * 0.3, yBot)
      ..lineTo(x - wBot, yBot)
      ..close();
    canvas.drawPath(
      lit,
      Paint()
        ..isAntiAlias = false
        ..color = Color.lerp(p.pillar, Colors.white, 0.18)!,
    );
    // 기둥머리
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(x, yTop), width: wTop * 2.9, height: h * 0.018),
      Paint()
        ..isAntiAlias = false
        ..color = Color.lerp(p.pillar, Colors.white, 0.28)!,
    );
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter old) =>
      old.time != time || old.p != p;
}
