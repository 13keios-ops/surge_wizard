/// 시전 강도 2단계 검증 (GAME_DESIGN v2 3.3절, WORK_ORDER_INTENSITY 작업 3-A).
/// 강도 수치는 enum 순서에 인덱스로 의존한다. 한 칸만 밀려도 전력이 보통 값을
/// 쓰게 되므로, 여기서 값을 표와 하나씩 대조한다.
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/check.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/enemy.dart';
import 'package:surge_wizard/models/spell.dart';

String _readData(String name) => File('assets/data/$name').readAsStringSync();

void main() {
  final spells = GameDataParser.parseSpells(_readData('spells.json'));
  final surges = GameDataParser.parseSurges(_readData('surges.json'));
  final enemies = GameDataParser.parseEnemies(_readData('enemies.json'));

  List<Spell> starterHand() => kStarterSpellIds
      .map((id) => spells.firstWhere((s) => s.id == id))
      .toList();

  final rat = enemies.firstWhere((e) => e.id == 'cave_rat');

  Battle freshBattle(Enemy enemy, int seed) => Battle(
        enemy: enemy,
        hand: starterHand(),
        surgePool: surges,
        random: Random(seed),
      );

  group('강도 표 정합성', () {
    test('「보통」의 DC·위력·마나·환급이 3.3절 표와 같다', () {
      const it = CastIntensity.normal;
      expect(it.dc, 10);
      expect(it.power, 1.0);
      expect(it.manaCost, 0); // v2 개정 핵심: 1 → 0
      expect(it.critManaRefund, 1);
      expect(it.label, '보통');
    });

    test('「전력」의 DC·위력·마나·환급이 3.3절 표와 같다', () {
      const it = CastIntensity.full;
      expect(it.dc, 13);
      expect(it.power, 3.0);
      expect(it.manaCost, 2);
      expect(it.critManaRefund, 2);
      expect(it.label, '전력');
    });

    test('강도는 2종뿐이다 (「약하게」 삭제)', () {
      expect(CastIntensity.values.length, 2);
      expect(CastIntensity.values,
          [CastIntensity.normal, CastIntensity.full]);
    });
  });

  group('마나 규칙', () {
    test('마나 0에서도 「보통」 시전이 성공한다', () {
      final b = freshBattle(rat, 1)..mana = 0;
      // 6+4+2 = 12: 족보 없는 평범한 성공 (대성공이면 환급이 섞인다)
      expect(b.castSpell(0, CastIntensity.normal, dice: [6, 4, 2]), isTrue);
      expect(b.mana, 0);
      expect(b.castCount, 1);
    });

    test('마나 1에서 「전력」 시전은 거부된다', () {
      final b = freshBattle(rat, 1)..mana = 1;
      expect(b.castSpell(0, CastIntensity.full, dice: [6, 6, 6]), isFalse);
      expect(b.mana, 1); // 비용을 떼지 않는다
      expect(b.castCount, 0);
      expect(b.enemyHp, rat.hp); // 적도 맞지 않는다
    });
  });

  group('대성공 강등 없음', () {
    test('「보통」 대성공은 위력이 2배로 들어간다', () {
      final b = freshBattle(rat, 1)..startTurn();
      final power = b.spellPower(b.hand[0]);
      b.castSpell(0, CastIntensity.normal, dice: [6, 6, 6]); // 트리플 = 확정 대성공
      expect(b.lastResult!.grade, CheckGrade.critSuccess);
      expect(b.lastAppliedGrade, CheckGrade.critSuccess);
      expect(b.gradeCounts[CheckGrade.critSuccess], 1);
      expect(b.enemyHp, rat.hp - (power * kCritDamageMultiplier).round());
    });

    test('「보통」 대성공이 마나 1을 환급하고 적을 지연시킨다', () {
      final b = freshBattle(rat, 1)..mana = 0;
      b.castSpell(0, CastIntensity.normal, dice: [6, 6, 6]);
      expect(b.mana, kCritManaRefundNormal);
      expect(b.enemyDelayTurns, kCritEnemyDelay);
    });
  });

  group('마력 축적', () {
    for (final it in CastIntensity.values) {
      test('마력 축적 3에서 「${it.label}」 시전은 게이지를 소모한다', () {
        final b = freshBattle(rat, 1)
          ..charge = kChargeThreshold
          ..mana = kManaCostFull;
        b.startTurn();
        b.castSpell(0, it, dice: [2, 3, 6]); // 족보 없음 — 게이지로만 대성공
        expect(b.lastAppliedGrade, CheckGrade.critSuccess);
        expect(b.charge, 0);
      });
    }
  });
}
