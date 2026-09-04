/// 시뮬레이터 공용 로직 (simulate.dart / meta_progression.dart 가 공유).
/// 봇의 판단(무엇을 · 얼마나 세게)은 bot_policy.dart 가 맡는다.
/// 성공 미만 예상이면 5·6을 잠그고 리롤하되 리롤 비용 체증을 감안한다.
/// 유물은 등급 우선, 주문은 최약체와 교체.
library;

import 'dart:io';
import 'dart:math';

import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/check.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/core/dice.dart';
import 'package:surge_wizard/core/relic_powers.dart';
import 'package:surge_wizard/core/stage_runner.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/meta_state.dart';
import 'package:surge_wizard/models/relic.dart';
import 'package:surge_wizard/models/spell.dart';
import 'package:surge_wizard/models/stage.dart';

import 'bot_policy.dart';
import 'sim_tally.dart';

export 'bot_policy.dart';
export 'sim_tally.dart';

/// 한 판(run)의 결과
class RunResult {
  int reachedFloor = 0; // 사망한 층 (마지막 층 + 1 = 완주)
  bool cleared = false;

  /// 이 판이 돈 스테이지의 총 층수
  int totalFloors = 0;

  /// 마력 결정 계산용: 돌파한 층 수
  int get clearedFloors => cleared ? totalFloors : reachedFloor - 1;
}

GameData loadGameData() => GameDataParser.parseAll(
    (name) => File('assets/data/$name').readAsStringSync());

// ── 시뮬레이터 임시 진입 지점 ──────────────────────────
// 선택 화면이 아직 없어 「지역 1 · 스테이지 1 · 보통」 고정으로 돈다.
// ⚠ 이 상태의 수치를 해석하지 마라 — 재측정은 다음 지시서다.

const int kSimRegionId = kEntryRegionId;
const int kSimStageIndex = kEntryStageIndex;
const Difficulty kSimDifficulty = kEntryDifficulty;

/// 시뮬레이터가 도는 스테이지
Stage simStage(GameData data) => data.stage(kSimRegionId, kSimStageIndex);

/// 한 판: 스테이지 하나의 1층~마지막 층. [meta] 영구 강화를 반영한다.
///
/// [useRerolls] 를 끄면 봇이 리롤 없이 첫 굴림 그대로 시전한다.
/// [useRelics] 를 끄면 유물을 하나도 얻지 않는다 (판정 보정 0).
/// 두 스위치는 measure.dart 의 A/B/C 모드 비교용이며 기본값은 기존 동작이다.
RunResult playRun(GameData data, Random random, Tally tally,
    {MetaState? meta,
    bool useRerolls = true,
    bool useRelics = true,
    BotPolicy policy = BotPolicy.utility}) {
  final m = meta ?? MetaState.initial();
  final region = data.region(kSimRegionId);
  final stage = simStage(data);
  final result = RunResult()..totalFloors = stage.floors;
  final relics = <Relic>[];
  if (useRelics && m.startRelicLevel > 0) {
    final commons = data.relics.where((r) => r.rarity == 'common').toList();
    relics.add(commons[random.nextInt(commons.length)]);
  }
  var hp = -1; // 첫 층에서 maxHp로 초기화
  var charge = 0;
  final hand = kStarterSpellIds
      .map((id) => data.spells.firstWhere((s) => s.id == id))
      .toList();

  for (var floor = 1; floor <= stage.floors; floor++) {
    final powers = RelicPowers.fromRelics(relics).add(
      maxHpUp: m.hpLevel * kMetaHpBonusPerLevel,
      extraRerolls: m.rerollLevel,
    );
    final maxHp = kPlayerStartHp + powers.maxHpUp;
    if (hp < 0) hp = maxHp;
    final battle = Battle(
      enemy: pickEnemy(data, region, stage, floor, kSimDifficulty, random),
      hand: hand,
      surgePool: data.surges,
      playerHp: hp,
      playerMaxHp: maxHp,
      maxMana: kPlayerStartMaxMana + m.manaLevel,
      relics: powers,
      random: random,
    )..charge = charge;

    runBattle(battle, powers, random,
        tally: tally, useRerolls: useRerolls, policy: policy);
    tally.addBattle(battle);

    if (!battle.playerWon) {
      result.reachedFloor = floor;
      return result;
    }
    final event = floorEvent(floor, stage.floors);
    // 전투 승리 회복은 유물 회복 위에 더한다. 보스 층은 주지 않는다.
    final winHeal = event == FloorEvent.boss ? 0 : battleWinHealAmount(maxHp);
    hp = min(maxHp, battle.playerHp + powers.healAfterBattle + winHeal);
    charge = battle.charge;

    switch (event) {
      case FloorEvent.spellReward:
      case FloorEvent.boss:
        spellReward(hand, data.spells, random, m);
      case FloorEvent.shop:
        hp = min(maxHp, hp + shopHealAmount(maxHp));
      case FloorEvent.relicReward:
        if (useRelics) relicReward(relics, data.relics, random);
      case FloorEvent.battle:
        break;
    }
  }
  result
    ..reachedFloor = stage.floors + 1
    ..cleared = true;
  return result;
}

/// 전투가 끝나지 않을 때 강제로 끊는 턴 수 (무한 루프 방지용 안전장치)
const int kMaxBattleTurns = 200;

