/// ★ 성장 반영 측정의 결론 표 (WORK_ORDER_GROWTH_SIM 작업 4-A ~ 4-D).
///
/// 「강화 없음(하한)」과 「만강(상한)」을 나란히 놓는다.
///   하한이 측정 17과 거의 같아야 한다 → 다르면 **구현이 틀린 것**이다
///   상한 열이 이번 측정의 답이다     → 여기서도 안 되면 「적이 세다」가 확정된다
library;

import 'package:surge_wizard/core/constants.dart';

import 'measure_deck_report.dart';
import 'measure_defs.dart';
import 'measure_growth.dart';
import 'measure_policy_report.dart';
import 'measure_profile.dart';
import 'measure_stage_report.dart';
import 'measure_stage_run.dart';
import 'measure_stats.dart';
import 'sim_core.dart';

/// 강화 수준 → 정책 → 조합표
typedef UpgradeTables = Map<BookUpgrade, PolicyTables>;

/// 측정 22(`reports/data/measure10_output.txt`)의 **보통 난이도 · utility 완주율**
/// (시드 20260831 · 채택 조건) — 강화 없음(하한).
/// **비교 기준일 뿐 이 도구가 쓰는 수치가 아니다.**
///
/// ★ 이번 측정의 「기준」 조건(옛 12지역 배율)이 **1~11지역에서** 이 값을
/// 소수점까지 되살려야 한다 — 검산은 5-B2 절에서 한다.
/// **12지역은 판 수가 달라져 비교 대상이 아니다.**
const Map<int, double> kClearRate22Low = {
  1: 97.0, 2: 97.3, 3: 92.0, 4: 78.3, 5: 54.0, 6: 45.3,
  7: 11.7, 8: 9.0, 9: 3.3, 10: 2.7, 11: 2.3, 12: 0.3,
};

/// 같은 측정 22의 만강(상한) 완주율. **12지역 상한이 15~25%(조건 B2)에
/// 닿았는지가 이번 측정의 성패다** — 판정은 6-B 절이 한다.
const Map<int, double> kClearRate22High = {
  1: 99.0, 2: 99.3, 3: 97.7, 4: 96.7, 5: 91.0, 6: 82.7,
  7: 67.7, 8: 55.7, 9: 47.3, 10: 43.7, 11: 27.7, 12: 13.3,
};

ComboResult _combo(
        UpgradeTables t, BookUpgrade u, BotPolicy p, int id, Difficulty d) =>
    t[u]![p]![id]![d]!;

double _clear(
        UpgradeTables t, BookUpgrade u, BotPolicy p, int id, Difficulty d) =>
    _combo(t, u, p, id, d).clearRate * 100;

String _delta(double v) => '${v >= 0 ? '+' : ''}${fix(v, 1)}';

List<ComboResult> _all(UpgradeTables t, BookUpgrade u, BotPolicy p) => [
      for (final id in kRegionIds)
        ...Difficulty.values.map((d) => t[u]![p]![id]![d]!),
    ];

/// 12지역을 뺀 합산. **12지역만 판 수가 1000으로 달라졌기 때문에**, 36조합
/// 합산을 그대로 과거 측정과 견주면 표본 비중이 달라 값이 어긋난다.
/// 이 목록이 측정 22와 **같은 저울**로 잰 값이다.
List<ComboResult> _exceptFinal(
        UpgradeTables t, BookUpgrade u, BotPolicy p) =>
    [
      for (final id in kRegionIds)
        if (id != kRegionIds.last)
          ...Difficulty.values.map((d) => t[u]![p]![id]![d]!),
    ];

