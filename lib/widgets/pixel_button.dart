/// 픽셀 게임풍 조작·강조 위젯 — 버튼·리본·뱃지.
/// (pixel_ui.dart 에서 갈라 냈다 — 내용은 그대로다)
library;

import 'package:flutter/material.dart';

import 'pixel_palette.dart';

/// 픽셀 게임풍 버튼. 아래쪽에 두꺼운 그림자를 깔아 눌리는 느낌을 준다.
class PixelButton extends StatefulWidget {
  const PixelButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = kGold,
    this.height = 46,
    this.fontSize = 20,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;

  /// 버튼 바탕색. 노랑(kGold)=주요 동작, 파랑(kManaBlue)=보조
  final Color color;
  final double height;
  final double fontSize;
  final Widget? icon;

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final base = enabled ? widget.color : kBgPanel;
    final dark = Color.lerp(base, Colors.black, 0.45)!;
    // 눌리면 버튼이 그림자 두께만큼 내려간다
    final drop = enabled && _down ? 4.0 : 0.0;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTap: widget.onPressed,
      child: SizedBox(
        height: widget.height + 4,
        child: Stack(
          children: [
            // 아래 그림자(버튼 두께)
            Positioned(
              left: 0,
              right: 0,
              top: 4,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: dark,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: drop,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: dark, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 7),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: pixelFontFor(widget.fontSize),
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: enabled
                              ? (widget.color == kGold
                                  ? const Color(0xFF4A3200)
                                  : Colors.white)
                              : kTextDim,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 양끝이 파인 리본 배너 (「보물 발견」, 「쓰러졌다」 같은 큰 알림용)
class RibbonBanner extends StatelessWidget {
  const RibbonBanner({
    super.key,
    required this.text,
    this.color = kManaBlue,
    this.fontSize = 24,
  });

  final String text;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _RibbonClipper(),
      child: Container(
        width: double.infinity,
        color: color,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 34),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: pixelFontFor(fontSize),
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: Colors.white,
            shadows: const [Shadow(color: Color(0x88000000), blurRadius: 3)],
          ),
        ),
      ),
    );
  }
}

/// 리본 양끝의 화살표 홈
class _RibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const notch = 18.0;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - notch, size.height / 2)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(notch, size.height / 2)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// 작은 라벨 뱃지 (「추천」, 「사용 중」 등)
class PixelBadge extends StatelessWidget {
  const PixelBadge({
    super.key,
    required this.text,
    this.color = kHpRed,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
            color: Color.lerp(color, Colors.black, 0.35)!, width: 1.5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: kFont9,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}
