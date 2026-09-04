/// 측정 코드 자체가 옳은지 검사한다 (WORK_ORDER_SIM 3-B).
/// 측정 코드가 틀리면 보고서의 모든 숫자가 거짓말이 되므로 여기가 가장 앞선다.
///
/// ⚠ 이 파일은 밸런스 수치를 단언하지 않는다. 「세는 방법」만 본다.
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/core/dice.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/effect.dart';
import 'package:surge_wizard/models/spell.dart';
import 'package:surge_wizard/models/surge_event.dart';

import '../tool/sim_core.dart';

String readData(String name) => File('assets/data/$name').readAsStringSync();

void main() {
  final spells = GameDataParser.parseSpells(readData('spells.json'));
  final enemies = GameDataParser.parseEnemies(readData('enemies.json'));

  Spell spellOf(String id) => spells.firstWhere((s) => s.id == id);
  List<Spell> starterHand() => kStarterSpellIds.map(spellOf).toList();

  /// 폭주 1종만 든 전투 (추첨이 반드시 그것을 고른다)
  Battle makeBattle(List<GameEffect> effects, {int hp = 20, int maxHp = 20}) =>
      Battle(
        enemy: enemies.firstWhere((e) => e.id == 'cave_rat'),
        hand: starterHand(),
        surgePool: [
          SurgeEvent(
            id: 'test_surge',
            name: '시험 폭주',
            text: '시험용이다',
            category: 'backlash',
            weight: 1,
            tags: const ['any'],
            effects: effects,
          ),
        ],
        playerHp: hp,
        playerMaxHp: maxHp,
        random: Random(1),
      );

  group('1. 굴림 횟수 세기', () {
    test('리롤을 하지 않으면 굴림은 1회다', () {
      final tally = Tally();
      final pool = DicePool(random: Random(7))..rollAll();
      tally.addRolls(pool);
      expect(tally.rolls, 1);
      expect(tally.checks, 1);
      expect(tally.rerolls, 0);
      expect(tally.paidRerolls, 0);
    });

    test('2회 리롤하면 굴림은 3회다', () {
      final tally = Tally();
      final pool = DicePool(random: Random(7))..rollAll();
      pool
        ..reroll()
        ..reroll();
      tally.addRolls(pool);
      expect(tally.rolls, 3);
      expect(tally.checks, 1);
      expect(tally.rerolls, 2);
      expect(tally.paidRerolls, 2);
    });

    test('무료 리롤은 굴림·리롤에는 세되 유료에는 세지 않는다', () {
      final tally = Tally();
      final pool = DicePool(random: Random(7))..rollAll();
      pool
        ..reroll(free: true)
        ..reroll();
      tally.addRolls(pool);
      expect(tally.rolls, 3);
      expect(tally.rerolls, 2);
      expect(tally.paidRerolls, 1);
    });

    test('여러 판정을 이어 세면 판정마다 초기 굴림 1회가 더해진다', () {
      final tally = Tally();
      final pool = DicePool(random: Random(7));
      pool.rollAll();
      pool.reroll();
      tally.addRolls(pool); // 굴림 2
      pool.rollAll(); // 새 판정이라 리롤 횟수가 초기화된다
      tally.addRolls(pool); // 굴림 1
      expect(tally.checks, 2);
      expect(tally.rolls, 3);
      expect(tally.rerolls, 1);
    });
  });

  group('2~4. 폭주 자해 상한 계측', () {
    /// 체력 20 기준 상한 = (20 × 0.4).floor() = 8
    final cap = (20 * kSurgeSelfDamageMaxRatio).floor();

    test('2. raw 는 언제나 applied 이상이다 (상한은 자르기만 한다)', () {
      for (final value in [1, 4, 8, 12, 30]) {
        final b = makeBattle([GameEffect(type: 'self_damage', value: value)],
            hp: 100, maxHp: 20);
        b.surge.applySurge(spellOf('fireball'), CastIntensity.normal);
        expect(b.surgeSelfDamageRaw, greaterThanOrEqualTo(b.surgeSelfDamageApplied),
            reason: 'value=$value 에서 raw < applied 가 됐다');
      }
    });

    test('3. 상한에 걸리지 않으면 두 값이 같다', () {
      final b = makeBattle([GameEffect(type: 'self_damage', value: cap - 1)]);
      b.surge.applySurge(spellOf('fireball'), CastIntensity.normal);
      expect(b.surgeSelfDamageRaw, cap - 1);
      expect(b.surgeSelfDamageApplied, cap - 1);
    });

    test('4. 상한에 걸리면 applied 는 최대 체력의 40% (내림)이다', () {
      final b = makeBattle([const GameEffect(type: 'self_damage', value: 99)],
          hp: 100, maxHp: 20);
      b.surge.applySurge(spellOf('fireball'), CastIntensity.normal);
      expect(b.surgeSelfDamageRaw, 99);
      expect(b.surgeSelfDamageApplied, cap);
      expect(b.surgeSelfDamageApplied,
          (b.playerMaxHp * kSurgeSelfDamageMaxRatio).floor());
    });

    test('4-b. 효과가 여러 개여도 「합산한 뒤」 한 번만 자른다', () {
      final b = makeBattle(const [
        GameEffect(type: 'self_damage', value: 6),
        GameEffect(type: 'self_damage', value: 6),
      ], hp: 100, maxHp: 20);
      b.surge.applySurge(spellOf('fireball'), CastIntensity.normal);
      expect(b.surgeSelfDamageRaw, 12);
      expect(b.surgeSelfDamageApplied, cap);
    });

    test('폭주가 여러 번 터지면 누적된다 (전투 단위 합계다)', () {
      final b = makeBattle([GameEffect(type: 'self_damage', value: cap - 1)],
          hp: 100, maxHp: 20);
      b.surge
        ..applySurge(spellOf('fireball'), CastIntensity.normal)
        ..applySurge(spellOf('fireball'), CastIntensity.normal);
      expect(b.surgeSelfDamageRaw, (cap - 1) * 2);
      expect(b.surgeSelfDamageApplied, (cap - 1) * 2);
    });

    test('자해가 없는 폭주는 두 값을 건드리지 않는다', () {
      final b = makeBattle(const [GameEffect(type: 'heal', value: 3)]);
      b.surge.applySurge(spellOf('fireball'), CastIntensity.normal);
      expect(b.surgeSelfDamageRaw, 0);
      expect(b.surgeSelfDamageApplied, 0);
    });
  });

  group('5. 등급 귀속 (원래 판정 1건만 센다)', () {
    test('시전 1회는 강도별 등급 표에 정확히 1건만 남긴다', () {
      final b = makeBattle(const [GameEffect(type: 'heal', value: 1)]);
      final tally = Tally();
      final probe = CastProbe.of(b);
      b.castSpell(0, CastIntensity.normal, dice: const [6, 6, 5]);
      tally.addCast(b, CastIntensity.normal, probe);
      final total = tally.primaryGrades[CastIntensity.normal]!.values
          .fold(0, (a, x) => a + x);
      expect(total, 1);
      expect(tally.forcedRerollApplies, 0);
    });

    test('마력 축적 확정 대성공은 pureGrades 에서 빠진다', () {
      final b = makeBattle(const [GameEffect(type: 'heal', value: 1)])
        ..charge = kChargeThreshold;
      final tally = Tally();
      final probe = CastProbe.of(b);
      b.castSpell(0, CastIntensity.normal, dice: const [1, 2, 4]);
      tally.addCast(b, CastIntensity.normal, probe);
      expect(tally.chargeForcedCasts, 1);
      expect(
          tally.pureGrades[CastIntensity.normal]!.values.fold(0, (a, x) => a + x),
          0);
      expect(
          tally.primaryGrades[CastIntensity.normal]!.values
              .fold(0, (a, x) => a + x),
          1);
    });
  });
}