/// 전투 1회: 리롤 정책을 쓰는 봇.
/// [useRerolls] 가 false 면 첫 굴림 그대로 시전한다 (measure.dart A 모드).
/// [policy] 는 주문 선택 정책이다 — 기본은 새 정책(utility), greedy 는 비교용.
void runBattle(Battle battle, RelicPowers powers, Random random,
    {int maxTurns = kMaxBattleTurns,
    Tally? tally,
    bool useRerolls = true,
    BotPolicy policy = BotPolicy.utility}) {
  final pool = DicePool(
    random: random,
    maxRerolls: kMaxRerollsPerCheck + powers.extraRerolls,
    faceTransform: powers.rerollOnesTo > 0
        ? (f) => f == 1 ? powers.rerollOnesTo : f
        : null,
  );
  var rollsThisBattle = 0;
  while (!battle.isOver && battle.turnCount < maxTurns) {
    battle.startTurn();
    final castable = battle.castableIndexes;
    if (castable.isEmpty) {
      battle.enemyTurn();
      continue;
    }
    final index = chooseSpellIndex(battle, castable, policy);
    final spell = battle.hand[index];
    final intensity = chooseIntensity(battle, spell);

    // 굴림 전 상태를 남겨 둔다 — 주사위 추가는 굴리는 순간 소비된다.
    final extraDie = battle.pendingExtraDie;
    if (useRerolls) {
      rollWithRerolls(battle, pool, spell, intensity, powers);
    } else {
      rollFresh(battle, pool);
    }
    rollsThisBattle += 1 + pool.rerollCount;
    tally?.addRolls(pool);

    final probe = tally == null
        ? null
        : (CastProbe.of(battle)
          ..dcModifier = spell.dcModifier
          ..extraDie = extraDie);
    if (battle.castSpell(index, intensity, dice: pool.values)) {
      tally?.addIntensity(intensity);
      tally?.addCastSpell(spell.id);
      if (probe != null) tally!.addCast(battle, intensity, probe);
    }
    if (!battle.isOver) battle.enemyTurn();
  }
  // 200턴 안전장치에 걸려 끝난 전투 (교착의 증거 — 0이어야 한다)
  if (!battle.isOver && battle.turnCount >= maxTurns) tally?.turnLimitBattles++;
  tally?.endBattle(battle, rollsThisBattle);
}

/// 새 판정을 위해 주사위를 처음 굴린다 (주사위 추가 효과가 걸려 있으면 그쪽으로).
void rollFresh(Battle battle, DicePool pool) {
  if (battle.pendingExtraDie) {
    pool.seed(battle.rollDice());
  } else {
    pool.rollAll();
  }
}

/// 굴림 + 리롤 정책: 예상 등급이 성공 미만이면 5·6을 잠그고 다시 굴린다.
void rollWithRerolls(Battle battle, DicePool pool, Spell spell,
    CastIntensity intensity, RelicPowers powers) {
  rollFresh(battle, pool);
  final dc = intensity.dc + spell.dcModifier;
  final intensityBonus = switch (intensity) {
    CastIntensity.full => powers.checkBonusFull,
    CastIntensity.normal => 0,
  };
  while (true) {
    final predicted = resolveCheck(
      dice: pool.values,
      dc: dc,
      modifier:
          powers.checkBonus + intensityBonus + battle.pendingCheckBonus,
      charge: battle.charge,
      pairBonus: kPairBonus + powers.pairBonusUp,
    );
    if (predicted.grade == CheckGrade.critSuccess ||
        predicted.grade == CheckGrade.success) {
      return;
    }
    final free = battle.freeRerollsLeft > 0;
    if (!pool.canReroll) return;
    final cost = rerollManaCost(pool.paidRerollCount);
    // 시전 비용을 남겨 두고도 리롤 값을 낼 수 있을 때만 리롤한다.
    // 보통이 마나 0이 되면서 이 조건을 통과하는 경우가 크게 늘었다
    // (v1에서는 시전에 1을 떼고 남은 마나로만 리롤할 수 있었다).
    if (!free && battle.mana - intensity.manaCost < cost) return;
    for (var i = 0; i < pool.values.length; i++) {
      final wantLock = pool.values[i] >= 5;
      if (pool.locked[i] != wantLock) pool.toggleLock(i);
    }
    if (!pool.canReroll) return;
    if (free) {
      battle.freeRerollsLeft--;
    } else {
      battle.mana -= cost;
    }
    pool.reroll(free: free);
  }
}

/// 주문 보상: 무작위 3장 중 최강을, 최약체 공격 주문과 교체.
/// 미해금 epic은 후보에서 제외된다.
void spellReward(
    List<Spell> hand, List<Spell> all, Random random, MetaState meta) {
  final available = all
      .where((s) =>
          s.rarity != 'epic' || meta.unlockedSpellIds.contains(s.id))
      .toList();
  final offers = List.generate(
      kRewardChoiceCount, (_) => available[random.nextInt(available.length)]);
  offers.sort((a, b) => b.baseDamage.compareTo(a.baseDamage));
  final best = offers.first;
  var weakest = -1;
  for (var i = 0; i < hand.length; i++) {
    if (hand[i].id == 'mana_shield') continue;
    if (weakest == -1 || hand[i].baseDamage < hand[weakest].baseDamage) {
      weakest = i;
    }
  }
  if (weakest != -1 && best.baseDamage > hand[weakest].baseDamage) {
    hand[weakest] = best;
  }
}

/// 유물 보상: 미보유 3개 중 등급 높은 것을 고른다 (사람의 선택 흉내).
void relicReward(List<Relic> owned, List<Relic> all, Random random) {
  const rank = {'epic': 2, 'rare': 1, 'common': 0};
  final candidates = all
      .where((r) => owned.every((o) => o.id != r.id))
      .toList()
    ..shuffle(random);
  final offers = candidates.take(kRewardChoiceCount).toList()
    ..sort((a, b) => rank[b.rarity]!.compareTo(rank[a.rarity]!));
  if (offers.isNotEmpty) owned.add(offers.first);
}
