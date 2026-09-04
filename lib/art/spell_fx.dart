/// 마법 이펙트. 속성별로 모양이 다른 투사체가 마법사에서 적으로 날아가고,
/// 명중 순간 폭발과 파편이 터진다. 전부 코드로 그린다.
library;

import 'dart:math';

import 'package:flutter/material.dart';

/// 속성별 이펙트 모양
enum SpellFxShape { orb, shard, bolt, skull, leaf, star }

/// 속성 문자열 → 이펙트 모양·색
({SpellFxShape shape, Color core, Color glow}) fxStyleFor(String element) =>
    switch (element) {
      'fire' => (
          shape: SpellFxShape.orb,
          core: const Color(0xFFFFE08A),
          glow: const Color(0xFFF25C2A)
        ),
      'frost' => (
          shape: SpellFxShape.shard,
          core: const Color(0xFFEAFBFF),
          glow: const Color(0xFF49B8E8)
        ),
      'arcane' => (
          shape: SpellFxShape.star,
          core: const Color(0xFFF6E6FF),
          glow: const Color(0xFFA85CE8)
        ),
      'shadow' => (
          shape: SpellFxShape.skull,
          core: const Color(0xFFD9C8F0),
          glow: const Color(0xFF6B3FA0)
        ),
      'nature' => (
          shape: SpellFxShape.leaf,
          core: const Color(0xFFE6FFC9),
          glow: const Color(0xFF4FB53C)
        ),
      _ => (
          shape: SpellFxShape.bolt,
          core: const Color(0xFFFFF3C4),
          glow: const Color(0xFFF2C14E)
        ),
    };

/// 이펙트 1회분의 상태 (위젯이 t를 0→1로 굴려준다)
class SpellFxSpec {
  const SpellFxSpec({
    required this.from,
    required this.to,
    required this.shape,
    required this.core,
    required this.glow,
    this.power = 1.0,
  });

  /// 출발점·도착점 (위젯 좌표계, 0~1 비율)
  final Offset from;
  final Offset to;
  final SpellFxShape shape;
  final Color core;
  final Color glow;

  /// 위력 배수 — 클수록 크고 파편이 많다
  final double power;
}

/// 마법 이펙트를 그리는 페인터.
/// [t] 0~1: 0~0.25 차징, 0.25~0.62 비행, 0.62~1 명중 폭발.
class SpellFxPainter extends CustomPainter {
  SpellFxPainter(this.spec, this.t);

  final SpellFxSpec spec;
  final double t;

  static const _chargeEnd = 0.25;
  static const _travelEnd = 0.62;

  @override
  void paint(Canvas canvas, Size size) {
    final from = Offset(spec.from.dx * size.width, spec.from.dy * size.height);
    final to = Offset(spec.to.dx * size.width, spec.to.dy * size.height);
    final unit = size.shortestSide;

    if (t < _chargeEnd) {
      _drawCharge(canvas, from, unit, t / _chargeEnd);
    } else if (t < _travelEnd) {
      final p = (t - _chargeEnd) / (_travelEnd - _chargeEnd);
      _drawTravel(canvas, from, to, unit, p);
    } else {
      final p = (t - _travelEnd) / (1 - _travelEnd);
      _drawImpact(canvas, to, unit, p);
    }
  }

