/// 진행 구조를 반영한 재측정 — 지역 12 × 난이도 3 (WORK_ORDER_SIM2 작업 3).
/// 실행: dart run tool/measure_stage.dart
///
/// ⚠ 이 도구는 아무것도 조정하지 않는다. 상수·데이터·확률표를 읽기만 한다.
/// `tool/simulate.dart`(기준선)와 `tool/measure.dart`(측정 12)는 건드리지 않았다.
///
/// 재는 것:
///   3-A  전투당 굴림 횟수 (각인 기대 적립 표는 확정돼 더 내지 않는다)
///   3-B  전투당 턴 수 (일반/보스)
///   3-C  지역 × 난이도 완주율
///   3-D  변종 등장 비율 (난이도 보정 검증)
///   3-E  폭주 자해 상한 (체력이 지역마다 다르다)
///   3-F  손패에 무엇이 잡혔나 (WORK_ORDER_DECK_SIM 작업 3)
///   P-A~E 두 봇 정책(greedy · utility) 비교 (WORK_ORDER_DECK_FIX 작업 4)
///   4-A·C~E 완주율 · 방어막/회복 · 굴림/턴 (WORK_ORDER_HEAL_FIX 작업 4)
///   5-B~D 소모전 지표 (WORK_ORDER_ATTRITION 작업 3) — B 조건 비교 ·
///         C 상점 층 도달·잔여 체력 · D 봇 정책 격차
///   6-A~D ★ 12지역 배율 하향 (WORK_ORDER_FINAL_TUNE2 작업 3) —
///         A 곡선과 낙차 · B **곡선 조건 판정 A·B1·B2·C** ·
///         C 지역별 보스만 승률 · D 한 판의 평균 턴 수
///
/// ★ 조건도 정책도 강화 수준도 `const` 가 아니라 인자다. 그래서 **한 번의
/// 실행**으로 「조건 2 × 하한·상한 × greedy·utility」를 모두 돌린다.
// ignore_for_file: avoid_print — 콘솔 출력용 CLI 도구라 print가 맞다
library;

import 'dart:io';

import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/data/parser.dart';

import 'measure_attrition_report.dart';
import 'measure_condition.dart';
import 'measure_deck_report.dart';
import 'measure_final_report.dart';
import 'measure_goal_report.dart';
import 'measure_growth.dart';
import 'measure_growth_report.dart';
import 'measure_heal_report.dart';
import 'measure_policy_report.dart';
import 'measure_profile.dart';
import 'measure_stage_driver.dart';
import 'measure_stage_report.dart';
import 'measure_stage_run.dart';
import 'measure_stats.dart';
import 'sim_core.dart';

/// 시드 2개 — 값이 시드에 따라 흔들리는지 확인한다.
/// 측정 12와 같은 두 값이라 그쪽 결과와 나란히 놓을 수 있다.
const List<int> kSeeds = [20260831, 20260902];

/// 결과를 남길 파일 (첫 번째 실행 인자로 바꿀 수 있다).
/// 측정 14는 measure2, 15는 measure3, 16(덱 기반)은 measure4,
/// 17(덱·봇 수정)은 measure5, 18(성장 반영)은 measure6,
/// 19(회복 수정)는 measure7, 20(소모전 완화)은 measure8,
/// 21(후반 곡선 정렬)은 measure9, 22(12지역 층수)는 measure10,
/// 23(12지역 배율)은 measure11 이다.
/// **measure10_output.txt 를 덮어쓰지 않는다** (측정 22의 원본이다).
const String kDefaultOutputPath = 'reports/data/measure11_output.txt';

void main(List<String> args) {
  final outputPath = args.isEmpty ? kDefaultOutputPath : args.first;
  final data = loadGameData();
  final circles = loadSpellCircles();
  final byPrefix = variantByPrefix(data);
  final variants = VariantRef(data);

  final buffer = StringBuffer();
  void emit(String line) {
    print(line);
    buffer.writeln(line);
  }

  for (final line in _header(data)) {
    emit(line);
  }

  final bySeed = <int, UpgradeTables>{};
  for (final seed in kSeeds) {
    final byCondition =
        runSeedAllConditions(data, circles, byPrefix, seed, kRunCounts);
    final adopted = byCondition[kAdoptedCondition]!;
    bySeed[seed] = adopted;
    for (final line in _seedReport(seed, byCondition, variants)) {
      emit(line);
    }
  }
  for (final line in _seedComparison(bySeed)) {
    emit(line);
  }

  final out = File(outputPath);
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  print('');
  print('결과를 $outputPath 에 저장했다.');
}