/// 4-A. ★ 완주율 — 이번 측정의 결론
List<String> sectionGrowthClearRate(UpgradeTables t) {
  const policy = BotPolicy.utility;
  final lines = <String>[
    '',
    '── 4-A. ★ 완주율 (보통 난이도 · 봇 utility) ──────',
    '  하한 = 강화 없음. 상한 = 마법서 전부 만강. **채택 조건(둘 다)** 값이다.',
    '  측정 22와 나란히 놓는다 — 곡선 조건 판정은 6-B 절이 따로 낸다.',
    '  ${pad('지역', 20)}${pad('22하한', 10)}${pad('22상한', 10)}'
        '${pad('이번하한', 12)}${pad('이번상한', 12)}'
        '${pad('하한차', 10)}${pad('상한차', 10)}',
  ];
  for (final id in kRegionIds) {
    final low = _clear(t, BookUpgrade.none, policy, id, Difficulty.normal);
    final high = _clear(t, BookUpgrade.full, policy, id, Difficulty.normal);
    final name =
        _combo(t, BookUpgrade.full, policy, id, Difficulty.normal).region.name;
    lines.add('  ${pad('$id $name', 20)}'
        '${pad('${fix(kClearRate22Low[id]!, 1)}%', 10)}'
        '${pad('${fix(kClearRate22High[id]!, 1)}%', 10)}'
        '${pad('${fix(low, 1)}%', 12)}${pad('${fix(high, 1)}%', 12)}'
        '${pad(_delta(low - kClearRate22Low[id]!), 10)}'
        '${pad(_delta(high - kClearRate22High[id]!), 10)}');
  }
  return [...lines, ..._clearRateByDifficulty(t), ..._clearRateByPolicy(t)];
}

/// 4-A2. 난이도 3개를 하한 → 상한으로
List<String> _clearRateByDifficulty(UpgradeTables t) {
  const policy = BotPolicy.utility;
  final lines = <String>[
    '',
    '── 4-A2. 난이도별 완주율 (하한 → 상한 · utility) ──',
    '  ${pad('지역', 20)}'
        '${Difficulty.values.map((d) => pad(kDifficultyLabels[d]!, 22)).join()}',
  ];
  for (final id in kRegionIds) {
    final name =
        _combo(t, BookUpgrade.full, policy, id, Difficulty.normal).region.name;
    lines.add('  ${pad('$id $name', 20)}${Difficulty.values.map((d) {
      final low = _clear(t, BookUpgrade.none, policy, id, d);
      final high = _clear(t, BookUpgrade.full, policy, id, d);
      return pad('${fix(low, 1)}% → ${fix(high, 1)}%', 22);
    }).join()}');
  }
  return lines;
}

/// 4-A3. 상한에서 두 봇을 나란히 — 봇 정책이 결론을 바꾸지 않는지 본다
List<String> _clearRateByPolicy(UpgradeTables t) {
  final lines = <String>[
    '',
    '── 4-A3. 상한에서 봇 정책 비교 (보통 난이도) ─────',
    '  격차(utility − greedy)가 +25%p를 넘으면 5-D 절이 경보를 낸다 (검토 19 3-4).',
    '  ${pad('지역', 20)}${pad('greedy', 12)}${pad('utility', 12)}'
        '${pad('정책효과', 12)}',
  ];
  for (final id in kRegionIds) {
    final g =
        _clear(t, BookUpgrade.full, BotPolicy.greedy, id, Difficulty.normal);
    final u =
        _clear(t, BookUpgrade.full, BotPolicy.utility, id, Difficulty.normal);
    final name =
        _combo(t, BookUpgrade.full, BotPolicy.utility, id, Difficulty.normal)
            .region
            .name;
    lines.add('  ${pad('$id $name', 20)}${pad('${fix(g, 1)}%', 12)}'
        '${pad('${fix(u, 1)}%', 12)}${pad(_delta(u - g), 12)}');
  }
  return lines;
}

