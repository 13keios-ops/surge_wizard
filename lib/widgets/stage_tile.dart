import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/stage.dart';
import 'pixel_ui.dart';

/// 스테이지 한 칸의 상태
enum StageMark {
  /// 이 난이도로 이미 깼다 (★)
  cleared,

  /// 열려 있지만 아직 안 깼다 (☆)
  open,

  /// 잠겨 있다 (「잠김」)
  locked,
}

/// 상태 표시 글자. **갈무리 폰트에 있는 글자만 쓴다** — 자물쇠(🔒)는 없어서
/// 한글 「잠김」으로 대신한다 (floor_tile.dart 의 같은 주의 참조).
String stageMarkText(StageMark mark) => switch (mark) {
      StageMark.cleared => '★',
      StageMark.open => '☆',
      StageMark.locked => '잠김',
    };

Color _markColor(StageMark mark) => switch (mark) {
      StageMark.cleared => kGold,
      StageMark.open => kTextDim,
      StageMark.locked => kBorderDim,
    };

/// 일반 스테이지 격자 칸 — 로마숫자 · 층수 · ★/☆/잠김 (UI_DESIGN 5-3)
class StageTile extends StatelessWidget {
  const StageTile({
    super.key,
    required this.stage,
    required this.mark,
    required this.onTap,
  });

  final Stage stage;
  final StageMark mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = mark == StageMark.locked;
    return GestureDetector(
      onTap: locked ? null : onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: locked ? kBgWell : kBgPanel,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
              color: mark == StageMark.cleared ? kGold : kBorderDim,
              width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(kStageRomans[stage.index - 1],
                style: TextStyle(
                    fontFamily: kFont9,
                    fontSize: 20,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: locked ? kBorderDim : kTextMain)),
            const SizedBox(height: 2),
            Text('${stage.floors}층',
                style: TextStyle(
                    fontFamily: kFont9,
                    fontSize: 10,
                    color: locked ? kBorderDim : kTextDim)),
            Text(stageMarkText(mark),
                style: TextStyle(
                    fontFamily: kFont9,
                    fontSize: 10,
                    height: 1.2,
                    color: _markColor(mark))),
          ],
        ),
      ),
    );
  }
}

/// 보스 스테이지 카드 — **혼자 크고 부제가 보인다** (UI_DESIGN 5-3).
/// 왕관(👑)은 갈무리 폰트에 없어 「보스」 뱃지로 대신한다.
class BossStageCard extends StatelessWidget {
  const BossStageCard({
    super.key,
    required this.stage,
    required this.mark,
    required this.onTap,
  });

  final Stage stage;
  final StageMark mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = mark == StageMark.locked;
    return GestureDetector(
      onTap: locked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: locked ? kBgWell : kBgPanel,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: locked ? kBorderDim : kHpRed, width: 2),
        ),
        child: Row(
          children: [
            Text(kStageRomans[stage.index - 1],
                style: TextStyle(
                    fontFamily: kFont9,
                    fontSize: 30,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: locked ? kBorderDim : kTextMain)),
            const SizedBox(width: 12),
            Expanded(child: _BossBody(stage: stage, locked: locked)),
            const SizedBox(width: 8),
            Text(stageMarkText(mark),
                style: TextStyle(
                    fontFamily: kFont9,
                    fontSize: 20,
                    height: 1,
                    color: _markColor(mark))),
          ],
        ),
      ),
    );
  }
}

/// 보스 카드 가운데 — 부제 + 층수·권장 레벨
class _BossBody extends StatelessWidget {
  const _BossBody({required this.stage, required this.locked});

  final Stage stage;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(stage.subtitle ?? '보스',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: locked ? kBorderDim : kTextMain),
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 6),
            // 잠겨 있어도 「여기가 보스다」는 보여 준다
            PixelBadge(text: '보스', color: locked ? kBgPanelLit : kHpRed),
          ],
        ),
        const SizedBox(height: 3),
        Text('${stage.floors}층 · 권장 Lv ${stage.recommendedLevel}',
            style: TextStyle(
                fontFamily: kFont9,
                fontSize: 10,
                color: locked ? kBorderDim : kTextDim)),
      ],
    );
  }
}
