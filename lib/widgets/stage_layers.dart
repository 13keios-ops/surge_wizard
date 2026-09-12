/// 전투 무대의 **배경 겹**을 한 덩어리로 묶는다.
///
/// 겹의 순서는 `GAME_DESIGN.md` 6.7절 ①이 정한다 —
/// 뒤에서 앞으로 **배경 판 · 성 · 보스 음영 · 길 옆 물체 · 소환수**.
/// 성과 보스 음영은 다음 지시서다.
///
/// 🔴 **배경 판은 움직이지 않는다.** 층이 오를 때 흐르는 것은 길 옆 물체뿐이다.
library;

import 'package:flutter/material.dart';

import '../art/art_sprite.dart';
import '../art/landmark.dart';
import '../art/roadside.dart';
import '../art/stage_backdrop.dart';
import '../core/surge.dart';
import '../data/parser.dart';
import '../models/enemy.dart';
import 'summon_row.dart';

class StageLayers extends StatelessWidget {
  const StageLayers({
    super.key,
    required this.art,
    required this.time,
    required this.regionId,
    required this.floor,
    required this.summons,
    required this.data,
    required this.onBossFloor,
  });

  /// 배경 원화 경로. `null`이면 코드로 그린 배경을 쓴다
  final String? art;
  final double time;
  final int regionId;
  final int floor;

  /// 전장에 나와 있는 소환수. 아군은 마법사 옆, 적대는 적 옆에 선다
  final List<SummonUnit> summons;

  /// 지역의 보스를 찾는 데 쓴다
  final GameData data;

  /// 🔴 보스 층이면 음영을 **안 그린다** — 실물이 그 자리에 섰다
  final bool onBossFloor;

  /// 이 지역의 보스. 길 끝에 음영으로 세울 것이다
  Enemy? get _boss {
    final id = data.regions
        .where((r) => r.id == regionId)
        .map((r) => r.bossId)
        .firstOrNull;
    return id == null
        ? null
        : data.enemies.where((e) => e.id == id).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final drawn = StageBackdrop(
        palette: BackdropPalette.forFloor(floor), time: time);
    return Stack(
      children: [
        Positioned.fill(
          child: art == null
              ? drawn
              : ArtBackdropView(art!, fallback: drawn),
        ),
        Positioned.fill(child: LandmarkView(regionId: regionId)),
        Positioned.fill(
          child: BossShadowView(
              art: onBossFloor ? null : kArtEnemies[_boss?.id],
              eyes: _boss?.eyes),
        ),
        Positioned.fill(
          child: RoadsideLayer(regionId: regionId, floor: floor),
        ),
        SummonRow(summons: summons),
      ],
    );
  }
}
