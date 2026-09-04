import 'dart:math';

import '../models/enemy.dart';
import 'battle.dart';

/// 적 턴 진행 담당: 고정 패턴 순환, 강타 예고, 보스 2페이즈.
/// Battle이 생성해 들고 쓴다 (SurgeSystem과 같은 구조).
class EnemyTurnRunner {
  EnemyTurnRunner(this._battle);

  final Battle _battle;

  int _patternIndex = 0;
  EnemyAction? _pendingCharge; // 예고된 강타 (다음 적 턴에 터진다)
  bool _phase2 = false;

  List<EnemyAction> get _activePattern =>
      _phase2 && _battle.enemy.phase2Pattern != null
          ? _battle.enemy.phase2Pattern!
          : _battle.enemy.pattern;

  /// 다음 적 행동 예고 (GAME_DESIGN 4.3절: 항상 정확해야 한다).
  /// 강타가 예고돼 있으면 패턴 다음 칸이 아니라 그 강타를 보여준다.
  EnemyAction get telegraph {
    final pending = _pendingCharge;
    if (pending != null) {
      return EnemyAction(
          action: 'attack', value: pending.value, label: pending.label);
    }
    return _activePattern[_patternIndex % _activePattern.length];
  }

  /// 적 턴 1회: 지연 검사 → 행동 → 2페이즈 전환 검사.
  /// 전환은 예고된 행동이 끝난 뒤에만 일어나 예고가 지켜진다.
  void run() {
    final b = _battle;
    if (b.enemyDelayTurns > 0) {
      b.enemyDelayTurns--;
      b.log.add('${b.enemy.name}의 행동이 지연됐다');
    } else {
      _execute();
      // 아슬아슬 반동으로 앞당겨진 추가 행동
      if (b.enemyActsAgain && !b.isOver) {
        b.enemyActsAgain = false;
        _execute();
      }
    }
    _checkPhase2();
  }

  /// 적 행동 1회 실행
  void _execute() {
    final b = _battle;
    // 예고된 강타가 있으면 그것부터 터진다
    final pending = _pendingCharge;
    if (pending != null) {
      b.dealToPlayer(pending.value);
      b.log.add('${b.enemy.name}의 강타! ${pending.value}');
      _pendingCharge = null;
      return;
    }
    final action = _activePattern[_patternIndex % _activePattern.length];
    _patternIndex = (_patternIndex + 1) % _activePattern.length;
    switch (action.action) {
      case 'attack':
        b.dealToPlayer(action.value);
      case 'charge':
        _pendingCharge = action; // 다음 턴에 터진다 (telegraph가 보여준다)
      case 'defend':
        b.enemyShield += action.value;
      case 'heal':
        b.enemyHp = min(b.enemy.hp, b.enemyHp + action.value);
    }
    b.log.add('${b.enemy.name}: ${action.label}');
  }

  /// 보스 2페이즈 전환 검사
  void _checkPhase2() {
    final b = _battle;
    if (_phase2 || !b.enemy.isBoss) return;
    final threshold = b.enemy.phase2HpThreshold;
    if (threshold != null && b.enemyHp <= threshold && b.enemyHp > 0) {
      _phase2 = true;
      _patternIndex = 0;
      b.log.add('${b.enemy.name}이(가) 2페이즈로 돌입했다!');
    }
  }
}
