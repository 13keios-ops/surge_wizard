import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/progress.dart';
import '../data/parser.dart';
import '../models/stage.dart';
import '../widgets/difficulty_tabs.dart';
import '../widgets/pixel_ui.dart';
import '../widgets/screen_header.dart';
import '../widgets/stage_tile.dart';
import 'map_screen.dart';
import 'meta_controller.dart';

/// 스테이지 선택 화면 (UI_DESIGN 5-3).
/// 위에 난이도 3탭, 아래에 스테이지 격자. 보스 스테이지만 크게 나온다.
class StageSelectScreen extends StatefulWidget {
  const StageSelectScreen({
    super.key,
    required this.data,
    required this.regionId,
  });

  final GameData data;
  final int regionId;

  @override
  State<StageSelectScreen> createState() => _StageSelectScreenState();
}

class _StageSelectScreenState extends State<StageSelectScreen> {
  /// 지금 고른 난이도. **스테이지를 고를 때 이 값을 그대로 들고 간다**
  Difficulty _difficulty = Difficulty.normal;

  /// 난이도 잠금은 스테이지 단위라, 탭의 해금 여부는 「이 지역에서 그 난이도로
  /// 갈 수 있는 스테이지가 하나라도 있는가」로 본다.
  Map<Difficulty, bool> _tabUnlocked(Progress progress, List<Stage> stages) => {
        for (final d in Difficulty.values)
          d: stages.any((s) =>
              progress.isDifficultyUnlocked(widget.regionId, s.index, d)),
      };

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final meta = context.watch<MetaController>().state;
    final progress = Progress(data, meta);
    final region = data.region(widget.regionId);
    final stages = data.stages
        .where((s) => s.regionId == widget.regionId)
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final unlocked = _tabUnlocked(progress, stages);
    return Scaffold(
      backgroundColor: kBgDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                  title: region.name,
                  subtitle: '스테이지 ${stages.length}개',
                  level: meta.level),
              const SizedBox(height: 8),
              DifficultyTabs(
                selected: _difficulty,
                unlocked: unlocked,
                onSelect: (d) => setState(() => _difficulty = d),
              ),
              const SizedBox(height: 4),
              _TabHint(reason: _hintFor(progress, stages, unlocked)),
              Expanded(
                child: _StageList(
                  stages: stages,
                  progress: progress,
                  difficulty: _difficulty,
                  onPick: (s) => _enterStage(context, s),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 지금 탭이 잠겼으면 왜 잠겼는지 한 줄. 열려 있으면 null.
  String? _hintFor(
      Progress progress, List<Stage> stages, Map<Difficulty, bool> unlocked) {
    if (unlocked[_difficulty] == true) return null;
    return switch (_difficulty) {
      Difficulty.normal => progress.regionLockReason(widget.regionId),
      Difficulty.hard => '스테이지를 보통으로 클리어하면 열린다',
      Difficulty.death => '스테이지를 하드로 클리어하면 열린다',
    };
  }

  void _enterStage(BuildContext context, Stage stage) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => MapScreen(
        data: widget.data,
        regionId: widget.regionId,
        stageIndex: stage.index,
        difficulty: _difficulty,
      ),
    ));
  }
}

/// 잠긴 난이도 탭 아래에 나오는 이유 한 줄 (자리는 늘 잡아 둬 화면이 안 튄다)
class _TabHint extends StatelessWidget {
  const _TabHint({required this.reason});

  final String? reason;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Center(
        child: Text(reason ?? '',
            style: const TextStyle(
                fontFamily: kFont9, fontSize: 10, color: kGold),
            overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

/// 스테이지 격자 + 맨 아래 보스 카드
class _StageList extends StatelessWidget {
  const _StageList({
    required this.stages,
    required this.progress,
    required this.difficulty,
    required this.onPick,
  });

  final List<Stage> stages;
  final Progress progress;
  final Difficulty difficulty;
  final ValueChanged<Stage> onPick;

  StageMark _markOf(Stage s) {
    if (!progress.isDifficultyUnlocked(s.regionId, s.index, difficulty)) {
      return StageMark.locked;
    }
    return progress.isCleared(s.regionId, s.index, difficulty)
        ? StageMark.cleared
        : StageMark.open;
  }

  /// 격자 칸 높이 — 남는 세로 공간을 줄 수로 나눈다 (WORK_ORDER_SCREENS2 작업 2).
  /// 하한은 **지금 화면의 칸**(폭 ÷ [kStageTileAspect])이라 자리가 빠듯하면
  /// 지금과 똑같아지고, 상한은 정사각형([kStageTileMaxAspect])이다.
  double _tileHeight(BoxConstraints box, int count) {
    const gap = kStageGridSpacing;
    final cellWidth = (box.maxWidth - gap * 2) / 3;
    final rows = (count / 3).ceil();
    final fit = (box.maxHeight - gap * (rows - 1)) / rows;
    return fit.clamp(
        cellWidth / kStageTileAspect, cellWidth / kStageTileMaxAspect);
  }

  @override
  Widget build(BuildContext context) {
    final normal = stages.where((s) => !s.isBossStage).toList();
    final boss = stages.where((s) => s.isBossStage).toList();
    // 보스 카드는 지금 비율 그대로 아래에 두고, 남는 높이는 격자가 다 쓴다
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          // 칸을 다 키우고도 남으면 세로 가운데로 모은다 (지도와 같은 방식)
          child: LayoutBuilder(
            builder: (context, box) => Center(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: kStageGridSpacing,
                  crossAxisSpacing: kStageGridSpacing,
                  mainAxisExtent: _tileHeight(box, normal.length),
                ),
                itemCount: normal.length,
                itemBuilder: (context, i) => StageTile(
                  stage: normal[i],
                  mark: _markOf(normal[i]),
                  onTap: () => onPick(normal[i]),
                ),
              ),
            ),
          ),
        ),
        for (final s in boss)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: BossStageCard(
              stage: s,
              mark: _markOf(s),
              onTap: () => onPick(s),
            ),
          ),
      ],
    );
  }
}
