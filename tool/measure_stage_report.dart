/// 재측정 표 5가지 (WORK_ORDER_SIM2 3-A ~ 3-E)를 사람이 읽을 줄 목록으로 만든다.
/// 여기에는 게임 규칙이 없다. 숫자를 세고 줄로 만드는 일만 한다.
library;

import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/core/stage_runner.dart';

import 'measure_profile.dart';
import 'measure_stats.dart';
import 'measure_stage_run.dart';

/// 지역 번호 → 난이도 → 조합 결과
typedef ComboTable = Map<int, Map<Difficulty, ComboResult>>;

const List<int> kRegionIds = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

String _diff(Difficulty d) => kDifficultyLabels[d]!;

List<ComboResult> _all(ComboTable t) =>
    [for (final id in kRegionIds) ...Difficulty.values.map((d) => t[id]![d]!)];

/// 3-C. ★ 어디서 막히는가 — 지역 × 난이도 완주율. 이번 측정의 결론이다.
List<String> sectionClearRate(ComboTable t) {
  final lines = <String>[
    '',
    '── 3-C. ★ 지역 × 난이도 완주율 ───────────────────',
    '  한 판 = 그 지역의 마지막(보스) 스테이지 1개를 1층부터 끝까지.',
    '  괄호 안은 평균 도달 층 / 그 스테이지의 총 층수.',
    '  ${pad('지역', 20)}${pad('층수', 6)}'
        '${Difficulty.values.map((d) => pad(_diff(d), 20)).join()}',
  ];
  for (final id in kRegionIds) {
    final row = t[id]!;
    final first = row[Difficulty.normal]!;
    lines.add('  ${pad('$id ${first.region.name}', 20)}'
        '${pad('${first.stage.floors}', 6)}'
        '${Difficulty.values.map((d) {
      final c = row[d]!;
      return pad('${pct(c.clearRate)}% (${fix(c.avgFloor, 1)})', 20);
    }).join()}');
  }
  return lines;
}

/// 3-A. ★ 전투당 굴림 횟수 — 각인 수치표가 기다리는 값
List<String> sectionRolls(ComboTable t) {
  final lines = <String>[
    '',
    '── 3-A. ★ 전투당 굴림 횟수 ───────────────────────',
    '  굴림 1회 = 주사위를 실제로 던진 1회 (초기 굴림 + 리롤 각각)',
    '  ${pad('지역', 20)}${pad('난이도', 8)}${pad('전투', 8)}'
        '${pad('전투당굴림', 12)}${pad('전투당판정', 12)}'
        '${pad('판정당리롤', 12)}${pad('그중유료', 10)}',
  ];
  for (final id in kRegionIds) {
    for (final d in Difficulty.values) {
      final c = t[id]![d]!;
      lines.add(_rollRow('$id ${c.region.name}', _diff(d), c));
    }
  }
  lines
    ..add('')
    ..add('  ${pad('전체 (36조합 합산)', 28)}${_rollCells(_all(t))}');
  return lines;
}

String _rollRow(String region, String difficulty, ComboResult c) =>
    '  ${pad(region, 20)}${pad(difficulty, 8)}${_rollCells([c])}';

String _rollCells(List<ComboResult> cs) {
  final b = cs.fold(0, (a, c) => a + c.tally.battles);
  final checks = cs.fold(0, (a, c) => a + c.tally.checks);
  final rolls = cs.fold(0, (a, c) => a + c.tally.rolls);
  final rerolls = cs.fold(0, (a, c) => a + c.tally.rerolls);
  final paid = cs.fold(0, (a, c) => a + c.tally.paidRerolls);
  return '${pad('$b', 8)}${pad(fix(b == 0 ? 0 : rolls / b), 12)}'
      '${pad(fix(b == 0 ? 0 : checks / b), 12)}'
      '${pad(fix(checks == 0 ? 0 : rerolls / checks), 12)}'
      '${pad(fix(checks == 0 ? 0 : paid / checks), 10)}';
}

/// ⚠ 3-A2(각인 기대 적립)는 **더 내지 않는다** — 기획 창이 검토 22에서
/// 실측 4.49굴림 기준으로 `ENGRAVINGS.md` 4절을 확정했다
/// (WORK_ORDER_FINAL_TUNE2 3-D).

