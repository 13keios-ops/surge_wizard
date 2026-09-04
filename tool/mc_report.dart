/// PROGRESS.md 기록용 몬테카를로 리포트.
/// 10만 회 굴려 DC별 4단계 결과 비율을 출력한다 (족보 미적용, 순수 합계 기준).
// ignore_for_file: avoid_print — 콘솔 출력용 CLI 도구라 print가 맞다
library;

import 'dart:math';

import 'package:surge_wizard/core/check.dart';
import 'package:surge_wizard/core/constants.dart';

void main() {
  const trials = 100000;
  final random = Random(20260831);

  // 합계 분포
  final sumCounts = <int, int>{};
  final rolls = List.generate(trials, (_) {
    final s = random.nextInt(6) + random.nextInt(6) + random.nextInt(6) + 3;
    sumCounts.update(s, (v) => v + 1, ifAbsent: () => 1);
    return s;
  });

  print('== 3d6 합계 분포 (10만 회) ==');
  for (var s = 3; s <= 18; s++) {
    final pct = (sumCounts[s] ?? 0) / trials * 100;
    print('$s\t${pct.toStringAsFixed(2)}%');
  }

  print('\n== DC별 결과 비율 ==');
  for (final dc in [kDcLow, kDcNormal, kDcFull]) {
    final counts = <CheckGrade, int>{};
    for (final s in rolls) {
      counts.update(gradeForValue(s, dc), (v) => v + 1, ifAbsent: () => 1);
    }
    String pct(CheckGrade g) =>
        ((counts[g] ?? 0) / trials * 100).toStringAsFixed(1);
    print('DC $dc: 대성공 ${pct(CheckGrade.critSuccess)}% / '
        '성공 ${pct(CheckGrade.success)}% / '
        '아슬아슬 ${pct(CheckGrade.graze)}% / '
        '실패 ${pct(CheckGrade.failure)}%');
  }
}