/// 측정 조건을 먼저 밝힌다. 배율은 **데이터에서 읽어** 찍는다 (매직 넘버 금지).
List<String> _header(GameData data) => [
      '== 시뮬 재측정 — 12지역 배율 하향 (지역 12 × 난이도 3) ==',
      '조합 ${kRegionIds.length * Difficulty.values.length}개 × '
          '${kRunCounts.label} × 시드 ${kSeeds.length}개 × '
          '조건 ${kConditions.length}개 × 강화 ${BookUpgrade.values.length}단 × '
          '정책 ${BotPolicy.values.length}개',
      '※ 측정 전용. **이 도구는 밸런스 수치를 하나도 바꾸지 않는다.**',
      '※ 대표 스테이지는 각 지역의 마지막(보스) 스테이지다.',
      '※ 마법서 강화: ${BookUpgrade.values.map((u) => u.label).join(' · ')}',
      '※ 봇 정책: ${BotPolicy.values.map((p) => p.label).join(' · ')}',
      '※ 패시브 최대 체력은 두 강화 수준에 똑같이 들어간다 (변인은 강화뿐).',
      '※ 이번 수정: 12지역 체력 배율 하향 '
          '($kOldRegion12HpScale → ${data.region(kScaleChangedRegion).hpScale}). '
          '11지역 ${data.region(11).hpScale} 보다 위라 단조 증가는 그대로다.',
      '※ 그 밖의 수치(적·보스 HP 405·atk_scale 1.45·난이도 배율·1~11지역 배율·'
          '모든 지역 층수·성장 프로필·강화율·회복)는 측정 22와 **한 값도 같다**.',
      '※ 판정이 **곡선 조건 A·B1·B2·C**로 바뀌었다 (B가 쪼개졌다) — '
          '6-B 절이 그 판정표다.',
      '※ ★ 12지역만 판 수가 ${kRunCounts.standard} → '
          '${kRunCounts.finalRegion}으로 달라졌다. 그 칸은 측정 22와 값이 달라도 '
          '정상이다 (1~11지역은 ${kRunCounts.standard}판 그대로다).',
      '※ 상세 표(4-x 이하)는 **채택 조건(${kAdoptedCondition.label})** 값이다.',
    ];

/// 시드 하나의 출력 — ★ 곡선 조건 판정이 맨 앞, 조건 비교가 그다음이다
List<String> _seedReport(
        int seed, ConditionTables byCondition, VariantRef variants) =>
    [
      '',
      '',
      '════════════════════════════════════════════════════',
      ' 시드 $seed — ★ 12지역 배율 측정 (작업 3)',
      '════════════════════════════════════════════════════',
      ...sectionCurve(byCondition[kAdoptedCondition]!),
      ...sectionCurveConditions(byCondition[kAdoptedCondition]!),
      ...sectionBossOnlyByRegion(byCondition),
      ...sectionRunLength(byCondition),
      ...sectionConditionCompare(byCondition),
      ...sectionShopFloor(byCondition),
      ...sectionPolicyGap(byCondition[kAdoptedCondition]!),
      ..._adoptedDetail(seed, byCondition[kAdoptedCondition]!, variants),
    ];

/// 채택 조건의 상세 — 측정 19와 같은 절 구성이라 그대로 대조할 수 있다
List<String> _adoptedDetail(
        int seed, UpgradeTables tables, VariantRef variants) =>
    [
      ...sectionGrowthClearRate(tables),
      ...sectionHealShieldHeal(tables),
      ...sectionGrowthRolls(tables),
      ...sectionGrowthTurns(tables),
      ...sectionGrowthKillVsDie(tables),
      for (final upgrade in BookUpgrade.values)
        ..._upgradeDetail(seed, upgrade, tables[upgrade]!, variants),
    ];

/// 강화 수준 하나의 상세 — 측정 17과 같은 절 구성이라 그대로 대조할 수 있다
List<String> _upgradeDetail(int seed, BookUpgrade upgrade, PolicyTables tables,
        VariantRef variants) =>
    [
      '',
      '',
      '════════════════════════════════════════════════════',
      ' 시드 $seed · 마법서 ${upgrade.label} — 정책 비교',
      '════════════════════════════════════════════════════',
      ...sectionPolicyClearRate(tables),
      ...sectionPolicyCastMix(tables),
      ...sectionPolicyRolls(tables),
      ...sectionPolicyTurns(tables),
      ...sectionPolicyTurnLimit(tables),
      for (final policy in BotPolicy.values)
        ..._policyDetail(seed, upgrade, policy, tables[policy]!, variants),
    ];