/// 3-B. ★ 전투당 턴 수 — 층수 상한이 기다리는 값
List<String> sectionTurns(ComboTable t) {
  final lines = <String>[
    '',
    '── 3-B. ★ 전투당 턴 수 ───────────────────────────',
    '  ⚠ 초로 환산하지 않는다. 턴당 몇 초인지는 사람이 플레이해야 안다.',
    '  ⚠ 보스는 **1체 기준**이다 (전조→본체·호위·연전은 아직 없다).',
    '  ${pad('지역', 20)}${pad('난이도', 8)}${pad('일반전투', 10)}'
        '${pad('평균턴', 10)}${pad('중앙값', 8)}${pad('보스전투', 10)}'
        '${pad('평균턴', 10)}${pad('중앙값', 8)}',
  ];
  for (final id in kRegionIds) {
    for (final d in Difficulty.values) {
      final c = t[id]![d]!;
      final n = c.tally.normalTurns;
      final b = c.tally.bossTurns;
      lines.add('  ${pad('$id ${c.region.name}', 20)}${pad(_diff(d), 8)}'
          '${pad('${n.length}', 10)}${pad(fix(mean(n)), 10)}'
          '${pad('${median(n)}', 8)}'
          '${pad('${b.length}', 10)}${pad(fix(mean(b)), 10)}'
          '${pad('${median(b)}', 8)}');
    }
  }
  final all = _all(t);
  final n = <int>[for (final c in all) ...c.tally.normalTurns];
  final b = <int>[for (final c in all) ...c.tally.bossTurns];
  lines
    ..add('')
    ..add('  ${pad('전체 (36조합 합산)', 28)}${pad('${n.length}', 10)}'
        '${pad(fix(mean(n)), 10)}${pad('${median(n)}', 8)}'
        '${pad('${b.length}', 10)}${pad(fix(mean(b)), 10)}'
        '${pad('${median(b)}', 8)}');
  return lines;
}

/// 3-B2. 보조 측정 — 보스 전투만 따로 (본 측정은 후반 표본이 0이다)
List<String> sectionBossOnly(ComboTable t) {
  final lines = <String>[
    '',
    '── 3-B2. 보스 전투만 따로 잰 값 〔보조 측정〕 ─────',
    '  본 측정(3-B)은 3지역 이후 **보스 층까지 못 가서 표본이 0**이다.',
    '  그래서 같은 보스를 **최대 체력에서 바로** 상대하는 전투를 따로 돌렸다.',
    '  층을 거치며 깎인 체력이 섞이지 않으므로 「보스 자체가 몇 턴짜리인가」만 남는다.',
    '  ⚠ 보스 1체 기준이다 (전조→본체·호위·연전은 아직 없다).',
    '  ${pad('지역', 20)}${pad('난이도', 8)}${pad('보스HP', 10)}'
        '${pad('승률', 10)}${pad('평균턴', 10)}${pad('중앙값', 8)}'
        '${pad('최대', 6)}${pad('전투당굴림', 12)}',
  ];
  for (final id in kRegionIds) {
    for (final d in Difficulty.values) {
      final c = t[id]![d]!;
      final turns = c.bossOnly.bossTurns;
      final b = c.bossOnly.battles;
      lines.add('  ${pad('$id ${c.region.name}', 20)}${pad(_diff(d), 8)}'
          '${pad('${c.bossHp}', 10)}'
          '${pad('${pct(c.bossOnlyWinRate)}%', 10)}'
          '${pad(fix(mean(turns)), 10)}${pad('${median(turns)}', 8)}'
          '${pad('${maxOf(turns)}', 6)}'
          '${pad(fix(b == 0 ? 0 : c.bossOnly.rolls / b), 12)}');
    }
  }
  return lines;
}

