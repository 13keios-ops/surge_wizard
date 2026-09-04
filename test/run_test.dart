/// 런 진행(RunController)·유물 효과(RelicPowers) 단위 테스트.
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/check.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/core/dice.dart';
import 'package:surge_wizard/core/relic_powers.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/run_state.dart';
import 'package:surge_wizard/models/spell.dart';
import 'package:surge_wizard/models/surge_event.dart';
import 'package:surge_wizard/screens/run_controller.dart';

String readData(String name) => File('assets/data/$name').readAsStringSync();

/// [floors]층 스테이지에서 [event]가 나오는 첫 층을 찾는다
int _floorWith(FloorEvent event, int floors) => List.generate(
        floors, (i) => i + 1)
    .firstWhere((f) => floorEvent(f, floors) == event,
        orElse: () => throw StateError('$floors층에 $event 층이 없다'));

void main() {
  final data = GameDataParser.parseAll(readData);

  List<Spell> starterHand() => kStarterSpellIds
      .map((id) => data.spells.firstWhere((s) => s.id == id))
      .toList();

  Battle makeBattle({
    RelicPowers relics = const RelicPowers(),
    int? hp,
    int? maxHp,
    List<SurgeEvent>? surges,
    int seed = 1,
  }) =>
      Battle(
        enemy: data.enemies.firstWhere((e) => e.id == 'cave_rat'),
        hand: starterHand(),
        surgePool: surges ?? data.surges,
        playerHp: hp,
        playerMaxHp: maxHp,
        relics: relics,
        random: Random(seed),
      );

  group('RelicPowers 합산', () {
    test('같은 유형은 더해지고, reroll_ones는 최댓값을 쓴다', () {
      final relics = [
        data.relics.firstWhere((r) => r.id == 'worn_lucky_coin'), // 판정 +1
        data.relics.firstWhere((r) => r.id == 'bent_horseshoe'), // 판정 +1
        data.relics.firstWhere((r) => r.id == 'loaded_die'), // 1 → 2
        data.relics.firstWhere((r) => r.id == 'golden_loaded_die'), // 1 → 3
        data.relics.firstWhere((r) => r.id == 'giant_belt'), // 최대체력 +5
      ];
      final p = RelicPowers.fromRelics(relics);
      expect(p.checkBonus, 2);
      expect(p.rerollOnesTo, 3);
      expect(p.maxHpUp, 5);
    });
  });

  group('유물 효과가 전투에 반영된다', () {
    test('check_bonus: 판정값이 올라 등급이 바뀐다', () {
      // 2-3-6 = 11, DC 13이면 아슬아슬. 판정 +2면 13 = 성공.
      final plain = makeBattle()..startTurn();
      plain.castSpell(0, CastIntensity.full, dice: [2, 3, 6]);
      expect(plain.lastResult!.grade, CheckGrade.graze);

      final boosted = makeBattle(relics: const RelicPowers(checkBonus: 2))
        ..startTurn();
      boosted.castSpell(0, CastIntensity.full, dice: [2, 3, 6]);
      expect(boosted.lastResult!.grade, CheckGrade.success);
    });

    test('check_bonus_full은 전력 시전에만 붙는다', () {
      final b = makeBattle(relics: const RelicPowers(checkBonusFull: 3))
        ..startTurn();
      b.castSpell(0, CastIntensity.normal, dice: [2, 3, 6]);
      expect(b.lastResult!.finalValue, 11); // 보통 시전에는 미적용
      final b2 = makeBattle(relics: const RelicPowers(checkBonusFull: 3))
        ..startTurn();
      b2.castSpell(0, CastIntensity.full, dice: [2, 3, 6]);
      expect(b2.lastResult!.finalValue, 14);
    });

    test('pair_bonus_up: 페어 보너스가 커진다', () {
      final b = makeBattle(relics: const RelicPowers(pairBonusUp: 2))
        ..startTurn();
      b.castSpell(0, CastIntensity.normal, dice: [4, 4, 2]);
      expect(b.lastResult!.finalValue, 10 + kPairBonus + 2);
    });

    test('damage_up: 공격 주문만 세지고 보조 주문(0)은 그대로', () {
      final b = makeBattle(relics: const RelicPowers(damageUp: 2))
        ..startTurn();
      final before = b.enemyHp;
      b.castSpell(0, CastIntensity.normal, dice: [2, 4, 5]); // 성공
      expect(before - b.enemyHp, 7 + 2); // 화염구 7 + 2

      final b2 = makeBattle(relics: const RelicPowers(damageUp: 2))
        ..startTurn();
      final before2 = b2.enemyHp;
      b2.castSpell(2, CastIntensity.normal, dice: [2, 4, 5]); // 마력방패
      expect(b2.enemyHp, before2); // 대미지 0 유지
    });

    test('start_shield: 전투 시작 방어막', () {
      final b = makeBattle(relics: const RelicPowers(startShield: 5));
      expect(b.shield, 5);
    });

    test('heal_on_crit: 대성공 시 회복', () {
      final b = makeBattle(
          relics: const RelicPowers(healOnCrit: 2), hp: 10, maxHp: 20)
        ..startTurn();
      b.castSpell(0, CastIntensity.normal, dice: [6, 6, 6]);
      expect(b.playerHp, 12);
    });

    test('charge_gain_up: 실패 시 마력 축적이 더 오른다', () {
      final b = makeBattle(relics: const RelicPowers(chargeGainUp: 1))
        ..startTurn();
      b.castSpell(0, CastIntensity.full, dice: [2, 3, 4]); // 합9<10 → 실패
      expect(b.charge, kFailChargeGain + 1);
    });

    test('mana_on_surge: 폭주 시 마나 회복', () {
      // 불발(효과 없음) 1종만 두어 결정적으로 만든다 — 마나에 손대지 않는다
      final benign = [
        SurgeEvent(
          id: 'test_surge',
          name: '시험 폭주',
          text: '아무 일도 없었다.',
          category: 'fizzle',
          weight: 1,
          tags: const ['any'],
          effects: const [],
        ),
      ];
      final b = makeBattle(
          relics: const RelicPowers(manaOnSurge: 2), surges: benign)
        ..startTurn();
      b.castSpell(0, CastIntensity.full, dice: [2, 3, 4]); // 마나 3→1, 실패
      expect(b.mana, 3); // 1 + 2 회복
    });

    test('reroll_ones: 굴림에서 1이 나오지 않는다', () {
      final b = makeBattle(relics: const RelicPowers(rerollOnesTo: 2));
      for (var i = 0; i < 200; i++) {
        expect(b.rollDice().contains(1), isFalse);
      }
    });

    test('DicePool: maxRerolls 확장과 faceTransform', () {
      final pool = DicePool(
        random: Random(5),
        maxRerolls: kMaxRerollsPerCheck + 2,
        faceTransform: (f) => f == 1 ? 2 : f,
      );
      pool.rollAll();
      var count = 0;
      while (pool.reroll()) {
        count++;
        expect(pool.values.contains(1), isFalse);
      }
      expect(count, kMaxRerollsPerCheck + 2);
    });
  });

  group('RunController 런 진행', () {
    RunController makeRun({
      int seed = 1,
      int regionId = kEntryRegionId,
      int stageIndex = kEntryStageIndex,
    }) =>
        RunController(
            data: data,
            random: Random(seed),
            regionId: regionId,
            stageIndex: stageIndex)
          ..startRun();

    test('시작 상태: 1층, 체력 20, 시작 손패, 지역 tier 풀 안의 적', () {
      final run = makeRun();
      expect(run.state.floor, 1);
      expect(run.state.hp, kPlayerStartHp);
      expect(run.hand.map((s) => s.id), kStarterSpellIds);
      expect(run.region.tierPool.keys, contains('${run.currentEnemy.tier}'));
      expect(run.currentEnemy.isBoss, isFalse);
    });

    test('마지막 층에 지역 보스가 서고 그 앞은 일반 적이다', () {
      final run = makeRun(regionId: 4, stageIndex: 1);
      for (var floor = 1; floor < run.floors; floor++) {
        run.state.floor = floor - 1;
        run.advanceFloor(); // floor로 이동하며 적을 뽑는다
        expect(run.currentEnemy.isBoss, isFalse, reason: '$floor층');
      }
      run.state.floor = run.floors - 1;
      run.advanceFloor();
      expect(run.currentEnemy.isBoss, isTrue);
      expect(run.currentEnemy.id, run.region.bossId);
    });

    test('주문 보상 층 승리 후 3종 (손패 제외, 중복 없음) → 교체 동작', () {
      // 주문 보상은 3의 배수 층이므로 8층짜리 스테이지에서 확인한다
      final run = makeRun(regionId: 9, stageIndex: 1);
      run.state.floor = _floorWith(FloorEvent.spellReward, run.floors);
      final battle = makeBattle()..enemyHp = 0;
      run.afterVictory(battle);
      expect(run.spellOffers.length, kRewardChoiceCount);
      final ids = run.spellOffers.map((s) => s.id).toSet();
      expect(ids.length, kRewardChoiceCount);
      expect(ids.intersection(run.state.handIds.toSet()), isEmpty);

      final chosen = run.spellOffers.first;
      run.takeSpell(chosen, 0);
      expect(run.state.handIds[0], chosen.id);
      expect(run.spellOffers, isEmpty);
    });

    test('유물 보상 층 승리 후 → 최대 체력 유물은 현재 체력도 올린다', () {
      final run = makeRun(regionId: 4, stageIndex: 1);
      run.state.floor = _floorWith(FloorEvent.relicReward, run.floors);
      run.afterVictory(makeBattle()..enemyHp = 0);
      expect(run.relicOffers.length, kRewardChoiceCount);

      final belt = data.relics.firstWhere((r) => r.id == 'giant_belt');
      final hpBefore = run.state.hp;
      run.takeRelic(belt);
      expect(run.maxHp, kPlayerStartHp + 5);
      expect(run.state.hp, hpBefore + 5);
    });

    test('상점 회복은 최대 체력의 30%이고 최대치를 넘지 않는다', () {
      final run = makeRun();
      final heal = shopHealAmount(run.maxHp);
      expect(heal, (run.maxHp * kShopHealRatio).round());
      run.state.hp = 5;
      run.shopHeal();
      expect(run.state.hp, 5 + heal); // 회복시킨다
      run.state.hp = kPlayerStartHp - 3;
      run.shopHeal();
      expect(run.state.hp, kPlayerStartHp); // 최대치를 넘지 않는다
    });

    test('승리 반영: 마력 축적 이어받기 + 유물 회복과 전투 승리 회복이 **더해진다**', () {
      final run = makeRun();
      run.state.relicIds.add('cozy_scarf'); // 전투 후 +2
      final win = battleWinHealAmount(run.maxHp); // 최대 체력의 12%
      expect(win, (kPlayerStartHp * kBattleWinHealRatio).round());
      final battle = makeBattle(hp: 10, maxHp: kPlayerStartHp)
        ..enemyHp = 0
        ..charge = 2;
      run.afterVictory(battle);
      // 유물 +2를 **대체하지 않고 더한다**
      expect(run.state.hp, 10 + 2 + win);
      expect(run.state.charge, 2);
    });

    test('전투 승리 회복은 최대 체력을 넘지 않는다', () {
      final run = makeRun();
      run.afterVictory(makeBattle(hp: kPlayerStartHp - 1, maxHp: kPlayerStartHp)
        ..enemyHp = 0);
      expect(run.state.hp, kPlayerStartHp);
    });

    test('보스 층에서는 전투 승리 회복이 없다', () {
      final run = makeRun();
      run.state.floor = run.floors; // 마지막 층 = 보스
      expect(run.currentEvent, FloorEvent.boss);
      run.afterVictory(makeBattle(hp: 10, maxHp: kPlayerStartHp)..enemyHp = 0);
      expect(run.state.hp, 10);
    });
  });

  group('RunState 저장 형식', () {
    test('toJson/fromJson 왕복이 값을 보존한다', () {
      final s = RunState.initial(
          regionId: 7, stageIndex: 3, difficulty: Difficulty.death)
        ..floor = 5
        ..hp = 13
        ..charge = 2;
      s.relicIds.add('loaded_die');
      final restored = RunState.fromJson(s.toJson());
      expect(restored.regionId, 7);
      expect(restored.stageIndex, 3);
      expect(restored.difficulty, Difficulty.death);
      expect(restored.floor, 5);
      expect(restored.hp, 13);
      expect(restored.charge, 2);
      expect(restored.handIds, s.handIds);
      expect(restored.relicIds, ['loaded_die']);
    });
  });
}
