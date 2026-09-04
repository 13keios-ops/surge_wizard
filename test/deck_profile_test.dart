/// 측정용 지역별 덱(`tool/measure_profile.dart`)이 옳게 짜이는지 본다
/// (WORK_ORDER_DECK_FIX 작업 5).
///
/// 측정 16에서 1지역 덱에 **적을 깎을 주문이 한 장뿐**이라 전투가 교착했다
/// (200턴 안전장치가 실제로 걸렸다). 그 일이 다시 일어나지 않게 막는 검사다.
/// 기대값은 `SPELL_CIRCLES.md` 1서클 절의 규칙이다.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/data/parser.dart';

import '../tool/measure_profile.dart';

void main() {
  final spells = GameDataParser.parseSpells(
      File('assets/data/spells.json').readAsStringSync());
  final circles = loadSpellCircles();

  test('1. ★ 모든 지역의 덱에 위력 > 0인 주문이 2장 이상 있다', () {
    for (final id in kDeckSlots.keys) {
      final deck = profileDeck(spells, circles, id);
      final attackers = deck.where((s) => s.baseDamage > 0).toList();
      expect(attackers.length, greaterThanOrEqualTo(2),
          reason: '$id지역 덱: ${deck.map((s) => '${s.name}(${s.baseDamage})')}'
              ' — 한 장이 봉인되면 적을 못 깎아 전투가 끝나지 않는다');
    }
  });

  test('2. 1지역 덱은 「잿불 방패 · 냉기 손길 · 영혼 갉기」다', () {
    final deck = profileDeck(spells, circles, 1);
    expect(deck.map((s) => s.id).toList(),
        ['cinder_shield', 'chill_touch', 'soul_nip']);
    // 셋 다 「위력을 지킨 유틸」이다 — 위력 5에 효과가 덤으로 붙어 있다
    for (final s in deck) {
      expect(s.baseDamage, 5, reason: s.id);
      expect(isUtilitySpell(s), isTrue, reason: s.id);
    }
  });

  test('3. 1서클 슬롯이 5칸이 되면 위력 0인 두 장도 들어온다', () {
    // 10지역부터 1서클이 5칸이다 (kDeckSlots). 「위력을 지킨 유틸」이 먼저지만
    // 칸이 남으면 치유 약초·마력방패가 자연히 뒤따라야 한다.
    final deck = profileDeck(spells, circles, 10);
    final ids = deck.map((s) => s.id).toSet();
    expect(ids.containsAll(['healing_herb', 'mana_shield']), isTrue);
  });
}
