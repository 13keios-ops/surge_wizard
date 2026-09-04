/// 전투 화면 아래쪽 주사위 트레이 — 자원 표시 · 주사위 · 족보 줄.
/// (battle_screen.dart 가 300줄을 넘어 갈라 냈다 — 내용은 그대로다)
library;

import 'package:flutter/material.dart';

import '../core/battle.dart';
import '../core/combo.dart';
import '../core/constants.dart';
import '../screens/battle_controller.dart';
import '../services/sfx_service.dart';
import 'cast_controls.dart';
import 'dice_widget.dart';
import 'pixel_ui.dart';
import 'result_banner.dart';

/// 주사위 트레이: 자원 표시 + 주사위 + 콤보 + 조작 버튼
class DiceTray extends StatelessWidget {
  const DiceTray({super.key, required this.controller});

  final BattleController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return PixelPanel(
      // 트레이는 화면에서 가장 어둡다 — 흰 주사위가 제일 밝게 뜨도록
      color: kBgTray,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ResourceBar(battle: c.battle),
          const SizedBox(height: 8),
          SizedBox(
            height: 96,
            child: Center(
              child: c.phase == BattlePhase.pick
                  ? const _EmptyDiceSlots()
                  : _DiceRow(controller: c),
            ),
          ),
          SizedBox(
            height: 58,
            child: Center(child: _ComboLine(controller: c)),
          ),
          if (c.phase == BattlePhase.pick) ...[
            IntensityRow(controller: c),
            const SizedBox(height: 8),
          ],
          ActionButtons(controller: c),
        ],
      ),
    );
  }
}

/// 아직 굴리지 않았을 때 보여줄 빈 주사위 자리
class _EmptyDiceSlots extends StatelessWidget {
  const _EmptyDiceSlots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < kDiceCount; i++)
          Container(
            width: 84,
            height: 84,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: kBgWell,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: kBorderDim,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Text(
                '?',
                style: TextStyle(
                  fontFamily: kFont9,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: kTextDim.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 주사위 3개 (크게)
class _DiceRow extends StatelessWidget {
  const _DiceRow({required this.controller});

  final BattleController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final pool = c.pool;
    final canLock = c.phase == BattlePhase.reroll;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < pool.values.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DiceWidget(
              value: pool.values[i],
              locked: pool.locked[i],
              rollId: c.rollId,
              size: 88,
              onTap: canLock
                  ? () {
                      SfxService.instance.lockClick();
                      c.toggleLock(i);
                    }
                  : null,
            ),
          ),
      ],
    );
  }
}

/// 굴린 뒤 족보·판정 결과 줄
class _ComboLine extends StatelessWidget {
  const _ComboLine({required this.controller});

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
    if (c.phase == BattlePhase.pick) return const SizedBox.shrink();
    if (c.phase != BattlePhase.reroll) return const SizedBox.shrink();
    // 굴리는 중: 지금 눈으로 성립한 족보와 예상 판정값을 보여준다
    final combo = detectCombo(c.pool.values);
    final label = _comboLabels[combo];
    final sum = c.pool.values.fold(0, (a, b) => a + b);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label.$1,
            style: TextStyle(
              fontFamily: kFont9,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: label.$2,
              shadows: [
                Shadow(color: label.$2.withValues(alpha: 0.6), blurRadius: 10),
              ],
            ),
          ),
        Text(
          '눈 합계 $sum',
          style: const TextStyle(
            fontFamily: kFont9,
            fontSize: 10,
            color: kTextDim,
          ),
        ),
      ],
    );
  }
}

/// 마나·마력 축적 표시
class _ResourceBar extends StatelessWidget {
  const _ResourceBar({required this.battle});

  final Battle battle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              '마나 ',
              style: TextStyle(
                fontFamily: kFont9,
                fontSize: 10,
                color: kTextDim,
              ),
            ),
            PixelPips(
              filled: battle.mana,
              total: battle.maxMana,
              color: kManaBlue,
            ),
          ],
        ),
        Row(
          children: [
            const Text(
              '마력 축적 ',
              style: TextStyle(
                fontFamily: kFont9,
                fontSize: 10,
                color: kTextDim,
              ),
            ),
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
