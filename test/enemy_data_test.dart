/// enemies.json 검산 — 보스 12종이 지역 1~12에 하나씩 대응하고,
/// 수치가 ENEMIES.md 2·3절 표와 정확히 일치하는지 본다.
/// `region`은 아직 Enemy 모델에 없는 필드이므로 JSON을 직접 읽는다.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 지역 → 보스 id (ENEMIES.md 2절)
const kBossByRegion = <int, String>{
  1: 'boss_elder_slime',
  2: 'boss_bone_heap',
  3: 'boss_bog_toad',
  4: 'boss_burning_treant',
  5: 'boss_iron_troll',
  6: 'boss_sun_sphinx',
  7: 'boss_white_wolf',
  8: 'boss_awakened_idol',
  9: 'boss_headless_knight',
  10: 'boss_archlich',
  11: 'boss_void_titan',
  12: 'boss_inferno_dragon',
};

/// 보스 id → [HP, 일반 공격, 강타, 방어] (ENEMIES.md 3절 수치표)
///
/// ★ 2026-09-03 「후반 곡선 정렬」 — **10~12지역 보스의 HP만** 내렸다
/// (330→310 · 400→355 · 480→405). 공격·강타·방어는 한 값도 바꾸지 않았다.
const kBossStats = <String, List<int>>{
  'boss_elder_slime': [40, 5, 9, 5],
  'boss_bone_heap': [55, 6, 11, 5],
  'boss_bog_toad': [70, 7, 13, 6],
  'boss_burning_treant': [90, 8, 15, 7],
  'boss_iron_troll': [115, 9, 17, 8],
  'boss_sun_sphinx': [145, 10, 19, 8],
  'boss_white_wolf': [180, 11, 21, 9],
  'boss_awakened_idol': [220, 12, 24, 10],
  'boss_headless_knight': [270, 13, 27, 10],
  'boss_archlich': [310, 14, 30, 11],
  'boss_void_titan': [355, 16, 34, 12],
  'boss_inferno_dragon': [405, 18, 38, 13],
};

/// 후반 곡선 정렬로 **내린** 보스 HP와 그에 딸린 2페이즈 임계 (지시서 O 작업 2).
/// 임계는 언제나 `hp ~/ 2` 다 — 표와 계산이 둘 다 맞는지 함께 본다.
const kLateBossHp = <String, List<int>>{
  'boss_archlich': [310, 155],
  'boss_void_titan': [355, 177],
  'boss_inferno_dragon': [405, 202],
};

/// 이번에 **손대지 않기로 한** 1~9지역 보스 HP.
/// kBossStats 에서 잘라 쓰지 않고 따로 적는다 — 그 표가 잘못 바뀌면 함께 틀린다.
const kEarlyBossHp = <int>[40, 55, 70, 90, 115, 145, 180, 220, 270];

/// 지역에 배정되지 않은 보스 (이벤트 던전용 — 현행 유지)
const kUnassignedBoss = 'boss_dice_devourer';

/// 이름 규칙 위반어 (ENEMIES.md 2절 — 직함은 형상을 알려주지 않는다)
const kBannedTitles = <String>['감독관', '문지기', '수호상'];