/// 3-D. 변종 등장 비율 (작업 1 검증)
List<String> sectionVariants(ComboTable t, List<String> variantIds,
    Map<String, String> variantNames, Map<int, Map<String, int>> baseWeights) {
  final lines = <String>[
    '',
    '── 3-D. 변종 등장 비율 (일반 층만 · 보스 제외) ────',
    '  각 칸은 「실측% (보정 후 가중치)」다. 둘이 맞아야 추첨이 옳다.',
    '  ★ 하드는 「고대의」가 원래 +10, 데스는 +20이어야 한다 (작업 1).',
  ];
  for (final d in Difficulty.values) {
    lines
      ..add('')
      ..add('  [${_diff(d)}]')
      ..add('  ${pad('지역', 20)}'
          '${variantIds.map((v) => pad(variantNames[v]!, 16)).join()}'
          '${pad('표본', 8)}');
    for (final id in kRegionIds) {
      final c = t[id]![d]!;
      final w = difficultyVariantWeights(baseWeights[id]!, d);
      final total = c.variantTotal;
      lines.add('  ${pad('$id ${c.region.name}', 20)}'
          '${variantIds.map((v) {
        final n = c.variantCounts[v] ?? 0;
        final target = w[v] ?? 0;
        if (n == 0 && target == 0) return pad('—', 16);
        return pad('${pct(total == 0 ? 0 : n / total)}% ($target)', 16);
      }).join()}${pad('$total', 8)}');
    }
  }
  return lines;
}

/// 3-E. 폭주 자해 상한 — 이제 체력이 지역마다 다르다
List<String> sectionSelfDamage(ComboTable t) {
  final lines = <String>[
    '',
    '── 3-E. 폭주 자해 상한 (지역별로 체력이 다르다) ───',
    '  상한 = 최대 체력의 ${pct(kSurgeSelfDamageMaxRatio)}% (한 폭주의 합계에 건다)',
    '  ${pad('지역', 20)}${pad('최대체력', 10)}${pad('상한', 8)}'
        '${pad('자해폭주', 10)}${pad('잘린수', 10)}${pad('잘린비율', 10)}'
        '${pad('raw평균', 10)}${pad('applied평균', 12)}',
  ];
  for (final id in kRegionIds) {
    final row = t[id]!;
    final cs = Difficulty.values.map((d) => row[d]!).toList();
    final p = cs.first.profile;
    final n = cs.fold(0, (a, c) => a + c.tally.selfDamageSurges);
    final capped = cs.fold(0, (a, c) => a + c.tally.selfDamageCapped);
    final raw = cs.fold(0, (a, c) => a + c.tally.selfDamageRawSum);
    final applied = cs.fold(0, (a, c) => a + c.tally.selfDamageAppliedSum);
    lines.add('  ${pad('$id ${cs.first.region.name}', 20)}'
        '${pad('${p.maxHp}', 10)}${pad('${selfDamageCapOf(p.maxHp)}', 8)}'
        '${pad('$n', 10)}${pad('$capped', 10)}'
        '${pad('${pct(n == 0 ? 0 : capped / n)}%', 10)}'
        '${pad(fix(n == 0 ? 0 : raw / n), 10)}'
        '${pad(fix(n == 0 ? 0 : applied / n), 12)}');
  }
  return lines;
}

/// 측정 조건 — 어떤 발판 위에서 잰 값인지 먼저 밝힌다
List<String> sectionProfile(ComboTable t) {
  final lines = <String>[
    '',
    '── 측정 조건: 〔가정〕 성장 프로필 ────────────────',
    '  ⚠ 설계 확정이 아니라 측정용 발판이다 (WORK_ORDER_SIM2 작업 2).',
    '  유물·패시브·각인 없음. 리롤은 기본 규칙(최대 3회, 비용 1/2/3).',
    '  ★ 손패는 고정이 아니라 **덱에서 매 턴 3장**을 뽑는다 (GAME_DESIGN 4.2절).',
    '  ${pad('지역', 20)}${pad('진입Lv', 8)}${pad('최대체력', 10)}'
        '${pad('최고서클', 10)}${pad('최대마나', 10)}${pad('덱 구성 (서클×장수)', 40)}',
  ];
  for (final id in kRegionIds) {
    final c = t[id]![Difficulty.normal]!;
    final p = c.profile;
    lines.add('  ${pad('$id ${c.region.name}', 20)}${pad('${p.level}', 8)}'
        '${pad('${p.maxHp}', 10)}${pad('${p.topCircle}', 10)}'
        '${pad('${p.maxMana}', 10)}'
        '${pad(_deckShape(c), 40)}');
  }
  return lines;
}

/// 덱의 서클 구성을 「1서클×3 2서클×1」 꼴로 줄인다 (덱 전체 목록은 3-F2에 있다)
String _deckShape(ComboResult c) {
  final slots = kDeckSlots[c.region.id]!;
  return [
    for (var i = 0; i < slots.length; i++) '${i + 1}서클×${slots[i]}',
  ].join(' ');
}
