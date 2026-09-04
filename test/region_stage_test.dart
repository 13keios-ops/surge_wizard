/// variants.json / regions.json / stages.json 검산.
/// 아직 모델·로더가 없는 신규 파일이므로 JSON을 직접 읽는다
/// (ENEMIES.md 5·6절 · STAGES.md 2~5절).
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 지역별 스테이지 수 (STAGES.md 5절)
const kStageCounts = <int>[8, 8, 8, 10, 10, 10, 10, 8, 8, 8, 6, 6];

/// 지역별 배경 테마 (STAGES.md 2절 + GAME_DESIGN.md 6.1절)
/// 「늪지는 숲의 녹색조, 설원·신전은 사막의 변형, 심연은 탑의 어두운 변형」
const kThemes = <String>[
  'forest', 'dungeon', 'forest', 'forest', 'dungeon', 'desert',
  'desert', 'desert', 'tower', 'tower', 'tower', 'dungeon',
];

/// 지역 체력 배율 (ENEMIES.md 6절, 2026-09-04 12지역 배율 하향) — hp·defend·heal에 곱한다.
/// 12지역만 3.50 → 3.35로 내렸다. 11지역이 이미 3.20이라 그 아래로는 못 내린다
/// (내리면 최종 지역 일반 적이 앞 지역보다 약해져 단조 증가가 깨진다).
/// **바뀐 것은 12지역 한 값뿐이고 1~11지역과 atk_scale 은 손대지 않았다.**
const kHpScales = <double>[
  1.00, 1.13, 1.30, 1.50, 1.72, 1.95, 2.18, 2.45, 2.70, 2.95, 3.20, 3.35,
];

/// 이번(2026-09-04 12지역 배율 하향)에 **손대지 않기로 한** 1~11지역 체력 배율.
/// 위 표에서 잘라 쓰지 않고 따로 적는다 — 위 표가 잘못 바뀌면 함께 틀리기 때문이다.
const kHpScalesRegion1to11 = <double>[
  1.00, 1.13, 1.30, 1.50, 1.72, 1.95, 2.18, 2.45, 2.70, 2.95, 3.20,
];

/// 이번에 **손대지 않기로 한** 공격 배율 12칸 (kAtkScales와 따로 적는다 — 위와 같은 이유).
const kAtkScalesFixed = <double>[
  1.00, 1.00, 1.05, 1.05, 1.10, 1.15, 1.15, 1.20, 1.25, 1.30, 1.40, 1.45,
];

/// 12지역 보스(고룡)의 HP — 배율을 내려도 보스는 불변이다 (ENEMIES.md 3절)
const kRegion12BossHp = 405;

/// 모든 스테이지의 층수 총합 (STAGES.md 4절, 2026-09-03 확정)
const kTotalFloors = 728;

/// 이번(2026-09-03 후반 곡선 정렬)에 **손대지 않기로 한** 1~8지역 값.
/// 위 표에서 잘라 쓰지 않고 따로 적는다 — 위 표가 잘못 바뀌면 함께 틀리기 때문이다.
const kHpScalesEarlyFixed = <double>[
  1.00, 1.13, 1.30, 1.50, 1.72, 1.95, 2.18, 2.45,
];

/// 이번(2026-09-03 12지역 층수 하향)에 **손대지 않기로 한** 1~11지역 층수
/// (STAGES.md 4절). 12지역 표에서 잘라 쓰지 않고 따로 적는다 —
/// 한쪽이 잘못 바뀌면 함께 틀려 검사가 아무것도 못 잡기 때문이다.
const kFloorsRegion1to11 = <List<int>>[
  [3, 3, 3, 4, 4, 4, 5, 5],
  [4, 4, 4, 5, 5, 5, 6, 6],
  [5, 5, 5, 6, 6, 6, 7, 7],
  [5, 5, 6, 6, 6, 7, 7, 7, 8, 8],
  [6, 6, 6, 7, 7, 7, 8, 8, 8, 9],
  [6, 6, 7, 7, 7, 8, 8, 8, 9, 9],
  [7, 7, 7, 8, 8, 8, 9, 9, 9, 10],
  [7, 8, 8, 8, 9, 9, 9, 10],
  [8, 8, 8, 9, 9, 9, 10, 10],
  [8, 8, 9, 9, 9, 10, 10, 10],
  [9, 9, 10, 10, 10, 10],
];

