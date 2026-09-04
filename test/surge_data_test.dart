/// surges.json 검산 — 폭주 6갈래 80종이 SURGE_DESIGN.md 와 정확히 일치하는지 본다.
/// 핵심은 마지막 검사다: **어떤 주문으로 실패해도 갈래 비율이 25/20/15/15/15/10%** 여야 한다.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/data/loader.dart';
import 'package:surge_wizard/models/surge_event.dart';

String readData(String name) => File('assets/data/$name').readAsStringSync();

/// 6갈래 (SURGE_DESIGN.md 2절)
const kCategories = <String>[
  'backlash', // 역류
  'misfire', // 오발
  'fizzle', // 불발
  'amplify', // 증폭
  'summon', // 소환
  'chain', // 연쇄
];

/// 갈래별 목표 종수
const kCountByCategory = <String, int>{
  'backlash': 20,
  'misfire': 18,
  'fizzle': 11,
  'amplify': 11,
  'summon': 11,
  'chain': 9,
};

/// 갈래별 목표 가중치 합 (총 1600)
const kWeightByCategory = <String, int>{
  'backlash': 400,
  'misfire': 320,
  'fizzle': 240,
  'amplify': 240,
  'summon': 240,
  'chain': 160,
};

/// 갈래별 목표 비율 — 천분율로 두어 정수 비교로 오차 없이 검산한다.
/// 25.0% / 20.0% / 15.0% / 15.0% / 15.0% / 10.0%
const kRatioPermille = <String, int>{
  'backlash': 250,
  'misfire': 200,
  'fizzle': 150,
  'amplify': 150,
  'summon': 150,
  'chain': 100,
};

/// 폭주가 쓰는 태그는 any + 속성 5종뿐이다 (SURGE_DESIGN.md 3절)
const kAllowedTags = <String>{
  'any',
  'fire',
  'frost',
  'arcane',
  'shadow',
  'nature',
};

int sumWeight(Iterable<SurgeEvent> list) =>
    list.fold(0, (acc, s) => acc + s.weight);

void main() {
  final surges = GameDataParser.parseSurges(readData('surges.json'));

  test('1. 80종이고 id 중복이 없다', () {
    expect(surges.length, 80);
    final seen = <String>{};
    for (final s in surges) {
      expect(seen.add(s.id), isTrue, reason: 'id "${s.id}" 중복');
    }
  });

  test('2. category가 6갈래 중 하나다', () {
    for (final s in surges) {
      expect(kCategories.contains(s.category), isTrue,
          reason: '${s.id}: 알 수 없는 갈래 "${s.category}"');
    }
  });

  test('3. 갈래별 종수 = 20 / 18 / 11 / 11 / 11 / 9', () {
    for (final entry in kCountByCategory.entries) {
      final count = surges.where((s) => s.category == entry.key).length;
      expect(count, entry.value, reason: entry.key);
    }
  });

  test('4. 갈래별 가중치 합 = 400 / 320 / 240 / 240 / 240 / 160 (총 1600)', () {
    for (final entry in kWeightByCategory.entries) {
      final w = sumWeight(surges.where((s) => s.category == entry.key));
      expect(w, entry.value, reason: entry.key);
    }
    expect(sumWeight(surges), 1600);
  });

  test('5. 태그는 any 또는 속성 5종만 쓴다 (태그 1개씩)', () {
    for (final s in surges) {
      expect(s.tags.length, 1, reason: '${s.id}: 태그는 하나여야 한다');
      for (final t in s.tags) {
        expect(kAllowedTags.contains(t), isTrue, reason: '${s.id}: 태그 "$t"');
      }
    }
  });

  test('6. any 40종 합 1000, 속성별 8종 합 각 120', () {
    final anyList = surges.where((s) => s.tags.contains('any')).toList();
    expect(anyList.length, 40);
    expect(sumWeight(anyList), 1000);

    for (final el in ['fire', 'frost', 'arcane', 'shadow', 'nature']) {
      final list = surges.where((s) => s.tags.contains(el)).toList();
      expect(list.length, 8, reason: el);
      expect(sumWeight(list), 120, reason: el);
    }
  });

  test('7. ★ 주문 70종 각각의 후보 풀에서 갈래 비율이 목표와 정확히 일치한다', () {
    final spells = GameDataParser.parseSpells(readData('spells.json'));
    expect(spells.length, 70);

    for (final spell in spells) {
      final pool =
          surges.where((s) => s.matchesTags(spell.surgeTags)).toList();
      final total = sumWeight(pool);
      expect(total, greaterThan(0), reason: spell.id);

      for (final entry in kRatioPermille.entries) {
        final w = sumWeight(pool.where((s) => s.category == entry.key));
        // w / total == permille / 1000 을 정수 곱으로 비교 (오차 0)
        expect(w * 1000, total * entry.value,
            reason: '${spell.id} / ${entry.key}: '
                '$w / $total (목표 ${entry.value / 10}%)');
      }
    }
  });

  test('8. fizzle 11종은 effects가 비어 있다', () {
    final fizzles = surges.where((s) => s.category == 'fizzle').toList();
    expect(fizzles.length, 11);
    for (final s in fizzles) {
      expect(s.effects, isEmpty, reason: s.id);
    }
  });
}
