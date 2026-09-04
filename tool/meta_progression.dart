/// 메타 진행 페이싱 시뮬레이터: 한 명의 플레이어가 연속으로 판을 돌며
/// 번 마력 결정을 강화에 쓰는 과정을 흉내낸다.
/// 실행: dart run tool/meta_progression.dart
///
/// 소비 정책 (사람 흉내): 체력 → 마나 → 리롤 → 시작 유물 순으로 다 산 뒤
/// epic 주문을 위력 높은 순서로 해금한다.
// ignore_for_file: avoid_print — 콘솔 출력용 CLI 도구라 print가 맞다
library;

import 'dart:math';

import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/models/meta_state.dart';
import 'package:surge_wizard/models/spell.dart';

import 'sim_core.dart';

/// 시뮬레이션할 총 판 수
const int kTotalRuns = 200;

/// 구간 요약 크기
const int kBlockSize = 25;

void main() {
  final data = loadGameData();
  final random = Random(20260831);
  final meta = MetaState.initial();
  final epicByPower = data.spells.where((s) => s.rarity == 'epic').toList()
    ..sort((a, b) => b.baseDamage.compareTo(a.baseDamage));

  int? firstClearRun;
  int? coreMaxedRun; // 체력·마나·리롤·유물 강화를 전부 산 시점
  var blockCleared = 0;
  var blockFloors = 0;

  print('== 메타 진행 페이싱 ($kTotalRuns판 연속 플레이) ==');
  print('판 구간\t완주율\t평균층\t보유💎\t강화(체/마/리/유물)\t해금');
  for (var run = 1; run <= kTotalRuns; run++) {
    final result = playRun(data, random, Tally(), meta: meta);
    meta.crystals += result.clearedFloors * kCrystalPerFloor +
        (result.cleared ? kBossClearCrystalBonus : 0);
    _spend(meta, epicByPower);

    if (result.cleared) {
      blockCleared++;
      firstClearRun ??= run;
    }
    blockFloors += min(result.reachedFloor, result.totalFloors);
    if (coreMaxedRun == null && _coreMaxed(meta)) coreMaxedRun = run;

    if (run % kBlockSize == 0) {
      print('${run - kBlockSize + 1}~$run\t'
          '${(blockCleared / kBlockSize * 100).toStringAsFixed(0)}%\t'
          '${(blockFloors / kBlockSize).toStringAsFixed(1)}\t'
          '${meta.crystals}\t'
          '${meta.hpLevel}/${meta.manaLevel}/${meta.rerollLevel}/${meta.startRelicLevel}\t'
          '${meta.unlockedSpellIds.length}/${epicByPower.length}');
      blockCleared = 0;
      blockFloors = 0;
    }
  }
  print('');
  print('첫 완주: ${firstClearRun ?? "없음"}판째');
  print('핵심 강화 4종 풀업: ${coreMaxedRun ?? "미달성"}판째');
}

bool _coreMaxed(MetaState m) =>
    m.hpLevel >= kMetaHpCosts.length &&
    m.manaLevel >= kMetaManaCosts.length &&
    m.rerollLevel >= kMetaRerollCosts.length &&
    m.startRelicLevel >= kMetaStartRelicCosts.length;

/// 소비 정책: 우선순위대로 살 수 있는 만큼 산다.
void _spend(MetaState m, List<Spell> epicByPower) {
  bool buy(List<int> costs, int level, void Function() up) {
    if (level >= costs.length || m.crystals < costs[level]) return false;
    m.crystals -= costs[level];
    up();
    return true;
  }

  var bought = true;
  while (bought) {
    bought = buy(kMetaHpCosts, m.hpLevel, () => m.hpLevel++) ||
        buy(kMetaManaCosts, m.manaLevel, () => m.manaLevel++) ||
        buy(kMetaRerollCosts, m.rerollLevel, () => m.rerollLevel++) ||
        buy(kMetaStartRelicCosts, m.startRelicLevel,
            () => m.startRelicLevel++);
    if (!bought && _coreMaxed(m) && m.crystals >= kSpellUnlockCost) {
      final next = epicByPower
          .where((s) => !m.unlockedSpellIds.contains(s.id))
          .firstOrNull;
      if (next != null) {
        m.crystals -= kSpellUnlockCost;
        m.unlockedSpellIds.add(next.id);
        bought = true;
      }
    }
  }
}
