import 'dart:math';

import 'package:flutter/material.dart';

/// 주사위 1개. 탭하면 잠금 토글.
/// [rollId] 가 바뀌면 굴림 애니메이션이 재생된다: 눈이 빠르게 바뀌며 튀어올랐다가
/// 마지막 400ms 동안 ease-out으로 감속하며 멈춘다 (GAME_DESIGN 6절).
class DiceWidget extends StatefulWidget {
  const DiceWidget({
    super.key,
    required this.value,
    required this.locked,
    this.rollId = 0,
    this.size = 84,
    this.onTap,
  });

  final int value;
  final bool locked;

  /// 굴림 회차. 바뀔 때마다 (잠기지 않은 주사위만) 애니메이션 재생.
  final int rollId;

  final double size;
  final VoidCallback? onTap;

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 750);

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _duration)
        ..addListener(() => setState(() {}));
  final _random = Random();

  @override
  void didUpdateWidget(DiceWidget old) {
    super.didUpdateWidget(old);
    if (old.rollId != widget.rollId && !widget.locked) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _rolling => _controller.isAnimating;

  /// 애니메이션 중 표시할 눈: ease-out 진행도에 따라 점점 천천히 바뀐다
  int get _displayValue {
    if (!_rolling) return widget.value;
    final eased = Curves.easeOutCubic.transform(_controller.value);
    if (eased >= 0.94) return widget.value;
    final tick = (eased * 11).floor();
    return (tick * 7 + widget.rollId * 3 + _random.nextInt(1)) % 6 + 1;
  }

  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOutCubic.transform(_controller.value);
    // 굴리는 동안 튀어오르며 기울었다가 바로 선다
    final tilt = _rolling ? sin(eased * pi * 5) * (1 - eased) * 0.30 : 0.0;
    final hop = _rolling ? sin(eased * pi) * -widget.size * 0.22 : 0.0;
    final squash = _rolling ? 1 + sin(eased * pi * 2) * 0.06 : 1.0;
    return GestureDetector(
      onTap: _rolling ? null : widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size * 1.16, // 그림자 자리
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // 바닥 그림자 (튀어오르면 작아진다)
            Positioned(
              bottom: 0,
              child: Container(
                width: widget.size * (0.62 - (hop.abs() / widget.size) * 0.3),
                height: widget.size * 0.10,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                      alpha: 0.35 - (hop.abs() / widget.size) * 0.2),
                  borderRadius: BorderRadius.all(
                      Radius.elliptical(widget.size, widget.size * 0.1)),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, hop),
              child: Transform.rotate(
                angle: tilt,
                child: Transform.scale(
                  scaleY: squash,
                  child: CustomPaint(
                    size: Size.square(widget.size),
                    painter: _DicePainter(
                      value: _displayValue,
                      locked: widget.locked,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.locked)
              Positioned(
                top: 0,
                right: widget.size * 0.02,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2C14E),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                        color: const Color(0xFF7A5A10), width: 1.5),
                  ),
                  child: Text('잠금',
                      style: const TextStyle(
                          fontFamily: 'Galmuri9',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4A3200))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 입체감 있는 주사위를 그린다: 윗면이 밝고 아랫면이 어두운 베벨 +
/// 안쪽 그림자 + 도톰한 사각 눈.
class _DicePainter extends CustomPainter {
  _DicePainter({required this.value, required this.locked});

  final int value;
  final bool locked;

  /// 눈금별 점 위치 (0~1 비율 좌표)
  static const Map<int, List<Offset>> _pips = {
    1: [Offset(0.5, 0.5)],
    2: [Offset(0.29, 0.29), Offset(0.71, 0.71)],
    3: [Offset(0.26, 0.26), Offset(0.5, 0.5), Offset(0.74, 0.74)],
    4: [
      Offset(0.29, 0.29), Offset(0.71, 0.29),
      Offset(0.29, 0.71), Offset(0.71, 0.71),
    ],
    5: [
      Offset(0.26, 0.26), Offset(0.74, 0.26), Offset(0.5, 0.5),
      Offset(0.26, 0.74), Offset(0.74, 0.74),
    ],
    6: [
      Offset(0.29, 0.22), Offset(0.71, 0.22),
      Offset(0.29, 0.5), Offset(0.71, 0.5),
      Offset(0.29, 0.78), Offset(0.71, 0.78),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final r = Radius.circular(s * 0.14);
    final body = RRect.fromRectAndRadius(Offset.zero & size, r);
    final paint = Paint()..isAntiAlias = true;

    // 잠근 주사위는 금빛으로 물든다
    final faceTop = locked ? const Color(0xFFFFF3CE) : const Color(0xFFFBF7EC);
    final faceBot = locked ? const Color(0xFFE8C46A) : const Color(0xFFD6CDBA);
    final edge = locked ? const Color(0xFF8A6612) : const Color(0xFF2A2438);

    // 바깥 테두리
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(-s * 0.035, -s * 0.035, s * 1.07, s * 1.07),
          Radius.circular(s * 0.17)),
      Paint()..color = edge,
    );
    // 면 그라데이션 (위가 밝다)
    canvas.drawRRect(
      body,
      paint
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [faceTop, faceBot],
        ).createShader(Offset.zero & size),
    );
    paint.shader = null;

    // 윗면 하이라이트 띠
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(s * 0.09, s * 0.07, s * 0.82, s * 0.16),
        topLeft: Radius.circular(s * 0.08),
        topRight: Radius.circular(s * 0.08),
        bottomLeft: Radius.circular(s * 0.06),
        bottomRight: Radius.circular(s * 0.06),
      ),
      Paint()..color = Colors.white.withValues(alpha: locked ? 0.55 : 0.75),
    );
    // 아래쪽 안쪽 그림자
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(s * 0.06, s * 0.80, s * 0.88, s * 0.14),
        bottomLeft: Radius.circular(s * 0.10),
        bottomRight: Radius.circular(s * 0.10),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.10),
    );

    // 눈 — 도톰하게 (그림자 + 본체)
    final pipR = s * 0.085;
    for (final p in _pips[value] ?? const <Offset>[]) {
      final c = Offset(p.dx * s, p.dy * s);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: c + Offset(0, pipR * 0.28),
              width: pipR * 2,
              height: pipR * 2),
          Radius.circular(pipR * 0.35),
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.18),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c, width: pipR * 2, height: pipR * 2),
          Radius.circular(pipR * 0.35),
        ),
        Paint()
          ..color = locked
              ? const Color(0xFF6B4A08)
              : const Color(0xFF2E2745),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DicePainter old) =>
      old.value != value || old.locked != locked;
}
