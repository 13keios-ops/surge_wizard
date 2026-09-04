import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/progress.dart';
import '../data/parser.dart';
import '../models/region.dart';
import '../widgets/pixel_ui.dart';
import '../widgets/region_card.dart';
import '../widgets/screen_header.dart';
import 'meta_controller.dart';
import 'stage_select_screen.dart';

/// 지역 선택 화면 (UI_DESIGN 5-2).
/// 12개를 세로로 훑으며 어디까지 열렸는지 본다.
class RegionSelectScreen extends StatelessWidget {
  const RegionSelectScreen({super.key, required this.data});

  final GameData data;

  /// 그 지역 스테이지들의 권장 레벨 범위 (카드에 「권장 Lv 1~8」로 나온다)
  (int, int) _levelRange(Region region) {
    final levels = data.stages
        .where((s) => s.regionId == region.id)
        .map((s) => s.recommendedLevel)
        .toList()
      ..sort();
    return levels.isEmpty ? (0, 0) : (levels.first, levels.last);
  }

  @override
  Widget build(BuildContext context) {
    // 클리어 기록이 바뀌면(=판을 깨고 돌아오면) 잠금이 그 자리에서 풀려야 한다
    final meta = context.watch<MetaController>().state;
    final progress = Progress(data, meta);
    final regions = [...data.regions]..sort((a, b) => a.id.compareTo(b.id));
    return Scaffold(
      backgroundColor: kBgDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                  title: '지역', subtitle: '갈 곳을 고른다', level: meta.level),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: regions.length,
                  itemBuilder: (context, i) => _card(context, progress, regions[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, Progress progress, Region region) {
    return RegionCard(
      region: region,
      levelRange: _levelRange(region),
      stars: progress.regionStars(region.id),
      lockReason: progress.regionLockReason(region.id),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => StageSelectScreen(data: data, regionId: region.id),
        ),
      ),
    );
  }
}
