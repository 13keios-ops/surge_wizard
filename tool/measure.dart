/// 시뮬레이션 「측정」 도구 — 설계 문서들이 세운 전제를 실제로 재 본다.
/// 실행: dart run tool/measure.dart
///
/// ⚠ 이 도구는 아무것도 조정하지 않는다. 상수·데이터·확률표를 읽기만 한다.
/// 기존 지표(완주율·층별 사망)는 simulate.dart 가 계속 담당하며 이 파일은
/// 그것을 건드리지 않는다.
///
/// 재는 것 (WORK_ORDER_SIM.md 2-A ~ 2-F):
///   2-A 전투당 굴림 횟수 + 각인 기대 적립 재계산
///   2-B 전투당 턴 수 (일반/보스)
///   2-C 등급 분포 3모드 (순수 / 리롤만 / 전체)
///   2-D 폭주 6갈래 실제 발생 비율
///   2-E 폭주 자해 상한이 무는 빈도
///   2-F 유물 판정 보정의 영향 (B와 C의 차이)
// ignore_for_file: avoid_print — 콘솔 출력용 CLI 도구라 print가 맞다
library;

import 'dart:io';
import 'dart:math';

import 'package:surge_wizard/data/parser.dart';

import 'measure_report.dart';
import 'sim_core.dart';

/// 모드마다 돌리는 판 수. simulate.dart 와 같게 두어 비교 가능하게 한다.
const int kMeasureRuns = 1000;

/// 시드 2개. 첫 번째는 기존 시뮬과 같은 값이라 기준선과 대조할 수 있고,
/// 두 번째는 「시드를 바꿔도 값이 흔들리지 않는지」 확인용이다.
const List<int> kMeasureSeeds = [20260831, 20260902];

/// 결과를 남길 파일
const String kOutputPath = 'reports/data/measure_output.txt';

void main() {
  final data = loadGameData();
  final buffer = StringBuffer();
  void emit(String line) {
    print(line);
    buffer.writeln(line);
  }

  emit('== 시뮬레이션 측정 ==');
  emit('판 수: $kMeasureRuns판 × 모드 ${SimMode.values.length}개 × '
      '시드 ${kMeasureSeeds.length}개');
  emit('※ 측정 전용. 밸런스 수치를 하나도 바꾸지 않았다.');

  final bySeed = <int, Map<SimMode, ModeResult>>{};
  for (final seed in kMeasureSeeds) {
    final perMode = <SimMode, ModeResult>{};
    for (final mode in SimMode.values) {
      perMode[mode] = _runMode(data, mode, seed);
    }
    bySeed[seed] = perMode;
    for (final line in reportSeed(seed, perMode)) {
      emit(line);
    }
  }
  for (final line in reportSeedComparison(bySeed)) {
    emit(line);
  }

  final out = File(kOutputPath);
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  print('');
  print('결과를 $kOutputPath 에 저장했다.');
}

/// 한 모드를 [kMeasureRuns] 판 돌린다.
ModeResult _runMode(GameData data, SimMode mode, int seed) {
  final random = Random(seed);
  final tally = Tally();
  var cleared = 0;
  var floorSum = 0;
  for (var run = 0; run < kMeasureRuns; run++) {
    final result = playRun(data, random, tally,
        useRerolls: mode.useRerolls, useRelics: mode.useRelics);
    if (result.cleared) cleared++;
    floorSum += min(result.reachedFloor, result.totalFloors);
  }
  return ModeResult(
    mode: mode,
    tally: tally,
    clearRate: cleared / kMeasureRuns,
    avgFloor: floorSum / kMeasureRuns,
  );
}
