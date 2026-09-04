/// 전투 중 체력이 변할 때 위로 튀어오르는 숫자.
/// (battle_stage.dart 에서 갈라 냈다 — 내용은 그대로다)
library;

import 'package:flutter/material.dart';

/// 떠오르는 숫자 하나
class DamagePopup {
  DamagePopup(this.text, this.color, this.onEnemy);

  /// 위젯 키로 쓰는 일련번호.
  /// 예전에는 `DateTime.now().microsecondsSinceEpoch` 를 썼는데, 한 프레임에
  /// 적과 나의 체력이 **동시에** 변하면 두 팝업이 같은 값을 받아
  /// "Duplicate keys found" 로 화면이 죽었다.
  static int _nextId = 0;

  final String text;
  final Color color;
  final bool onEnemy;
  final int id = _nextId++;
}

/// 위로 튀어오르며 사라지는 숫자
class PopupText extends StatefulWidget {
  const PopupText({super.key, required this.popup});

  final DamagePopup popup;

  @override
  State<PopupText> createState() => _PopupTextState();
}

class _PopupTextState extends State<PopupText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_c.value);
        // 처음에 팡 커졌다가 작아지며 떠오른다
        final scale = _c.value < 0.18
            ? Curves.easeOutBack.transform(_c.value / 0.18) * 1.25
            : 1.25 - (_c.value - 0.18) * 0.3;
        return Positioned(
          left: 0,
          right: 0,
          top: widget.popup.onEnemy ? 88 - t * 44 : null,
          bottom: widget.popup.onEnemy ? null : 74 + t * 44,
          child: IgnorePointer(
            child: Opacity(
              opacity: (1 - t * t).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: scale.clamp(0.2, 1.4),
                child: Text(
                  widget.popup.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: widget.popup.color,
                    shadows: const [
                      Shadow(color: Colors.black, blurRadius: 5),
                      Shadow(color: Colors.black, offset: Offset(2, 2)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