/// 12지역 층수 (STAGES.md 4절, 2026-09-03 하향 — 9·10·10·10·10·10 에서 내렸다).
/// 최종 지역 완주율이 곱해지는 관문의 수에 눌려 있었다 (측정 21 · 검토 21).
const kFloorsRegion12 = <int>[7, 8, 8, 8, 8, 8];

/// 지역 공격 배율 (ENEMIES.md 6절, 2026-09-02 개정) — attack·charge에 곱한다.
/// tier가 이미 공격을 올리므로 훨씬 완만하고, **같은 값이 이어진다**(단조 비감소)
const kAtkScales = <double>[
  1.00, 1.00, 1.05, 1.05, 1.10, 1.15, 1.15, 1.20, 1.25, 1.30, 1.40, 1.45,
];

List<Map<String, dynamic>> readJson(String name) =>
    (jsonDecode(File('assets/data/$name').readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();

int sumOf(Map<String, dynamic> m) =>
    m.values.fold(0, (a, b) => a + (b as num).toInt());

void main() {
  final variants = readJson('variants.json');
  final regions = readJson('regions.json');
  final stages = readJson('stages.json');
  final enemies = readJson('enemies.json');

  final variantIds = variants.map((v) => v['id'] as String).toSet();

  group('variants.json', () {
    test('1. 6종, id 중복 없음, normal의 배율이 1.0', () {
      expect(variants.length, 6);
      expect(variantIds.length, 6);
      final normal = variants.firstWhere((v) => v['id'] == 'normal');
      expect(normal['hp_mul'], 1.0);
      expect(normal['atk_mul'], 1.0);
      expect(normal['name_prefix'], '');
      expect(normal['tint'], isNull);
      // 나머지 5종은 접두어와 색조를 갖는다
      for (final v in variants.where((v) => v['id'] != 'normal')) {
        expect((v['name_prefix'] as String).isNotEmpty, isTrue);
        expect(v['tint'], isNotNull);
      }
    });
  });

  group('regions.json', () {
    test('2. 12개, id 1~12 각각 하나씩', () {
      expect(regions.length, 12);
      final ids = regions.map((r) => r['id'] as int).toList()..sort();
      expect(ids, List<int>.generate(12, (i) => i + 1));
    });

    test('3. tier_pool 12행이 각각 합 100이고 tier가 1~5다', () {
      for (final r in regions) {
        final pool = (r['tier_pool'] as Map).cast<String, dynamic>();
        expect(sumOf(pool), 100, reason: '지역 ${r['id']} tier 풀 합');
        for (final k in pool.keys) {
          final t = int.parse(k);
          expect(t >= 1 && t <= 5, isTrue, reason: '지역 ${r['id']} tier $k');
          expect((pool[k] as num) > 0, isTrue, reason: '0인 항목을 넣지 않는다');
        }
      }
    });

    test('4. variant_weights 12행이 각각 합 100이고 키가 variants.json 안에 있다', () {
      for (final r in regions) {
        final w = (r['variant_weights'] as Map).cast<String, dynamic>();
        expect(sumOf(w), 100, reason: '지역 ${r['id']} 변종 가중치 합');
        for (final k in w.keys) {
          expect(variantIds.contains(k), isTrue,
              reason: '지역 ${r['id']}: 없는 변종 $k');
          expect((w[k] as num) > 0, isTrue, reason: '0인 항목을 넣지 않는다');
        }
      }
    });

    test('5. boss_id가 enemies.json에 실제로 있고 is_boss가 참이다', () {
      for (final r in regions) {
        final boss = enemies.firstWhere((e) => e['id'] == r['boss_id'],
            orElse: () => <String, dynamic>{});
        expect(boss.isNotEmpty, isTrue, reason: '없는 보스 ${r['boss_id']}');
        expect(boss['is_boss'], isTrue);
        expect(boss['region'], r['id'], reason: '${r['boss_id']} 지역 불일치');
      }
    });

    test('6-1. hp_scale이 표와 같고 1.00 → 3.35로 단조 증가한다', () {
      for (var i = 0; i < 12; i++) {
        expect(regions[i]['hp_scale'], kHpScales[i],
            reason: '지역 ${i + 1} 체력 배율');
        if (i > 0) {
          expect(
              (regions[i]['hp_scale'] as num) >
                  (regions[i - 1]['hp_scale'] as num),
              isTrue,
              reason: '지역 ${i + 1}에서 체력 배율이 늘지 않았다');
        }
      }
      expect(regions.first['hp_scale'], 1.00);
      expect(regions.last['hp_scale'], 3.35);
    });

    test('6-1b. 1~8지역 hp_scale은 이번에 한 칸도 바뀌지 않았다', () {
      for (var i = 0; i < kHpScalesEarlyFixed.length; i++) {
        expect(regions[i]['hp_scale'], kHpScalesEarlyFixed[i],
            reason: '지역 ${i + 1}: 후반 정렬이 초반까지 건드렸다');
      }
    });

    test('6-1c. 9~12지역 hp_scale이 새 값 네 개다 (12지역 배율 하향)', () {
      const lateScales = <int, double>{9: 2.70, 10: 2.95, 11: 3.20, 12: 3.35};
      lateScales.forEach((id, want) {
        expect(regions[id - 1]['hp_scale'], want, reason: '지역 $id 체력 배율');
      });
    });

    test('6-1d. 12지역 hp_scale이 3.35이고 1~11지역은 한 칸도 안 바뀌었다', () {
      expect(regions[11]['hp_scale'], 3.35, reason: '12지역 체력 배율');
      for (var i = 0; i < kHpScalesRegion1to11.length; i++) {
        expect(regions[i]['hp_scale'], kHpScalesRegion1to11[i],
            reason: '지역 ${i + 1}: 12지역 하향이 앞 지역까지 건드렸다');
      }
      // 11지역(3.20)보다 위여야 한다 — 아래로 내리면 단조 증가가 깨진다
      expect((regions[11]['hp_scale'] as num) > (regions[10]['hp_scale'] as num),
          isTrue);
    });

    test('6-2. atk_scale이 표와 같고 1.00 → 1.45로 단조 비감소한다', () {
      for (var i = 0; i < 12; i++) {
        expect(regions[i]['atk_scale'], kAtkScales[i],
            reason: '지역 ${i + 1} 공격 배율');
        if (i > 0) {
          expect(
              (regions[i]['atk_scale'] as num) >=
                  (regions[i - 1]['atk_scale'] as num),
              isTrue,
              reason: '지역 ${i + 1}에서 공격 배율이 줄었다');
        }
      }
      expect(regions.first['atk_scale'], 1.00);
      expect(regions.last['atk_scale'], 1.45);
    });

    test('6-2b. atk_scale 12칸은 이번에 한 값도 바뀌지 않았다', () {
      for (var i = 0; i < kAtkScalesFixed.length; i++) {
        expect(regions[i]['atk_scale'], kAtkScalesFixed[i],
            reason: '지역 ${i + 1}: 체력 배율 하향이 공격 배율까지 건드렸다');
      }
    });

    test('6-2c. 12지역 보스 HP가 405 그대로다 (배율은 보스에 안 붙는다)', () {
      final boss = enemies.firstWhere((e) => e['id'] == 'boss_inferno_dragon');
      expect(boss['hp'], kRegion12BossHp);
      expect(boss['region'], 12);
    });

    test('6-3. 옛 단일 scale 필드는 남아 있지 않다', () {
      for (final r in regions) {
        expect(r.containsKey('scale'), isFalse, reason: '지역 ${r['id']}');
      }
    });

    test('7. 12지역 이름이 「고룡의 둥지」다', () {
      expect(regions[11]['name'], '고룡의 둥지');
      for (final r in regions) {
        expect(r['name'], isNot('미지의 던전'));
        expect(r['theme'], kThemes[(r['id'] as int) - 1],
            reason: '지역 ${r['id']} 테마');
      }
    });
  });

  group('stages.json', () {
    test('8. 정확히 100개, id 중복 없음', () {
      expect(stages.length, 100);
      expect(stages.map((s) => s['id']).toSet().length, 100);
    });

    test('9. 지역별 스테이지 수가 8·8·8·10·10·10·10·8·8·8·6·6 이고 '
        'stage_count와 일치한다', () {
      for (var region = 1; region <= 12; region++) {
        final list = stages.where((s) => s['region_id'] == region).toList();
        expect(list.length, kStageCounts[region - 1], reason: '지역 $region');
        expect(regions[region - 1]['stage_count'], list.length);
        // index 는 1..n 이 하나씩, id 는 r{지역}_s{순번}
        for (var i = 0; i < list.length; i++) {
          expect(list[i]['index'], i + 1);
          expect(list[i]['id'], 'r${region}_s${i + 1}');
        }
      }
    });

    test('10. 각 지역의 마지막 스테이지만 is_boss_stage 다 (총 12개)', () {
      final bossStages = stages.where((s) => s['is_boss_stage'] == true);
      expect(bossStages.length, 12);
      for (final s in stages) {
        final last = s['index'] == kStageCounts[(s['region_id'] as int) - 1];
        expect(s['is_boss_stage'], last, reason: '${s['id']}');
      }
    });

    test('11. subtitle을 가진 스테이지가 정확히 그 12개다', () {
      final titled = stages.where((s) => s['subtitle'] != null).toList();
      expect(titled.length, 12);
      for (final s in titled) {
        expect(s['is_boss_stage'], isTrue);
        expect((s['subtitle'] as String).isNotEmpty, isTrue);
      }
      expect(titled.map((s) => s['subtitle']).toSet().length, 12);
    });

    test('12. 모든 스테이지가 10층 이하이고 총합이 728이다', () {
      var total = 0;
      for (final s in stages) {
        final f = s['floors'] as int;
        expect(f >= 1 && f <= 10, isTrue, reason: '${s['id']}: $f층');
        total += f;
      }
      expect(total, kTotalFloors);
    });

    test('13. floors가 지역 안에서 감소하지 않는다', () {
      for (var region = 1; region <= 12; region++) {
        final list = stages.where((s) => s['region_id'] == region).toList();
        for (var i = 1; i < list.length; i++) {
          expect((list[i]['floors'] as int) >= (list[i - 1]['floors'] as int),
              isTrue, reason: '${list[i]['id']}에서 층수가 줄었다');
        }
      }
    });

    test('14. recommended_level이 지역 안에서 증가하고 지역 경계에서 이어진다 (1→99)',
        () {
      int? prevRegionLast;
      for (var region = 1; region <= 12; region++) {
        final list = stages.where((s) => s['region_id'] == region).toList();
        final levels = list.map((s) => s['recommended_level'] as int).toList();
        for (var i = 1; i < levels.length; i++) {
          expect(levels[i] > levels[i - 1], isTrue,
              reason: '지역 $region: ${list[i]['id']} 권장 레벨이 증가하지 않음');
        }
        if (prevRegionLast != null) {
          expect(levels.first, prevRegionLast,
              reason: '지역 $region 첫 스테이지가 앞 지역 마지막과 끊긴다');
        }
        prevRegionLast = levels.last;
      }
      expect(stages.first['recommended_level'], 1);
      expect(prevRegionLast, 99);
    });

    test('15. 12지역 여섯 스테이지의 층수가 7·8·8·8·8·8 이다 (2026-09-03 하향)',
        () {
      final list = stages.where((s) => s['region_id'] == 12).toList();
      expect(list.map((s) => s['floors']).toList(), kFloorsRegion12);
      expect(list.fold(0, (a, s) => a + (s['floors'] as int)), 47);
    });

    test('16. 1~11지역 층수는 이번에 한 칸도 바뀌지 않았다', () {
      for (var region = 1; region <= 11; region++) {
        final list = stages.where((s) => s['region_id'] == region).toList();
        expect(list.map((s) => s['floors']).toList(),
            kFloorsRegion1to11[region - 1],
            reason: '지역 $region 층수가 바뀌었다');
      }
    });

    test('17. 12지역만 바꿔도 권장 레벨·부제·보스 표시는 그대로다', () {
      final list = stages.where((s) => s['region_id'] == 12).toList();
      expect(list.map((s) => s['recommended_level']).toList(),
          [94, 95, 96, 97, 98, 99]);
      expect(list.map((s) => s['is_boss_stage']).toList(),
          [false, false, false, false, false, true]);
      expect(list.last['subtitle'], '잿더미 왕좌');
    });
  });
}
