/// 족보 판정(combo.dart)과 주사위 잠금·리롤(dice.dart) 단위 테스트.
/// 판정 등급·확률표 검증은 check_test.dart 에 있다.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/core/combo.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/core/dice.dart';

/// 216가지 (a,b,c) 조합 전부를 순회하는 헬퍼
Iterable<List<int>> allDiceCombos() sync* {
  for (var a = 1; a <= 6; a++) {
    for (var b = 1; b <= 6; b++) {
      for (var c = 1; c <= 6; c++) {
        yield [a, b, c];
      }
    }
  }
}

void main() {
  group('족보 우선순위 (트리플 > 스트레이트 > 뱀눈 > 페어)', () {
    test('전수 검사: 216가지 조합의 족보 분류가 정의와 일치', () {
      for (final dice in allDiceCombos()) {
        final combo = detectCombo(dice);
        final a = dice[0], b = dice[1], c = dice[2];
        final sorted = [...dice]..sort();
        final isTriple = a == b && b == c;
        final isStraight =
            sorted[1] == sorted[0] + 1 && sorted[2] == sorted[1] + 1;
        final ones = dice.where((d) => d == 1).length;
        final hasPair = a == b || b == c || a == c;

        if (isTriple) {
          expect(combo, ComboType.triple, reason: '$dice');
        } else if (isStraight) {
          expect(combo, ComboType.straight, reason: '$dice');
        } else if (ones >= 2) {
          expect(combo, ComboType.snakeEyes, reason: '$dice');
        } else if (hasPair) {
          expect(combo, ComboType.pair, reason: '$dice');
        } else {
          expect(combo, ComboType.none, reason: '$dice');
        }
      }
    });

    test('1-1-1은 트리플 (뱀눈 아님)', () {
      expect(detectCombo([1, 1, 1]), ComboType.triple);
    });

    test('1-2-3은 스트레이트 (1이 있어도 뱀눈 아님)', () {
      expect(detectCombo([1, 2, 3]), ComboType.straight);
    });

    test('1-1-4는 뱀눈 (페어 아님)', () {
      expect(detectCombo([1, 1, 4]), ComboType.snakeEyes);
    });

    test('스트레이트는 순서와 무관하게 성립', () {
      expect(detectCombo([5, 3, 4]), ComboType.straight);
      expect(detectCombo([6, 4, 5]), ComboType.straight);
    });
  });

  group('주사위 잠금·리롤 동작', () {
    test('잠근 주사위는 리롤해도 값이 유지된다', () {
      final pool = DicePool(random: Random(42));
      pool.rollAll();
      final before = pool.values[0];
      pool.toggleLock(0);
      // 여러 번 리롤해도 0번은 불변
      while (pool.canReroll) {
        pool.reroll();
        expect(pool.values[0], before);
      }
    });

    test('리롤은 한 판정당 최대 3회', () {
      final pool = DicePool(random: Random(7));
      pool.rollAll();
      var count = 0;
      while (pool.reroll()) {
        count++;
      }
      expect(count, kMaxRerollsPerCheck);
    });

    test('새로 굴리면 잠금과 리롤 횟수가 초기화된다', () {
      final pool = DicePool(random: Random(99));
      pool.rollAll();
      pool.toggleLock(1);
      pool.reroll();
      pool.rollAll();
      expect(pool.locked, [false, false, false]);
      expect(pool.rerollCount, 0);
    });
  });
}