/// 4-E. 「죽이기 대 죽기」 — 보조 표.
List<String> sectionGrowthKillVsDie(UpgradeTables t) {
  const policy = BotPolicy.utility;
  final lines = <String>[
    '',
    '── 4-E. 죽이기 대 죽기 (보통 난이도 · utility) ───',
    '  측정 18의 확인 지점은 「상한에서 일반 전투 턴이 4턴 아래인가」였다.',
    '  보스 턴은 「보스만 측정」값이다 — 본 측정은 후반에 보스 층까지 못 간다.',
    '  ${pad('지역', 20)}${pad('최대체력', 10)}'
        '${pad('일반턴 하한', 14)}${pad('상한', 10)}'
        '${pad('보스턴 하한', 14)}${pad('상한', 10)}'
        '${pad('시전위력 하한', 16)}${pad('상한', 10)}',
  ];
  for (final id in kRegionIds) {
    final low = _combo(t, BookUpgrade.none, policy, id, Difficulty.normal);
    final high = _combo(t, BookUpgrade.full, policy, id, Difficulty.normal);
    lines.add('  ${pad('$id ${high.region.name}', 20)}'
        '${pad('${high.profile.maxHp}', 10)}'
        '${pad(fix(mean(low.tally.normalTurns)), 14)}'
        '${pad(fix(mean(high.tally.normalTurns)), 10)}'
        '${pad(fix(mean(low.bossOnly.bossTurns)), 14)}'
        '${pad(fix(mean(high.bossOnly.bossTurns)), 10)}'
        '${pad(fix(_power(low)), 16)}${pad(fix(_power(high)), 10)}');
  }
  return [...lines, ..._profileTable(t)];
}

/// 지역 하나 · 난이도 하나의 평균 시전 위력
double _power(ComboResult c) => castMixOf({c.difficulty: c}).avgPower;

/// 4-E2. 프로필이 실제로 어떻게 바뀌었나 (성장 가정 검산용)
List<String> _profileTable(UpgradeTables t) {
  const policy = BotPolicy.utility;
  final lines = <String>[
    '',
    '── 4-E2. 프로필 변화 (성장 가정이 실제로 들어갔나) ──',
    '  체력 = 기존 프로필 + 패시브(round(20 × (Lv−1) / 98)).',
    '  덱 위력 = 그 지역 덱의 base_damage 합계.',
    '  ${pad('지역', 20)}${pad('진입Lv', 8)}${pad('기존체력', 10)}'
        '${pad('패시브', 8)}${pad('최종체력', 10)}${pad('자해상한', 10)}'
        '${pad('덱위력 하한', 14)}${pad('상한', 10)}${pad('배수', 8)}',
  ];
  for (final id in kRegionIds) {
    final low = _combo(t, BookUpgrade.none, policy, id, Difficulty.normal);
    final high = _combo(t, BookUpgrade.full, policy, id, Difficulty.normal);
    final p = high.profile;
    final lowSum = low.deck.fold(0, (a, s) => a + s.baseDamage);
    final highSum = high.deck.fold(0, (a, s) => a + s.baseDamage);
    lines.add('  ${pad('$id ${high.region.name}', 20)}${pad('${p.level}', 8)}'
        '${pad('${p.baseMaxHp}', 10)}${pad('+${p.passiveHp}', 8)}'
        '${pad('${p.maxHp}', 10)}${pad('${selfDamageCapOf(p.maxHp)}', 10)}'
        '${pad('$lowSum', 14)}${pad('$highSum', 10)}'
        '${pad('×${fix(lowSum == 0 ? 0 : highSum / lowSum)}', 8)}');
  }
  return lines;
}

/// 4-D. 전투당 굴림 — 측정 12~19와 한 표에
List<String> sectionGrowthRolls(UpgradeTables t) {
  final lines = <String>[
    '',
    '── 4-D. 전투당 굴림 (36조합 합산) ────────────────',
    '  과거 측정과 한 표에 놓는다. 출처는 각 measure*_output.txt 다.',
    '  ${pad('측정', 36)}${pad('전투', 10)}${pad('전투당굴림', 12)}'
        '${pad('전투당판정', 12)}${pad('판정당리롤', 12)}${pad('그중유료', 10)}',
  ];
  kRollsHistory.forEach((label, rolls) {
    lines.add('  ${pad(label, 36)}${pad('—', 10)}${pad(fix(rolls), 12)}'
        '${pad('—', 12)}${pad('—', 12)}${pad('—', 10)}');
  });
  for (final u in BookUpgrade.values) {
    for (final p in BotPolicy.values) {
      lines.add(
          '  ${pad('${u.label} ${p.label}', 36)}${_rollCells(_all(t, u, p))}');
    }
  }
  lines
    ..add('')
    ..add('  ⚠ 위 줄은 **36조합 합산**이라 과거 측정과 저울이 다르다 — '
        '12지역만 판 수가 1000으로')
    ..add('  늘어 전투가 더 긴 그 지역의 비중이 커졌다.')
    ..add('  아래는 **12지역을 뺀** 값이다. 과거 측정(12지역이 1/12로 섞여 있다)과도')
    ..add('  똑같지는 않지만, 늘어난 가중치의 영향만은 없다.');
  for (final u in BookUpgrade.values) {
    for (final p in BotPolicy.values) {
      lines.add('  ${pad('1~11 ${u.label} ${p.label}', 36)}'
          '${_rollCells(_exceptFinal(t, u, p))}');
    }
  }
  return lines;
}

