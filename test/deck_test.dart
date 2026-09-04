/// 덱에서 손패 뽑기 검증 (GAME_DESIGN 4.2절 · WORK_ORDER_DECK_SIM 작업 1).
///
/// 핵심은 두 가지다.
///  1. `deck`을 주지 않으면 **기존과 완전히 같이** 동작한다 (손패 고정)
///  2. `deck`을 주면 매 턴 덱에서 중복 없이 3장을 뽑고, 직전 턴에 시전한
///     주문은 한 턴 쉬며, 봉인된 주문은 뽑히지 않는다
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/data/loader.dart';
import 'package:surge_wizard/models/enemy.dart';
import 'package:surge_wizard/models/spell.dart';

String readData(String name) => File('assets/data/$name').readAsStringSync();

void main() {
  final spells = GameDataParser.parseSpells(readData('spells.json'));
  final surges = GameDataParser.parseSurges(readData('surges.json'));

  Spell spellOf(String id) => spells.firstWhere((s) => s.id == id);

  /// 덱 검증용 허수아비 — 체력이 커서 전투가 도중에 끝나지 않는다
  Enemy dummy() => const Enemy(
        id: 'dummy',
        name: '허수아비',
        icon: 'slime',
        tier: 1,
        hp: 9999,
        isBoss: false,
        pattern: [
          EnemyAction(action: 'defend', value: 0, label: '버틴다'),
        ],
      );

  /// 손패 3장이 반드시 있어야 뽑기 규칙을 볼 수 있으므로 넉넉한 덱을 쓴다
  List<Spell> bigDeck() => [
        'ember_dart',
        'ice_shard',
        'magic_missile',
        'dark_pinch',
        'stone_throw',
        'healing_herb',
        'mana_shield',
        'chill_touch',
      ].map(spellOf).toList();

  List<Spell> starterHand() =>
      ['fireball', 'frost_arrow', 'mana_shield'].map(spellOf).toList();

  Battle makeBattle({List<Spell>? deck, int seed = 7}) => Battle(
        enemy: dummy(),
        hand: starterHand(),
        deck: deck,
        surgePool: surges,
        random: Random(seed),
      );

  test('1. deck이 없으면 손패는 턴이 지나도 그대로다 (기존 동작 보존)', () {
    final battle = makeBattle();
    final before = List.of(battle.hand);
    for (var i = 0; i < 5; i++) {
      battle.startTurn();
      expect(battle.hand, same(battle.hand));
      expect(battle.hand.map((s) => s.id).toList(),
          before.map((s) => s.id).toList());
    }
    expect(battle.handDeck, isNull);
  });

  test('2. deck을 주면 매 턴 덱에서 3장이 채워진다', () {
    final deck = bigDeck();
    final battle = makeBattle(deck: deck);
    final deckIds = deck.map((s) => s.id).toSet();
    for (var i = 0; i < 10; i++) {
      battle.startTurn();
      expect(battle.hand.length, kHandSize);
      for (final s in battle.hand) {
        expect(deckIds, contains(s.id));
      }
    }
  });

  test('3. 손패에 같은 주문이 두 장 들어가지 않는다', () {
    final battle = makeBattle(deck: bigDeck());
    for (var i = 0; i < 30; i++) {
      battle.startTurn();
      final ids = battle.hand.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
    }
  });

  test('4. 직전 턴에 시전한 주문은 다음 턴 손패에서 빠진다', () {
    final battle = makeBattle(deck: bigDeck());
    for (var turn = 0; turn < 20; turn++) {
      battle.startTurn();
      final cast = battle.hand[battle.castableIndexes.first];
      battle.castSpell(battle.castableIndexes.first, CastIntensity.normal);
      battle.startTurn();
      expect(battle.hand.map((s) => s.id), isNot(contains(cast.id)),
          reason: '$turn번째 턴에 시전한 ${cast.id}가 다음 턴에 또 나왔다');
      // 한 턴만 쉰다 — 그다음 턴부터는 다시 후보가 된다
    }
  });

  test('5. 덱이 정확히 3장이면 쉬는 규칙보다 3장 채우기가 우선이다', () {
    final deck = ['ember_dart', 'ice_shard', 'healing_herb'].map(spellOf).toList();
    final battle = makeBattle(deck: deck);
    for (var turn = 0; turn < 10; turn++) {
      // 아슬아슬 반동의 봉인이 섞이면 후보가 줄어든다 — 쉬는 규칙만 본다
      battle.sealedSpellIds.clear();
      battle.startTurn();
      expect(battle.hand.length, kHandSize);
      expect(battle.hand.map((s) => s.id).toSet(), deck.map((s) => s.id).toSet());
      battle.castSpell(0, CastIntensity.normal);
    }
  });

  test('6. 봉인된 주문은 뽑히지 않는다', () {
    final battle = makeBattle(deck: bigDeck());
    battle.sealedSpellIds.addAll(['ember_dart', 'ice_shard']);
    for (var i = 0; i < 30; i++) {
      battle.startTurn();
      final ids = battle.hand.map((s) => s.id);
      expect(ids, isNot(contains('ember_dart')));
      expect(ids, isNot(contains('ice_shard')));
      expect(battle.hand.length, kHandSize);
    }
  });

  test('7. 같은 시드면 같은 손패 순서가 나온다 (재현성)', () {
    List<List<String>> play(int seed) {
      final battle = makeBattle(deck: bigDeck(), seed: seed);
      return [
        for (var i = 0; i < 8; i++)
          () {
            battle.startTurn();
            battle.castSpell(0, CastIntensity.normal);
            return battle.hand.map((s) => s.id).toList();
          }()
      ];
    }

    expect(play(12345), play(12345));
    expect(play(12345), isNot(play(999)));
  });
}
