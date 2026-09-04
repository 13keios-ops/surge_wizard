/// 판정 엔진 단위 테스트 (CLAUDE.md "테스트 규칙" 전체 커버)
///
/// 검증 목록:
/// 1. 3d6 합계 분포가 216가지 경우와 일치 (몬테카를로 10만 회, 오차 1% 이내)
/// 2. DC 7/10/13 각각의 4단계 결과 비율이 GAME_DESIGN.md 3.4절 표와 일치
/// 3. 트리플은 판정값과 무관하게 항상 대성공
/// 4. 뱀눈은 항상 폭주
/// 5. 페어 +3 보정이 정확히 적용
/// 6. 족보 우선순위 → combo_test.dart 로 분리 (파일 300줄 규칙)
/// 7. 마력 축적 3칸에서 다음 시전이 무조건 대성공
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/core/check.dart';
import 'package:surge_wizard/core/combo.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/core/dice.dart';

/// 몬테카를로 시행 횟수
const int kTrials = 100000;

/// 허용 오차 (1% = 0.01)
const double kTolerance = 0.01;

/// 3d6 합계별 경우의 수 (GAME_DESIGN 3.4절, 총 216가지)
const Map<int, int> kSumWays = {
  3: 1, 4: 3, 5: 6, 6: 10, 7: 15, 8: 21, 9: 25, 10: 27,
  11: 27, 12: 25, 13: 21, 14: 15, 15: 10, 16: 6, 17: 3, 18: 1,
};

