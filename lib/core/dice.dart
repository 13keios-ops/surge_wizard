import 'dart:math';

import 'constants.dart';

/// 주사위 3개의 굴림·잠금·리롤을 담당한다.
/// 판정 계산은 하지 않는다 (check.dart 담당).
class DicePool {
  DicePool({
    Random? random,
    this.maxRerolls = kMaxRerollsPerCheck,
    this.faceTransform,
  }) : _random = random ?? Random();

  final Random _random;

  /// 이 판정에서 허용되는 최대 리롤 횟수 (유물로 늘어날 수 있다)
  final int maxRerolls;

  /// 눈 변환 규칙 (예: 유물 "납 넣은 주사위" — 1이 나오면 2로)
  final int Function(int face)? faceTransform;

  /// 현재 눈금. 아직 굴리지 않았으면 비어 있다.
  final List<int> _values = [];

  /// 각 주사위의 잠금 여부
  final List<bool> _locked = List.filled(kDiceCount, false);

  /// 이번 판정에서 사용한 리롤 횟수 (무료 포함)
  int _rerollCount = 0;

  /// 그중 마나를 내고 굴린 횟수. 비용 체증(1→2→3)의 회차는 이 값으로 센다.
  /// 무료 리롤(유물)은 횟수 제한에만 걸리고 단계를 올리지 않는다.
  int _paidRerollCount = 0;

  List<int> get values => List.unmodifiable(_values);

  List<bool> get locked => List.unmodifiable(_locked);

  int get rerollCount => _rerollCount;

  int get paidRerollCount => _paidRerollCount;

  bool get hasRolled => _values.isNotEmpty;

  /// 세 눈의 합계
  int get sum => _values.fold(0, (a, b) => a + b);

  /// 리롤 가능 여부 (횟수 제한만 검사, 마나는 호출자가 검사)
  bool get canReroll =>
      hasRolled && _rerollCount < maxRerolls && _locked.contains(false);

  int _rollOne() {
    final face = _random.nextInt(kDiceSides) + 1;
    return faceTransform?.call(face) ?? face;
  }

  /// 새 판정 시작: 잠금과 리롤 횟수를 초기화하고 3개 전부 굴린다.
  List<int> rollAll() {
    _values
      ..clear()
      ..addAll(List.generate(kDiceCount, (_) => _rollOne()));
    for (var i = 0; i < kDiceCount; i++) {
      _locked[i] = false;
    }
    _rerollCount = 0;
    _paidRerollCount = 0;
    return values;
  }

  /// 외부에서 계산된 눈으로 판을 시작한다 (주사위 추가 효과 등).
  /// 잠금과 리롤 횟수도 새 판정 기준으로 초기화된다.
  void seed(List<int> newValues) {
    assert(newValues.length == kDiceCount, '주사위는 반드시 3개여야 한다');
    _values
      ..clear()
      ..addAll(newValues);
    for (var i = 0; i < kDiceCount; i++) {
      _locked[i] = false;
    }
    _rerollCount = 0;
    _paidRerollCount = 0;
  }

  /// 주사위 하나의 잠금 상태를 반전한다.
  void toggleLock(int index) {
    if (!hasRolled) return;
    _locked[index] = !_locked[index];
  }

  /// 잠기지 않은 주사위만 다시 굴린다.
  /// [free] 면 비용 회차를 올리지 않는다 (유물의 무료 리롤).
  /// 리롤 불가 상태면 false 를 돌려주고 아무것도 하지 않는다.
  bool reroll({bool free = false}) {
    if (!canReroll) return false;
    for (var i = 0; i < kDiceCount; i++) {
      if (!_locked[i]) {
        _values[i] = _rollOne();
      }
    }
    _rerollCount++;
    if (!free) _paidRerollCount++;
    return true;
  }
}