String _rollCells(List<ComboResult> cs) {
  final b = cs.fold(0, (a, c) => a + c.tally.battles);
  final checks = cs.fold(0, (a, c) => a + c.tally.checks);
  final rolls = cs.fold(0, (a, c) => a + c.tally.rolls);
  final rerolls = cs.fold(0, (a, c) => a + c.tally.rerolls);
  final paid = cs.fold(0, (a, c) => a + c.tally.paidRerolls);
  return '${pad('$b', 10)}${pad(fix(b == 0 ? 0 : rolls / b), 12)}'
      '${pad(fix(b == 0 ? 0 : checks / b), 12)}'
      '${pad(fix(checks == 0 ? 0 : rerolls / checks), 12)}'
      '${pad(fix(checks == 0 ? 0 : paid / checks), 10)}';
}

/// ⚠ 4-D2(각인 기대 적립)는 **더 내지 않는다** — 기획 창이 검토 22에서
/// 실측 4.49굴림 기준으로 `ENGRAVINGS.md` 4절을 확정했다
/// (WORK_ORDER_FINAL_TUNE2 3-D). 값을 다시 계산하면 확정된 표와 어긋난다.

/// 4-D3. 전투당 턴 수 · 200턴 안전장치 건수 (**0이어야 한다**)
List<String> sectionGrowthTurns(UpgradeTables t) {
  final lines = <String>[
    '',
    '── 4-D3. 전투당 턴 수 · 200턴 안전장치 ───────────',
    '  안전장치가 0이 아니면 「적을 깎을 주문이 없어 교착했다」는 뜻이다.',
    '  본 측정 + 보스만 측정을 모두 센다.',
    '  ${pad('조건', 32)}${pad('일반 전투', 10)}${pad('평균턴', 10)}'
        '${pad('중앙값', 8)}${pad('보스 전투', 10)}${pad('평균턴', 10)}'
        '${pad('보스만', 8)}${pad('안전장치', 10)}${pad('최장턴', 8)}',
  ];
  for (final u in BookUpgrade.values) {
    for (final p in BotPolicy.values) {
      lines.add('  ${pad('${u.label} ${p.label}', 32)}${_turnCells(_all(t, u, p))}');
    }
  }
  return lines;
}

String _turnCells(List<ComboResult> all) {
  final n = <int>[for (final c in all) ...c.tally.normalTurns];
  final b = <int>[for (final c in all) ...c.tally.bossTurns];
  final only = <int>[for (final c in all) ...c.bossOnly.bossTurns];
  var hits = 0;
  var longest = 0;
  for (final c in all) {
    for (final tally in [c.tally, c.bossOnly]) {
      hits += tally.turnLimitBattles;
      longest = [longest, maxOf(tally.normalTurns), maxOf(tally.bossTurns)]
          .reduce((x, y) => x > y ? x : y);
    }
  }
  return '${pad('${n.length}', 10)}${pad(fix(mean(n)), 10)}'
      '${pad('${median(n)}', 8)}${pad('${b.length}', 10)}'
      '${pad(fix(mean(b)), 10)}${pad(fix(mean(only)), 8)}'
      '${pad('$hits', 10)}${pad('$longest', 8)}';
}