void main() {
  final raw = File('assets/data/enemies.json').readAsStringSync();
  final enemies = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

  final bosses = enemies.where((e) => e['is_boss'] == true).toList();
  final normals = enemies.where((e) => e['is_boss'] != true).toList();

  test('1. 적 39종이고 id 중복이 없다', () {
    expect(enemies.length, 39);
    expect(enemies.map((e) => e['id']).toSet().length, 39);
  });

  test('2. 보스가 13종이다 (지역 12 + 주사위 포식자 1)', () {
    expect(bosses.length, 13);
    expect(normals.length, 26);
  });

  test('3. region을 가진 보스가 12종이고 값이 1~12 각각 하나씩이다', () {
    final regioned = bosses.where((e) => e['region'] != null).toList();
    expect(regioned.length, 12);
    final regions = regioned.map((e) => e['region'] as int).toList()..sort();
    expect(regions, List<int>.generate(12, (i) => i + 1));
    // 지역별 보스 id 가 ENEMIES.md 2절 배정과 같다
    for (final e in regioned) {
      expect(e['id'], kBossByRegion[e['region']],
          reason: '지역 ${e['region']} 보스 배정이 다르다');
    }
  });

  test('4. 보스 중 region이 없는 것은 주사위 포식자뿐이다', () {
    final without =
        bosses.where((e) => e['region'] == null).map((e) => e['id']).toList();
    expect(without, [kUnassignedBoss]);
  });

  test('5. 일반 적 26종에는 region이 없다', () {
    for (final e in normals) {
      expect(e.containsKey('region'), isFalse, reason: '${e['id']}: region 있음');
    }
  });

  test('6. 보스 12종의 수치가 ENEMIES.md 3절 표와 일치한다', () {
    var prevHp = 0;
    for (var region = 1; region <= 12; region++) {
      final id = kBossByRegion[region]!;
      final e = enemies.firstWhere((x) => x['id'] == id);
      final want = kBossStats[id]!;
      expect(e['hp'], want[0], reason: '$id HP');
      expect(e['hp'] as int > prevHp, isTrue, reason: '$id: HP가 단조 증가하지 않음');
      prevHp = e['hp'] as int;

      // 패턴의 각 value 는 종류별 고정값이다 (회복량 = 일반 공격)
      for (final a in (e['pattern'] as List).cast<Map<String, dynamic>>()) {
        final expected = switch (a['action'] as String) {
          'attack' || 'heal' => want[1],
          'charge' => want[2],
          'defend' => want[3],
          _ => -1,
        };
        expect(a['value'], expected,
            reason: '$id ${a['action']} "${a['label']}" 값이 표와 다름');
      }
    }
    expect(prevHp, 405); // 12지역 화염룡까지 40 → 405 (2026-09-03 하향)
  });

  test('7. 보스 13종 전부 2페이즈가 있고 임계 = hp ~/ 2 다', () {
    for (final e in bosses) {
      expect(e['phase2_hp_threshold'], isNotNull, reason: '${e['id']}: 임계 없음');
      expect(e['phase2_pattern'], isNotNull, reason: '${e['id']}: 2페이즈 패턴 없음');
      expect((e['phase2_pattern'] as List).isNotEmpty, isTrue);
      if (e['id'] == kUnassignedBoss) {
        expect(e['phase2_hp_threshold'], 44); // 지역 미배정 — 현행값 유지
        continue;
      }
      expect(e['phase2_hp_threshold'], (e['hp'] as int) ~/ 2,
          reason: '${e['id']}: 임계가 HP 50%가 아니다');
    }
  });

  test('8. 보스 이름에 직함(감독관·문지기·수호상)이 없다', () {
    for (final e in bosses) {
      for (final banned in kBannedTitles) {
        expect((e['name'] as String).contains(banned), isFalse,
            reason: '${e['id']}: 이름에 "$banned"');
      }
    }
  });
  test('9. 2페이즈 값 = 1페이즈 값 ×1.2, 같은 종류가 둘 이상이면 둘째부터 −1', () {
    for (var region = 1; region <= 12; region++) {
      final id = kBossByRegion[region]!;
      final e = enemies.firstWhere((x) => x['id'] == id);
      final want = kBossStats[id]!;
      final seen = <String, int>{};
      for (final a in (e['phase2_pattern'] as List).cast<Map<String, dynamic>>()) {
        final action = a['action'] as String;
        final base = switch (action) {
          'attack' || 'heal' => want[1],
          'charge' => want[2],
          'defend' => want[3],
          _ => -1,
        };
        // ×1.2 반올림 후, 같은 종류가 앞에 나온 횟수만큼 1씩 낮춘다
        final expected = (base * 1.2).round() - (seen[action] ?? 0);
        seen[action] = (seen[action] ?? 0) + 1;
        expect(a['value'], expected,
            reason: '$id 2페이즈 $action "${a['label']}"');
      }
    }
  });

  test('10. 후반 보스 3종의 HP가 내려갔고 임계가 hp ~/ 2 다 (후반 곡선 정렬)', () {
    kLateBossHp.forEach((id, want) {
      final e = enemies.firstWhere((x) => x['id'] == id);
      expect(e['hp'], want[0], reason: '$id HP');
      expect(e['phase2_hp_threshold'], want[1], reason: '$id 2페이즈 임계');
      expect(e['phase2_hp_threshold'], (e['hp'] as int) ~/ 2,
          reason: '$id 임계 = hp ~/ 2');
    });
  });

  test('11. 1~9지역 보스 HP는 한 값도 바뀌지 않았다', () {
    for (var region = 1; region <= 9; region++) {
      final e = enemies.firstWhere((x) => x['id'] == kBossByRegion[region]);
      expect(e['hp'], kEarlyBossHp[region - 1],
          reason: '지역 $region 보스: 후반 하향이 앞까지 건드렸다');
    }
  });
}
