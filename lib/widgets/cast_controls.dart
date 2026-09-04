/// 전투 화면의 조작부 — 시전 강도 선택과 단계별 메인 버튼.
/// (battle_screen.dart 에서 갈라 냈다 — 내용은 그대로다)
library;

import 'package:flutter/material.dart';

import '../core/cast_intensity.dart';
import '../screens/battle_controller.dart';
import '../services/sfx_service.dart';
import 'pixel_ui.dart';
import 'surge_popup.dart';

/// 시전 강도 선택 (보통 / 전력 — GAME_DESIGN v2 3.3절)
class IntensityRow extends StatelessWidget {
  const IntensityRow({super.key, required this.controller});

  final BattleController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final it in CastIntensity.values) ...[
          Expanded(
            child: GestureDetector(
              onTap: controller.battle.mana >= it.manaCost
                  ? () => controller.selectIntensity(it)
                  : null,
              child: Opacity(
                opacity: controller.battle.mana >= it.manaCost ? 1 : 0.35,
                child: PixelPanel(
                  // 강도가 둘로 줄어 자리가 남는다. 손가락으로 누르는
                  // 화면이므로 남는 자리를 버튼 높이로 돌려준다.
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: controller.intensity == it ? kBgPanelLit : kBgPanel,
                  borderColor: controller.intensity == it
                      ? kBorderLit
                      : kBorderDim,
                  // 패널은 내용 너비로 줄어든다. 자리를 다 쓰도록 폭을 편다
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          it.label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: kTextMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'DC${it.dc} · 마나${it.manaCost}',
                          style: const TextStyle(
                            fontFamily: kFont9,
                            fontSize: 10,
                            color: kTextDim,
                          ),
                        ),
                        Text(
                          '위력 ×${it.power.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontFamily: kFont9,
                            fontSize: 10,
                            color: kTextDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (it != CastIntensity.values.last) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

/// 단계별 메인 버튼
class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key, required this.controller});

  final BattleController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    switch (c.phase) {
      case BattlePhase.pick:
        return PixelButton(
          label: c.canRoll ? '주사위 굴리기' : '주문을 고르세요',
          height: 54,
          fontSize: 24,
          onPressed: c.canRoll
              ? () {
                  SfxService.instance.diceRoll();
                  c.rollDice();
                }
              : null,
        );
      case BattlePhase.reroll:
        return Row(
          children: [
            Expanded(
              child: PixelButton(
                // 리롤 비용이 1→2→3으로 오르므로 이번 회차 비용을 함께 보여준다
                label:
                    '리롤 ${c.pool.maxRerolls - c.pool.rerollCount}회'
                    '${c.nextRerollIsFree ? ' (무료)' : ' (마나 ${c.nextRerollCost})'}',
                fontSize: 12,
                height: 54,
                color: kBgPanel,
                onPressed: c.canReroll
                    ? () {
                        SfxService.instance.diceRoll();
                        c.reroll();
                      }
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PixelButton(
                label: '시전!',
                height: 54,
                fontSize: 24,
                onPressed: () {
                  c.confirmCast();
                  final surge = c.lastSurge;
                  if (surge != null) {
                    showDialog<void>(
                      context: context,
                      builder: (_) =>
                          SurgePopup(surge: surge, summary: c.lastSurgeSummary),
                    );
                  }
                },
              ),
            ),
          ],
        );
      case BattlePhase.result:
        return PixelButton(
          label: '턴 종료',
          height: 54,
          fontSize: 24,
          onPressed: c.endTurn,
        );
      case BattlePhase.over:
        return PixelButton(
          label: c.battle.playerWon ? '승리!' : '쓰러졌다...',
          height: 54,
          fontSize: 24,
          onPressed: () => Navigator.of(context).pop(c.battle.playerWon),
        );
    }
  }
}