/// 정책 하나의 상세 표 (측정 16과 같은 절 구성이라 그대로 대조할 수 있다)
List<String> _policyDetail(int seed, BookUpgrade upgrade, BotPolicy policy,
        ComboTable table, VariantRef variants) =>
    [
      '',
      '',
      '──────────────────────────────────────────────────',
      ' 시드 $seed · ${upgrade.label} · ${policy.label} — 상세',
      '──────────────────────────────────────────────────',
      ...sectionProfile(table),
      ...sectionDeck(table),
      ...sectionDeckList(table),
      ...sectionClearRate(table),
      ...sectionRolls(table),
      ...sectionTurns(table),
      ...sectionBossOnly(table),
      ...sectionVariants(table, variants.ids, variants.names, variants.weights),
      ...sectionSelfDamage(table),
    ];

/// 시드끼리 값이 얼마나 흔들리는지 (표본이 충분한지 확인하는 절차다).
/// 정책마다 따로 낸다 — 봇이 달라지면 흔들림도 달라진다.
List<String> _seedComparison(Map<int, UpgradeTables> bySeed) {
  final seeds = bySeed.keys.toList();
  final lines = <String>[
    '',
    '',
    '════════════════════════════════════════════════════',
    ' 시드 비교 — 값이 시드에 따라 흔들리는가 (채택 조건)',
    '════════════════════════════════════════════════════',
  ];
  for (final upgrade in BookUpgrade.values) {
    for (final policy in BotPolicy.values) {
      lines
        ..add('')
        ..add('  [${upgrade.label} · 정책 ${policy.label}]')
        ..add('  ${pad('지표', 30)}${seeds.map((s) => pad('$s', 14)).join()}'
            '${pad('차이', 12)}');
      for (final entry in _metrics().entries) {
        final values = seeds
            .map((s) => entry.value(bySeed[s]![upgrade]![policy]!))
            .toList();
        final diff = values.reduce((a, b) => (a - b).abs());
        lines.add('  ${pad(entry.key, 30)}'
            '${values.map((v) => pad(fix(v, 3), 14)).join()}'
            '${pad(fix(diff, 3), 12)}');
      }
    }
  }
  return lines;
}

/// 시드 비교에 쓸 대표 지표
Map<String, double Function(ComboTable)> _metrics() {
  List<ComboResult> all(ComboTable t) => [
        for (final id in kRegionIds)
          ...Difficulty.values.map((d) => t[id]![d]!),
      ];

  double clear(ComboTable t, int id, Difficulty d) =>
      t[id]![d]!.clearRate * 100;

  return {
    '전체 전투당 굴림': (t) {
      final cs = all(t);
      final b = cs.fold(0, (a, c) => a + c.tally.battles);
      final rolls = cs.fold(0, (a, c) => a + c.tally.rolls);
      return b == 0 ? 0 : rolls / b;
    },
    '전체 일반 전투 평균 턴': (t) =>
        mean([for (final c in all(t)) ...c.tally.normalTurns]),
    '전체 보스 전투 평균 턴': (t) =>
        mean([for (final c in all(t)) ...c.tally.bossTurns]),
    '보스만 평균 턴 (보조)': (t) =>
        mean([for (final c in all(t)) ...c.bossOnly.bossTurns]),
    '보스만 승률 % — 12지역 보통': (t) =>
        t[12]![Difficulty.normal]!.bossOnlyWinRate * 100,
    '완주율 % — 1지역 보통': (t) => clear(t, 1, Difficulty.normal),
    '완주율 % — 3지역 보통': (t) => clear(t, 3, Difficulty.normal),
    '완주율 % — 6지역 보통': (t) => clear(t, 6, Difficulty.normal),
    '완주율 % — 9지역 보통': (t) => clear(t, 9, Difficulty.normal),
    '완주율 % — 12지역 보통': (t) => clear(t, 12, Difficulty.normal),
    '완주율 % — 1지역 데스': (t) => clear(t, 1, Difficulty.death),
    '완주율 % — 12지역 데스': (t) => clear(t, 12, Difficulty.death),
    '상점층 잔여체력% — 9지역': (t) =>
        t[9]![Difficulty.normal]!.shopHpShare * 100,
    '상점층 잔여체력% — 12지역': (t) =>
        t[12]![Difficulty.normal]!.shopHpShare * 100,
    '한 판 평균 턴 — 12지역': (t) => t[12]![Difficulty.normal]!.avgRunTurns,
    '자해 상한에 잘린 % (전체)': (t) {
      final cs = all(t);
      final n = cs.fold(0, (a, c) => a + c.tally.selfDamageSurges);
      final capped = cs.fold(0, (a, c) => a + c.tally.selfDamageCapped);
      return n == 0 ? 0 : capped / n * 100;
    },
  };
}
