/// 전투 화면 아래쪽 조작부 — 주사위 · 족보 줄 · 자원 표시.
///
/// v3에서 **어두운 트레이 상자를 없앴다.** 배경이 화면 전체를 덮고 이 조각들이
/// 그 위에 뜬다. 그래서 여기 있는 것들은 **자기 자리만 차지하고 바탕을 안 칠한다** —
/// 어디에 놓을지는 `battle_screen.dart` 가 화면 아래를 기준으로 정한다.
library;

import 'package:flutter/material.dart';

import '../core/battle.dart';
import '../core/combo.dart';
import '../core/constants.dart';
import '../screens/battle_controller.dart';
import '../services/sfx_service.dart';
import 'battle_overlay.dart';
import 'cast_controls.dart';
import 'dice_widget.dart';
import 'pixel_ui.dart';
import 'result_banner.dart';

/// 조작부 한 줄: 왼쪽에 판정 주사위 3개, 오른쪽에 리롤·시전 버튼.
/// 기획서 6.7절의 「그 아래 좌 = 주사위 / 그 아래 우 = 버튼 둘」이다.
class DiceTray extends StatelessWidget {
  const DiceTray({super.key, required this.controller});

  final BattleController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: kDiceBlockWidth,
          height: kDiceRowHeight,
          child: controller.phase == BattlePhase.pick
              ? const _EmptyDiceSlots()
              : _DiceCluster(controller: controller),
        ),
        const SizedBox(width: 10),
        Expanded(child: ActionButtons(controller: controller)),
      ],
    );
  }
}

/// 주사위 3개가 차지하는 가로 폭 (틀어진 삼각편대 기준)
const double kDiceBlockWidth = 148.0;

/// 삼각편대 배치 — 나란히 세우지 않는다 (기획서 6.7절)
const List<(double, double, double)> _diceSlots = [
  (0, 0, -7), // 왼쪽 위
  (84, 4, 6), // 오른쪽 위
  (42, 40, -3), // 아래 가운데
];

/// 아직 굴리지 않았을 때 보여줄 빈 주사위 자리
class _EmptyDiceSlots extends StatelessWidget {
  const _EmptyDiceSlots();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var i = 0; i < kDiceCount && i < _diceSlots.length; i++)
          Positioned(
            left: _diceSlots[i].$1,
            top: _diceSlots[i].$2,
            child: Transform.rotate(
              angle: _diceSlots[i].$3 * 3.1415926 / 180,
              child: Container(
                width: kDiceSize,
                height: kDiceSize,
                decoration: BoxDecoration(
                  color: kBgWell.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: kBorderDim, width: 2),
                ),
                child: Center(
                  child: Text(
                    '?',
                    style: TextStyle(
                      fontFamily: kFont9,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: kTextDim.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 굴린 주사위 3개 — 틀어진 삼각편대
class _DiceCluster extends StatelessWidget {
  const _DiceCluster({required this.controller});

  final BattleController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final pool = c.pool;
    final canLock = c.phase == BattlePhase.reroll;
    return Stack(
      children: [
        for (var i = 0; i < pool.values.length && i < _diceSlots.length; i++)
          Positioned(
            left: _diceSlots[i].$1,
            top: _diceSlots[i].$2,
            child: Transform.rotate(
              angle: _diceSlots[i].$3 * 3.1415926 / 180,
              child: DiceWidget(
                value: pool.values[i],
                locked: pool.locked[i],
                rollId: c.rollId,
                size: kDiceSize,
                onTap: canLock
                    ? () {
                        SfxService.instance.lockClick();
                        c.toggleLock(i);
                      }
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

/// 굴린 뒤 족보·판정 결과 줄 (주사위 바로 아래)
class ComboLine extends StatelessWidget {
  const ComboLine({super.key, required this.controller});

  final BattleController controller;

  static const Map<ComboType, (String, Color)> _comboLabels = {
    ComboType.triple: ('트리플!  확정 대성공', kGold),
    ComboType.straight: ('스트레이트!  동시 시전', kManaBlue),
    ComboType.snakeEyes: ('뱀눈...  폭주 확정', kCharge),
    ComboType.pair: ('페어  +$kPairBonus', kGold),
  };

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c.phase == BattlePhase.result && c.lastResult != null) {
      return ResultBanner(
        result: c.lastResult!,
        grade: c.appliedGrade ?? c.lastResult!.grade,
      );
    }
    if (c.phase != BattlePhase.reroll) return const SizedBox.shrink();
    // 굴리는 중: 지금 눈으로 성립한 족보와 눈 합계를 보여준다
    final combo = detectCombo(c.pool.values);
    final label = _comboLabels[combo];
    final sum = c.pool.values.fold(0, (a, b) => a + b);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label.$1,
            style: TextStyle(
              fontFamily: kFont9,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: label.$2,
              shadows: kOnArtShadow,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          '눈 합계 $sum',
          style: const TextStyle(
            fontSize: 12,
            color: kTextMain,
            shadows: kOnArtShadow,
          ),
        ),
      ],
    );
  }
}

/// 마나·마력 축적 표시 (주문 슬롯 바로 위 한 줄)
class ResourceRow extends StatelessWidget {
  const ResourceRow({super.key, required this.battle});

  final Battle battle;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
        fontFamily: kFont11, fontSize: 12, color: kTextMain,
        shadows: kOnArtShadow);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text('마나 ', style: style),
            PixelPips(
              filled: battle.mana,
              total: battle.maxMana,
              color: kManaBlue,
            ),
          ],
        ),
        Row(
          children: [
            const Text('마력 축적 ', style: style),
            PixelPips(
              filled: battle.charge,
              total: kChargeThreshold,
              color: kCharge,
            ),
          ],
        ),
      ],
    );
  }
}
