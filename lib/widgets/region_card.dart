import 'package:flutter/material.dart';

import '../art/region_art.dart';
import '../models/region.dart';
import 'pixel_ui.dart';
import 'screen_header.dart';

/// 지역 선택 화면의 카드 1장 (UI_DESIGN 5-2).
/// 번호 · 이름 · 권장 레벨 · ★ 3개를 담고, 잠겼으면 어둡게 + 조건 한 줄.
class RegionCard extends StatelessWidget {
  const RegionCard({
    super.key,
    required this.region,
    required this.levelRange,
    required this.stars,
    required this.lockReason,
    required this.onTap,
  });

  final Region region;

  /// 그 지역 스테이지들의 권장 레벨 (최솟값, 최댓값)
  final (int, int) levelRange;

  /// 난이도 3개의 보스 클리어 여부
  final List<bool> stars;

  /// 잠긴 이유 한 줄. 열려 있으면 null
  final String? lockReason;

  final VoidCallback onTap;

  bool get _locked => lockReason != null;

  /// 배경 원화가 들어오면 region_art.dart 의 색 대신 그림이 깔린다
  BoxDecoration _decoration(RegionLook look) => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [look.top, look.bottom],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: look.accent, width: 2),
      );

  @override
  Widget build(BuildContext context) {
    // 잠긴 카드는 테마 색을 아예 안 쓰고 공통 회색조를 받는다.
    // 검은 막을 덮던 옛 방식은 밝은 테마(사막)가 열린 카드보다 밝게 남았다
    // (WORK_ORDER_SCREENS2 작업 1).
    final look = regionLook(region, locked: _locked);
    return GestureDetector(
      onTap: _locked ? null : onTap,
      child: Container(
        height: 88,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: _decoration(look),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Text('${region.id}',
                style: TextStyle(
                    fontFamily: kFont9,
                    fontSize: 30,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    // 글씨도 함께 눌러야 잠긴 카드가 통째로 가라앉아 보인다
                    color: _locked ? kTextDim : Colors.white,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 4)])),
            const SizedBox(width: 12),
            Expanded(
                child: _Body(
                    region: region,
                    levelRange: levelRange,
                    lockReason: lockReason)),
            if (!_locked) ClearStars(stars: stars, size: 20),
          ],
        ),
      ),
    );
  }
}

/// 카드 가운데 — 이름 + (열렸으면 권장 레벨 / 잠겼으면 해금 조건 한 줄)
class _Body extends StatelessWidget {
  const _Body({
    required this.region,
    required this.levelRange,
    required this.lockReason,
  });

  final Region region;
  final (int, int) levelRange;
  final String? lockReason;

  @override
  Widget build(BuildContext context) {
    final locked = lockReason != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(region.name,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.1,
                color: locked ? kTextDim : Colors.white,
                shadows: const [Shadow(color: Colors.black, blurRadius: 4)]),
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(
            locked ? '잠김 · $lockReason' : '권장 Lv ${levelRange.$1}~${levelRange.$2}',
            style: TextStyle(
                fontFamily: kFont9,
                fontSize: 10,
                color: locked ? kGold : Colors.white,
                shadows: const [Shadow(color: Colors.black, blurRadius: 3)]),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
