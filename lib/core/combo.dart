/// 족보 판정 (GAME_DESIGN 3.5절).
/// 우선순위: 트리플 > 스트레이트 > 뱀눈 > 페어
library;

/// 족보 종류
enum ComboType {
  /// 같은 눈 3개 — 무조건 대성공
  triple,

  /// 연속 3개 (예: 3-4-5) — 다른 주문 1개 자동 동시 시전
  straight,

  /// 1이 2개 이상 — 폭주 확정, 마력 축적 +2
  snakeEyes,

  /// 같은 눈 2개 — 판정값 +3
  pair,

  /// 족보 없음
  none,
}

/// 주사위 눈 3개에서 성립하는 최우선 족보를 돌려준다.
ComboType detectCombo(List<int> dice) {
  assert(dice.length == 3, '주사위는 반드시 3개여야 한다');
  final a = dice[0], b = dice[1], c = dice[2];

  // 트리플: 셋 다 같은 눈
  if (a == b && b == c) return ComboType.triple;

  // 스트레이트: 정렬했을 때 연속 3개
  final sorted = [...dice]..sort();
  if (sorted[1] == sorted[0] + 1 && sorted[2] == sorted[1] + 1) {
    return ComboType.straight;
  }

  // 뱀눈: 1이 2개 이상 (트리플 1은 위에서 이미 걸러짐 → 여기서는 정확히 2개)
  final ones = dice.where((d) => d == 1).length;
  if (ones >= 2) return ComboType.snakeEyes;

  // 페어: 같은 눈 정확히 2개
  if (a == b || b == c || a == c) return ComboType.pair;

  return ComboType.none;
}
