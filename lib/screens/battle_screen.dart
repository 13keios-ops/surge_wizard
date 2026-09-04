import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/sfx_service.dart';
import '../widgets/battle_fx.dart';
import '../widgets/battle_stage.dart';
import '../widgets/dice_tray.dart';
import '../widgets/pixel_ui.dart';
import '../widgets/spell_card.dart';
import 'battle_controller.dart';

/// 전투 화면. 딸깍 다이스식 세로 구도 (GAME_DESIGN 9.5절):
/// 위 = 적, 가운데 = 마법사와 손패, 아래 = 주사위 트레이(화면의 주인공).
class BattleScreen extends StatelessWidget {
  const BattleScreen(
      {super.key, required this.controller, this.floor, this.floors});

  final BattleController controller;

  /// 현재 층 (좌측 노드 트랙 표시용)
  final int? floor;

  /// 이 스테이지의 총 층수 (노드 트랙 표시용)
  final int? floors;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: BattleFx(
        controller: controller,
        child: _BattleView(floor: floor, floors: floors),
      ),
    );
  }
}

class _BattleView extends StatelessWidget {
  const _BattleView({this.floor, this.floors});

  final int? floor;
  final int? floors;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<BattleController>();
    return Scaffold(
      backgroundColor: kBgDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          child: Column(
            children: [
              // 무대는 남는 높이를 채운다 (작은 기기에서도 넘치지 않게)
              Expanded(
                child: BattleStage(controller: c, floor: floor, floors: floors),
              ),
              const SizedBox(height: 6),
              _HandRow(controller: c),
              const SizedBox(height: 6),
              // 하단 주사위 트레이 — 화면의 주인공
              DiceTray(controller: c),
            ],
          ),
        ),
      ),
    );
  }
}

/// 손패 3장 (한 줄)
class _HandRow extends StatelessWidget {
  const _HandRow({required this.controller});

  final BattleController controller;

  @override
  Widget build(BuildContext context) {
    final battle = controller.battle;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < battle.hand.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: SpellCard(
              spell: battle.hand[i],
              selected: controller.selectedSpell == i,
              sealed: battle.sealedSpellIds.contains(battle.hand[i].id),
              onTap: () {
                SfxService.instance.lockClick();
                controller.selectSpell(i);
              },
            ),
          ),
      ],
    );
  }
}