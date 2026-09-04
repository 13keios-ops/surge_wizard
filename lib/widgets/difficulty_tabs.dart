import 'package:flutter/material.dart';

import '../core/constants.dart';
import 'pixel_ui.dart';

/// 난이도 3탭 (UI_DESIGN 5-3).
/// **탭을 바꿔도 스테이지를 다시 고르지 않는다** — 고른 스테이지는 그대로 두고
/// 난이도만 갈아 끼운다. 잠긴 탭은 눌리지 않는다.
class DifficultyTabs extends StatelessWidget {
  const DifficultyTabs({
    super.key,
    required this.selected,
    required this.unlocked,
    required this.onSelect,
  });

  final Difficulty selected;

  /// 난이도별 해금 여부 (Difficulty.values 순서)
  final Map<Difficulty, bool> unlocked;

  final ValueChanged<Difficulty> onSelect;

  /// 난이도가 올라갈수록 색이 뜨거워진다 (별 색과 같은 순서다)
  static const _colors = {
    Difficulty.normal: kGold,
    Difficulty.hard: kManaBlue,
    Difficulty.death: kHpRed,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final d in Difficulty.values) ...[
          Expanded(
            child: _Tab(
              label: kDifficultyLabels[d]!,
              color: _colors[d]!,
              selected: d == selected,
              locked: unlocked[d] != true,
              onTap: () => onSelect(d),
            ),
          ),
          if (d != Difficulty.values.last) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.color,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: locked ? null : onTap,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? kBgPanelLit : kBgPanel,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
              color: selected ? color : kBorderDim, width: selected ? 2 : 1.5),
        ),
        child: Text(
          locked ? '$label 잠김' : label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: locked ? kBorderDim : (selected ? color : kTextDim),
          ),
        ),
      ),
    );
  }
}
