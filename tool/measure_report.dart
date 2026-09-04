/// 측정 결과를 사람이 읽을 줄 목록으로 조립한다.
/// 절별 표는 measure_sections.dart 가 만든다.
library;

import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/check.dart';

import 'measure_mode.dart';
import 'measure_sections.dart';
import 'measure_sections_battle.dart';
import 'measure_stats.dart';
import 'sim_tally.dart';

export 'measure_mode.dart';

/// 시드 하나의 전체 보고
List<String> reportSeed(int seed, Map<SimMode, ModeResult> byMode) => [
      '',
      '',
      '════════════════════════════════════════════════════',
      ' 시드 $seed',
      '════════════════════════════════════════════════════',
      ...sectionContext(byMode),
      ...sectionGrades(byMode),
      ...sectionRolls(byMode),
      ...sectionEngravings(byMode),
      ...sectionTurns(byMode),
      ...sectionSurges(byMode),
      ...sectionSelfDamage(byMode),
      ...sectionRelicEffect(byMode),
    ];

/// 시드끼리 값이 얼마나 흔들리는지 (표본이 충분한지 확인하는 절차다)
List<String> reportSeedComparison(
    Map<int, Map<SimMode, ModeResult>> bySeed) {
  final seeds = bySeed.keys.toList();
  final lines = <String>[
    '',
    '',
    '════════════════════════════════════════════════════',
    ' 시드 비교 — 값이 시드에 따라 흔들리는가',
    '════════════════════════════════════════════════════',
    '  ${pad('지표', 34)}${seeds.map((s) => pad('$s', 14)).join()}${pad('차이', 12)}',
  ];
  for (final entry in _metrics().entries) {
    final values = seeds.map((s) => entry.value(bySeed[s]!)).toList();
    final diff = values.reduce((a, b) => (a - b).abs());
    lines.add('  ${pad(entry.key, 34)}'
        '${values.map((v) => pad(fix(v, 3), 14)).join()}'
        '${pad(fix(diff, 3), 12)}');
  }
  return lines;
}

/// 시드 비교에 쓸 대표 지표들
Map<String, double Function(Map<SimMode, ModeResult>)> _metrics() {
  double gradeRatio(Map<SimMode, ModeResult> m, SimMode mode, CastIntensity it,
      CheckGrade g) {
    final counts = m[mode]!.tally.pureGrades[it]!;
    final total = counts.values.fold(0, (a, b) => a + b);
    return total == 0 ? 0 : counts[g]! / total * 100;
  }

  return {
    'A 보통 대성공 %': (m) =>
        gradeRatio(m, SimMode.pure, CastIntensity.normal, CheckGrade.critSuccess),
    'A 보통 실패 %': (m) =>
        gradeRatio(m, SimMode.pure, CastIntensity.normal, CheckGrade.failure),
    'A 전력 대성공 %': (m) =>
        gradeRatio(m, SimMode.pure, CastIntensity.full, CheckGrade.critSuccess),
    'A 전력 실패 %': (m) =>
        gradeRatio(m, SimMode.pure, CastIntensity.full, CheckGrade.failure),
    'C 전투당 굴림': (m) => mean(m[SimMode.full]!.tally.rollsPerBattle),
    'C 전투당 판정': (m) =>
        m[SimMode.full]!.tally.checks / m[SimMode.full]!.tally.battles,
    'C 일반 전투 평균 턴': (m) => mean(m[SimMode.full]!.tally.normalTurns),
    'C 보스 전투 평균 턴': (m) => mean(m[SimMode.full]!.tally.bossTurns),
    'C 역류 갈래 %': (m) => _surgeRatio(m[SimMode.full]!.tally, 'backlash'),
    'C 연쇄 갈래 %': (m) => _surgeRatio(m[SimMode.full]!.tally, 'chain'),
    'C 자해 상한에 잘린 %': (m) {
      final t = m[SimMode.full]!.tally;
      return t.selfDamageSurges == 0
          ? 0
          : t.selfDamageCapped / t.selfDamageSurges * 100;
    },
    'C 완주율 %': (m) => m[SimMode.full]!.clearRate * 100,
  };
}

double _surgeRatio(Tally t, String category) {
  final total = t.surgeCategories.values.fold(0, (a, b) => a + b);
  return total == 0 ? 0 : (t.surgeCategories[category] ?? 0) / total * 100;
}
