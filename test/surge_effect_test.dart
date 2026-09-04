/// 폭주 효과 적용 검증 (SURGE_DESIGN 4절).
/// 추첨에 맡기지 않고 SurgeEvent를 손으로 만들어 결정적으로 검사한다.
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/effect.dart';
import 'package:surge_wizard/models/spell.dart';
import 'package:surge_wizard/models/surge_event.dart';

String readData(String name) => File('assets/data/$name').readAsStringSync();

void main() {
  final spells = GameDataParser.parseSpells(readData('spells.json'));
  final enemies = GameDataParser.parseEnemies(readData('enemies.json'));

  Spell spellOf(String id) => spells.firstWhere((s) => s.id == id);

  /// 시작 손패: 화염구(위력7) / 서리화살(위력6) / 마력방패(위력0, 방어막6)
  List<Spell> starterHand() => kStarterSpellIds.map(spellOf).toList();

  /// 폭주 1종만 든 전투를 만든다 (추첨이 반드시 그것을 고른다)
  Battle makeBattle(List<GameEffect> effects,
          {String category = 'backlash', int hp = 20, int maxHp = 20}) =>
      Battle(
        enemy: enemies.firstWhere((e) => e.id == 'cave_rat'),
        hand: starterHand(),
        surgePool: [
          SurgeEvent(
            id: 'test_surge',
            name: '시험 폭주',
            text: '시험용이다',
            category: category,
            weight: 1,
            tags: const ['any'],
            effects: effects,
          ),
        ],
        playerHp: hp,
        playerMaxHp: maxHp,
        random: Random(1),
      );

  /// 판정을 거치지 않고 폭주만 직접 태운다 (결정적으로 만들기 위해서다)
  void surgeWith(Battle b,
          {String spellId = 'fireball',
          CastIntensity it = CastIntensity.normal}) =>
      b.surge.applySurge(spellOf(spellId), it);

  group('새 효과 4종', () {
    test('1. shield: 방어막이 오르고 다음 피해를 먼저 흡수한다', () {
      final b = makeBattle(const [GameEffect(type: 'shield', value: 6)],
          category: 'misfire');
      surgeWith(b);
      expect(b.shield, 6);
      b.dealToPlayer(4);
      expect(b.shield, 2);
      expect(b.playerHp, 20); // 체력은 아직 안 깎인다
      b.dealToPlayer(5);
      expect(b.shield, 0);
      expect(b.playerHp, 17); // 5 중 2만 흡수
    });

    test('2. enemy_heal: 적이 회복하되 최대 체력을 넘지 않는다', () {
      final b = makeBattle(const [GameEffect(type: 'enemy_heal', value: 6)],
          category: 'misfire');
      final maxHp = b.enemy.hp;
      b.enemyHp = maxHp - 2;
      surgeWith(b);
      expect(b.enemyHp, maxHp); // 2만 차고 잘린다
      surgeWith(b);
      expect(b.enemyHp, maxHp); // 이미 가득이면 그대로
    });

    test('3. self_damage_spell 100: 화염구(위력 7)로 정확히 7 피해', () {
      final b =
          makeBattle(const [GameEffect(type: 'self_damage_spell', value: 100)]);
      surgeWith(b);
      expect(b.playerHp, 20 - 7);
    });

    test('3-b. self_damage_spell 70: 7 × 0.7 = 4.9 → 반올림 5', () {
      final b =
          makeBattle(const [GameEffect(type: 'self_damage_spell', value: 70)]);
      surgeWith(b);
      expect(b.playerHp, 20 - 5);
    });

    test('4. ★ 시전 강도 배율이 곱해지지 않는다 (보통 = 전력)', () {
      final normal =
          makeBattle(const [GameEffect(type: 'self_damage_spell', value: 100)]);
      surgeWith(normal, it: CastIntensity.normal);

      final full =
          makeBattle(const [GameEffect(type: 'self_damage_spell', value: 100)]);
      surgeWith(full, it: CastIntensity.full);

      expect(full.playerHp, normal.playerHp);
      expect(full.playerHp, 20 - 7); // 전력(3배)이어도 21이 아니다
    });

    test('5. 위력 0 주문(마력방패)은 최소 기준값 4가 적용된다', () {
      final b =
          makeBattle(const [GameEffect(type: 'self_damage_spell', value: 100)]);
      surgeWith(b, spellId: 'mana_shield');
      expect(kBacklashMinPower, 4);
      expect(b.playerHp, 20 - 4); // 0이 아니다
    });

    test('6. ★ 자해 상한: 여러 자해 효과의 「총합」이 최대 체력의 40%로 잘린다', () {
      // 7(100%) + 7(100%) + 6(self_damage) = 20 → 상한 8
      final b = makeBattle(const [
        GameEffect(type: 'self_damage_spell', value: 100),
        GameEffect(type: 'self_damage_spell', value: 100),
        GameEffect(type: 'self_damage', value: 6),
      ]);
      surgeWith(b);
      expect(b.playerHp, 20 - 8);
    });

    test('6-b. 상한 미만이면 그대로 다 들어간다', () {
      // 7 × 0.6 = 4.2 → 4, + self_damage 2 = 6 (상한 8 미만)
      final b = makeBattle(const [
        GameEffect(type: 'self_damage_spell', value: 60),
        GameEffect(type: 'self_damage', value: 2),
      ]);
      surgeWith(b);
      expect(b.playerHp, 20 - 6);
    });

    test('6-c. 상한은 최대 체력 기준이고, 방어막은 그 뒤에 흡수한다', () {
      final b = makeBattle(const [
        GameEffect(type: 'self_damage_spell', value: 100),
        GameEffect(type: 'self_damage', value: 20),
      ], hp: 10, maxHp: 20);
      b.shield = 3;
      surgeWith(b);
      expect(b.shield, 0);
      expect(b.playerHp, 10 - (8 - 3)); // 8로 자른 뒤 방어막 3 흡수
    });
  });

  group('chain_cast (연쇄)', () {
    test('7. chain_cast 1: 손패의 「다른」 주문 1개가 적에게 터진다', () {
      final b = makeBattle(const [GameEffect(type: 'chain_cast', value: 1)],
          category: 'chain');
      final before = b.enemyHp;
      surgeWith(b); // 시전 주문은 화염구
      // 화염구를 뺀 첫 주문 = 서리화살(위력 6)
      expect(before - b.enemyHp, 6);
      expect(b.playerHp, 20); // 나는 안 다친다
    });

    test('8. chain_cast -1: 피해가 나에게 오고 부가 효과는 발동하지 않는다', () {
      // 마력방패를 시전 → 연쇄 대상 첫 주문은 화염구(위력 7)
      final b = makeBattle(const [GameEffect(type: 'chain_cast', value: -1)],
          category: 'chain');
      final enemyBefore = b.enemyHp;
      surgeWith(b, spellId: 'mana_shield');
      expect(b.playerHp, 20 - 7);
      expect(b.enemyHp, enemyBefore); // 적은 멀쩡하다
    });

    test('8-b. 음수 연쇄는 대상 주문의 부가 효과를 적용하지 않는다', () {
      // 화염구를 시전 → 대상은 서리화살(6), 마력방패(0, 방어막 6)
      final b = makeBattle(const [GameEffect(type: 'chain_cast', value: -2)],
          category: 'chain');
      surgeWith(b);
      expect(b.shield, 0); // 마력방패의 방어막이 붙으면 안 된다
      expect(b.playerHp, 20 - 6); // 6 + 0 = 6 (상한 8 미만)
    });

    test('9. chain_cast 2: 서로 다른 주문 2개가 터진다', () {
      final b = makeBattle(const [GameEffect(type: 'chain_cast', value: 2)],
          category: 'chain');
      final before = b.enemyHp;
      surgeWith(b);
      expect(before - b.enemyHp, 6); // 서리화살 6 + 마력방패 0
      expect(b.shield, 6); // 양수 연쇄는 부가 효과까지 적용된다
    });

    test('9-b. 손패가 모자라면 있는 만큼만 터진다', () {
      final b = makeBattle(const [GameEffect(type: 'chain_cast', value: 5)],
          category: 'chain');
      final before = b.enemyHp;
      surgeWith(b);
      expect(before - b.enemyHp, 6); // 다른 주문은 2개뿐
    });

    test('10. 봉인된 주문은 연쇄에 뽑히지 않는다', () {
      final b = makeBattle(const [GameEffect(type: 'chain_cast', value: 2)],
          category: 'chain');
      b.sealedSpellIds.add('frost_arrow');
      final before = b.enemyHp;
      surgeWith(b);
      expect(before - b.enemyHp, 0); // 마력방패(위력 0) 하나만 남는다
      expect(b.shield, 6);
    });
  });

  group('불발과 결과 요약', () {
    test('11. fizzle: 체력·마나·적 체력이 하나도 안 변한다', () {
      final b = makeBattle(const [], category: 'fizzle');
      final enemyBefore = b.enemyHp;
      final manaBefore = b.mana;
      surgeWith(b);
      expect(b.playerHp, 20);
      expect(b.mana, manaBefore);
      expect(b.enemyHp, enemyBefore);
      expect(b.shield, 0);
      expect(b.surge.summons, isEmpty);
    });

    test('12-a. 불발의 요약은 빈 문자열이다', () {
      final b = makeBattle(const [], category: 'fizzle');
      surgeWith(b);
      expect(b.surge.lastSurgeSummary, '');
    });

    test('12-b. 역류: 자해 합계가 「−N」 하나로 앞에 온다', () {
      final b = makeBattle(const [
        GameEffect(type: 'self_damage_spell', value: 100),
        GameEffect(type: 'mana_change', value: -1),
      ]);
      surgeWith(b);
      expect(b.surge.lastSurgeSummary, '−7  마나 −1');
    });

    test('12-c. 오발·증폭·소환·연쇄의 요약', () {
      final shield = makeBattle(const [GameEffect(type: 'shield', value: 6)],
          category: 'misfire');
      surgeWith(shield);
      expect(shield.surge.lastSurgeSummary, '방어막 6');

      final heal = makeBattle(const [GameEffect(type: 'enemy_heal', value: 8)],
          category: 'misfire');
      surgeWith(heal);
      expect(heal.surge.lastSurgeSummary, '적 +8');

      final amp = makeBattle(
          const [GameEffect(type: 'damage_multiplier', value: 3)],
          category: 'amplify');
      surgeWith(amp);
      expect(amp.surge.lastSurgeSummary, '×3');

      final summon = makeBattle(
          const [GameEffect(type: 'summon_ally', value: 4)],
          category: 'summon');
      surgeWith(summon);
      expect(summon.surge.lastSurgeSummary, '소환 4');

      final chain = makeBattle(const [GameEffect(type: 'chain_cast', value: 2)],
          category: 'chain');
      surgeWith(chain);
      expect(chain.surge.lastSurgeSummary, '연쇄 2');
    });

    test('12-d. 새 시전이 시작되면 요약이 지워진다', () {
      final b = makeBattle(const [], category: 'fizzle');
      surgeWith(b);
      expect(b.surge.lastSurgeSummary, isNotNull);
      b.startTurn();
      b.castSpell(0, CastIntensity.normal, dice: [6, 5, 4]); // 합 15 → 성공
      expect(b.surge.lastSurge, isNull);
      expect(b.surge.lastSurgeSummary, isNull);
    });
  });

  group('실데이터 정합성', () {
    test('surges.json 의 모든 효과 타입을 코드가 처리한다', () {
      const handled = {
        'self_damage',
        'self_damage_spell',
        'chain_cast',
        'heal',
        'shield',
        'enemy_heal',
        'mana_change',
        'seal_spell',
        'swap_hp',
        'summon_ally',
        'damage_multiplier',
        'skip_enemy_turn',
        'extra_die',
        'force_reroll',
      };
      final surges = GameDataParser.parseSurges(readData('surges.json'));
      final used = {
        for (final s in surges)
          for (final e in s.effects) e.type,
      };
      expect(used.difference(handled), isEmpty);
    });
  });
}
