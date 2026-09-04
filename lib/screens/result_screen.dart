import 'package:flutter/material.dart';

import '../art/pixel_sprite.dart';
import '../art/sprites_characters.dart';
import '../art/sprites_items.dart';
import '../widgets/pixel_ui.dart';

/// 한 판 종료 화면 (승리 또는 사망) + 마력 결정 지급 표시.
/// 도달 층수를 거대한 숫자로 보여준다 (refs/DICERO_ANALYSIS.md §7).
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.cleared,
    required this.floor,
    required this.totalFloors,
    required this.crystalsEarned,
    required this.expEarned,
    required this.levelsGained,
    required this.level,
  });

  /// 마지막 층의 보스까지 잡았는가
  final bool cleared;

  /// 도달(사망) 층
  final int floor;

  /// 이 스테이지의 총 층수 (스테이지마다 3~10으로 다르다)
  final int totalFloors;

  /// 이번 판으로 얻은 마력 결정
  final int crystalsEarned;

  /// 이번 판에서 받은 경험치 누계. **판이 실패해도 이 값은 이미 들어가 있다**
  final int expEarned;

  /// 이번 판에서 오른 레벨 수 (0이면 레벨업 없음)
  final int levelsGained;

  /// 지금 캐릭터 레벨 (레벨업 뒤의 값)
  final int level;

  @override
  Widget build(BuildContext context) {
    final accent = cleared ? kGold : kCharge;
    return Scaffold(
      backgroundColor: kBgDeep,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.2,
            colors: [accent.withValues(alpha: 0.25), kBgDeep],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PixelSpriteView(
                  cleared ? kSpriteWizard : kIconSword,
                  size: cleared ? 108 : 84,
                  tint: accent,
                ),
                const SizedBox(height: 14),
                RibbonBanner(
                  // 「탑」은 v1 잔재다 — 지금 깬 것은 스테이지 하나이고,
                  // 탑은 9·10지역의 이름일 뿐이다 (WORK_ORDER_SCREENS2 작업 3)
                  text: cleared ? '스테이지 클리어!' : '정말 아쉽네요!',
                  color: cleared ? kGold : kBgPanelLit,
                  fontSize: 24,
                ),
                const SizedBox(height: 22),
                const Text('도달 층수',
                    style: TextStyle(fontSize: 12, color: kTextDim)),
                // 거대한 숫자 = 이번 판의 점수
                Text(
                  '$floor',
                  style: TextStyle(
                    fontSize: 84,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    color: accent,
                    shadows: [
                      Shadow(color: accent.withValues(alpha: 0.7), blurRadius: 24),
                      const Shadow(color: Colors.black, blurRadius: 4),
                    ],
                  ),
                ),
                Text('/ $totalFloors',
                    style: const TextStyle(fontSize: 12, color: kTextDim)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                        child: Divider(color: kBorderDim, thickness: 2)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('보상 획득',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: kTextMain)),
                    ),
                    const Expanded(
                        child: Divider(color: kBorderDim, thickness: 2)),
                  ],
                ),
                const SizedBox(height: 12),
                _RewardTile(amount: crystalsEarned),
                const SizedBox(height: 6),
                const Text('타이틀의 "영구 강화"에서 쓸 수 있다',
                    style: TextStyle(
                        fontFamily: kFont9, fontSize: 10, color: kTextDim)),
                const SizedBox(height: 14),
                // 위 안내 문구는 **마력 결정에 붙은 것**이라 경험치는 그 아래에 둔다
                _ExpTile(
                    expEarned: expEarned,
                    levelsGained: levelsGained,
                    level: level),
                const SizedBox(height: 28),
                // 반복 플레이가 편하도록 **스테이지 선택으로 바로 돌아간다.**
                // 이 화면은 지도 자리를 대신 차지하고 있어서, 한 번만 물러나면
                // 스테이지 선택 화면이다 (WORK_ORDER_SCREENS 2-D).
                SizedBox(
                  width: 230,
                  child: PixelButton(
                    label: '스테이지 선택으로',
                    height: 52,
                    fontSize: 20,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 230,
                  child: PixelButton(
                    label: '타이틀로',
                    height: 44,
                    fontSize: 12,
                    color: kBgPanel,
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 경험치 한 줄. 레벨업이 있었으면 오른 레벨을 함께 보여준다.
/// **막대·연출은 일부러 만들지 않았다** — 숫자만 보이면 된다 (WORK_ORDER_LEVEL 3절).
class _ExpTile extends StatelessWidget {
  const _ExpTile(
      {required this.expEarned,
      required this.levelsGained,
      required this.level});

  final int expEarned;
  final int levelsGained;
  final int level;

  @override
  Widget build(BuildContext context) {
    final up = levelsGained > 0;
    return Column(
      children: [
        Text('경험치  +$expEarned',
            style: const TextStyle(
                fontFamily: kFont9,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: kManaBlue)),
        if (up)
          Text('레벨 업!  ×$levelsGained  →  Lv.$level',
              style: const TextStyle(
                  fontFamily: kFont9, fontSize: 10, color: kGold))
        else
          Text('Lv.$level',
              style: const TextStyle(
                  fontFamily: kFont9, fontSize: 10, color: kTextDim)),
      ],
    );
  }
}

/// 보상 타일 (아이콘 + 수량)
class _RewardTile extends StatelessWidget {
  const _RewardTile({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      borderColor: kCharge,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PixelSpriteView(kIconGem, size: 32, tint: kCharge),
          const SizedBox(width: 12),
          Text('마력 결정  ×$amount',
              style: const TextStyle(
                  fontFamily: kFont9,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: kCharge)),
        ],
      ),
    );
  }
}
