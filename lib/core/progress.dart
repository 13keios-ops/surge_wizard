/// 진행 잠금 규칙 (WORK_ORDER_SCREENS 1-B).
/// 「어디까지 깼는가」(MetaState.clearedStageKeys)만 보고 무엇이 열렸는지 답한다.
///
/// 규칙은 기획 창이 정했다 — 임의로 바꾸지 말 것:
///   1지역 Ⅰ 보통  → 처음부터 열림
///   다음 스테이지 → 같은 지역의 앞 스테이지를 **보통**으로 클리어
///   다음 지역    → 앞 지역의 **마지막(보스) 스테이지**를 보통으로 클리어
///   하드         → 그 스테이지를 **보통**으로 클리어
///   데스         → 그 스테이지를 **하드**로 클리어
///
/// Flutter 의존이 없어 단위 테스트에서 그대로 쓴다.
library;

import '../data/parser.dart';
import '../models/meta_state.dart';
import 'constants.dart';

/// 처음부터 열려 있는 지역 번호
const int kFirstRegionId = 1;

/// 처음부터 열려 있는 스테이지 순번
const int kFirstStageIndex = 1;

/// 게임 데이터 + 저장된 클리어 기록으로 잠금을 판정한다.
class Progress {
  const Progress(this.data, this.meta);

  final GameData data;
  final MetaState meta;

  /// 그 스테이지를 그 난이도로 깼는가
  bool isCleared(int regionId, int stageIndex, Difficulty difficulty) =>
      meta.hasCleared(regionId, stageIndex, difficulty);

  /// 지역의 마지막(보스) 스테이지 순번
  int bossStageIndexOf(int regionId) => data.region(regionId).stageCount;

  /// 지역 보스를 보통으로 깼는가 — 다음 지역이 열리는 조건이다
  bool _bossClearedNormal(int regionId) =>
      isCleared(regionId, bossStageIndexOf(regionId), Difficulty.normal);

  /// 지역이 열렸는가. 1지역은 처음부터, 그 뒤는 앞 지역 보스를 보통으로 깨야 한다.
  bool isRegionUnlocked(int regionId) =>
      regionId <= kFirstRegionId || _bossClearedNormal(regionId - 1);

  /// 스테이지가 열렸는가. 지역의 첫 스테이지는 지역 해금 조건과 같고,
  /// 그 뒤는 같은 지역의 앞 스테이지를 보통으로 깨야 한다.
  bool isStageUnlocked(int regionId, int stageIndex) =>
      stageIndex <= kFirstStageIndex
          ? isRegionUnlocked(regionId)
          : isCleared(regionId, stageIndex - 1, Difficulty.normal);

  /// 난이도가 열렸는가. **스테이지 단위**로 판정한다 (지역 단위가 아니다).
  bool isDifficultyUnlocked(
      int regionId, int stageIndex, Difficulty difficulty) {
    if (!isStageUnlocked(regionId, stageIndex)) return false;
    return switch (difficulty) {
      Difficulty.normal => true,
      Difficulty.hard => isCleared(regionId, stageIndex, Difficulty.normal),
      Difficulty.death => isCleared(regionId, stageIndex, Difficulty.hard),
    };
  }

  /// 지역 카드의 ★ 3개 — 그 지역의 **보스 스테이지**를 난이도별로 깼는가.
  /// 지역 전체가 아니라 보스 기준이다 (WORK_ORDER_SCREENS 1-B).
  List<bool> regionStars(int regionId) {
    final boss = bossStageIndexOf(regionId);
    return [
      for (final d in Difficulty.values) isCleared(regionId, boss, d),
    ];
  }

  /// 지역이 잠긴 이유 한 줄. 열려 있으면 null.
  String? regionLockReason(int regionId) => isRegionUnlocked(regionId)
      ? null
      : '${data.region(regionId - 1).name}의 보스를 보통으로 클리어';

  /// 스테이지가 잠긴 이유 한 줄. 열려 있으면 null.
  String? stageLockReason(int regionId, int stageIndex) {
    if (isStageUnlocked(regionId, stageIndex)) return null;
    if (stageIndex <= kFirstStageIndex) return regionLockReason(regionId);
    return '${kStageRomans[stageIndex - 2]} 스테이지를 보통으로 클리어';
  }

  /// 난이도 탭이 잠긴 이유 한 줄. 열려 있으면 null.
  String? difficultyLockReason(
      int regionId, int stageIndex, Difficulty difficulty) {
    if (isDifficultyUnlocked(regionId, stageIndex, difficulty)) return null;
    return switch (difficulty) {
      Difficulty.normal => stageLockReason(regionId, stageIndex),
      Difficulty.hard => '이 스테이지를 보통으로 클리어해야 열린다',
      Difficulty.death => '이 스테이지를 하드로 클리어해야 열린다',
    };
  }
}