/// GAME_DESIGN 3.4절 강도별 결과 분포 (보정 0, 족보 미적용 순수 합계 기준)
const Map<int, Map<CheckGrade, double>> kExpectedGradeDist = {
  kDcLow: {
    CheckGrade.critSuccess: 0.625,
    CheckGrade.success: 0.282,
    CheckGrade.graze: 0.088,
    CheckGrade.failure: 0.005,
  },
  kDcNormal: {
    CheckGrade.critSuccess: 0.259,
    CheckGrade.success: 0.366,
    CheckGrade.graze: 0.282,
    CheckGrade.failure: 0.093,
  },
  kDcFull: {
    CheckGrade.critSuccess: 0.046,
    CheckGrade.success: 0.213,
    CheckGrade.graze: 0.366,
    CheckGrade.failure: 0.375,
  },
};

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
  group('1. 3d6 합계 분포 (몬테카를로 10만 회)', () {
    test('합계별 실측 빈도가 이론 확률과 오차 1% 이내', () {
      final random = Random(20260831); // 재현 가능하도록 시드 고정
      final pool = DicePool(random: random);
      final counts = <int, int>{};
      for (var i = 0; i < kTrials; i++) {
        pool.rollAll();
        counts.update(pool.sum, (v) => v + 1, ifAbsent: () => 1);
      }
      for (final entry in kSumWays.entries) {
        final expected = entry.value / 216;
        final observed = (counts[entry.key] ?? 0) / kTrials;
        expect(
          (observed - expected).abs(),
          lessThan(kTolerance),
          reason: '합계 ${entry.key}: 이론 $expected, 실측 $observed',
        );
      }
      // 3~18 밖의 합계가 나오면 안 된다
      expect(counts.keys.every((s) => s >= 3 && s <= 18), isTrue);
    });
  });

  group('2. DC별 4단계 결과 비율 (GAME_DESIGN 3.4절 표)', () {
    // 3.4절 표는 족보를 적용하지 않은 순수 합계 기준이므로
    // gradeForValue(합계, DC)로 검증한다.
    for (final dc in [kDcLow, kDcNormal, kDcFull]) {
      test('DC $dc: 몬테카를로 결과가 표와 오차 1% 이내', () {
        final random = Random(dc * 7919); // DC마다 다른 시드
        final pool = DicePool(random: random);
        final counts = <CheckGrade, int>{};
        for (var i = 0; i < kTrials; i++) {
          pool.rollAll();
          final grade = gradeForValue(pool.sum, dc);
          counts.update(grade, (v) => v + 1, ifAbsent: () => 1);
        }
        for (final entry in kExpectedGradeDist[dc]!.entries) {
          final observed = (counts[entry.key] ?? 0) / kTrials;
          expect(
            (observed - entry.value).abs(),
            lessThan(kTolerance),
            reason: 'DC $dc ${entry.key}: 기대 ${entry.value}, 실측 $observed',
          );
        }
      });

      test('DC $dc: 216가지 전수 계산이 표와 정확히 일치', () {
        // 몬테카를로가 아니라 전수(exhaustive) 검산.
        // 표의 수치는 소수 1자리 반올림이므로 0.001 이내로 본다.
        final counts = <CheckGrade, int>{};
        for (final dice in allDiceCombos()) {
          final sum = dice[0] + dice[1] + dice[2];
          final grade = gradeForValue(sum, dc);
          counts.update(grade, (v) => v + 1, ifAbsent: () => 1);
        }
        for (final entry in kExpectedGradeDist[dc]!.entries) {
          final exact = (counts[entry.key] ?? 0) / 216;
          expect(
            (exact - entry.value).abs(),
            lessThan(0.001),
            reason: 'DC $dc ${entry.key}: 표 ${entry.value}, 전수 $exact',
          );
        }
      });
    }
  });

  group('3. 트리플은 항상 대성공', () {
    test('모든 트리플 × 모든 DC에서 대성공', () {
      for (var face = 1; face <= 6; face++) {
        for (final dc in [kDcLow, kDcNormal, kDcFull]) {
          final result = resolveCheck(dice: [face, face, face], dc: dc);
          expect(result.grade, CheckGrade.critSuccess,
              reason: '트리플 $face-$face-$face, DC $dc');
          expect(result.combo, ComboType.triple);
          expect(result.surgeTriggered, isFalse);
        }
      }
    });

    test('1-1-1 트리플도 뱀눈이 아니라 대성공 (우선순위)', () {
      final result = resolveCheck(dice: [1, 1, 1], dc: kDcFull);
      expect(result.grade, CheckGrade.critSuccess);
      expect(result.combo, ComboType.triple);
    });
  });

  group('4. 뱀눈은 항상 폭주', () {
    test('1이 정확히 2개인 모든 조합 × 모든 DC에서 폭주', () {
      for (var other = 2; other <= 6; other++) {
        // 1-1-x 의 세 가지 배치 전부 검사
        for (final dice in [
          [1, 1, other],
          [1, other, 1],
          [other, 1, 1],
        ]) {
          for (final dc in [kDcLow, kDcNormal, kDcFull]) {
            final result = resolveCheck(dice: dice, dc: dc);
            expect(result.grade, CheckGrade.failure,
                reason: '뱀눈 $dice, DC $dc');
            expect(result.surgeTriggered, isTrue);
            expect(result.combo, ComboType.snakeEyes);
            expect(result.chargeGained, kSnakeEyesChargeGain);
          }
        }
      }
    });

    test('보정치가 아무리 높아도 뱀눈은 폭주', () {
      final result = resolveCheck(dice: [1, 1, 6], dc: kDcLow, modifier: 99);
      expect(result.grade, CheckGrade.failure);
      expect(result.surgeTriggered, isTrue);
    });
  });

  group('5. 페어 +3 보정', () {
    test('페어 성립 시 최종 판정값 = 합계 + 3 + 보정치', () {
      // 5-5-2: 합계 12, 페어 +3 → 15
      final result = resolveCheck(dice: [5, 5, 2], dc: kDcNormal);
      expect(result.combo, ComboType.pair);
      expect(result.finalValue, 12 + kPairBonus);
    });

    test('페어 보정으로 등급이 실제로 올라간다', () {
      // 4-4-2: 합계 10. DC 13이면 아슬아슬이지만 페어 +3 → 13 = 성공
      final result = resolveCheck(dice: [4, 4, 2], dc: kDcFull);
      expect(result.finalValue, 13);
      expect(result.grade, CheckGrade.success);
    });

    test('페어 아니면 보너스 없음', () {
      // 2-4-6: 족보 없음, 합계 12 그대로
      final result = resolveCheck(dice: [2, 4, 6], dc: kDcNormal);
      expect(result.combo, ComboType.none);
      expect(result.finalValue, 12);
    });

    test('외부 보정치와 페어 보너스가 함께 더해진다', () {
      // 3-3-6: 합계 12, 페어 +3, 보정 +2 → 17
      final result = resolveCheck(dice: [3, 3, 6], dc: kDcNormal, modifier: 2);
      expect(result.finalValue, 17);
    });
  });

  // 족보 우선순위·주사위 잠금 테스트는 combo_test.dart 로 분리했다
  // (파일 300줄 규칙).

  group('7. 마력 축적 3칸 → 무조건 대성공', () {
    test('최악의 주사위(1-1-2, 뱀눈)라도 게이지 3이면 대성공', () {
      final result =
          resolveCheck(dice: [1, 1, 2], dc: kDcFull, charge: kChargeThreshold);
      expect(result.grade, CheckGrade.critSuccess);
      expect(result.surgeTriggered, isFalse);
      expect(result.chargeConsumed, isTrue);
    });

    test('족보 없는 낮은 눈이라도 게이지 3이면 대성공', () {
      final result =
          resolveCheck(dice: [1, 2, 4], dc: kDcFull, charge: kChargeThreshold);
      expect(result.grade, CheckGrade.critSuccess);
      expect(result.chargeConsumed, isTrue);
    });

    test('게이지 2 이하에서는 발동하지 않는다', () {
      final result = resolveCheck(dice: [1, 2, 4], dc: kDcFull, charge: 2);
      expect(result.grade, CheckGrade.failure);
      expect(result.chargeConsumed, isFalse);
    });

    test('실패 시 게이지 +1, 뱀눈 폭주 시 +2', () {
      // 2-2-1: 합계 5, 페어 +3 → 8. DC 13이면 실패
      final fail = resolveCheck(dice: [2, 2, 1], dc: kDcFull);
      expect(fail.grade, CheckGrade.failure);
      expect(fail.chargeGained, kFailChargeGain);

      final snake = resolveCheck(dice: [1, 1, 5], dc: kDcLow);
      expect(snake.chargeGained, kSnakeEyesChargeGain);
    });
  });

  group('보조: 스트레이트 효과 플래그', () {
    test('스트레이트면 extraCastTriggered = true', () {
      final result = resolveCheck(dice: [3, 4, 5], dc: kDcLow);
      expect(result.combo, ComboType.straight);
      expect(result.extraCastTriggered, isTrue);
    });

    test('스트레이트가 아니면 false', () {
      final result = resolveCheck(dice: [2, 2, 6], dc: kDcLow);
      expect(result.extraCastTriggered, isFalse);
    });
  });
}
