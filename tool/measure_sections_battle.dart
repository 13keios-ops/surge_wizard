/// 턴 수(2-B)·폭주 갈래(2-D)·자해 상한(2-E)·유물 영향(2-F) 표.
library;

import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/check.dart';

import 'measure_defs.dart';
import 'measure_mode.dart';
import 'measure_stats.dart';

List<String> sectionTurns(Map<SimMode, ModeResult> byMode) {
  final lines = <String>[
    '',
    '── 2-B. 전투당 턴 수 ──────────────────────────────',
    '  ⚠ 초로 환산하지 않는다. 턴당 몇 초인지는 사람이 플레이해야 안다.',
    '  ${pad('모드', 12)}${pad('일반 전투', 10)}${pad('평균턴', 10)}'
        '${pad('중앙값', 8)}${pad('최대', 6)}${pad('보스 전투', 10)}'
        '${pad('평균턴', 10)}${pad('중앙값', 8)}${pad('최대', 6)}',
  ];
  for (final mode in SimMode.values) {
    final t = byMode[mode]!.tally;
    lines.add('  ${pad(mode.label, 12)}'
        '${pad('${t.normalTurns.length}', 10)}${pad(fix(mean(t.normalTurns)), 10)}'
        '${pad('${median(t.normalTurns)}', 8)}${pad('${maxOf(t.normalTurns)}', 6)}'
        '${pad('${t.bossTurns.length}', 10)}${pad(fix(mean(t.bossTurns)), 10)}'
        '${pad('${median(t.bossTurns)}', 8)}${pad('${maxOf(t.bossTurns)}', 6)}');
  }
  final keys = histogram(<int>[], kTurnBuckets).keys.toList();
  lines
    ..add('')
    ..add('  턴 수 분포 (모드 C)')
    ..add('  ${pad('구분', 12)}${keys.map((k) => pad(k, 14)).join()}');
  final t = byMode[SimMode.full]!.tally;
  for (final entry in {'일반': t.normalTurns, '보스': t.bossTurns}.entries) {
    final h = histogram(entry.value, kTurnBuckets);
    final n = entry.value.length;
    lines.add('  ${pad(entry.key, 12)}'
        '${keys.map((k) => pad('${h[k]} (${pct(n == 0 ? 0 : h[k]! / n)}%)', 14)).join()}');
  }
  return lines;
}

List<String> sectionSurges(Map<SimMode, ModeResult> byMode) {
  final lines = <String>[
    '',
    '── 2-D. 폭주 6갈래 발생 비율 ──────────────────────',
    '  ${pad('갈래', 10)}${pad('목표', 8)}'
        '${SimMode.values.map((m) => pad(m.label, 16)).join()}'
        '${pad('C−목표', 10)}',
  ];
  final totals = {
    for (final m in SimMode.values)
      m: byMode[m]!.tally.surgeCategories.values.fold(0, (a, b) => a + b),
  };
  for (final key in kSurgeTargets.keys) {
    final cells = SimMode.values.map((m) {
      final n = byMode[m]!.tally.surgeCategories[key] ?? 0;
      final total = totals[m]!;
      return pad('$n (${pct(total == 0 ? 0 : n / total)}%)', 16);
    }).join();
    final cRatio = totals[SimMode.full]! == 0
        ? 0.0
        : (byMode[SimMode.full]!.tally.surgeCategories[key] ?? 0) /
            totals[SimMode.full]!;
    final diff = (cRatio - kSurgeTargets[key]!) * 100;
    lines.add('  ${pad(kSurgeNames[key]!, 10)}'
        '${pad('${pct(kSurgeTargets[key]!)}%', 8)}$cells'
        '${pad('${diff >= 0 ? '+' : ''}${fix(diff, 2)}%p', 10)}');
  }
  lines.add('  ${pad('합계', 10)}${pad('', 8)}'
      '${SimMode.values.map((m) => pad('${totals[m]}', 16)).join()}');
  final unknown = byMode[SimMode.full]!
      .tally
      .surgeCategories
      .keys
      .where((k) => !kSurgeTargets.containsKey(k))
      .toList();
  if (unknown.isNotEmpty) {
    lines.add('  ⚠ 6갈래에 없는 category: ${unknown.join(', ')}');
  }
  return lines;
}

List<String> sectionSelfDamage(Map<SimMode, ModeResult> byMode) {
  final lines = <String>[
    '',
    '── 2-E. 폭주 자해 상한이 무는 빈도 ────────────────',
    '  상한 = 최대 체력의 ${pct(0.4)}% (한 번의 폭주 전체 합계에 건다)',
    '  ${pad('모드', 12)}${pad('자해폭주', 10)}${pad('잘린수', 10)}'
        '${pad('잘린비율', 10)}${pad('raw합', 10)}${pad('applied합', 12)}'
        '${pad('raw평균', 10)}${pad('applied평균', 12)}${pad('잘린손실평균', 14)}',
  ];
  for (final mode in SimMode.values) {
    final t = byMode[mode]!.tally;
    final n = t.selfDamageSurges;
    lines.add('  ${pad(mode.label, 12)}${pad('$n', 10)}'
        '${pad('${t.selfDamageCapped}', 10)}'
        '${pad('${pct(n == 0 ? 0 : t.selfDamageCapped / n)}%', 10)}'
        '${pad('${t.selfDamageRawSum}', 10)}${pad('${t.selfDamageAppliedSum}', 12)}'
        '${pad(fix(n == 0 ? 0 : t.selfDamageRawSum / n), 10)}'
        '${pad(fix(n == 0 ? 0 : t.selfDamageAppliedSum / n), 12)}'
        '${pad(fix(t.selfDamageCapped == 0 ? 0 : t.selfDamageLostSum / t.selfDamageCapped), 14)}');
  }
  return lines;
}

List<String> sectionRelicEffect(Map<SimMode, ModeResult> byMode) {
  final lines = <String>[
    '',
    '── 2-F. 유물 판정 보정의 영향 (C − B, %p) ─────────',
    '  유물 40종 중 11종이 판정 보정이다 (전력 +N 6종 · 전체 +N 5종).',
    '  ${pad('', 18)}$gradeHeader',
  ];
  for (final it in CastIntensity.values) {
    final b = byMode[SimMode.rerollOnly]!.tally.pureGrades[it]!;
    final c = byMode[SimMode.full]!.tally.pureGrades[it]!;
    final bt = b.values.fold(0, (a, x) => a + x);
    final ct = c.values.fold(0, (a, x) => a + x);
    if (bt == 0 || ct == 0) continue;
    final cells = CheckGrade.values.map((g) {
      final d = (c[g]! / ct - b[g]! / bt) * 100;
      return pad('${d >= 0 ? '+' : ''}${fix(d, 2)}%p', 12);
    }).join();
    lines.add('  ${pad('${it.label} 시전', 18)}$cells');
  }
  return lines;
}

/// 참고 지표 — 모드마다 게임 난이도가 다르다는 것을 보여준다.
List<String> sectionContext(Map<SimMode, ModeResult> byMode) => [
      '',
      '── 참고: 모드별 완주율 (측정 조건 확인용) ─────────',
      '  ${pad('모드', 12)}${pad('완주율', 10)}${pad('평균도달층', 12)}',
      for (final mode in SimMode.values)
        '  ${pad(mode.label, 12)}${pad('${pct(byMode[mode]!.clearRate)}%', 10)}'
            '${pad(fix(byMode[mode]!.avgFloor), 12)}',
    ];
