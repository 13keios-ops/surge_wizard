/// 지역 카드의 겉모습을 **여기 한 곳에서만** 정한다.
///
/// 배경 원화 8종(`ASSET_LIST_BG.md`)이 아직 없어서 지금은 테마 색으로 칠한다.
/// 원화가 들어오면 [RegionLook]에 그림 경로를 하나 더 달고 이 파일의 표만
/// 고치면 된다 — 화면 코드는 손대지 않는다 (WORK_ORDER_SCREENS 2-A).
library;

import 'package:flutter/material.dart';

import '../models/region.dart';
import 'stage_backdrop.dart';

/// 지역 카드에 쓸 색 묶음
class RegionLook {
  const RegionLook({
    required this.top,
    required this.bottom,
    required this.accent,
  });

  /// 전투 배경 팔레트에서 그대로 뽑아 쓴다 — 지역 카드와 전투 화면의 색이
  /// 어긋나지 않게 하려는 것이다.
  RegionLook.fromPalette(BackdropPalette p, {required this.accent})
      : top = p.skyTop,
        bottom = p.skyBottom;

  /// 카드 위쪽 색 (먼 하늘)
  final Color top;

  /// 카드 아래쪽 색 (지평선)
  final Color bottom;

  /// 이름·테두리에 쓰는 강조색
  final Color accent;
}

/// 테마 4종 → 카드 색.
/// dungeon·tower·desert 는 전투 배경 팔레트를 그대로 쓰고,
/// forest 만 대응하는 배경 팔레트가 없어 여기서 정의한다.
final Map<String, RegionLook> _byTheme = {
  'forest': const RegionLook(
    top: Color(0xFF14301D),
    bottom: Color(0xFF4E9455),
    accent: Color(0xFF8FE09A),
  ),
  'dungeon':
      RegionLook.fromPalette(BackdropPalette.frost, accent: const Color(0xFF9FC0F5)),
  'tower':
      RegionLook.fromPalette(BackdropPalette.arcane, accent: const Color(0xFFCEA6FF)),
  'desert':
      RegionLook.fromPalette(BackdropPalette.ember, accent: const Color(0xFFFFC489)),
};

/// 잠긴 지역이 쓰는 **공통 회색조 한 벌**.
///
/// 테마 색 위에 검은 막을 덮는 방식은 못 쓴다. 테마마다 바탕 밝기가 너무 달라
/// (숲 vs 사막) 같은 농도를 덮어도 밝은 테마가 열린 카드보다 밝게 남는다.
/// 막의 농도를 올려도 안 풀린다 — 테마마다 필요한 농도가 다르기 때문이다
/// (검토 24 3-1절).
///
/// 잠긴 카드끼리 테마를 구분할 이유가 없다. 이 화면의 목적은
/// **「어디까지 열렸나」가 한눈에 읽히는 것**이다.
/// 배경 원화가 들어오면 이 자리에 **그림의 회색조 판**을 깔면 된다.
const RegionLook kLockedRegionLook = RegionLook(
  top: Color(0xFF101018),
  bottom: Color(0xFF2E2C3A),
  accent: Color(0xFF565370),
);

/// 지역의 카드 색. 모르는 테마면 무난한 기본값으로 떨어진다.
/// [locked] 면 테마를 아예 안 보고 [kLockedRegionLook] 을 준다.
RegionLook regionLook(Region region, {bool locked = false}) => locked
    ? kLockedRegionLook
    : (_byTheme[region.theme] ?? _byTheme['dungeon']!);

/// 테마 4종의 카드 색 (검산용 — 잠긴 회색조가 이들보다 어두운지 잰다)
Iterable<RegionLook> get allRegionLooks => _byTheme.values;
