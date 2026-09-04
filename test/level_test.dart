/// 레벨 · 경험치 · 서클 슬롯표 검증 (WORK_ORDER_LEVEL 작업 4).
/// 기준 문서는 GROWTH.md 1·2·3절이다 — **여기서 수치를 임의로 바꾸지 말 것.**
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/data/loader.dart';
import 'package:surge_wizard/models/meta_state.dart';
import 'package:surge_wizard/screens/meta_controller.dart';
import 'package:surge_wizard/screens/run_controller.dart';
import 'package:surge_wizard/services/save_service.dart';

String readData(String name) => File('assets/data/$name').readAsStringSync();

/// GROWTH.md 1.4절 「도달」 열 — 지역을 한 바퀴씩만 돌았을 때의 레벨
const List<int> kGrowthReachedLevels = [
  7, 16, 24, 35, 44, 55, 65, 72, 80, 88, 95, 99,
];

/// GROWTH.md 1.3절 지역별 일반 적 경험치
const List<int> kGrowthRegionExp = [
  25, 80, 135, 170, 210, 260, 295, 320, 355, 385, 420, 455,
];

void main() {
  final data = GameDataParser.parseAll(readData);

  group('경험치 곡선 (GROWTH 1.2)', () {
    test('1. 레벨 1→2가 60, 98→99가 5,880, 1→99 누적이 291,060', () {
      expect(expToNextLevel(1), 60);
      expect(expToNextLevel(98), 5880);
      expect(expToNextLevel(kMaxLevel), isNull); // 만렙은 다음이 없다
      var total = 0;
      for (var l = 1; l < kMaxLevel; l++) {
        total += expToNextLevel(l)!;
      }
      expect(total, 291060);
    });

    test('2. 레벨이 99를 넘지 않는다 — 만렙에서 더 받아도 안전하다', () {
      final meta = MetaState.initial();
      expect(meta.gainExp(291060), kMaxLevel - 1);
      expect(meta.level, kMaxLevel);
      expect(meta.passivePoints, kMaxLevel - 1);
      // 만렙 뒤에 더 부어도 레벨·포인트가 안 움직인다
      expect(meta.gainExp(999999), 0);
      expect(meta.level, kMaxLevel);
      expect(meta.passivePoints, kMaxLevel - 1);
      expect(meta.exp, 0);
    });

    test('3. 한 전투로 여러 레벨이 올라도 포인트가 그만큼 쌓인다', () {
      final meta = MetaState.initial();
      // 60 + 120 + 180 = 360 → 레벨 4, 남는 경험치 0
      expect(meta.gainExp(360), 3);
      expect(meta.level, 4);
      expect(meta.passivePoints, 3);
      expect(meta.exp, 0);
      // 레벨 4→5 는 240 — 100만 주면 레벨은 그대로고 경험치만 쌓인다
      expect(meta.gainExp(100), 0);
      expect(meta.level, 4);
      expect(meta.exp, 100);
    });

    test('4. 보스 ×5 · 변종 ×1.5 · 하드 ×1.5 · 데스 ×2.0 이 곱해진다', () {
      int e(
              {bool boss = false,
              bool variant = false,
              Difficulty d = Difficulty.normal}) =>
          battleExp(
              regionExp: 100, isBoss: boss, isVariant: variant, difficulty: d);
      expect(e(), 100);
      expect(e(boss: true), 500);
      expect(e(variant: true), 150);
      expect(e(d: Difficulty.hard), 150);
      expect(e(d: Difficulty.death), 200);
      // 곱해진다 — 100 × 5 × 1.5 × 2.0
      expect(e(boss: true, variant: true, d: Difficulty.death), 1500);
    });
  });

  group('regions.json', () {
    test('12지역 exp 값이 GROWTH 1.3절 표와 같다', () {
      for (var i = 0; i < 12; i++) {
        expect(data.region(i + 1).exp, kGrowthRegionExp[i],
            reason: '${i + 1}지역');
      }
    });

    test('10. exp 외의 칸은 한 값도 안 바뀌었다 (12지역 전수 대조)', () {
      // toJson 에서 exp 만 빼면 이번 작업 이전의 파일 내용과 정확히 같아야 한다
      final raw = (jsonDecode(readData('regions.json')) as List)
          .cast<Map<String, dynamic>>();
      expect(raw.length, 12);
      for (final r in raw) {
        final region = data.region((r['id'] as num).toInt());
        final round = Map<String, dynamic>.of(region.toJson())..remove('exp');
        expect(round, Map<String, dynamic>.of(r)..remove('exp'));
      }
    });
  });

  group('★ 4-A. GROWTH 1.4절 검산 — 한 바퀴 돌면 어디까지 오르나', () {
    test('지역 12개의 도달 레벨이 문서 표와 ±0으로 같다', () {
      final meta = MetaState.initial();
      final reached = <int>[];
      for (var regionId = 1; regionId <= 12; regionId++) {
        final region = data.region(regionId);
        final stages =
            data.stages.where((s) => s.regionId == regionId).toList();
        for (final stage in stages) {
          for (var floor = 1; floor <= stage.floors; floor++) {
            // 층 = 전투 1회. **각 스테이지의 마지막 층은 지역 보스**다
            // (stage_runner.pickEnemy 와 같은 규칙). 변종·난이도 배수는 없다.
            meta.gainExp(battleExp(
              regionExp: region.exp,
              isBoss: floor == stage.floors,
              isVariant: false,
              difficulty: Difficulty.normal,
            ));
          }
        }
        reached.add(meta.level);
      }
      expect(reached, kGrowthReachedLevels);
    });
  });

  group('서클 슬롯표 (GROWTH 3절)', () {
    test('5. 레벨 1·9·10·44·45·99 조회가 문서 표와 같다', () {
      // 표에 없는 레벨은 **바로 위 칸**을 쓴다 — 9는 1행, 44는 30행이다
      expect(data.circleSlotsAt(1), [3, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(data.circleSlotsAt(9), [3, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(data.circleSlotsAt(10), [3, 1, 0, 0, 0, 0, 0, 0, 0]);
      expect(data.circleSlotsAt(44), [4, 2, 1, 1, 0, 0, 0, 0, 0]);
      expect(data.circleSlotsAt(45), [4, 3, 2, 1, 1, 0, 0, 0, 0]);
      expect(data.circleSlotsAt(99), [5, 4, 3, 3, 2, 1, 1, 1, 1]);
    });

    test('6. 어느 레벨에서도 슬롯 총량이 3 이상이다 (손패 3장)', () {
      for (var level = 1; level <= kMaxLevel; level++) {
        final total = data.circleSlotsAt(level).fold(0, (a, b) => a + b);
        expect(total, greaterThanOrEqualTo(kHandSize), reason: '레벨 $level');
      }
    });

    test('7. 레벨 99에서 덱 총량이 21이다', () {
      expect(data.circleSlotsAt(kMaxLevel).fold(0, (a, b) => a + b), 21);
    });

    test('덱 총량이 레벨을 따라 단조 증가하고, 9칸씩이다', () {
      var previous = 0;
      for (final row in data.circleSlots) {
        expect(row.slots.length, 9, reason: '레벨 ${row.level} 행');
        expect(row.total, greaterThan(previous), reason: '레벨 ${row.level} 행');
        previous = row.total;
      }
      // 밸런스 곡선을 잰 덱이 레벨 90 행이다 (GROWTH 3.1) — 19장·8서클 1장
      expect(data.circleSlotsAt(90).fold(0, (a, b) => a + b), 19);
      expect(data.circleSlotsAt(90)[7], 1);
    });
  });

  group('전투 승리로 실제 경험치가 오른다 (RunController → MetaController)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('1지역 Ⅰ 3층을 한 층씩 이기면 레벨이 오르고, 판이 끝나기 전에 저장된다', () {
      final meta = MetaController(MetaState.initial(), save: SaveService());
      final run = RunController(
          data: data,
          meta: meta.state,
          random: Random(1),
          regionId: 1,
          stageIndex: 1,
          difficulty: Difficulty.normal)
        ..startRun();
      expect(run.floors, 3);

      for (var floor = 1; floor <= run.floors; floor++) {
        final before = run.expEarned;
        run.grantExp(meta); // MapScreen 이 전투를 이긴 직후에 부르는 바로 그 길
        expect(run.expEarned, greaterThan(before), reason: '$floor층');
        if (floor < run.floors) run.advanceFloor();
      }

      // 1지역 일반 25 × 2층 + 보스 25×5 = 175 → 레벨 3 (60+120=180 미만)
      // 변종이 섞이면 더 받으므로 하한으로만 확인한다
      expect(run.expEarned, greaterThanOrEqualTo(175));
      expect(meta.state.level, greaterThanOrEqualTo(2));
      expect(run.levelsGained, meta.state.level - kStartLevel);
      expect(meta.state.passivePoints, run.levelsGained);
    });

    test('보스 층이 일반 층보다 5배를 준다 (변종 없는 값끼리)', () {
      final run = RunController(
          data: data, random: Random(3), regionId: 1, stageIndex: 1)
        ..startRun();
      final normalFloor = run.battleExpReward;
      run
        ..advanceFloor()
        ..advanceFloor();
      expect(run.isBossFloor, isTrue);
      // 변종 배수가 섞일 수 있어 「최소 3배」로 본다 (1.5배 변종이 붙어도 성립)
      expect(run.battleExpReward, greaterThan(normalFloor * 3));
    });
  });

  group('저장 (MetaState)', () {
    test('8. level·exp·passive_points 칸이 없는 옛 저장본도 읽힌다', () {
      final old = MetaState.fromJson({
        'crystals': 40,
        'hp_level': 2,
        'unlocked_spells': <String>['spell_x'],
      });
      expect(old.level, kStartLevel);
      expect(old.exp, 0);
      expect(old.passivePoints, 0);
      expect(old.crystals, 40); // 옛 값은 그대로 살아 있다
    });

    test('9. 저장·복원 왕복', () {
      final meta = MetaState.initial()
        ..crystals = 7
        ..gainExp(200);
      meta.markCleared(1, 1, Difficulty.normal);
      final back = MetaState.fromJson(
          jsonDecode(jsonEncode(meta.toJson())) as Map<String, dynamic>);
      expect(back.level, meta.level);
      expect(back.exp, meta.exp);
      expect(back.passivePoints, meta.passivePoints);
      expect(back.crystals, 7);
      expect(back.hasCleared(1, 1, Difficulty.normal), isTrue);
    });
  });
}
