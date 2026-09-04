/// 방어막·회복 실측 표 (WORK_ORDER_HEAL_FIX 4-C · WORK_ORDER_ATTRITION 3-C 2번).
///
/// 4-A(완주율)·4-D(굴림·턴)는 `measure_growth_report.dart` 가 그대로 낸다.
///
/// ⛔ 함께 있던 4-B「전투당 피해 / 최대 체력 %」는 **뺐다.**
/// 완주율이 오르면 더 깊은 층이 표본에 섞여 평균이 도로 올라가는 생존 편향이
/// 있어 개선을 재는 지표로 쓸 수 없다 (검토 19 9-1 · WORK_ORDER_ATTRITION
/// 「하지 않을 것」). 대신 판 단위 지표가 `measure_attrition_report.dart` 5-C 다.
library;

import 'package:surge_wizard/core/constants.dart';

import 'measure_deck_report.dart';
import 'measure_growth.dart';
import 'measure_growth_report.dart';
import 'measure_stage_report.dart';
import 'measure_stage_run.dart';
import 'measure_stats.dart';
import 'sim_core.dart';

/// 4-C2가 들여다볼 덱. 1서클 슬롯이 5칸이라 마력방패·치유 약초가 다 들어온다
const int kUtilityDeckRegion = 12;

ComboResult _combo(UpgradeTables t, BookUpgrade u, int id) =>
    t[u]![BotPolicy.utility]![id]![Difficulty.normal]!;

/// 4-C. 방어막·회복이 실제로 얼마나 막고 회복했나 — 작업 1이 들었는지 본다
List<String> sectionHealShieldHeal(UpgradeTables t) {
  final lines = <String>[
    '',
    '── 4-C. 방어막·회복 실측 (보통 · utility) ────────',
    '  ★ 작업 1(강화가 heal·shield 도 올린다)이 실제로 들었는지 여기서 본다.',
    '  총량은 그 조합의 300판 합계인데 **판이 길어지면 총량도 커지므로**,',
    '  비교는 「전투당」 열로 한다 (총량은 상한 쪽만 참고로 싣는다).',
    '  ${pad('지역', 20)}${pad('전투당막음 하한', 18)}${pad('상한', 10)}'
        '${pad('전투당회복 하한', 18)}${pad('상한', 10)}'
        '${pad('막은총량 상한', 16)}${pad('회복총량 상한', 16)}'
        '${pad('유틸비율 상한', 16)}',
  ];
  for (final id in kRegionIds) {
    final low = _combo(t, BookUpgrade.none, id);
    final high = _combo(t, BookUpgrade.full, id);
    final mix = castMixOf({high.difficulty: high});
    lines.add('  ${pad('$id ${high.region.name}', 20)}'
        '${pad(fix(_perBattle(low, (x) => x.shieldAbsorbed)), 18)}'
        '${pad(fix(_perBattle(high, (x) => x.shieldAbsorbed)), 10)}'
        '${pad(fix(_perBattle(low, (x) => x.healed)), 18)}'
        '${pad(fix(_perBattle(high, (x) => x.healed)), 10)}'
        '${pad('${high.tally.shieldAbsorbed}', 16)}'
        '${pad('${high.tally.healed}', 16)}'
        '${pad('${pct(mix.utilityRate)}%', 16)}');
  }
  return [...lines, ..._utilityValues(t)];
}

/// 전투 1회당 값 — 판 길이가 달라도 하한·상한을 나란히 놓을 수 있게 한다
double _perBattle(ComboResult c, int Function(Tally) pick) =>
    c.tally.battles == 0 ? 0 : pick(c.tally) / c.tally.battles;

/// 4-C2. 강화가 유틸 수치를 실제로 얼마로 만들었나 (덱 안의 값을 그대로 찍는다).
/// 표가 아니라 **검산**이다 — 마력방패 6 → 12 가 눈으로 확인돼야 한다.
List<String> _utilityValues(UpgradeTables t) {
  final lines = <String>[
    '',
    '── 4-C2. 덱 안 유틸 주문의 실제 수치 (강화 전 → 후) ─',
    '  $kUtilityDeckRegion지역 덱 기준 — 1서클 슬롯이 다 열려 마력방패·치유 '
        '약초까지 들어 있다.',
    '  회복·방어막만 오르고 나머지 효과는 그대로여야 한다.',
    '  ${pad('주문', 20)}${pad('효과', 14)}${pad('하한', 10)}${pad('상한', 10)}',
  ];
  final low = _combo(t, BookUpgrade.none, kUtilityDeckRegion).deck;
  final high = _combo(t, BookUpgrade.full, kUtilityDeckRegion).deck;
  final byId = {for (final s in high) s.id: s};
  for (final s in low) {
    final e = s.effect;
    final up = byId[s.id]?.effect;
    if (e == null || up == null) continue;
    lines.add('  ${pad(s.name, 20)}${pad(e.type, 14)}'
        '${pad('${e.value}', 10)}${pad('${up.value}', 10)}');
  }
  return lines;
}
