/// 성장 가정(`tool/measure_growth.dart`)이 문서 표와 일치하는지 본다
/// (WORK_ORDER_GROWTH_SIM 작업 5).
///
/// ⚠ **게임 코드가 아니라 측정용 가정**을 검사한다. 이 값이 틀리면 측정 18의
/// 「상한」 열이 통째로 거짓말이 되므로, 허용 범위가 아니라 **기대값 표와 대조**한다.
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/enemy.dart';
import 'package:surge_wizard/models/spell.dart';

import '../tool/bot_policy.dart';
import '../tool/measure_growth.dart';
import '../tool/measure_profile.dart';

/// 지시서 작업 1의 표 — 서클 → 만강 배수
const Map<int, double> kExpectedMultipliers = {
  1: 2.00,
  2: 1.90,
  3: 1.80,
  4: 1.70,
  5: 1.60,
  6: 1.50,
  7: 1.40,
  8: 1.30,
  9: 1.20,
};

/// 지시서 작업 2의 표 — 지역 → 최종 최대 체력
const Map<int, int> kExpectedMaxHp = {
  1: 20,
  2: 25,
  3: 31,
  4: 37,
  5: 44,
  6: 51,
  7: 59,
  8: 66,
  9: 70,
  10: 76,
  11: 82,
  12: 86,
};

void main() {
  final spells = GameDataParser.parseSpells(
      File('assets/data/spells.json').readAsStringSync());
  final enemies = GameDataParser.parseEnemies(
      File('assets/data/enemies.json').readAsStringSync());
  final circles = loadSpellCircles();

  test('1. 서클별 만강 배수가 지시서 표와 일치한다', () {
    kExpectedMultipliers.forEach((circle, expected) {
      expect(upgradeMultiplier(circle, BookUpgrade.full),
          closeTo(expected, 1e-9),
          reason: '$circle서클');
      // 강화 없음은 언제나 원본 그대로다
      expect(upgradeMultiplier(circle, BookUpgrade.none), 1.0);
    });
    // 상한 단계 수도 「11 − 서클」이어야 한다
    expect(upgradeStepsOf(1), 10);
    expect(upgradeStepsOf(9), 2);
  });

  test('2. 강화가 heal·shield를 위력과 같은 배수로 올린다', () {
    // WORK_ORDER_HEAL_FIX 작업 1. 지시서가 못 박은 두 값을 직접 대조한다.
    Spell upgraded(String id) {
      final spell = spells.firstWhere((s) => s.id == id);
      return upgradedSpell(spell, circles[id]!, BookUpgrade.full);
    }

    expect(upgraded('mana_shield').effect?.value, 12); // 방어막 6 → 12
    expect(upgraded('healing_herb').effect?.value, 10); // 회복 5 → 10

    // 전수: 위력과 같은 배수 · 같은 반올림이어야 한다
    for (final spell in spells) {
      final circle = circles[spell.id]!;
      final multiplier = kExpectedMultipliers[circle]!;
      final up = upgradedSpell(spell, circle, BookUpgrade.full);
      final e = spell.effect;
      if (e == null || !kUpgradableEffectTypes.contains(e.type)) continue;
      expect(up.effect?.value, (e.value * multiplier).round(), reason: spell.id);
    }
  });

  test('2-a. 강화가 판정·지연·마나 효과와 dc_modifier는 안 바꾼다', () {
    // check_bonus·extra_die 는 3.4절 확률표에, delay_enemy 는 지연 상한에
    // 직접 개입한다. mana_restore 는 최대 마나가 3~5뿐이라 의미가 없다.
    for (final spell in spells) {
      final circle = circles[spell.id]!;
      final up = upgradedSpell(spell, circle, BookUpgrade.full);
      expect(up.baseDamage,
          (spell.baseDamage * kExpectedMultipliers[circle]!).round(),
          reason: spell.id);
      expect(up.dcModifier, spell.dcModifier, reason: spell.id);
      expect(up.effect?.type, spell.effect?.type, reason: spell.id);
      expect(up.element, spell.element, reason: spell.id);
      expect(up.id, spell.id);
      final e = spell.effect;
      if (e == null || kUpgradableEffectTypes.contains(e.type)) continue;
      expect(up.effect?.value, e.value, reason: '${spell.id} (${e.type})');
    }
    // 올리는 효과는 회복·방어막 둘뿐이다
    expect(kUpgradableEffectTypes, {'heal', 'shield'});
  });

  test('2-b. 덱은 강화 수준과 무관하게 같은 주문으로 짜인다', () {
    // 「강화만 달라졌다」가 성립해야 하한·상한 비교가 뜻을 가진다
    for (final id in kDeckSlots.keys) {
      final low = profileDeck(spells, circles, id);
      final high =
          profileDeck(spells, circles, id, upgrade: BookUpgrade.full);
      expect(high.map((s) => s.id).toList(), low.map((s) => s.id).toList(),
          reason: '$id지역');
      int power(List<Spell> deck) => deck.fold(0, (a, s) => a + s.baseDamage);
      expect(power(high), greaterThan(power(low)),
          reason: '$id지역 — 강화했는데 덱 위력 합이 안 올랐다');
    }
  });

  test('3. 지역별 최종 최대 체력이 지시서 표와 일치한다', () {
    kExpectedMaxHp.forEach((id, expected) {
      final p = profileOf(id);
      expect(p.maxHp, expected, reason: '$id지역');
      expect(p.maxHp, p.baseMaxHp + p.passiveHp, reason: '$id지역');
    });
    // 양 끝 — 1레벨은 0, 만렙은 +20이다
    expect(passiveMaxHp(1), 0);
    expect(passiveMaxHp(kMaxLevel), kPassiveMaxHpAtCap);
  });

  test('4. 봇은 회복보다 방어막을 먼저 본다', () {
    // 체력 40% 아래(회복 규칙 발동) + 다음 강타에 죽는 상황(방어막 규칙 발동).
    // 두 규칙이 동시에 걸리므로 어느 쪽을 먼저 보는지가 그대로 드러난다.
    final battle = _dyingBattle(spells, enemies);
    expect(battle.playerHp < battle.playerMaxHp * kBotHealHpRatio, isTrue,
        reason: '회복 규칙이 걸리는 상황이어야 한다');
    expect(survivesNextHit(battle), isFalse,
        reason: '방어막 규칙이 걸리는 상황이어야 한다');

    final picked = chooseSpellIndex(
        battle, battle.castableIndexes, BotPolicy.utility);
    expect(battle.hand[picked].effect?.type, 'shield',
        reason: '방어막(${battle.hand[1].name})이 아니라 '
            '${battle.hand[picked].name}을 골랐다');
  });
}

/// 회복·방어막을 한 장씩 들고, 다음 적 공격에 죽는 체력으로 선 전투.
Battle _dyingBattle(List<Spell> spells, List<Enemy> enemies) {
  Spell spellOf(String id) => spells.firstWhere((s) => s.id == id);
  final enemy = enemies.firstWhere((e) => e.id == 'cave_rat');
  return Battle(
    enemy: enemy,
    hand: [spellOf('healing_herb'), spellOf('mana_shield')],
    surgePool: const [],
    // 최대 체력의 40% 미만이면서, 적 공격(cave_rat)에 죽는 값
    playerHp: 1,
    playerMaxHp: 20,
    random: Random(1),
  );
}
