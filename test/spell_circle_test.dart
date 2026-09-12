/// spells.json 검산 — 주문 90종의 `circle`(서클 1~9)이 SPELL_CIRCLES.md 와 맞는지 본다.
/// `circle`은 아직 Spell 모델에 없는 필드이므로 JSON을 직접 읽는다.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 서클별 목표 종수 (2026-09-13 개정 — 70종 → 90종).
/// **속성마다** 1~3서클 3종 · 4~6서클 2종 · 7~9서클 1종 = 18종, × 5속성 = 90종.
/// 칸마다 최소 2종이 있어야 슬롯머신이 돈다 (GAME_DESIGN 5.4절).
const kCountByCircle = <int, int>{
  1: 15,
  2: 15,
  3: 15,
  4: 10,
  5: 10,
  6: 10,
  7: 5,
  8: 5,
  9: 5,
};

/// 속성 하나가 그 서클에 가져야 할 종수
const kPerElementByCircle = <int, int>{
  1: 3,
  2: 3,
  3: 3,
  4: 2,
  5: 2,
  6: 2,
  7: 1,
  8: 1,
  9: 1,
};

const kElements = <String>['fire', 'frost', 'arcane', 'shadow', 'nature'];

/// circle → rarity 대응 (SPELL_CIRCLES.md 3절)
String rarityForCircle(int circle) {
  if (circle <= 3) return 'common';
  if (circle <= 6) return 'rare';
  return 'epic';
}

void main() {
  final raw = File('assets/data/spells.json').readAsStringSync();
  final spells = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

  test('1. 90종 전부 circle이 있고 1~9 범위다', () {
    expect(spells.length, 90);
    for (final s in spells) {
      final c = s['circle'];
      expect(c, isNotNull, reason: '${s['id']}: circle 없음');
      expect(c, isA<int>(), reason: '${s['id']}: circle이 정수가 아니다');
      expect(c as int, inInclusiveRange(1, 9), reason: '${s['id']}');
    }
  });

  test('2. 서클별 종수 = 10·10·10·10·10·5·5·5·5', () {
    for (final entry in kCountByCircle.entries) {
      final count = spells.where((s) => s['circle'] == entry.key).length;
      expect(count, entry.value, reason: '${entry.key}서클');
    }
  });

  test('3. ★ 모든 서클에 5속성이 전부 존재한다', () {
    for (var c = 1; c <= 9; c++) {
      final elements =
          spells.where((s) => s['circle'] == c).map((s) => s['element']).toSet();
      for (final el in kElements) {
        expect(elements.contains(el), isTrue, reason: '$c서클에 $el 없음');
      }
    }
  });

  test('4. circle ↔ rarity 대응이 100% 일치 (1~3 common / 4~6 rare / 7~9 epic)', () {
    for (final s in spells) {
      expect(s['rarity'], rarityForCircle(s['circle'] as int),
          reason: '${s['id']} (${s['circle']}서클)');
    }
    // 등급별 총량도 함께 확인 (45 / 30 / 15 — 2026-09-13 90종)
    expect(spells.where((s) => s['rarity'] == 'common').length, 45);
    expect(spells.where((s) => s['rarity'] == 'rare').length, 30);
    expect(spells.where((s) => s['rarity'] == 'epic').length, 15);
  });

  test('5. 9서클 5종의 dc_modifier가 전부 3이다', () {
    final ninth = spells.where((s) => s['circle'] == 9).toList();
    expect(ninth.length, 5);
    for (final s in ninth) {
      expect(s['dc_modifier'], 3, reason: '${s['id']}');
    }
  });

  // ── WORK_ORDER_DECK_FIX 작업 5 (사용자 승인 수치) ──

  test('6. 영혼 수확(soul_reaper)의 위력이 13이다', () {
    final s = spells.firstWhere((s) => s['id'] == 'soul_reaper');
    expect(s['base_damage'], 13);
    // 회복 5와 DC +1은 그대로 둔다 — 그게 이 주문의 정체성이다
    expect(s['effect'], {'type': 'heal', 'value': 5});
    expect(s['dc_modifier'], 1);
  });

  test('7. 7서클 5종의 위력이 12~13 범위다', () {
    final seventh = spells.where((s) => s['circle'] == 7).toList();
    expect(seventh.length, 5);
    for (final s in seventh) {
      expect(s['base_damage'], inInclusiveRange(12, 13), reason: '${s['id']}');
    }
  });

  // ── WORK_ORDER_HEAL_FIX 작업 3 (어감 때문에 이름만 고쳤다) ──

  test('8. 개명 3종의 이름이 새 이름이고 id·수치는 그대로다', () {
    // 「침」이 타액으로, 「사출」·「분출」이 다른 뜻으로 읽혔다 (SPELL_CIRCLES 0절).
    // id 로 코드·테스트가 주문을 찾으므로 id 는 절대 바뀌면 안 된다.
    const renamed = {
      'magma_spit': '용암 덩이',
      'snow_bolt': '눈덩이 투척',
      'sap_surge': '수액 채취',
    };
    // 수치는 개명 전 값 그대로여야 한다 (위력 · dc_modifier · 서클 · effect)
    const untouched = {
      'magma_spit': [12, 0, 5],
      'snow_bolt': [7, 0, 2],
      'sap_surge': [8, 0, 4],
    };
    renamed.forEach((id, name) {
      final s = spells.firstWhere((s) => s['id'] == id);
      expect(s['name'], name, reason: id);
      expect([s['base_damage'], s['dc_modifier'], s['circle']], untouched[id],
          reason: id);
    });
    expect(spells.firstWhere((s) => s['id'] == 'sap_surge')['effect'],
        {'type': 'mana_restore', 'value': 1});
    expect(spells.firstWhere((s) => s['id'] == 'magma_spit')['effect'], isNull);
    expect(spells.firstWhere((s) => s['id'] == 'snow_bolt')['effect'], isNull);
    // 옛 이름이 어디에도 남아 있지 않아야 한다
    for (final s in spells) {
      expect(const ['용암 침', '눈덩이 사출', '수액 분출'].contains(s['name']), isFalse,
          reason: '${s['id']} 에 옛 이름이 남았다');
    }
  });

  test('9. (속성 × 서클) 칸마다 목표 종수가 정확히 들어 있다', () {
    for (final e in kElements) {
      for (var c = 1; c <= 9; c++) {
        final n = spells
            .where((s) => s['element'] == e && s['circle'] == c)
            .length;
        expect(n, kPerElementByCircle[c],
            reason: '$e $c서클: $n종 (목표 ${kPerElementByCircle[c]})');
      }
    }
  });

  test('10. 효과 타입은 코드가 아는 6종뿐이다', () {
    const known = {
      'shield', 'heal', 'delay_enemy', 'mana_restore', 'check_bonus', 'extra_die'
    };
    for (final s in spells) {
      final e = s['effect'];
      if (e == null) continue;
      expect(known, contains(e['type']), reason: '${s['id']}: 모르는 효과');
    }
  });
}
