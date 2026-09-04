/// ★ 조건 비교 · 소모전 지표 · 정책 격차 (WORK_ORDER_FINAL_TUNE2 3-B·3-D).
///
///   5-B  조건 2개 비교 — 12지역 배율 하향이 얼마나 들었나
///   5-C  상점 층 도달률 · 도달했을 때 남은 체력 % (판 단위 소모전 지표)
///   5-D  봇 정책 격차 경보 (+25%p를 넘으면 보고한다)
///
/// 곡선 조건 판정(6-A·6-B)·보스만 승률(6-C)·판당 턴(6-D)은
/// `measure_goal_report.dart` 에 있다.
///
/// 「전투당 피해 %」는 **더 내지 않는다** — 개선될수록 깊은 층이 표본에 섞여
/// 평균이 도로 올라가는 생존 편향이 있다 (검토 19).
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

/// 봇 정책 격차 경보선 — 이 값을 넘으면 「방어막 외길」을 의심한다 (검토 19 3-4)
const double kPolicyGapAlert = 25.0;

ComboResult _combo(UpgradeTables t, BookUpgrade u, int id) =>
    t[u]![BotPolicy.utility]![id]![Difficulty.normal]!;

double _clearHigh(UpgradeTables t, int id) =>
    _combo(t, BookUpgrade.full, id).clearRate * 100;

double _clearLow(UpgradeTables t, int id) =>
    _combo(t, BookUpgrade.none, id).clearRate * 100;

String _signed(double v) => '${v >= 0 ? '+' : ''}${fix(v, 1)}';

/// 5-B. ★ 조건 2개 비교 — 배율을 껐다 켜서 기여를 가른다 (3-B)
List<String> sectionConditionCompare(ConditionTables byCondition) {
  final adopted = byCondition[kAdoptedCondition]!;
  final lines = <String>[
    '',
    '── 5-B. ★ 조건 2개 비교 (하한 → 상한 · 보통 · utility) ─',
    '  기준 = 12지역 옛 배율($kOldRegion12HpScale) · '
        '채택 = 새 배율(${_scaleOf(adopted)}).',
    '  **1~11지역은 두 조건이 소수점까지 같아야 한다** — 안 건드렸다는 증거다.',
    '  12지역은 두 조건 모두 ${kRunCounts.finalRegion}판이라 나란히 놓을 수 있다.',
    '  ${pad('지역', 20)}'
        '${kConditions.map((c) => pad(c.label, 22)).join()}${pad('상한차', 10)}',
  ];
  for (final id in kRegionIds) {
    final name = _combo(adopted, BookUpgrade.full, id).region.name;
    final cells = kConditions.map((c) {
      final t = byCondition[c]!;
      return pad('${fix(_clearLow(t, id), 1)}% → ${fix(_clearHigh(t, id), 1)}%',
          22);
    }).join();
    final gap = _clearHigh(adopted, id) -
        _clearHigh(byCondition[kCondBase]!, id);
    lines.add('  ${pad('$id $name', 20)}$cells${pad(_signed(gap), 10)}');
  }
  return [...lines, ..._baseReproduction(byCondition[kCondBase]!)];
}

/// 채택 조건이 실제로 쓴 12지역 체력 배율 (매직 넘버 대신 데이터에서 읽는다)
double _scaleOf(UpgradeTables t) =>
    _combo(t, BookUpgrade.full, kRegionIds.last).region.hpScale;

/// 5-B2. 기준 조건이 측정 22를 소수점까지 되살렸는가 (되살리지 못하면 보고한다).
///
/// ★ **12지역은 판 수가 달라졌으므로 비교 대상이 아니다** (3-B). 그 칸은 표에
/// 「판수 다름」으로 찍고 최대 차이 계산에서 뺀다 — 1~11지역 22칸만 센다.
List<String> _baseReproduction(UpgradeTables base) {
  var worst = 0.0;
  final rows = <String>[];
  for (final id in kRegionIds) {
    final low = _combo(base, BookUpgrade.none, id).clearRate * 100;
    final high = _clearHigh(base, id);
    final dLow = low - kClearRate22Low[id]!;
    final dHigh = high - kClearRate22High[id]!;
    final counted = id != kRegionIds.last;
    if (counted) {
      worst = [worst, dLow.abs(), dHigh.abs()].reduce((a, b) => a > b ? a : b);
    }
    final note = counted ? '' : ' ← 판수 다름(비교 제외)';
    rows.add('  ${pad('$id', 20)}${pad('${fix(kClearRate22Low[id]!, 1)}%', 12)}'
        '${pad('${fix(low, 1)}%', 12)}${pad(_signed(dLow), 10)}'
        '${pad('${fix(kClearRate22High[id]!, 1)}%', 12)}'
        '${pad('${fix(high, 1)}%', 12)}${pad(_signed(dHigh), 10)}$note');
  }
  return [
    '',
    '── 5-B2. 기준 조건 = 측정 22 재현 검산 ───────────',
    '  기준(12지역 옛 배율 $kOldRegion12HpScale)이 측정 22와 **소수점까지**',
    '  같아야 한다.',
    '  ⚠ 비교 상수는 **시드 20260831** 값이다 — 다른 시드에서는 0.0이 아닌 것이',
    '  정상이다 (그쪽은 5-B의 조건 2개 비교로 본다).',
    '  ⚠ **12지역은 판 수가 ${kRunCounts.standard} → ${kRunCounts.finalRegion}으로',
    '  달라졌으므로 값이 달라도 정상이다** — 아래 최대 차이에서 뺐다.',
    '  ★ 1~11지역 22칸 최대 차이 ${fix(worst, 1)}%p — 0.0이 아니면 구현이 틀린 것이다.',
    '  ${pad('지역', 20)}${pad('22하한', 12)}${pad('기준하한', 12)}${pad('차', 10)}'
        '${pad('22상한', 12)}${pad('기준상한', 12)}${pad('차', 10)}',
    ...rows,
  ];
}

