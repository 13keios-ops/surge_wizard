import 'dart:math';

import '../models/relic.dart';

/// 보유 유물들의 효과를 전투·런이 쓰기 좋은 형태로 합산한 값 묶음.
/// 유물이 없으면 전부 0 (const RelicPowers()).
class RelicPowers {
  const RelicPowers({
    this.checkBonus = 0,
    this.checkBonusFull = 0,
    this.damageUp = 0,
    this.maxHpUp = 0,
    this.startShield = 0,
    this.healAfterBattle = 0,
    this.extraRerolls = 0,
    this.freeRerolls = 0,
    this.pairBonusUp = 0,
    this.chargeGainUp = 0,
    this.healOnCrit = 0,
    this.manaOnSurge = 0,
    this.rerollOnesTo = 0,
  });

  /// 모든 판정값 +N
  final int checkBonus;

  /// 전력 시전 판정값 +N
  final int checkBonusFull;

  /// 모든 공격 주문 대미지 +N (대미지 0인 보조 주문에는 미적용)
  final int damageUp;

  /// 최대 체력 +N (런 레벨에서 적용)
  final int maxHpUp;

  /// 전투 시작 시 방어막 N
  final int startShield;

  /// 전투 승리 후 체력 N 회복 (런 레벨에서 적용)
  final int healAfterBattle;

  /// 판정당 리롤 가능 횟수 +N
  final int extraRerolls;

  /// 전투마다 마나 없이 리롤 N회
  final int freeRerolls;

  /// 페어 보너스 +N
  final int pairBonusUp;

  /// 실패로 마력 축적이 오를 때 +N 추가
  final int chargeGainUp;

  /// 대성공 시 체력 N 회복
  final int healOnCrit;

  /// 폭주 발생 시 마나 N 회복
  final int manaOnSurge;

  /// 주사위 눈 1이 나오면 이 값으로 바뀐다 (0 = 효과 없음, 중복 시 최댓값)
  final int rerollOnesTo;

  /// 일부 값이 더해진 복사본 (메타 영구 강화를 유물 효과 위에 얹을 때 사용)
  RelicPowers add({int maxHpUp = 0, int extraRerolls = 0}) => RelicPowers(
        checkBonus: checkBonus,
        checkBonusFull: checkBonusFull,
        damageUp: damageUp,
        maxHpUp: this.maxHpUp + maxHpUp,
        startShield: startShield,
        healAfterBattle: healAfterBattle,
        extraRerolls: this.extraRerolls + extraRerolls,
        freeRerolls: freeRerolls,
        pairBonusUp: pairBonusUp,
        chargeGainUp: chargeGainUp,
        healOnCrit: healOnCrit,
        manaOnSurge: manaOnSurge,
        rerollOnesTo: rerollOnesTo,
      );

  /// 유물 목록에서 효과를 합산한다.
  factory RelicPowers.fromRelics(Iterable<Relic> relics) {
    var checkBonus = 0, full = 0, damage = 0, maxHp = 0;
    var shield = 0, healAfter = 0, extraRr = 0, freeRr = 0, pair = 0;
    var chargeUp = 0, healCrit = 0, manaSurge = 0, onesTo = 0;
    for (final r in relics) {
      final v = r.effect.value;
      switch (r.effect.type) {
        case 'check_bonus':
          checkBonus += v;
        case 'check_bonus_full':
          full += v;
        case 'damage_up':
          damage += v;
        case 'max_hp_up':
          maxHp += v;
        case 'start_shield':
          shield += v;
        case 'heal_after_battle':
          healAfter += v;
        case 'extra_reroll':
          extraRr += v;
        case 'free_rerolls':
          freeRr += v;
        case 'pair_bonus_up':
          pair += v;
        case 'charge_gain_up':
          chargeUp += v;
        case 'heal_on_crit':
          healCrit += v;
        case 'mana_on_surge':
          manaSurge += v;
        case 'reroll_ones':
          onesTo = max(onesTo, v);
      }
    }
    return RelicPowers(
      checkBonus: checkBonus,
      checkBonusFull: full,
      damageUp: damage,
      maxHpUp: maxHp,
      startShield: shield,
      healAfterBattle: healAfter,
      extraRerolls: extraRr,
      freeRerolls: freeRr,
      pairBonusUp: pair,
      chargeGainUp: chargeUp,
      healOnCrit: healCrit,
      manaOnSurge: manaSurge,
      rerollOnesTo: onesTo,
    );
  }
}
