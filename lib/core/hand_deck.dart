import 'dart:math';

import '../models/spell.dart';
import 'constants.dart';

/// 덱에서 매 턴 손패를 뽑는 담당 (GAME_DESIGN 4.2절).
///
/// 규칙
/// - 매 턴 덱에서 무작위 [kHandSize]장을 뽑는다 (같은 주문이 두 장 들어가지 않는다)
/// - 직전 턴에 시전한 주문은 1턴 쉰다
/// - 봉인된 주문은 뽑히지 않는다
/// - 쉬는 규칙 때문에 손패를 못 채우면 **채우는 쪽을 우선**한다 (덱이 작을 때)
///
/// Battle 이 덱을 받았을 때만 만들어진다. 덱이 없으면 손패는 고정이다.
class HandDeck {
  HandDeck(this.deck, this._random);

  /// 이 전투에서 쓰는 덱. 원본 목록을 바꾸지 않는다.
  final List<Spell> deck;

  final Random _random;

  /// 직전 턴에 시전해 이번 턴을 쉬는 주문 id
  String? _restingId;

  /// 방금 시전한 주문을 적어 둔다 (다음 턴 후보에서 빠진다)
  void markCast(String spellId) => _restingId = spellId;

  /// 이번 턴 손패를 뽑는다. 뽑고 나면 쉬는 표시가 풀린다 (1턴만 쉰다).
  List<Spell> draw(Set<String> sealedIds) {
    final pool = _pool(sealedIds);
    final rested = pool.where((s) => s.id != _restingId).toList();
    // 쉬는 주문을 빼면 손패가 모자랄 때는 「손패 채우기」가 이긴다
    final candidates = rested.length >= kHandSize ? rested : pool;
    _restingId = null;
    return (List.of(candidates)..shuffle(_random)).take(kHandSize).toList();
  }

  /// 뽑기 후보: 봉인되지 않았고 id가 겹치지 않는 주문들
  List<Spell> _pool(Set<String> sealedIds) {
    final picked = <Spell>[];
    final seen = <String>{};
    for (final s in deck) {
      if (sealedIds.contains(s.id)) continue;
      if (seen.add(s.id)) picked.add(s);
    }
    return picked;
  }
}
