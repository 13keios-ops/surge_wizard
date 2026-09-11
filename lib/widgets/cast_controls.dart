/// 전투 화면 조작부의 메인 버튼 — 단계에 따라 리롤·시전·턴 종료를 낸다.
///
/// 🔴 **시전 강도(보통 / 전력) 선택은 v3에서 삭제됐다** (GAME_DESIGN 3.3절).
/// DC와 마나는 이제 주문의 **서클**이 정한다. 예전 `IntensityRow` 는 지웠다.
library;

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../screens/battle_controller.dart';
import '../services/sfx_service.dart';
import 'pixel_ui.dart';
import 'surge_popup.dart';

/// 단계별 메인 버튼. 주사위 오른쪽 칸에 세로로 쌓인다 (기획서 6.7절).
class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key, required this.controller});

  final BattleController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    switch (c.phase) {
      case BattlePhase.pick:
        return _one(PixelButton(
          label: c.canRoll ? '주사위 굴리기' : '주문을 고르세요',
          height: kCastButtonHeight,
          fontSize: c.canRoll ? kCastButtonFont : 12,
          onPressed: c.canRoll
              ? () {
                  SfxService.instance.diceRoll();
                  c.rollDice();
                }
              : null,
        ));
      case BattlePhase.reroll:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PixelButton(
              // 리롤 비용이 1→2→3으로 오르므로 이번 회차 비용을 함께 보여준다
              label: '리롤 ${c.pool.maxRerolls - c.pool.rerollCount}회'
                  '${c.nextRerollIsFree ? ' (무료)' : ' (마나 ${c.nextRerollCost})'}',
              fontSize: 12,
              height: kCastButtonHeight,
              color: kBgPanel,
              onPressed: c.canReroll
                  ? () {
                      SfxService.instance.diceRoll();
                      c.reroll();
                    }
                  : null,
            ),
            const SizedBox(height: 8),
            PixelButton(
              label: '시전!',
              height: kCastButtonHeight,
              fontSize: kCastButtonFont,
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
          ],
        );
      case BattlePhase.result:
        return _one(PixelButton(
          label: '턴 종료',
          height: kCastButtonHeight,
          fontSize: kCastButtonFont,
          onPressed: c.endTurn,
        ));
      case BattlePhase.over:
        return _one(PixelButton(
          label: c.battle.playerWon ? '승리!' : '쓰러졌다...',
          height: kCastButtonHeight,
          fontSize: kCastButtonFont,
          onPressed: () => Navigator.of(context).pop(c.battle.playerWon),
        ));
    }
  }

  /// 버튼이 하나뿐인 단계도 두 개짜리와 같은 자리에 오도록 가운데 둔다
  Widget _one(Widget button) =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [button]);
}