/// 5-C. ★ 상점 층 도달률 · 도달했을 때 남은 체력 % (3-B)
List<String> sectionShopFloor(ConditionTables byCondition) {
  final base = byCondition[kCondBase]!;
  final both = byCondition[kAdoptedCondition]!;
  final lines = <String>[
    '',
    '── 5-C. ★ 상점 층 도달률 · 남은 체력 % (상한 · 보통 · utility) ─',
    '  「전투당 피해 %」를 대신하는 **판 단위** 소모전 지표다 (검토 19 9-1).',
    '  12지역이 측정 22의 도달률 54.0% · 남은 체력 57.0%에서 어떻게',
    '  움직이는지가 이번 측정의 핵심이다 (3-D 1번).',
    '  남은 체력 %는 상점 층에 **들어설 때** 값이다 (그 층 전투 전 · 회복 전).',
    '  **도달하지 못한 판은 평균에서 뺐다** — 그래서 도달률을 나란히 낸다.',
    '  ${pad('지역', 20)}${pad('최대체력', 10)}'
        '${pad('도달률 기준', 14)}${pad('채택', 10)}${pad('차', 10)}'
        '${pad('남은체력 기준', 16)}${pad('채택', 10)}${pad('차', 10)}',
  ];
  for (final id in kRegionIds) {
    final b = _combo(base, BookUpgrade.full, id);
    final a = _combo(both, BookUpgrade.full, id);
    lines.add('  ${pad('$id ${a.region.name}', 20)}'
        '${pad('${a.profile.maxHp}', 10)}'
        '${pad('${pct(b.shopReachRate)}%', 14)}'
        '${pad('${pct(a.shopReachRate)}%', 10)}'
        '${pad(_signed((a.shopReachRate - b.shopReachRate) * 100), 10)}'
        '${pad('${pct(b.shopHpShare)}%', 16)}'
        '${pad('${pct(a.shopHpShare)}%', 10)}'
        '${pad(_signed((a.shopHpShare - b.shopHpShare) * 100), 10)}');
  }
  return lines;
}

/// 5-D. 봇 정책 격차 경보 — utility 가 greedy 를 +25%p 넘게 앞서면 알린다
List<String> sectionPolicyGap(UpgradeTables adopted) {
  final over = <String>[];
  var worst = 0.0;
  var worstAt = '';
  for (final id in kRegionIds) {
    for (final d in Difficulty.values) {
      final g = adopted[BookUpgrade.full]![BotPolicy.greedy]![id]![d]!.clearRate;
      final u =
          adopted[BookUpgrade.full]![BotPolicy.utility]![id]![d]!.clearRate;
      final gap = (u - g) * 100;
      if (gap > worst) {
        worst = gap;
        worstAt = '$id지역 ${kDifficultyLabels[d]}';
      }
      if (gap > kPolicyGapAlert) {
        over.add('  [경보] $id지역 ${kDifficultyLabels[d]} — '
            'utility ${pct(u)}% vs greedy ${pct(g)}% (${_signed(gap)}%p)');
      }
    }
  }
  return [
    '',
    '── 5-D. 봇 정책 격차 (상한 · 36조합 전수) ────────',
    '  격차가 +${fix(kPolicyGapAlert, 0)}%p를 넘으면 「방어막을 안 쓰면 손해」인',
    '  외길을 의심한다 (검토 19 3-4). 최대 격차 ${fix(worst, 1)}%p ($worstAt).',
    if (over.isEmpty)
      '  경보선을 넘은 칸이 없다.'
    else ...[
      '  경보선을 넘은 칸 ${over.length}개:',
      ...over,
    ],
  ];
}
