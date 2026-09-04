/// 봇의 판단 정책 — 「무엇을 시전할까」와 「얼마나 세게 칠까」.
///
/// `sim_core.dart` 에서 떼어 낸 이유는 두 가지다.
///  1. `sim_core.dart` 가 300줄 규칙에 닿아 있었다
///  2. ★ 정책을 **`const` 가 아니라 인자로** 받아야 한 번의 실행에서
///     두 정책을 나란히 잴 수 있다 (WORK_ORDER_DECK_FIX 작업 3-B).
///     측정 15에서 `kBotFullManaReserve` 가 `const` 라 도구를 두 번 돌리고
///     출력 파일을 손으로 옮겨야 했는데, 그 수고를 되풀이하지 않으려는 것이다.
///
/// ⚠ 밸런스 수치가 아니라 **봇의 행동**이다. 주문·적·확률표를 건드리지 않는다.
library;

import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/models/spell.dart';

/// 봇의 주문 선택 정책
enum BotPolicy {
  /// 측정 12~16까지의 봇 — 언제나 **가장 센 주문**을 고른다.
  /// 손에 회복·방어막이 잡혀도 공격 주문이 항상 이긴다.
  greedy('greedy(최강만)'),

  /// 여기에 **「사람이라면 당연히 하는 것」 두 줄만** 더한 봇.
  /// 그 이상 똑똑하게 만들지 않는다 (WORK_ORDER_DECK_FIX 3-A).
  /// 두 줄의 **순서는 방어막 → 회복**이다 (WORK_ORDER_GROWTH_SIM 작업 3).
  utility('utility(유틸)');

  const BotPolicy(this.label);

  /// 표에 찍을 이름
  final String label;
}

/// 회복을 공격보다 먼저 고르기 시작하는 체력 비율 (최대 체력 대비)
const double kBotHealHpRatio = 0.4;

/// 봇이 전력 시전을 시도할 때 남겨두려는 여유 마나.
/// 0이면 "전력을 낼 수 있으면 무조건 낸다"는 뜻이다.
const int kBotFullManaReserve = 0;

/// 이번 턴에 시전할 손패 인덱스를 고른다.
///
/// [castable] 은 봉인되지 않은 손패 인덱스다 (`Battle.castableIndexes`).
/// 마나 조건은 `Battle.castSpell` 이 그대로 검사하므로 여기서 우회하지 않는다.
/// ★ 순서 주의 — **방어막이 회복보다 먼저다** (WORK_ORDER_GROWTH_SIM 작업 3).
/// 반대로 두었더니 체력 40% 아래에서 강타를 예고받았을 때 방어막 4 대신
/// 회복 2를 골라 그대로 죽었다 (측정 17 · 검토 17 11-1 B).
/// 「죽을 것 같으면 먼저 막는다」가 사람의 순서다.
int chooseSpellIndex(Battle battle, List<int> castable, BotPolicy policy) {
  if (policy == BotPolicy.utility) {
    final urgent = _shieldIndex(battle, castable) ?? _healIndex(battle, castable);
    if (urgent != null) return urgent;
  }
  return _strongestIndex(battle, castable);
}

/// 정책 1) 다음 적 공격(예고된 강타 포함)이 **현재 체력 + 방어막 이상**이라
/// 그대로 맞으면 죽을 때, 손패에 방어막이 있으면 **가장 큰 것**을 고른다.
int? _shieldIndex(Battle battle, List<int> castable) {
  if (survivesNextHit(battle)) return null;
  return _bestEffectIndex(battle, castable, 'shield');
}

/// 정책 2) 체력이 최대의 [kBotHealHpRatio] 미만이고 손패에 회복이 있으면
/// **회복량이 가장 큰 것**을 고른다.
int? _healIndex(Battle battle, List<int> castable) {
  if (battle.playerHp >= battle.playerMaxHp * kBotHealHpRatio) return null;
  return _bestEffectIndex(battle, castable, 'heal');
}

/// 손패에서 [type] 효과를 가진 주문 중 효과 수치가 가장 큰 것.
/// 같은 값이면 먼저 잡힌 것을 쓴다 (실행할 때마다 같은 선택이 나온다).
int? _bestEffectIndex(Battle battle, List<int> castable, String type) {
  int? best;
  var bestValue = 0;
  for (final i in castable) {
    final effect = battle.hand[i].effect;
    if (effect == null || effect.type != type || effect.value <= 0) continue;
    if (best == null || effect.value > bestValue) {
      best = i;
      bestValue = effect.value;
    }
  }
  return best;
}

/// 정책 3) 그 밖에는 지금까지와 같다 — 가장 센 주문.
/// 위력이 같으면 손패에서 먼저 잡힌 쪽을 쓴다.
int _strongestIndex(Battle battle, List<int> castable) {
  var best = castable.first;
  for (final i in castable) {
    if (battle.hand[i].baseDamage > battle.hand[best].baseDamage) best = i;
  }
  return best;
}

/// 봇의 시전 강도 판단 (WORK_ORDER_INTENSITY 작업 2-E, 2단계용).
/// 1) 확정 대성공(마력 축적 만땅)이면 전력 — 크게 쓴다
/// 2) 전력으로 이번 턴에 적을 끝낼 수 있고 마나가 되면 전력
/// 3) 마나가 넉넉하고 다음 적 공격을 버틸 수 있으면 전력
/// 4) 그 밖에는 보통 (마나 0이므로 언제나 낼 수 있다)
///
/// v1과 달리 「마나가 없어서 못 쓴다」는 갈래가 없다. 보통은 항상 가능하다.
/// ⚠ **정책과 무관하게 같다** — 지시서가 강도는 건드리지 말라고 했다.
CastIntensity chooseIntensity(Battle battle, Spell spell) {
  final power = battle.spellPower(spell);
  final toKill = battle.enemyHp + battle.enemyShield;
  final canPayFull = battle.mana >= kManaCostFull;

  if (battle.charge >= kChargeThreshold && canPayFull) return CastIntensity.full;
  if (canPayFull && (power * kPowerFull).round() >= toKill) {
    return CastIntensity.full;
  }
  if (battle.mana >= kManaCostFull + kBotFullManaReserve &&
      survivesNextHit(battle)) {
    return CastIntensity.full;
  }
  return CastIntensity.normal;
}

/// 다음 적 공격을 맞고도 살아남는가 (지연 중이면 애초에 안 맞는다).
/// 예고된 강타는 `Battle.telegraph` 가 attack 으로 보여 준다.
bool survivesNextHit(Battle battle) {
  if (battle.enemyDelayTurns > 0) return true;
  final next = battle.telegraph;
  if (next.action != 'attack') return true;
  return battle.playerHp + battle.shield > next.value;
}
