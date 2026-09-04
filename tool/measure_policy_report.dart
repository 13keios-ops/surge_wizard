/// 두 봇 정책을 나란히 놓는 비교표 (WORK_ORDER_DECK_FIX 작업 4).
///
/// ⚠ 절 이름을 4-A~4-E 에서 **P-A~P-E** 로 바꿨다. 이번 측정(작업 4-A~4-D)이
/// 같은 번호를 쓰기 때문이다. 표의 내용과 셈법은 측정 17과 똑같다.
///
/// 한 번의 실행에서 greedy·utility 를 모두 돌리므로, 「덱 순서 수정의 효과」와
/// 「봇 정책의 효과」를 갈라 읽을 수 있다.
///   greedy 가 측정 16보다 좋아졌다면  → 덱 채우는 순서를 고친 효과
///   utility 가 greedy 보다 좋아졌다면 → 봇 정책의 효과
library;

import 'package:surge_wizard/core/constants.dart';

import 'measure_deck_report.dart';
import 'measure_profile.dart';
import 'measure_stage_report.dart';
import 'measure_stage_run.dart';
import 'measure_stats.dart';
import 'sim_core.dart';

/// 정책 → 조합표
typedef PolicyTables = Map<BotPolicy, ComboTable>;

/// 과거 측정의 **보통 난이도 완주율** (시드 20260831).
/// `reports/data/measure3_output.txt`(측정 15)와 `measure4_output.txt`(측정 16)의
/// 3-C 표에서 그대로 옮긴 값이다. **비교 기준일 뿐 이 도구가 쓰는 수치가 아니다.**
const Map<int, double> kClearRate15 = {
  1: 98.0, 2: 98.3, 3: 42.3, 4: 46.3, 5: 10.0, 6: 5.0,
  7: 0.0, 8: 0.0, 9: 0.0, 10: 13.3, 11: 8.3, 12: 0.0,
};
const Map<int, double> kClearRate16 = {
  1: 70.3, 2: 61.0, 3: 68.3, 4: 30.0, 5: 8.3, 6: 3.0,
  7: 0.0, 8: 0.0, 9: 0.0, 10: 0.0, 11: 0.0, 12: 0.0,
};

/// P-A. 완주율 3단 비교 (측정 17의 4-A). 이번 측정의 결론은 4-A 쪽이다.
List<String> sectionPolicyClearRate(PolicyTables tables) {
  final lines = <String>[
    '',
    '── P-A. 완주율 3단 비교 (보통 난이도) ────────────',
    '  측정 15 = 고정 손패 / 측정 16 = 덱(채우는 순서가 틀렸다).',
    '  ⚠ 이 표는 **강화 수준 하나 안에서만** 비교한다 (15·16은 강화가 없었다).',
    '  greedy 열이 측정 16보다 좋아졌으면 **덱 순서 수정**의 효과,',
    '  utility 열이 greedy 보다 좋아졌으면 **봇 정책**의 효과다.',
    '  ${pad('지역', 20)}${pad('측정15', 10)}${pad('측정16', 10)}'
        '${pad('greedy', 10)}${pad('utility', 10)}'
        '${pad('덱순서효과', 12)}${pad('정책효과', 12)}',
  ];
  for (final id in kRegionIds) {
    final g = _clear(tables[BotPolicy.greedy]!, id, Difficulty.normal);
    final u = _clear(tables[BotPolicy.utility]!, id, Difficulty.normal);
    final name = tables[BotPolicy.utility]![id]![Difficulty.normal]!.region.name;
    lines.add('  ${pad('$id $name', 20)}'
        '${pad('${fix(kClearRate15[id]!, 1)}%', 10)}'
        '${pad('${fix(kClearRate16[id]!, 1)}%', 10)}'
        '${pad('${fix(g, 1)}%', 10)}${pad('${fix(u, 1)}%', 10)}'
        '${pad(_delta(g - kClearRate16[id]!), 12)}'
        '${pad(_delta(u - g), 12)}');
  }
  return [...lines, ..._clearRateByDifficulty(tables)];
}

/// 하드·데스도 두 정책을 나란히 (측정 15·16과 같은 조건이라 비교된다)
List<String> _clearRateByDifficulty(PolicyTables tables) {
  final lines = <String>[
    '',
    '── P-A2. 난이도별 완주율 (greedy → utility) ──────',
    '  ${pad('지역', 20)}'
        '${Difficulty.values.map((d) => pad(kDifficultyLabels[d]!, 22)).join()}',
  ];
  for (final id in kRegionIds) {
    final name = tables[BotPolicy.utility]![id]![Difficulty.normal]!.region.name;
    lines.add('  ${pad('$id $name', 20)}${Difficulty.values.map((d) {
      final g = _clear(tables[BotPolicy.greedy]!, id, d);
      final u = _clear(tables[BotPolicy.utility]!, id, d);
      return pad('${fix(g, 1)}% → ${fix(u, 1)}%', 22);
    }).join()}');
  }
  return lines;
}

