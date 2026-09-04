import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../data/parser.dart';
import '../widgets/floor_tile.dart';
import '../widgets/next_enemy_card.dart';
import '../widgets/pixel_ui.dart';
import '../widgets/run_summary.dart';
import '../widgets/screen_header.dart';
import '../widgets/shop_dialog.dart';
import 'battle_screen.dart';
import 'meta_controller.dart';
import 'result_screen.dart';
import 'reward_screen.dart';
import 'run_controller.dart';

/// 지도 화면 (UI_DESIGN 5-4): 한 스테이지 안의 층 진행.
/// **층수가 3~10으로 가변**이라 칸 수는 스테이지마다 달라진다.
class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
    required this.data,
    required this.regionId,
    required this.stageIndex,
    required this.difficulty,
  });

  final GameData data;
  final int regionId;
  final int stageIndex;
  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RunController(
        data: data,
        meta: context.read<MetaController>().state,
        regionId: regionId,
        stageIndex: stageIndex,
        difficulty: difficulty,
      )..startRun(),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView();

  @override
  Widget build(BuildContext context) {
    final run = context.watch<RunController>();
    return Scaffold(
      backgroundColor: kBgDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MapHeader(run: run),
              const SizedBox(height: 8),
              Expanded(child: _FloorPath(run: run)),
              const SizedBox(height: 8),
              NextEnemyCard(enemy: run.currentEnemy),
              const SizedBox(height: 8),
              PixelButton(
                label: '들어가기  ·  ${run.state.floor}층',
                height: 54,
                fontSize: 20,
                onPressed: () => _enterBattle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 전투 → (승리 시) 보상·상점 → 다음 층. 패배·완주면 결과 화면으로.
  Future<void> _enterBattle(BuildContext context) async {
    final run = context.read<RunController>();
    final bc = run.buildBattleController();
    final won = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BattleScreen(
            controller: bc, floor: run.state.floor, floors: run.floors),
      ),
    );
    if (!context.mounted) return;
    if (won != true) return _finish(context, run, cleared: false);

    final wasBossFloor = run.isBossFloor;
    // 경험치가 먼저다 — 층을 넘기기 전에, 그리고 판이 끝나기 전에 즉시 준다
    run.grantExp(context.read<MetaController>());
    run.afterVictory(bc.battle);

    // 보스 층에도 주문 보상이 나온다 (스테이지 완주 보상)
    if (run.spellOffers.isNotEmpty) {
      await Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (_) => RewardScreen.spells(run: run)));
      if (!context.mounted) return;
    }
    if (wasBossFloor) return _finish(context, run, cleared: true);

    if (run.relicOffers.isNotEmpty) {
      await Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (_) => RewardScreen.relics(run: run)));
      if (!context.mounted) return;
    }
    if (run.currentEvent == FloorEvent.shop) {
      await _showShop(context, run);
      if (!context.mounted) return;
    }
    run.advanceFloor();
  }

  /// 판을 끝낸다. **클리어했을 때만** 진행 기록을 남긴다 (죽으면 안 남긴다).
  void _finish(BuildContext context, RunController run,
      {required bool cleared}) {
    final meta = context.read<MetaController>();
    if (cleared) {
      meta.markStageCleared(
          run.state.regionId, run.state.stageIndex, run.state.difficulty);
    }
    final earned = meta.earnRunReward(
        clearedFloors: cleared ? run.floors : run.state.floor - 1,
        clearedBoss: cleared);
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => ResultScreen(
          cleared: cleared,
          floor: cleared ? run.floors : run.state.floor,
          totalFloors: run.floors,
          crystalsEarned: earned,
          expEarned: run.expEarned,
          levelsGained: run.levelsGained,
          level: meta.state.level),
    ));
  }

  /// 상점: 지금은 휴식 회복만 (경제 설계는 메타 단계에서)
  Future<void> _showShop(BuildContext context, RunController run) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ShopDialog(
        healAmount: shopHealAmount(run.maxHp),
        onRest: () {
          run.shopHeal();
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}

/// 지도 머리 — 스테이지 이름 · 난이도 · 진행 막대 · 플레이어 요약
class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.run});

  final RunController run;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScreenHeader(
          title: run.stageTitle,
          subtitle: [
            if (run.stageSubtitle != null) run.stageSubtitle!,
            kDifficultyLabels[run.difficulty]!,
          ].join('  ·  '),
        ),
        const SizedBox(height: 8),
        // 진행 막대 + 「n / m층」 — 층수가 가변이라 분모를 늘 보여준다
        PixelBar(
          value: (run.state.floor - 1) / run.floors,
          color: kGold,
          height: 14,
          label: '${run.state.floor} / ${run.floors}층',
        ),
        const SizedBox(height: 8),
        RunSummary(run: run),
      ],
    );
  }
}

/// 아래에서 위로 오르는 세로 경로. **칸 수는 스테이지의 층수를 그대로 따른다.**
class _FloorPath extends StatelessWidget {
  const _FloorPath({required this.run});

  final RunController run;

  @override
  Widget build(BuildContext context) {
    final floor = run.state.floor;
    final floors = run.floors;
    // 남는 세로 공간을 층수로 나눠 칸 높이를 정한다 (WORK_ORDER_SCREENS2 작업 2).
    // 3층이면 칸이 커지고, 층이 많아 자리가 빠듯하면 하한에 걸려 지금 크기가 된다.
    return LayoutBuilder(
      builder: (context, box) {
        final tileHeight = (box.maxHeight / floors)
            .clamp(kFloorTileMinHeight, kFloorTileMaxHeight);
        // reverse: 첫 항목(1층)이 맨 아래. 위로 갈수록 높은 층이다.
        // shrinkWrap + Center: 칸을 다 키우고도 남으면 세로 가운데로 모은다.
        return Center(
          child: ListView(
            reverse: true,
            shrinkWrap: true,
            children: [
              for (var f = 1; f <= floors; f++)
                FloorTile(
                  floor: f,
                  floors: floors,
                  isCurrent: f == floor,
                  isCleared: f < floor,
                  enemyName: f == floor ? run.currentEnemy.name : null,
                  enemyId: f == floor ? run.currentEnemy.id : null,
                  height: tileHeight,
                ),
            ],
          ),
        );
      },
    );
  }
}
