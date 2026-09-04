import 'dart:math';

import '../models/spell.dart';
import 'battle.dart';
import 'constants.dart';

/// 주문의 부가 효과와 아슬아슬 반동을 전투에 적용한다
/// (GAME_DESIGN 4.5절 · 3.2절).
///
/// `battle.dart` 가 300줄을 넘지 않도록 떼어낸 것이며, 규칙은 그대로다.
/// 주문 발동이 성공한 뒤에만 불린다 (폭주 연쇄 chain_cast 도 같은 경로).
void applyEffectTo(Battle b, Spell spell) {
  final e = spell.effect;
  if (e == null) return;
  switch (e.type) {
    case 'shield':
      b.shield += e.value;
    case 'heal':
      b.healPlayer(e.value);
    case 'delay_enemy':
      b.addEnemyDelay(e.value);
    case 'mana_restore':
      b.mana = min(b.maxMana, b.mana + e.value);
    case 'check_bonus':
      b.pendingCheckBonus += e.value;
    case 'extra_die':
      b.pendingExtraDie = true;
  }
}

/// 아슬아슬 반동: kGrazeBacklashKinds가지 중 무작위 1개 (GAME_DESIGN 3.2절).
/// [random] 은 전투가 쓰는 난수원 그대로다 (굴림 순서가 바뀌지 않는다).
void applyGrazeBacklash(Battle b, Spell spell, Random random) {
  switch (random.nextInt(kGrazeBacklashKinds)) {
    case 0:
      b.dealToPlayer(kGrazeBacklashHpLoss);
      b.log.add('반동: 체력 -$kGrazeBacklashHpLoss');
    case 1:
      b.mana = 0;
      b.log.add('반동: 마나 전부 소모');
    case 2:
      b.sealedSpellIds.add(spell.id);
      b.log.add('반동: ${spell.name} 봉인');
    case 3:
      b.enemyActsAgain = true;
      b.log.add('반동: 적 행동 앞당김');
  }
}
