/// 36조합(지역 12 × 난이도 3)을 실제로 돌리는 실행기.
///
/// `measure_stage.dart` 가 보고서를 조립하는 동안 여기서는 **판을 돈다.**
/// 강화 수준·봇 정책·측정 조건이 전부 `const` 가 아니라 **인자**이므로
/// 한 번의 실행으로 「조건 2 × 강화 2 × 정책 2」를 모두 낸다.
// ignore_for_file: avoid_print — 진행 상황을 콘솔에만 알린다
library;

import 'dart:math';

import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/data/parser.dart';

import 'measure_condition.dart';
import 'measure_growth.dart';
import 'measure_growth_report.dart';
import 'measure_profile.dart';
import 'measure_stage_report.dart';
import 'measure_stage_run.dart';
import 'sim_core.dart';

/// 조건 → 강화 → 정책 → 조합표
typedef ConditionTables = Map<MeasureCondition, UpgradeTables>;

/// 변종 표에 필요한 이름·가중치 묶음 (표를 찍을 때만 쓴다)
class VariantRef {
  VariantRef(GameData data)
      : ids = data.variants.map((v) => v.id).toList(),
        names = {
          for (final v in data.variants)
            v.id: v.namePrefix.isEmpty ? '기본' : v.namePrefix,
        },
        weights = {for (final r in data.regions) r.id: r.variantWeights};

  final List<String> ids;
  final Map<String, String> names;
  final Map<int, Map<String, int>> weights;
}

/// 조합당 판 수 — **지역마다 다르다** (WORK_ORDER_FINAL_TUNE2 3-A).
///
/// 12지역은 완주 표본이 40판 안팎이라 시드에 따라 상한이 13.3 ↔ 19.0%로
/// 흔들렸다 (측정 22). 그 칸만 판 수를 올려 통과·미달을 가른다.
/// **1~11지역은 300판 그대로여야 기준 조건이 측정 22를 소수점까지 재현한다.**
class RunCounts {
  const RunCounts({required this.standard, required this.finalRegion});

  /// 1~11지역
  final int standard;

  /// 12지역 (표본을 키우는 칸)
  final int finalRegion;

  int forRegion(int regionId) =>
      regionId == kScaleChangedRegion ? finalRegion : standard;

  /// 표·머리말에 찍을 설명
  String get label => '1~11지역 $standard판 · 12지역 $finalRegion판';
}

/// 이번 측정이 쓰는 판 수. **상수로 박지 않고 인자로 흘린다** (3-A).
const RunCounts kRunCounts = RunCounts(standard: 300, finalRegion: 1000);

/// 시드 하나를 **두 조건 × 강화 2 × 정책 2**로 전부 돈다.
///
/// 조건이 「옛 배율」이면 **데이터 사본**을 만들어 넘긴다
/// (`dataFor` — 12지역의 hp_scale 만 되돌린 사본이다).
ConditionTables runSeedAllConditions(
  GameData data,
  Map<String, int> circles,
  Map<String, String> byPrefix,
  int seed,
  RunCounts runs,
) =>
    {
      for (final condition in kConditions)
        condition: {
          for (final upgrade in BookUpgrade.values)
            upgrade: {
              for (final policy in BotPolicy.values)
                policy: runCombos(dataFor(data, condition), circles, byPrefix,
                    seed, upgrade, policy, condition, runs),
            },
        },
    };

/// 시드 하나 · 강화 하나 · 정책 하나 · 조건 하나로 36조합을 전부 돈다.
///
/// 씨앗 식이 강화·정책·조건과 무관하므로 모든 조합이 **같은 판**을 돈다
/// (비교가 성립한다).
ComboTable runCombos(
  GameData data,
  Map<String, int> circles,
  Map<String, String> byPrefix,
  int seed,
  BookUpgrade upgrade,
  BotPolicy policy,
  MeasureCondition condition,
  RunCounts runs,
) {
  final table = <int, Map<Difficulty, ComboResult>>{};
  for (final id in kRegionIds) {
    // 「옛 배율」 조건이면 여기서 나오는 지역의 hp_scale 이 옛 값이다.
    final region = data.region(id);
    // 대표 스테이지 = 그 지역의 마지막 스테이지 (보스가 포함돼야 보스 턴을 잰다).
    final stage = data.stage(id, region.stageCount);
    final runCount = runs.forRegion(id);
    final profile = profileOf(id);
    final deck = profileDeck(data.spells, circles, id, upgrade: upgrade);
    table[id] = {};
    for (final difficulty in Difficulty.values) {
      final combo = ComboResult(
        region: region,
        stage: stage,
        difficulty: difficulty,
        profile: profile,
        deck: deck,
        policy: policy,
        upgrade: upgrade,
        condition: condition,
      );
      // 조합마다 다른 씨앗을 준다 (13·1009는 12지역 × 3난이도에서 겹치지 않는다)
      final random = Random(seed + id * 13 + difficulty.index * 1009);
      for (var run = 0; run < runCount; run++) {
        playStageRun(data, combo, byPrefix, random);
      }
      // 보조 측정 — 본 측정은 후반 지역에서 보스 표본이 0이 된다.
      // 본 측정과 같은 판 수를 돈다 (난수를 이어 쓰므로 짝을 맞춘다).
      for (var run = 0; run < runCount; run++) {
        playBossOnly(data, combo, random);
      }
      table[id]![difficulty] = combo;
    }
  }
  return table;
}
