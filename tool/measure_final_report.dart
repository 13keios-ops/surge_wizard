/// ★ 최종 지역 확인용 두 표 (WORK_ORDER_FINAL_TUNE2 3-D 2번·5번).
///
/// 곡선 조건 판정(6-A·6-B)은 `measure_goal_report.dart` 에 있다.
/// 이 파일은 그 판정을 **뒷받침하는** 두 표만 낸다.
///
///   6-C  지역별 보스만 승률 (측정 22와 나란히 — 1~11지역은 바뀌면 안 된다)
///   6-D  한 판의 평균 턴 수 (원칙 6이 재는 단위는 전투가 아니라 판이다)
library;

import 'package:surge_wizard/core/constants.dart';

import 'measure_condition.dart';
import 'measure_growth.dart';
import 'measure_growth_report.dart';
import 'measure_stage_driver.dart';
import 'measure_stage_report.dart';
import 'measure_stage_run.dart';
import 'measure_stats.dart';
import 'sim_core.dart';

/// 측정 22의 **지역별 보스만 승률**(보통 · 상한 · utility · 시드 20260831 ·
/// 채택 조건). 출처는 `reports/data/measure10_output.txt` 6-C 절이다.
/// **보스 HP도 배율도 보스에는 안 붙으므로 1~11지역은 바뀌면 안 된다** (3-D 2번).
/// 12지역만 난수 흐름이 밀려 움직일 수 있다 — 아래 절의 설명을 볼 것.
const Map<int, double> kBossOnly22 = {
  1: 99.7, 2: 99.3, 3: 99.3, 4: 95.7, 5: 97.7, 6: 88.3,
  7: 86.7, 8: 89.0, 9: 84.3, 10: 70.7, 11: 61.0, 12: 47.3,
};

ComboResult _combo(UpgradeTables t, BookUpgrade u, int id) =>
    t[u]![BotPolicy.utility]![id]![Difficulty.normal]!;

String _signed(double v) => '${v >= 0 ? '+' : ''}${fix(v, 1)}';

/// 6-C. 지역별 보스만 승률 — 측정 22와 나란히 (3-D 2번).
/// **지역 배율은 보스에 붙지 않으므로 1~11지역은 바뀌면 안 된다.**
/// 다만 12지역은 판 수가 300 → 1000으로 달라졌고 앞선 판이 뽑는 난수량도
/// 달라져, 보조 측정이 물려받는 **난수 흐름이 밀린다** (설계 변경이 아니다).
List<String> sectionBossOnlyByRegion(ConditionTables byCondition) {
  final base = byCondition[kCondBase]!;
  final adopted = byCondition[kAdoptedCondition]!;
  final lines = <String>[
    '',
    '── 6-C. 보스만 승률 (보통 · 상한 · utility) ───────',
    '  최대 체력에서 **보스와 바로** 붙었을 때의 승률이다.',
    '  지역 배율은 **보스에 붙지 않는다** — 1~11지역은 **바뀌면 안 된다.**',
    '  ⚠ 「측정22」 열은 **시드 20260831 · 채택 조건** 값이다 — 다른 시드와는',
    '  나란히 못 놓는다.',
    '  12지역은 판 수가 ${kRunCounts.standard} → ${kRunCounts.finalRegion}으로',
    '  달라져 보조 측정이 물려받는 난수 흐름이 밀린다 (설계 변경이 아니다).',
    '  ${pad('지역', 20)}${pad('보스HP', 8)}${pad('측정22', 10)}'
        '${pad('기준', 10)}${pad('기준차', 10)}'
        '${pad('채택', 10)}${pad('채택차', 10)}${pad('평균턴', 8)}',
  ];
  for (final id in kRegionIds) {
    final b = _combo(base, BookUpgrade.full, id);
    final c = _combo(adopted, BookUpgrade.full, id);
    final was = kBossOnly22[id]!;
    lines.add('  ${pad('$id ${c.region.name}', 20)}${pad('${c.bossHp}', 8)}'
        '${pad('${fix(was, 1)}%', 10)}'
        '${pad('${fix(b.bossOnlyWinRate * 100, 1)}%', 10)}'
        '${pad(_signed(b.bossOnlyWinRate * 100 - was), 10)}'
        '${pad('${fix(c.bossOnlyWinRate * 100, 1)}%', 10)}'
        '${pad(_signed(c.bossOnlyWinRate * 100 - was), 10)}'
        '${pad(fix(mean(c.bossOnly.bossTurns)), 8)}');
  }
  return lines;
}

/// 6-D. 12지역 한 판의 평균 턴 수 (3-C 5번) — 원칙 6(한 판 10분)이 재는 단위다.
/// 전투당 턴이 아니라 **판당 턴**이라야 층수를 줄인 효과가 보인다.
List<String> sectionRunLength(ConditionTables byCondition) {
  final base = byCondition[kCondBase]!;
  final adopted = byCondition[kAdoptedCondition]!;
  final lines = <String>[
    '',
    '── 6-D. 한 판의 평균 턴 수 (보통 · utility · 하한→상한) ─',
    '  판 하나(스테이지 1층~보스층)가 끝날 때까지 돈 전투 턴의 총합이다.',
    '  **죽어서 끝난 판도 넣는다** — 사람이 실제로 앉아 있던 시간이기 때문이다.',
    '  그래서 완주율이 오르면 이 값도 함께 오른다 (더 깊이 간다).',
    '  ${pad('지역', 20)}${pad('배율 기준→채택', 18)}'
        '${pad('하한 기준', 12)}${pad('하한 채택', 12)}${pad('차', 10)}'
        '${pad('상한 기준', 12)}${pad('상한 채택', 12)}${pad('차', 10)}',
  ];
  for (final id in kRegionIds) {
    final bl = _combo(base, BookUpgrade.none, id);
    final al = _combo(adopted, BookUpgrade.none, id);
    final bh = _combo(base, BookUpgrade.full, id);
    final ah = _combo(adopted, BookUpgrade.full, id);
    lines.add('  ${pad('$id ${ah.region.name}', 20)}'
        '${pad('${bh.region.hpScale} → ${ah.region.hpScale}', 18)}'
        '${pad(fix(bl.avgRunTurns), 12)}${pad(fix(al.avgRunTurns), 12)}'
        '${pad(_signed(al.avgRunTurns - bl.avgRunTurns), 10)}'
        '${pad(fix(bh.avgRunTurns), 12)}${pad(fix(ah.avgRunTurns), 12)}'
        '${pad(_signed(ah.avgRunTurns - bh.avgRunTurns), 10)}');
  }
  return lines;
}
