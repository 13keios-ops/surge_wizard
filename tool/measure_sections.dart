/// 등급 분포(2-C)와 굴림 횟수(2-A·2-A2) 표.
library;

import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/check.dart';

import 'measure_defs.dart';
import 'measure_mode.dart';
import 'measure_stats.dart';

List<String> sectionGrades(Map<SimMode, ModeResult> byMode) {
  final lines = <String>[
    '',
    '── 2-C. 등급 분포 ─────────────────────────────────',
    '  「원래 판정」만 세고, 마력 축적으로 확정된 대성공은 뺐다.',
    '  (폭주 force_reroll 의 재적용분도 뺐다 — 새로 굴린 판정이 아니다)',
    '  ★ 「A 보정0」은 3.4절 표와 **완전히 같은 조건**만 남긴 것이다:',
    '    주문 DC 보정 0 · 주문 판정보너스 없음 · 주사위 추가 없음 · 유물 없음.',
    '  ★ 「엔진 전수계산」은 resolveCheck 로 3d6 216가지를 전부 돌린 값이다.',
    '    「A 보정0」이 이 줄과 맞으면 측정 코드가 옳다.',
  ];
  for (final it in CastIntensity.values) {
    lines
      ..add('')
      ..add('  [${it.label} 시전]')
      ..add('  ${pad('', 18)}$gradeHeader')
      ..add(gradeRow('3.4절 표', kDesignTable[it]!))
      ..add(gradeRow('엔진 전수계산', exactDistribution(it)));
    final strict = byMode[SimMode.pure]!.tally.unmodifiedGrades[it]!;
    final strictTotal = strict.values.fold(0, (a, b) => a + b);
    if (strictTotal > 0) {
      lines.add(gradeRow('★ A 보정0 (n=$strictTotal)',
          CheckGrade.values.map((g) => strict[g]! / strictTotal).toList()));
    }
    for (final mode in SimMode.values) {
      final counts = byMode[mode]!.tally.pureGrades[it]!;
      final total = counts.values.fold(0, (a, b) => a + b);
      if (total == 0) {
        lines.add('  ${pad(mode.label, 18)}(표본 없음)');
        continue;
      }
      lines.add(gradeRow('${mode.label} (n=$total)',
          CheckGrade.values.map((g) => counts[g]! / total).toList()));
    }
  }
  lines
    ..add('')
    ..add('  봇이 고른 주문의 DC 보정 분포 (보정이 붙은 주문일수록 실패가 는다)');
  for (final mode in SimMode.values) {
    final counts = byMode[mode]!.tally.dcModifierCasts;
    final total = counts.values.fold(0, (a, b) => a + b);
    final keys = counts.keys.toList()..sort();
    lines.add('  ${pad(mode.label, 12)}'
        '${keys.map((k) => pad('+$k: ${pct(counts[k]! / total)}%', 14)).join()}');
  }
  lines.add('');
  for (final mode in SimMode.values) {
    final t = byMode[mode]!.tally;
    final primary = CastIntensity.values
        .map((it) => t.primaryGrades[it]!.values.fold(0, (a, b) => a + b))
        .fold(0, (a, b) => a + b);
    lines.add('  ${pad(mode.label, 12)}'
        '확정 대성공(마력 축적) ${t.chargeForcedCasts}회 / 판정 $primary회 '
        '= ${pct(primary == 0 ? 0 : t.chargeForcedCasts / primary)}%, '
        'force_reroll 재적용 ${t.forcedRerollApplies}회');
  }
  return lines;
}

List<String> sectionRolls(Map<SimMode, ModeResult> byMode) {
  final lines = <String>[
    '',
    '── 2-A. 굴림 횟수 ─────────────────────────────────',
    '  굴림 1회 = 주사위를 실제로 던진 1회 (초기 굴림 + 리롤 각각)',
    '  ${pad('모드', 12)}${pad('전투', 8)}${pad('전투당굴림', 12)}'
        '${pad('전투당판정', 12)}${pad('판정당리롤', 12)}${pad('그중유료', 10)}',
  ];
  for (final mode in SimMode.values) {
    final t = byMode[mode]!.tally;
    final b = t.battles;
    final c = t.checks;
    lines.add('  ${pad(mode.label, 12)}${pad('$b', 8)}'
        '${pad(fix(t.rolls / b), 12)}${pad(fix(c / b), 12)}'
        '${pad(fix(c == 0 ? 0 : t.rerolls / c), 12)}'
        '${pad(fix(c == 0 ? 0 : t.paidRerolls / c), 10)}');
  }
  lines
    ..add('')
    ..add('  전투당 굴림 횟수 분포');
  final keys = histogram(<int>[], kRollBuckets).keys.toList();
  lines.add('  ${pad('모드', 12)}${keys.map((k) => pad(k, 12)).join()}'
      '${pad('중앙값', 8)}${pad('최대', 6)}');
  for (final mode in SimMode.values) {
    final v = byMode[mode]!.tally.rollsPerBattle;
    final h = histogram(v, kRollBuckets);
    final cells = keys
        .map((k) => pad('${h[k]} (${pct(h[k]! / v.length)}%)', 12))
        .join();
    lines.add('  ${pad(mode.label, 12)}$cells'
        '${pad('${median(v)}', 8)}${pad('${maxOf(v)}', 6)}');
  }
  return lines;
}

List<String> sectionEngravings(Map<SimMode, ModeResult> byMode) {
  final rolls = countByValue(byMode[SimMode.full]!.tally.rollsPerBattle);
  final avg = mean(byMode[SimMode.full]!.tally.rollsPerBattle);
  return [
    '',
    '── 2-A2. 각인 기대 적립 재계산 ────────────────────',
    '  ENGRAVINGS.md 4절은 「전투당 $kDocRollsPerBattle굴림」을 가정했다.',
    '  실측(모드 C)은 전투당 ${fix(avg)}굴림이다. 아래는 실측 분포를 그대로',
    '  이항분포의 시행 수로 넣어 E[min(X, 상한)] 을 다시 계산한 것이다.',
    '  ${pad('조건 유형', 20)}${pad('1굴림확률', 12)}${pad('상한', 6)}'
        '${pad('9굴림계산', 12)}${pad('9굴림문서', 12)}${pad('실측기대적립', 14)}'
        '${pad('전설보너스', 12)}${pad('문서보너스', 12)}',
    for (final k in kEngravingKinds)
      '  ${pad(k.label, 20)}${pad(fix(k.p, 3), 12)}${pad('${k.cap}회', 6)}'
          '${pad('${fix(expectedCapped(kDocRollsPerBattle, k.p, k.cap))}회', 12)}'
          '${pad('${fix(k.docE, 1)}회', 12)}'
          '${pad('${fix(expectedCappedMixed(rolls, k.p, k.cap))}회', 14)}'
          '${pad('${pct(expectedCappedMixed(rolls, k.p, k.cap) * k.legendary)}%', 12)}'
          '${pad('${pct(k.docBonus)}%', 12)}',
  ];
}
