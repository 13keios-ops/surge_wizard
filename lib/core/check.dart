import 'combo.dart';
import 'constants.dart';

/// 판정 결과 4단계 (GAME_DESIGN 3.2절)
enum CheckGrade {
  /// 대성공: 위력 2배, 마나 1 환급, 적 행동 지연
  critSuccess,

  /// 성공: 정상 발동
  success,

  /// 아슬아슬: 발동하되 위력 50% + 반동
  graze,

  /// 실패: 미발동 + 폭주
  failure,
}

/// 판정 한 번의 결과.
class CheckResult {
  const CheckResult({
    required this.grade,
    required this.combo,
    required this.finalValue,
    required this.surgeTriggered,
    required this.extraCastTriggered,
    required this.chargeGained,
    required this.chargeConsumed,
  });

  /// 결과 등급
  final CheckGrade grade;

  /// 적용된 족보
  final ComboType combo;

  /// 최종 판정값 (눈 합계 + 족보 보너스 + 보정치)
  final int finalValue;

  /// 폭주 발생 여부 (실패 시 항상 true)
  final bool surgeTriggered;

  /// 스트레이트 효과: 다른 주문 1개 자동 동시 시전 여부
  final bool extraCastTriggered;

  /// 이번 판정으로 늘어난 마력 축적량
  final int chargeGained;

  /// 마력 축적 3칸 소모(확정 대성공)가 발동했는지
  final bool chargeConsumed;
}

/// 판정값만으로 등급을 계산한다 (족보·마력 축적 미적용).
/// 3.4절 확률표 검증 테스트에서도 이 함수를 쓴다.
CheckGrade gradeForValue(int value, int dc) {
  if (value >= dc + kCritMargin) return CheckGrade.critSuccess;
  if (value >= dc) return CheckGrade.success;
  if (value >= dc - kGrazeMargin) return CheckGrade.graze;
  return CheckGrade.failure;
}

/// 판정 엔진 본체.
///
/// [dice] 주사위 눈 3개, [dc] 목표치, [modifier] 유물·버프 보정치,
/// [charge] 현재 마력 축적 게이지 (0~3),
/// [pairBonus] 페어 성립 시 보너스 (기본 +3, 유물로 커질 수 있다).
///
/// 처리 순서:
/// 1. 마력 축적이 가득이면 무조건 대성공 (게이지 소모) — BLOCKERS.md 판단 2
/// 2. 트리플이면 무조건 대성공
/// 3. 뱀눈이면 폭주 확정 (마력 축적 +2)
/// 4. 그 외에는 판정값 = 합계 + 페어 보너스 + 보정치 로 등급 산출
CheckResult resolveCheck({
  required List<int> dice,
  required int dc,
  int modifier = 0,
  int charge = 0,
  int pairBonus = kPairBonus,
}) {
  final combo = detectCombo(dice);
  final sum = dice.fold(0, (a, b) => a + b);
  final finalValue =
      sum + (combo == ComboType.pair ? pairBonus : 0) + modifier;
  final isStraight = combo == ComboType.straight;

  // 1) 마력 축적 가득: 무조건 대성공 (뱀눈보다 우선)
  if (charge >= kChargeThreshold) {
    return CheckResult(
      grade: CheckGrade.critSuccess,
      combo: combo,
      finalValue: finalValue,
      surgeTriggered: false,
      extraCastTriggered: isStraight,
      chargeGained: 0,
      chargeConsumed: true,
    );
  }

  // 2) 트리플: 판정값과 무관하게 대성공
  if (combo == ComboType.triple) {
    return CheckResult(
      grade: CheckGrade.critSuccess,
      combo: combo,
      finalValue: finalValue,
      surgeTriggered: false,
      extraCastTriggered: false,
      chargeGained: 0,
      chargeConsumed: false,
    );
  }

  // 3) 뱀눈: 폭주 확정, 마력 축적 +2
  if (combo == ComboType.snakeEyes) {
    return CheckResult(
      grade: CheckGrade.failure,
      combo: combo,
      finalValue: finalValue,
      surgeTriggered: true,
      extraCastTriggered: false,
      chargeGained: kSnakeEyesChargeGain,
      chargeConsumed: false,
    );
  }

  // 4) 일반 판정
  final grade = gradeForValue(finalValue, dc);
  final failed = grade == CheckGrade.failure;
  return CheckResult(
    grade: grade,
    combo: combo,
    finalValue: finalValue,
    surgeTriggered: failed,
    extraCastTriggered: isStraight,
    chargeGained: failed ? kFailChargeGain : 0,
    chargeConsumed: false,
  );
}
