/// 게임 데이터 4개 JSON이 전부 오류 없이 모델로 파싱되는지 검증한다.
/// 파일은 디스크에서 직접 읽는다 (에셋 번들 없이도 동작).
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/data/loader.dart';

String readData(String name) =>
    File('assets/data/$name').readAsStringSync();

/// 리스트에서 id 중복이 없는지 확인하는 헬퍼
void expectUniqueIds(Iterable<String> ids, String label) {
  final seen = <String>{};
  for (final id in ids) {
    expect(seen.add(id), isTrue, reason: '$label: id "$id" 중복');
  }
}

void main() {
  group('spells.json', () {
    final spells = GameDataParser.parseSpells(readData('spells.json'));

    test('70종 전부 파싱된다', () {
      expect(spells.length, 70);
      expectUniqueIds(spells.map((s) => s.id), 'spells');
    });

    test('등급·속성 값이 정해진 범위 안이다', () {
      const rarities = {'common', 'rare', 'epic'};
      const elements = {'fire', 'frost', 'arcane', 'shadow', 'nature'};
      for (final s in spells) {
        expect(rarities.contains(s.rarity), isTrue, reason: s.id);
        expect(elements.contains(s.element), isTrue, reason: s.id);
        expect(s.surgeTags, isNotEmpty, reason: s.id);
      }
    });

    test('등급별 수량이 목표와 일치 (30/25/15)', () {
      expect(spells.where((s) => s.rarity == 'common').length, 30);
      expect(spells.where((s) => s.rarity == 'rare').length, 25);
      expect(spells.where((s) => s.rarity == 'epic').length, 15);
    });

    test('시작 주문 3종이 존재한다', () {
      final ids = spells.map((s) => s.id).toSet();
      expect(ids.containsAll(['fireball', 'frost_arrow', 'mana_shield']),
          isTrue);
    });

    test('toJson 왕복 변환이 데이터를 보존한다', () {
      final s = spells.first;
      final round = s.toJson();
      expect(round['id'], s.id);
      expect(round['base_damage'], s.baseDamage);
      expect(round['surge_tags'], s.surgeTags);
    });
  });

  group('surges.json', () {
    final surges = GameDataParser.parseSurges(readData('surges.json'));

    test('80종 전부 파싱된다', () {
      expect(surges.length, 80);
      expectUniqueIds(surges.map((s) => s.id), 'surges');
    });

    test('effect type이 규약에 정의된 14종 안이다', () {
      // 기존 10종 + v2 신규 4종 (SURGE_DESIGN.md 4절).
      // 신규 4종의 구현은 지시서 C의 일이라 아직 core/surge.dart 에 없다.
      const allowed = {
        'self_damage', 'heal', 'mana_change', 'seal_spell', 'swap_hp',
        'summon_ally', 'damage_multiplier', 'skip_enemy_turn', 'extra_die',
        'force_reroll',
        'self_damage_spell', 'enemy_heal', 'shield', 'chain_cast',
      };
      for (final s in surges) {
        // 불발(fizzle)은 effects가 비어 있는 것이 정상이다.
        if (s.category != 'fizzle') {
          expect(s.effects, isNotEmpty, reason: s.id);
        }
        for (final e in s.effects) {
          expect(allowed.contains(e.type), isTrue,
              reason: '${s.id}: ${e.type}');
        }
      }
    });

    test('weight가 전부 1 이상이다', () {
      for (final s in surges) {
        expect(s.weight, greaterThanOrEqualTo(1), reason: s.id);
      }
    });

    test('태그 매칭: any는 모든 주문과, 속성 태그는 해당 속성과만 맞는다', () {
      final anySurge = surges.firstWhere((s) => s.tags.contains('any'));
      expect(anySurge.matchesTags(['fire']), isTrue);
      final fireSurge = surges.firstWhere(
          (s) => s.tags.contains('fire') && !s.tags.contains('any'));
      expect(fireSurge.matchesTags(['fire']), isTrue);
      expect(fireSurge.matchesTags(['frost']), isFalse);
    });

    test('모든 주문의 surge_tags에 대해 발생 가능한 폭주가 충분하다', () {
      // 어떤 주문이 실패해도 뽑을 폭주가 최소 10종은 있어야 한다
      final spells = GameDataParser.parseSpells(readData('spells.json'));
      for (final spell in spells) {
        final candidates =
            surges.where((s) => s.matchesTags(spell.surgeTags)).length;
        expect(candidates, greaterThanOrEqualTo(10),
            reason: '${spell.id}: 매칭 폭주 $candidates종뿐');
      }
    });
  });

  group('enemies.json', () {
    final enemies = GameDataParser.parseEnemies(readData('enemies.json'));

    test('39종 전부 파싱된다 (보스 13 포함)', () {
      expect(enemies.length, 39);
      expect(enemies.where((e) => e.isBoss).length, 13);
      expectUniqueIds(enemies.map((e) => e.id), 'enemies');
    });

    test('패턴은 3~4개 행동이고 종류가 유효하다', () {
      const actions = {'attack', 'charge', 'defend', 'heal'};
      for (final e in enemies) {
        expect(e.pattern.length, inInclusiveRange(3, 4), reason: e.id);
        for (final a in e.pattern) {
          expect(actions.contains(a.action), isTrue,
              reason: '${e.id}: ${a.action}');
          expect(a.label, isNotEmpty, reason: e.id);
        }
      }
    });

    test('보스는 전부 2페이즈 정보를 갖는다', () {
      for (final boss in enemies.where((e) => e.isBoss)) {
        // 지역 1~12 보스는 HP 40 → 405 곡선을 그린다
        // (ENEMIES.md 3절 · 2026-09-03 후반 하향)
        expect(boss.hp, inInclusiveRange(40, 405), reason: boss.id);
        expect(boss.phase2HpThreshold, isNotNull, reason: boss.id);
        expect(boss.phase2Pattern, isNotEmpty, reason: boss.id);
      }
    });

    test('tier는 1~5이고 tier별로 최소 5마리씩 있다', () {
      for (var tier = 1; tier <= 5; tier++) {
        final count =
            enemies.where((e) => !e.isBoss && e.tier == tier).length;
        expect(count, greaterThanOrEqualTo(5), reason: 'tier $tier');
      }
    });
  });

  group('relics.json', () {
    final relics = GameDataParser.parseRelics(readData('relics.json'));

    test('40종 전부 파싱된다', () {
      expect(relics.length, 40);
      expectUniqueIds(relics.map((r) => r.id), 'relics');
    });

    test('등급별 수량이 목표와 일치 (18/14/8)', () {
      expect(relics.where((r) => r.rarity == 'common').length, 18);
      expect(relics.where((r) => r.rarity == 'rare').length, 14);
      expect(relics.where((r) => r.rarity == 'epic').length, 8);
    });

    test('판정 보정(check_bonus 계열)은 최대 +3까지만', () {
      for (final r in relics) {
        if (r.effect.type.startsWith('check_bonus')) {
          expect(r.effect.value, lessThanOrEqualTo(3), reason: r.id);
        }
      }
    });

    test('판정 확률 관련 유물이 70% 이상이다', () {
      const probTypes = {
        'check_bonus', 'check_bonus_full',
        'extra_reroll', 'free_rerolls', 'pair_bonus_up', 'charge_gain_up',
        'reroll_ones',
      };
      final probCount =
          relics.where((r) => probTypes.contains(r.effect.type)).length;
      expect(probCount / relics.length, greaterThanOrEqualTo(0.7));
    });
  });
}
