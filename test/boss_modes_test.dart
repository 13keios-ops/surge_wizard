import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/boss_modes.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/models/enemy.dart';
import 'package:surge_wizard/models/spell.dart';

/// 보스 등장 방식 3종 (`WORK_ORDER_BOSS_MODES.md` 6절).
///
/// 이것이 없으면 하드와 데스가 **수치 배율만 다른 똑같은 전투**다.
void main() {
  Enemy boss({int hp = 100, int attack = 10}) => Enemy(
        id: 'boss_test',
        name: '시험 보스',
        icon: 'x',
        hp: hp,
        tier: 5,
        isBoss: true,
        variantId: kNormalVariantId,
        pattern: [EnemyAction(action: 'attack', value: attack, label: '후려치기')],
        phase2HpThreshold: hp ~/ 2,
        phase2Pattern: [
          EnemyAction(action: 'attack', value: attack * 2, label: '광폭화')
        ],
      );

  Battle battleWith({Enemy? next, int escort = 0}) => Battle(
        enemy: boss(),
        hand: const <Spell>[],
        surgePool: const [],
        nextWave: next,
        escort: escort,
      );

  group('전조 — 지역 8~12의 1층', () {
    test('1. 지역 8 이상의 1층에서만 나온다', () {
      expect(isOmenFloor(8, 1), isTrue);
      expect(isOmenFloor(12, 1), isTrue);
      expect(isOmenFloor(7, 1), isFalse, reason: '8 미만은 적용 안 됨');
      expect(isOmenFloor(8, 2), isFalse, reason: '1층에서만');
    });

    test('2. 약화판은 체력 40% · 공격 70%다', () {
      final weak = omenOf(boss(hp: 100, attack: 10));
      expect(weak.hp, 40);
      expect(weak.pattern.first.value, 7);
    });

    test('3. 🔴 약화판은 2페이즈를 쓰지 않는다', () {
      final weak = omenOf(boss());
      expect(weak.phase2HpThreshold, isNull);
      expect(weak.phase2Pattern, isNull);
    });

    test('4. 배율이 작아도 값이 0으로 내려가지 않는다', () {
      final weak = omenOf(boss(hp: 1, attack: 1));
      expect(weak.hp, greaterThanOrEqualTo(1));
      expect(weak.pattern.first.value, greaterThanOrEqualTo(1));
    });
  });

  group('호위 — 하드 보스 층', () {
    test('5. 하드의 보스에만 붙는다', () {
      expect(hasEscort(boss(), Difficulty.hard), isTrue);
      expect(hasEscort(boss(), Difficulty.normal), isFalse);
      expect(hasEscort(boss(), Difficulty.death), isFalse);
    });

    test('6. 위력은 보스 일반 공격의 0.4배이고 **음수**다 (적대)', () {
      expect(escortPower(boss(attack: 10)), -4);
    });

    test('7. 전투가 시작되면 적대 소환수 1체가 서 있다', () {
      final b = battleWith(escort: escortPower(boss(attack: 10)));
      expect(b.surge.summons.length, 1);
      expect(b.surge.summons.first.power, lessThan(0));
    });

    test('8. 호위가 없으면 소환수도 없다', () {
      expect(battleWith().surge.summons, isEmpty);
    });
  });

  group('연전 — 데스 보스 층', () {
    test('9. 데스의 보스에만 붙는다', () {
      expect(hasSecondWave(boss(), Difficulty.death), isTrue);
      expect(hasSecondWave(boss(), Difficulty.normal), isFalse);
      expect(hasSecondWave(boss(), Difficulty.hard), isFalse);
    });

    test('10. 2체째는 체력 60%, 공격은 그대로다', () {
      final second = secondWaveOf(boss(hp: 100, attack: 10));
      expect(second.hp, 60);
      expect(second.pattern.first.value, 10);
    });

    test('11. 🔴 1체째를 죽여도 전투가 안 끝나고 2체째가 선다', () {
      final b = battleWith(next: secondWaveOf(boss(hp: 100)));
      b.dealToEnemy(999);
      expect(b.isOver, isFalse, reason: '아직 2체째가 남았다');
      expect(b.playerWon, isFalse);
      expect(b.enemyHp, 60, reason: '2체째의 체력으로 다시 찬다');
    });

    test('12. 🔴 2체째로 넘어갈 때 플레이어 체력·마력이 그대로다', () {
      final b = battleWith(next: secondWaveOf(boss()));
      b.playerHp = 33;
      b.mana = 2;
      b.dealToEnemy(999);
      expect(b.playerHp, 33, reason: '회복을 주지 않는다');
      expect(b.mana, 2);
    });

    test('13. 🔴 2체째까지 죽여야 승리다', () {
      final b = battleWith(next: secondWaveOf(boss()));
      b.dealToEnemy(999);
      b.dealToEnemy(999);
      expect(b.isOver, isTrue);
      expect(b.playerWon, isTrue);
    });

    test('14. 2체째도 2페이즈를 쓴다 (줄어든 체력의 절반)', () {
      final second = secondWaveOf(boss(hp: 100));
      expect(second.phase2HpThreshold, 30);
      expect(second.phase2Pattern, isNotNull);
    });
  });

  group('회귀', () {
    test('15. 🔴 평범한 1체 전투는 지금과 똑같다', () {
      final b = battleWith();
      expect(b.isOver, isFalse);
      b.dealToEnemy(999);
      expect(b.isOver, isTrue);
      expect(b.playerWon, isTrue);
      expect(b.surge.summons, isEmpty);
    });
  });
}
