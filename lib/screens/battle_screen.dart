import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../services/sfx_service.dart';
import '../widgets/battle_fx.dart';
import '../widgets/battle_overlay.dart';
import '../widgets/battle_stage.dart';
import '../widgets/dice_tray.dart';
import '../widgets/pixel_ui.dart';
import '../widgets/spell_slots.dart';
import 'battle_controller.dart';

/// 전투 화면 (v3 구도 — 보고서 31 · 4-8절).
///
/// 🔴 **배경이 화면 전체를 덮고 그 위에 UI가 뜬다.** 예전처럼 위쪽 「무대 상자」와
/// 아래쪽 「어두운 트레이」로 나누지 않는다. 조작부가 불투명하면 화면이 답답하고,
/// 무엇보다 **조작부 높이가 고정이라 작은 기기에서 화면의 59%를 먹었다**
/// (지시서 6-A 2-1절).
///
/// 자리는 전부 **화면 아래에서 몇 dp** 로 잡는다. 기기 비율이 16:9 ~ 20:9 로
/// 제각각이라 위에서 재면 기기마다 구도가 달라지지만, 아래에서 재면
/// **위쪽 배경만 더 보이고** 조작부·마법사·적의 관계는 그대로다.
class BattleScreen extends StatelessWidget {
  const BattleScreen(
      {super.key,
      required this.controller,
      this.title,
      this.regionId,
      this.floor,
      this.floors});

  final BattleController controller;

  /// 상단 띠에 띄울 던전 이름
  final String? title;

  /// 현재 지역 (배경 원화 선택용)
  final int? regionId;

  /// 현재 층 / 이 스테이지의 총 층수 (상단 띠 표시용)
  final int? floor;
  final int? floors;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: BattleFx(
        controller: controller,
        child: _BattleView(
            title: title, regionId: regionId, floor: floor, floors: floors),
      ),
    );
  }
}

class _BattleView extends StatelessWidget {
  const _BattleView({this.title, this.regionId, this.floor, this.floors});

  final String? title;
  final int? regionId;
  final int? floor;
  final int? floors;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<BattleController>();
    final battle = c.battle;
    return Scaffold(
      backgroundColor: kBgDeep,
      body: Stack(
        children: [
          // ① 배경 + 캐릭터 — 화면 끝까지
          Positioned.fill(
            child: BattleStage(
                controller: c,
                regionId: regionId,
                floor: floor,
                floors: floors),
          ),
          // ② 상단 띠 — 노치를 피해 안전 영역 안에 둔다
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BattleTopBar(
                    title: title ?? '던전',
                    floor: floor,
                    floors: floors,
                  ),
                  // 보스만 체력을 화면 맨 위 가로 전체로 보여준다.
                  // 일반 적은 발밑(`UnitPlate`)에 붙는다
                  if (battle.enemy.isBoss)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 4, 30, 0),
                      child: BossHpBar(battle: battle),
                    ),
                ],
              ),
            ),
          ),
          // ③ 조작부 — 전부 화면 아래에서 잰다
          Positioned(
            bottom: kResBottom,
            left: 10,
            right: 10,
            child: ResourceRow(battle: battle),
          ),
          Positioned(
            bottom: kSlotsBottom,
            left: 8,
            right: 8,
            child: SpellSlots(
              hand: battle.hand,
              selected: c.selectedSpell,
              sealedIds: battle.sealedSpellIds.toSet(),
              onTap: (i) {
                SfxService.instance.lockClick();
                c.selectSpell(i);
              },
            ),
          ),
          Positioned(
            bottom: kCtrlBottom + kDiceRowHeight + 4,
            left: 8,
            right: 8,
            child: SizedBox(
              height: kComboLineHeight,
              child: Center(child: ComboLine(controller: c)),
            ),
          ),
          Positioned(
            bottom: kCtrlBottom,
            left: 8,
            right: 8,
            child: DiceTray(controller: c),
          ),
        ],
      ),
    );
  }
}
