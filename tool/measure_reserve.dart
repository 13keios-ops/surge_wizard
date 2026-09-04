/// 봇 성향 비교 — 「보통 위주」로 치면 전투가 얼마나 길어지는가
/// (WORK_ORDER_SCALE_FIX 작업 3-A · 검토 14의 7-5).
///
/// 실행: dart run tool/measure_reserve.dart
///
/// ⚠ **밸런스 수치를 하나도 바꾸지 않는다.** 이 도구는 `sim_core.dart` 의
/// `kBotFullManaReserve` 를 **읽기만** 한다. 값을 0 과 1 로 바꿔 두 번 돌린 뒤
/// 두 출력을 나란히 놓는 것은 사람이 한다 (상수는 컴파일 시점에 박히므로
/// 한 번의 실행으로 두 성향을 동시에 잴 수 없다).
///
/// 재는 것은 `measure_stage.dart` 의 부분집합이다 — **대표 4지역(1·5·9·12)**
/// 만 돌고, 완주율·도달 층·턴·굴림만 낸다. 조건(판 수·시드·프로필·손패)은
/// 본 측정과 똑같이 맞췄으므로 값을 그대로 비교할 수 있다.
// ignore_for_file: avoid_print — 콘솔 출력용 CLI 도구라 print가 맞다
library;

import 'dart:math';

import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/data/parser.dart';

import 'measure_profile.dart';
import 'measure_stage_run.dart';
import 'measure_stats.dart';
import 'sim_core.dart';

/// 비교에 쓸 대표 지역 — 도입·중반·후반·최종
const List<int> kSampleRegionIds = [1, 5, 9, 12];

/// 본 측정과 같은 판 수·시드를 쓴다 (달라지면 비교가 안 된다)
const int kRunsPerCombo = 300;
const List<int> kSeeds = [20260831, 20260902];

void main() {
  final data = loadGameData();
  final circles = loadSpellCircles();
  final byPrefix = variantByPrefix(data);

  print('== 봇 성향 비교 — 전력 여유 마나(kBotFullManaReserve) = '
      '$kBotFullManaReserve ==');
  print('대표 지역 ${kSampleRegionIds.join("·")} × 난이도 3 × '
      '$kRunsPerCombo판 × 시드 ${kSeeds.length}개');
  print('0 = 낼 수 있으면 무조건 전력 / 1 = 여유가 있어야 전력(보통 위주)');
  print('');
  print('  ${pad('지역', 18)}${pad('난이도', 8)}${pad('완주율', 10)}'
      '${pad('평균도달층', 12)}${pad('일반턴', 10)}${pad('보스턴', 10)}'
      '${pad('전투당굴림', 12)}');

  for (final id in kSampleRegionIds) {
    for (final difficulty in Difficulty.values) {
      print(_line(data, circles, byPrefix, id, difficulty));
    }
  }
}

/// 지역 × 난이도 한 줄. 시드 2개를 합산해 한 줄로 낸다.
String _line(
  GameData data,
  Map<String, int> circles,
  Map<String, String> byPrefix,
  int regionId,
  Difficulty difficulty,
) {
  final region = data.region(regionId);
  final stage = data.stage(regionId, region.stageCount);
  final profile = profileOf(regionId);
  final combo = ComboResult(
    region: region,
    stage: stage,
    difficulty: difficulty,
    profile: profile,
    deck: profileDeck(data.spells, circles, regionId),
  );
  for (final seed in kSeeds) {
    // 본 측정과 같은 씨앗 식이라 같은 판을 돈다
    final random = Random(seed + regionId * 13 + difficulty.index * 1009);
    for (var run = 0; run < kRunsPerCombo; run++) {
      playStageRun(data, combo, byPrefix, random);
    }
  }
  final rolls = combo.tally.battles == 0
      ? 0.0
      : combo.tally.rolls / combo.tally.battles;
  return '  ${pad('$regionId ${region.name}', 18)}'
      '${pad(_difficultyName(difficulty), 8)}'
      '${pad('${pct(combo.clearRate)}%', 10)}'
      '${pad('${fix(combo.avgFloor, 1)}/${stage.floors}', 12)}'
      '${pad(fix(mean(combo.tally.normalTurns)), 10)}'
      '${pad(fix(mean(combo.tally.bossTurns)), 10)}'
      '${pad(fix(rolls), 12)}';
}

String _difficultyName(Difficulty d) => switch (d) {
      Difficulty.normal => '보통',
      Difficulty.hard => '하드',
      Difficulty.death => '데스',
    };
