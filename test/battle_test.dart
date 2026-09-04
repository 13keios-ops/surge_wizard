/// 전투 로직 검증: 화면 없이 실제 데이터로 전투를 끝까지 시뮬레이션한다.
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/check.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/core/relic_powers.dart';
import 'package:surge_wizard/data/loader.dart';
import 'package:surge_wizard/screens/battle_controller.dart';
import 'package:surge_wizard/models/enemy.dart';
import 'package:surge_wizard/models/spell.dart';

String readData(String name) => File('assets/data/$name').readAsStringSync();

void main() {
  final spells = GameDataParser.parseSpells(readData('spells.json'));
  final surges = GameDataParser.parseSurges(readData('surges.json'));
  final enemies = GameDataParser.parseEnemies(readData('enemies.json'));

  /// 시작 손패: 화염구 / 서리화살 / 마력방패 (GAME_DESIGN 4.2절)
  List<Spell> starterHand() => ['fireball', 'frost_arrow', 'mana_shield']
      .map((id) => spells.firstWhere((s) => s.id == id))
      .toList();

  /// 단순 정책으로 전투를 끝까지 돌린다. 종료까지 걸린 턴 수를 돌려준다.
  int runBattle(Battle battle, {int maxTurns = 300}) {
    while (!battle.isOver && battle.turnCount < maxTurns) {
      battle.startTurn();
      final castable = battle.castableIndexes;
      if (castable.isNotEmpty) {
        // 「보통」은 마나 0이라 언제나 낼 수 있다 (GAME_DESIGN v2 3.3절)
        battle.castSpell(castable.first, CastIntensity.normal);
      }
      if (!battle.isOver) battle.enemyTurn();
    }
    return battle.turnCount;
  }

  group('전투 시뮬레이션 (실데이터)', () {
    test('tier 1 적과의 전투가 정상 종료된다 (시드 20종)', () {
      final slime = enemies.firstWhere((e) => e.id == 'green_slime');
      for (var seed = 0; seed < 20; seed++) {
        final battle = Battle(
          enemy: slime,
          hand: starterHand(),
          surgePool: surges,
          random: Random(seed),
        );
        final turns = runBattle(battle);
        expect(battle.isOver, isTrue, reason: '시드 $seed: $turns턴에도 안 끝남');
        expect(battle.playerHp <= 0 || battle.enemyHp <= 0, isTrue);
      }
    });

    test('모든 적 39종과의 전투가 전부 정상 종료된다', () {
      for (final enemy in enemies) {
        final battle = Battle(
          enemy: enemy,
          hand: starterHand(),
          surgePool: surges,
          random: Random(enemy.id.hashCode),
        );
        runBattle(battle);
        expect(battle.isOver, isTrue, reason: enemy.id);
      }
    });

    test('보스전에서 2페이즈 전환이 일어날 수 있다', () {
      final boss = enemies.firstWhere((e) => e.id == 'boss_archlich');
      var phase2Seen = false;
      // 여러 시드로 돌려 한 번이라도 2페이즈 로그가 찍히면 성공
      for (var seed = 0; seed < 30 && !phase2Seen; seed++) {
        final battle = Battle(
          enemy: boss,
          hand: starterHand(),
          surgePool: surges,
          playerHp: 2000, // 보스 후반까지 살아남도록 체력만 넉넉히
          random: Random(seed),
        );
        runBattle(battle);
        phase2Seen = battle.log.any((l) => l.contains('2페이즈'));
      }
      expect(phase2Seen, isTrue);
    });
  });

  group('적 행동 규칙 (고정 패턴)', () {
    // 검증용 수제 적: 공격3 → 강타예고10 → 방어5 순환
    final dummy = Enemy(
      id: 'test_dummy',
      name: '허수아비',
      icon: 'dummy',
      hp: 999,
      tier: 1,
      isBoss: false,
      pattern: const [
        EnemyAction(action: 'attack', value: 3, label: '때리기'),
        EnemyAction(action: 'charge', value: 10, label: '강타 준비'),
        EnemyAction(action: 'defend', value: 5, label: '막기'),
      ],
    );

    Battle freshBattle({int? hp}) => Battle(
          enemy: dummy,
          hand: starterHand(),
          surgePool: surges,
          playerHp: hp ?? 100,
          random: Random(1),
        );

    test('예고(telegraph)가 패턴 순서대로 나온다', () {
      final b = freshBattle();
      expect(b.telegraph.label, '때리기');
      b.enemyTurn(); // 공격 실행
      expect(b.telegraph.label, '강타 준비');
    });

    test('공격은 체력을 깎고, 방어막이 있으면 먼저 깎인다', () {
      final b = freshBattle(hp: 100);
      b.shield = 2;
      b.enemyTurn(); // 공격 3 → 방어막 2 흡수, 체력 1 감소
      expect(b.shield, 0);
      expect(b.playerHp, 99);
    });

    test('강타(charge)는 예고 턴에는 안 터지고 다음 턴에 터진다', () {
      final b = freshBattle(hp: 100);
      b.enemyTurn(); // 공격 3 → 97
      b.enemyTurn(); // 강타 준비 (대미지 없음)
      expect(b.playerHp, 97);
      b.enemyTurn(); // 강타 10 → 87
      expect(b.playerHp, 87);
    });

    test('강타 대기 중에는 예고(telegraph)가 강타를 보여준다', () {
      final b = freshBattle(hp: 100);
      b.enemyTurn(); // 공격
      b.enemyTurn(); // 강타 준비 → 이제 다음 행동은 강타 그 자체
      expect(b.telegraph.action, 'attack');
      expect(b.telegraph.value, 10);
      b.enemyTurn(); // 강타 발동 후에는 패턴 순환으로 복귀
      expect(b.telegraph.label, '막기');
    });

    test('적 행동 지연(enemyDelayTurns)이 턴을 건너뛴다', () {
      final b = freshBattle(hp: 100);
      b.enemyDelayTurns = 1;
      b.enemyTurn(); // 지연으로 건너뜀
      expect(b.playerHp, 100);
      b.enemyTurn(); // 이제 공격 3
      expect(b.playerHp, 97);
    });

    test('defend는 적 방어막을 만들고 플레이어 대미지가 먼저 깎는다', () {
      final b = freshBattle();
      b.enemyTurn(); // attack
      b.enemyTurn(); // charge 예고
      b.enemyTurn(); // 강타 발동
      b.enemyTurn(); // defend 5
      expect(b.enemyShield, 5);
      final hpBefore = b.enemyHp;
      // 화염구로 강제 대성공 시전: 트리플 6은 무조건 대성공
      b.mana = 3;
      b.castSpell(0, CastIntensity.normal, dice: [6, 6, 6]);
      // 화염구 7 × 2배 = 14 중 방어막 5 흡수 → 체력 9 감소
      expect(b.enemyShield, 0);
      expect(b.enemyHp, hpBefore - 9);
    });
  });

  group('보스 2페이즈와 예고 일관성', () {
    // 시험용 보스: 임계 40, 1페이즈는 약공격, 2페이즈는 강공격
    final testBoss = Enemy(
      id: 'test_boss',
      name: '시험 보스',
      icon: 'x',
      hp: 45,
      tier: 5,
      isBoss: true,
      pattern: const [
        EnemyAction(action: 'attack', value: 2, label: '느린 주먹'),
        EnemyAction(action: 'attack', value: 2, label: '느린 주먹'),
        EnemyAction(action: 'attack', value: 2, label: '느린 주먹'),
      ],
      phase2HpThreshold: 40,
      phase2Pattern: const [
        EnemyAction(action: 'attack', value: 9, label: '분노의 연타'),
        EnemyAction(action: 'attack', value: 9, label: '분노의 연타'),
        EnemyAction(action: 'attack', value: 9, label: '분노의 연타'),
      ],
    );

    test('임계 돌파 턴에는 예고된 행동이 그대로 나오고, 다음 예고부터 2페이즈', () {
      final b = Battle(
        enemy: testBoss,
        hand: starterHand(),
        surgePool: surges,
        playerHp: 100,
        random: Random(1),
      );
      b.startTurn();
      expect(b.telegraph.label, '느린 주먹');
      // 성공 시전(화염구 7): 45 → 38 로 임계(40) 돌파
      b.castSpell(0, CastIntensity.normal, dice: [2, 4, 5]);
      expect(b.enemyHp, 38);
      // 아직 적 턴 전: 예고는 그대로 (예고를 보고 시전한 유저와의 약속)
      expect(b.telegraph.label, '느린 주먹');
      final hpBefore = b.playerHp;
      b.enemyTurn();
      // 예고된 약공격이 실행됐고 (2 대미지), 전환은 그 뒤에 일어난다
      expect(b.playerHp, hpBefore - 2);
      expect(b.log.any((l) => l.contains('2페이즈')), isTrue);
      expect(b.telegraph.label, '분노의 연타');
    });
  });

  group('판정 결과가 전투에 반영된다', () {
    final rat = enemies.firstWhere((e) => e.id == 'cave_rat');

    Battle freshBattle(int seed) => Battle(
          enemy: rat,
          hand: starterHand(),
          surgePool: surges,
          random: Random(seed),
        );

    test('대성공: 위력 2배 + 마나 환급 + 적 지연', () {
      final b = freshBattle(1);
      b.startTurn(); // 마나 3 유지 (최대)
      b.castSpell(0, CastIntensity.normal, dice: [6, 6, 6]);
      expect(b.enemyHp, rat.hp - 14); // 화염구 7 × 1.0 × 2
      expect(b.mana, 3); // 1 소모 후 1 환급
      expect(b.enemyDelayTurns, 1);
    });

    test('성공: 정상 위력', () {
      final b = freshBattle(1);
      b.startTurn();
      // 합 11, 족보 없음 → DC 10 성공
      b.castSpell(0, CastIntensity.normal, dice: [2, 4, 5]);
      expect(b.enemyHp, rat.hp - 7);
    });

    test('실패(뱀눈): 주문 미발동 + 폭주 + 마력 축적 +2', () {
      final b = freshBattle(3);
      b.startTurn();
      final hpBefore = b.enemyHp;
      b.castSpell(0, CastIntensity.full, dice: [1, 1, 3]);
      expect(b.charge, 2); // 뱀눈 축적 +2
      expect(b.log.any((l) => l.contains('폭주')), isTrue);
      // 주문 자체는 불발이므로 적 체력은 늘어날 수 없다
      // (폭주 효과의 소환수·도박형 대미지로 줄어드는 것만 가능)
      expect(b.enemyHp <= hpBefore, isTrue);
    });

    test('마력 축적 3이면 다음 시전은 무조건 대성공 후 게이지 초기화', () {
      final b = freshBattle(1);
      b.charge = 3;
      b.startTurn();
      // 최악의 눈(뱀눈)이어도 확정 대성공
      b.castSpell(0, CastIntensity.full, dice: [1, 2, 1]);
      expect(b.enemyHp, rat.hp - 42); // 7 × 3.0 × 2 = 42
      expect(b.charge, 0);
    });

    test('아슬아슬: 위력 50% + 반동 1개', () {
      final b = freshBattle(7);
      b.startTurn();
      // 합 9, 족보 없음(1-2-6) → DC 10 기준 아슬아슬
      b.castSpell(0, CastIntensity.normal, dice: [1, 2, 6]);
      expect(b.enemyHp, rat.hp - 4); // 7 × 0.5 = 3.5 → 반올림 4
      expect(b.log.any((l) => l.contains('반동')), isTrue);
    });

    test('스트레이트: 성공 시 다른 주문 1개가 동시 시전된다', () {
      final b = freshBattle(1);
      b.startTurn();
      // 4-5-6 스트레이트, 합 15 → DC 10 대성공 + 동시 시전
      b.castSpell(0, CastIntensity.normal, dice: [4, 5, 6]);
      // 화염구 7×2=14 + 서리화살 6×1=6 동시 시전 → 총 20
      expect(b.enemyHp, rat.hp - 20);
      expect(b.log.any((l) => l.contains('동시 시전')), isTrue);
    });
  });

  // 밸런스 개정 (지연 상한·리롤 체증) 검증
  group('밸런스 개정: 지연 상한·리롤 체증', () {
    final rat = enemies.firstWhere((e) => e.id == 'cave_rat');
    final boss = enemies.firstWhere((e) => e.isBoss);

    Battle freshBattle(Enemy enemy, int seed) => Battle(
          enemy: enemy,
          hand: starterHand(),
          surgePool: surges,
          random: Random(seed),
        );

    test('대성공을 여러 번 내도 적 지연이 상한(2턴)을 넘지 않는다', () {
      final b = freshBattle(boss, 1);
      b.maxMana = 9;
      b.mana = 9;
      for (var i = 0; i < 4; i++) {
        b.castSpell(0, CastIntensity.normal, dice: [6, 6, 6]);
      }
      expect(b.enemyDelayTurns, kMaxEnemyDelayStack);
    });

    test('「전력」 대성공이 마나를 2 환급한다', () {
      final b = freshBattle(rat, 1);
      b.mana = 2;
      b.castSpell(0, CastIntensity.full, dice: [6, 6, 6]);
      // 비용 2 → 0, 대성공 환급 +2
      expect(b.mana, kCritManaRefundFull);
    });

    test('「보통」 대성공은 강등되지 않고 그대로 집계된다', () {
      final b = freshBattle(rat, 1);
      b.startTurn();
      b.castSpell(0, CastIntensity.normal, dice: [6, 6, 6]);
      expect(b.lastAppliedGrade, CheckGrade.critSuccess);
      expect(b.gradeCounts[CheckGrade.critSuccess], 1);
    });

    test('무료 리롤은 비용 회차를 올리지 않는다', () {
      final c = BattleController(
        data: GameData(
            spells: spells,
            surges: surges,
            enemies: enemies,
            relics: const [],
            regions: const [],
            stages: const [],
            variants: const [],
            circleSlots: const []),
        random: Random(1),
      )..startBattle(
          enemy: rat,
          hand: starterHand(),
          maxMana: 10,
          relics: const RelicPowers(freeRerolls: 1),
        );
      c.selectSpell(0);
      c.selectIntensity(CastIntensity.normal);
      c.rollDice();
      final before = c.battle.mana;
      expect(c.nextRerollIsFree, isTrue);
      c.reroll(); // 무료 — 회차를 올리지 않는다
      expect(c.battle.mana, before);
      expect(c.nextRerollCost, kRerollManaCosts.first); // 여전히 1
      c.reroll();
      expect(c.battle.mana, before - 1);
      expect(c.nextRerollCost, kRerollManaCosts[1]); // 그 다음이 2
    });

    test('리롤 3회의 총 마나 비용이 6이다 (1+2+3)', () {
      final c = BattleController(
        data: GameData(
            spells: spells,
            surges: surges,
            enemies: enemies,
            relics: const [],
            regions: const [],
            stages: const [],
            variants: const [],
            circleSlots: const []),
        random: Random(1),
      )..startBattle(
          enemy: rat,
          hand: starterHand(),
          maxMana: 10,
        );
      c.selectSpell(0);
      c.selectIntensity(CastIntensity.normal); // 시전 비용 0으로 리롤만 측정
      c.rollDice();
      final before = c.battle.mana;
      final costs = <int>[];
      while (c.canReroll) {
        costs.add(c.nextRerollCost);
        c.reroll();
      }
      expect(costs, kRerollManaCosts); // 1 → 2 → 3
      expect(before - c.battle.mana, 6);
    });
  });
}