  /// 1) 차징 — 마법사 손끝에 빛이 모인다
  void _drawCharge(Canvas canvas, Offset at, double unit, double p) {
    final r = unit * 0.055 * spec.power * Curves.easeOutBack.transform(p);
    canvas.drawCircle(
      at,
      r * 2.6,
      Paint()..color = spec.glow.withValues(alpha: 0.22 * p),
    );
    canvas.drawCircle(at, r, Paint()..color = spec.core);
    // 빨려드는 빛줄기
    for (var i = 0; i < 6; i++) {
      final a = i * pi / 3 + p * 3;
      final d = unit * 0.11 * (1 - p);
      final from = at + Offset(cos(a), sin(a)) * (d + r * 1.6);
      final to = at + Offset(cos(a), sin(a)) * (r * 1.2);
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = spec.glow.withValues(alpha: 0.7 * (1 - p))
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  /// 2) 비행 — 꼬리를 끌며 날아간다
  void _drawTravel(
      Canvas canvas, Offset from, Offset to, double unit, double p) {
    final eased = Curves.easeInCubic.transform(p);
    final pos = Offset.lerp(from, to, eased)!;
    final r = unit * 0.055 * spec.power;

    // 꼬리 (지나온 자리에 잔상)
    for (var i = 1; i <= 7; i++) {
      final back = (eased - i * 0.035).clamp(0.0, 1.0);
      final tp = Offset.lerp(from, to, back)!;
      final fade = (1 - i / 7) * 0.55;
      canvas.drawCircle(
        tp,
        r * (1 - i * 0.09),
        Paint()..color = spec.glow.withValues(alpha: fade),
      );
    }
    // 겉광
    canvas.drawCircle(
        pos, r * 2.3, Paint()..color = spec.glow.withValues(alpha: 0.30));
    _drawShape(canvas, pos, r, p);
  }

  /// 속성별 투사체 모양
  void _drawShape(Canvas canvas, Offset at, double r, double p) {
    final core = Paint()..color = spec.core;
    final glow = Paint()..color = spec.glow;
    switch (spec.shape) {
      case SpellFxShape.orb:
        canvas.drawCircle(at, r * 1.25, glow);
        canvas.drawCircle(at, r * 0.72, core);
      case SpellFxShape.shard:
        // 마름모 결정
        canvas.save();
        canvas.translate(at.dx, at.dy);
        canvas.rotate(p * 6);
        final d = Path()
          ..moveTo(0, -r * 1.7)
          ..lineTo(r * 0.75, 0)
          ..lineTo(0, r * 1.7)
          ..lineTo(-r * 0.75, 0)
          ..close();
        canvas.drawPath(d, glow);
        canvas.scale(0.55);
        canvas.drawPath(d, core);
        canvas.restore();
      case SpellFxShape.star:
        _star(canvas, at, r * 1.8, glow, p * 4);
        _star(canvas, at, r * 1.0, core, p * 4);
      case SpellFxShape.skull:
        canvas.drawCircle(at, r * 1.2, glow);
        canvas.drawCircle(at + Offset(-r * 0.35, -r * 0.1), r * 0.28, core);
        canvas.drawCircle(at + Offset(r * 0.35, -r * 0.1), r * 0.28, core);
      case SpellFxShape.leaf:
        canvas.save();
        canvas.translate(at.dx, at.dy);
        canvas.rotate(p * 5);
        final leaf = Path()
          ..moveTo(0, -r * 1.6)
          ..quadraticBezierTo(r * 1.1, 0, 0, r * 1.6)
          ..quadraticBezierTo(-r * 1.1, 0, 0, -r * 1.6);
        canvas.drawPath(leaf, glow);
        canvas.restore();
      case SpellFxShape.bolt:
        canvas.drawCircle(at, r * 1.1, glow);
        canvas.drawRect(
          Rect.fromCenter(center: at, width: r * 0.6, height: r * 2.4),
          core,
        );
    }
  }

  /// 3) 명중 — 링 충격파 + 파편 + 섬광
  void _drawImpact(Canvas canvas, Offset at, double unit, double p) {
    final fade = (1 - p).clamp(0.0, 1.0);
    final base = unit * 0.09 * spec.power;

    // 팽창하는 링 2겹
    for (final ringOffset in [0.0, 0.22]) {
      final rp = (p - ringOffset).clamp(0.0, 1.0);
      if (rp <= 0) continue;
      final rr = base * (0.4 + Curves.easeOutCubic.transform(rp) * 3.4);
      canvas.drawCircle(
        at,
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = base * 0.42 * (1 - rp)
          ..color = spec.glow.withValues(alpha: 0.85 * (1 - rp)),
      );
    }
    // 중심 섬광
    canvas.drawCircle(
      at,
      base * 1.7 * fade,
      Paint()..color = spec.core.withValues(alpha: fade),
    );
    canvas.drawCircle(
      at,
      base * 3.0 * fade,
      Paint()..color = spec.glow.withValues(alpha: 0.35 * fade),
    );
    // 사방으로 튀는 파편
    final n = (10 * spec.power).round().clamp(8, 20);
    final rnd = Random(1234);
    for (var i = 0; i < n; i++) {
      final a = i * 2 * pi / n + rnd.nextDouble() * 0.4;
      final dist = base * (1.2 + rnd.nextDouble() * 3.2) *
          Curves.easeOutCubic.transform(p);
      final sp = at + Offset(cos(a), sin(a)) * dist;
      final s = base * 0.28 * fade;
      canvas.save();
      canvas.translate(sp.dx, sp.dy);
      canvas.rotate(a);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: s * 2.2, height: s),
        Paint()..color = spec.core.withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint, double rot) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = rot + i * pi / 4;
      final rad = i.isEven ? r : r * 0.42;
      final pt = c + Offset(cos(a), sin(a)) * rad;
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path..close(), paint);
  }

  @override
  bool shouldRepaint(covariant SpellFxPainter old) => old.t != t;
}
