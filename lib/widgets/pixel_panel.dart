/// 픽셀 게임풍 바탕 위젯 — 패널·막대·칸 표시.
/// (pixel_ui.dart 에서 갈라 냈다 — 내용은 그대로다)
library;

import 'package:flutter/material.dart';

import 'pixel_palette.dart';

/// 픽셀 게임풍 패널. 2px 테두리 + 네 모서리 장식 + 아래 그림자.
class PixelPanel extends StatelessWidget {
  const PixelPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(10),
    this.color = kBgPanel,
    this.borderColor = kBorderDim,
    this.borderWidth = 2,
    this.glow,
    this.corners = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;
  final double borderWidth;

  /// 지정하면 테두리 바깥으로 은은한 빛이 퍼진다
  final Color? glow;

  /// 네 모서리에 장식 조각을 그릴지
  final bool corners;

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          if (glow != null)
            BoxShadow(color: glow!.withValues(alpha: 0.45), blurRadius: 12),
          const BoxShadow(
              color: Color(0x66000000), blurRadius: 0, offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
    if (!corners) return panel;
    return Stack(
      children: [
        panel,
        // 모서리 장식 4개
        for (final a in const [
          Alignment.topLeft,
          Alignment.topRight,
          Alignment.bottomLeft,
          Alignment.bottomRight,
        ])
          Positioned.fill(
            child: Align(
              alignment: a,
              child: Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.all(2),
                color: borderColor,
              ),
            ),
          ),
      ],
    );
  }
}

/// 각진 체력·마나 막대. [label]을 주면 막대 위에 숫자를 겹쳐 쓴다
/// (딸깍 다이스 방식 — refs/DICERO_ANALYSIS.md §1).
class PixelBar extends StatelessWidget {
  const PixelBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 12,
    this.label,
    this.background = kBgWell,
  });

  /// 0.0 ~ 1.0
  final double value;
  final Color color;
  final double height;

  /// 막대 위에 겹쳐 쓸 문구 (보통 체력 숫자)
  final String? label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: background,
              border: Border.all(color: kBgWell, width: 2),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    border: Border(
                      top: BorderSide(
                        color: Color.lerp(color, Colors.white, 0.4)!,
                        width: height * 0.22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (label != null)
            Text(
              label!,
              style: TextStyle(
                // 막대 높이 14 → 10, 20 이상 → 12 (픽셀 폰트 정수 배율)
                fontFamily: height >= 20 ? kFont11 : kFont9,
                fontSize: height >= 20 ? 12 : 10,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 2),
                  Shadow(color: Colors.black, offset: Offset(1, 1)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 여러 칸으로 나뉜 자원 표시 (마나, 마력 축적)
class PixelPips extends StatelessWidget {
  const PixelPips({
    super.key,
    required this.filled,
    required this.total,
    required this.color,
    this.size = 12,
  });

  final int filled;
  final int total;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          Container(
            width: size,
            height: size,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              color: i < filled ? color : kBgWell,
              border: Border.all(
                color: i < filled
                    ? Color.lerp(color, Colors.white, 0.45)!
                    : kBorderDim,
                width: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}