/// P-B. 손패에 무엇이 잡히고 무엇을 썼나 — 두 정책을 나란히
List<String> sectionPolicyCastMix(PolicyTables tables) {
  final lines = <String>[
    '',
    '── P-B. 덱에 든 유틸을 실제로 쓰는가 ─────────────',
    '  측정 16의 시전 유틸 비율은 4~9지역에서 1.6~10%였다.',
    '  ${pad('지역', 20)}${pad('덱크기', 8)}${pad('덱유틸%', 10)}'
        '${pad('시전유틸% greedy', 18)}${pad('utility', 12)}'
        '${pad('회복시전% g/u', 18)}${pad('평균위력 g/u', 16)}',
  ];
  for (final id in kRegionIds) {
    final rowG = tables[BotPolicy.greedy]![id]!;
    final rowU = tables[BotPolicy.utility]![id]!;
    final combo = rowU[Difficulty.normal]!;
    final deck = combo.deck;
    final deckUtil = deck.where(isUtilitySpell).length;
    final g = castMixOf(rowG);
    final u = castMixOf(rowU);
    lines.add('  ${pad('$id ${combo.region.name}', 20)}'
        '${pad('${deck.length}', 8)}'
        '${pad('${pct(deckUtil / deck.length)}%', 10)}'
        '${pad('${pct(g.utilityRate)}%', 18)}'
        '${pad('${pct(u.utilityRate)}%', 12)}'
        '${pad('${pct(g.healRate)}% / ${pct(u.healRate)}%', 18)}'
        '${pad('${fix(g.avgPower)} / ${fix(u.avgPower)}', 16)}');
  }
  return lines;
}

/// P-D. 전투당 턴 수 (일반 / 보스) — 교착이 사라졌는지가 여기서 보인다
List<String> sectionPolicyTurns(PolicyTables tables) {
  final lines = <String>[
    '',
    '── P-D. 전투당 턴 수 (36조합 합산) ───────────────',
    '  측정 16의 보스 9.34턴은 1·2지역 교착이 끌어올린 값이었다.',
    '  ${pad('정책', 20)}${pad('일반 전투', 10)}${pad('평균턴', 10)}'
        '${pad('중앙값', 8)}${pad('보스 전투', 10)}${pad('평균턴', 10)}'
        '${pad('중앙값', 8)}${pad('보스만(보조)', 14)}',
  ];
  for (final policy in BotPolicy.values) {
    final all = _allCombos(tables[policy]!);
    final n = <int>[for (final c in all) ...c.tally.normalTurns];
    final b = <int>[for (final c in all) ...c.tally.bossTurns];
    final only = <int>[for (final c in all) ...c.bossOnly.bossTurns];
    lines.add('  ${pad(policy.label, 20)}${pad('${n.length}', 10)}'
        '${pad(fix(mean(n)), 10)}${pad('${median(n)}', 8)}'
        '${pad('${b.length}', 10)}${pad(fix(mean(b)), 10)}'
        '${pad('${median(b)}', 8)}${pad(fix(mean(only)), 14)}');
  }
  return lines;
}

/// P-E. 200턴 안전장치에 걸린 전투 수 — **0이어야 한다**
List<String> sectionPolicyTurnLimit(PolicyTables tables) {
  final lines = <String>[
    '',
    '── P-E. 200턴 안전장치에 걸린 전투 ───────────────',
    '  0이 아니면 「적을 깎을 주문이 없어 교착했다」는 뜻이다 (작업 2 미완).',
    '  본 측정 + 보스만 측정을 모두 센다.',
    '  ${pad('정책', 20)}${pad('전투 수', 12)}${pad('안전장치', 12)}'
        '${pad('최장 전투(턴)', 16)}',
  ];
  for (final policy in BotPolicy.values) {
    final all = _allCombos(tables[policy]!);
    var battles = 0;
    var hits = 0;
    var longest = 0;
    for (final c in all) {
      for (final t in [c.tally, c.bossOnly]) {
        battles += t.battles;
        hits += t.turnLimitBattles;
        longest = [longest, maxOf(t.normalTurns), maxOf(t.bossTurns)]
            .reduce((a, b) => a > b ? a : b);
      }
    }
    lines.add('  ${pad(policy.label, 20)}${pad('$battles', 12)}'
        '${pad('$hits', 12)}${pad('$longest', 16)}');
  }
  return lines;
}

/// P-C. 전투당 굴림 — 각인 기대 적립의 시행 수가 되는 값
List<String> sectionPolicyRolls(PolicyTables tables) {
  final lines = <String>[
    '',
    '── P-C. 전투당 굴림 (36조합 합산) ────────────────',
    '  측정 12 = 2.40 / 14 = 4.40 / 15 = 5.49 / 16 = 6.66 이었다.',
    '  ${pad('정책', 20)}${pad('전투', 10)}${pad('전투당굴림', 12)}'
        '${pad('전투당판정', 12)}${pad('판정당리롤', 12)}${pad('그중유료', 10)}',
  ];
  for (final policy in BotPolicy.values) {
    final all = _allCombos(tables[policy]!);
    final b = all.fold(0, (a, c) => a + c.tally.battles);
    final checks = all.fold(0, (a, c) => a + c.tally.checks);
    final rolls = all.fold(0, (a, c) => a + c.tally.rolls);
    final rerolls = all.fold(0, (a, c) => a + c.tally.rerolls);
    final paid = all.fold(0, (a, c) => a + c.tally.paidRerolls);
    lines.add('  ${pad(policy.label, 20)}${pad('$b', 10)}'
        '${pad(fix(b == 0 ? 0 : rolls / b), 12)}'
        '${pad(fix(b == 0 ? 0 : checks / b), 12)}'
        '${pad(fix(checks == 0 ? 0 : rerolls / checks), 12)}'
        '${pad(fix(checks == 0 ? 0 : paid / checks), 10)}');
  }
  return lines;
}

double _clear(ComboTable t, int id, Difficulty d) => t[id]![d]!.clearRate * 100;

String _delta(double v) => '${v >= 0 ? '+' : ''}${fix(v, 1)}';

List<ComboResult> _allCombos(ComboTable t) =>
    [for (final id in kRegionIds) ...Difficulty.values.map((d) => t[id]![d]!)];
