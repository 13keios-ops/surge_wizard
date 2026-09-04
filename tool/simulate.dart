/// 밸런스 시뮬레이터: 무강화 상태로 스테이지 한 판을 1000회 자동 플레이.
/// 진입 지점은 sim_core.dart 의 「지역 1 · 스테이지 1 · 보통」 고정이다.
/// 실행: dart run tool/simulate.dart
/// 봇 정책·공용 로직은 sim_core.dart, 결과 해석은 BALANCE.md 참조.
// ignore_for_file: avoid_print — 콘솔 출력용 CLI 도구라 print가 맞다
library;

import 'dart:math';

import 'package:surge_wizard/core/battle.dart';

import 'sim_core.dart';

/// 시뮬레이션 판 수
const int kRuns = 1000;

void main() {
  final data = loadGameData();
  final random = Random(20260831);
  final results = <RunResult>[];
  final deathsPerFloor = <int, int>{};
  final tally = Tally();

  for (var run = 0; run < kRuns; run++) {
    final result = playRun(data, random, tally);
    results.add(result);
    if (!result.cleared) {
      deathsPerFloor.update(result.reachedFloor, (v) => v + 1,
          ifAbsent: () => 1);
    }
  }
  _printReport(results, deathsPerFloor, tally, simStage(data).floors);
}

void _printReport(
    List<RunResult> results, Map<int, int> deaths, Tally t, int floors) {
  final cleared = results.where((r) => r.cleared).length;
  final avgFloor =
      results.fold(0, (a, r) => a + min(r.reachedFloor, floors)) /
          results.length;

  print('== 밸런스 시뮬레이션 ($kRuns판, 리롤 봇 + 유물 전체 반영, 무강화) ==');
  print('스테이지: $floors층');
  print('완주율: ${(cleared / results.length * 100).toStringAsFixed(1)}%');
  print('평균 도달 층수: ${avgFloor.toStringAsFixed(2)}');
  print('');
  print('층별 사망 수 (사망률%):');
  for (var f = 1; f <= floors; f++) {
    final d = deaths[f] ?? 0;
    final reached = results.where((r) => r.reachedFloor >= f).length;
    final rate = reached == 0 ? 0 : d / reached * 100;
    print('$f층\t$d명\t(도달 $reached판 중 ${rate.toStringAsFixed(1)}%)');
  }
  print('');
  print('판정 결과 분포 (시전 ${t.casts}회, 재굴림 포함 판정 ${t.resolutions}회):');
  String pct(int n) => (n / t.resolutions * 100).toStringAsFixed(1);
  print('대성공 ${pct(t.crit)}% / 성공 ${pct(t.success)}% / '
      '아슬아슬 ${pct(t.graze)}% / 실패 ${pct(t.fail)}%');
  print('폭주 발생: ${t.surge}회 '
      '(시전의 ${(t.surge / t.casts * 100).toStringAsFixed(1)}%)');
  print('');
  print('시전 강도 사용 비율 (총 ${t.intensityTotal}회):');
  for (final it in CastIntensity.values) {
    final n = t.intensityCasts[it]!;
    print('${it.label}	$n회	'
        '(${(n / t.intensityTotal * 100).toStringAsFixed(1)}%)');
  }
}
