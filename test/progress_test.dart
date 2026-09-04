/// 진행 잠금 규칙 검산 (WORK_ORDER_SCREENS 1-B · 작업 4 검사 1~6).
///
/// 규칙은 기획 창이 정했다. **이 표가 규칙의 사본**이므로, 코드가 바뀌어도
/// 여기가 함께 바뀌지 않는 한 통과하지 못한다.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/core/progress.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/meta_state.dart';

String readData(String name) => File('assets/data/$name').readAsStringSync();

void main() {
  final data = GameDataParser.parseAll(readData);

  /// 1지역의 마지막(보스) 스테이지 순번 — 데이터에서 읽는다
  final bossOf1 = data.region(1).stageCount;

  Progress fresh() => Progress(data, MetaState.initial());

  Progress after(List<(int, int, Difficulty)> clears) {
    final meta = MetaState.initial();
    for (final c in clears) {
      meta.markCleared(c.$1, c.$2, c.$3);
    }
    return Progress(data, meta);
  }

  group('검사 1 — 처음 시작하면 1지역 Ⅰ 보통만 열려 있다', () {
    final p = fresh();

    test('1지역 Ⅰ 보통은 열려 있다', () {
      expect(p.isRegionUnlocked(1), isTrue);
      expect(p.isStageUnlocked(1, 1), isTrue);
      expect(p.isDifficultyUnlocked(1, 1, Difficulty.normal), isTrue);
    });

    test('Ⅱ 스테이지는 잠겨 있다', () {
      expect(p.isStageUnlocked(1, 2), isFalse);
      expect(p.stageLockReason(1, 2), isNotNull);
    });

    test('1지역 Ⅰ 의 하드·데스는 잠겨 있다', () {
      expect(p.isDifficultyUnlocked(1, 1, Difficulty.hard), isFalse);
      expect(p.isDifficultyUnlocked(1, 1, Difficulty.death), isFalse);
    });

    test('2지역부터 12지역까지 전부 잠겨 있다', () {
      for (var r = 2; r <= data.regions.length; r++) {
        expect(p.isRegionUnlocked(r), isFalse, reason: '$r지역');
        expect(p.regionLockReason(r), isNotNull, reason: '$r지역');
      }
    });

    test('★ 3개가 전부 비어 있다', () {
      expect(p.regionStars(1), [false, false, false]);
    });
  });

  group('검사 2 — Ⅰ 보통 클리어: Ⅱ 와 「Ⅰ 하드」가 열리고 2지역은 안 열린다', () {
    final p = after([(1, 1, Difficulty.normal)]);

    test('Ⅱ 스테이지가 열린다', () {
      expect(p.isStageUnlocked(1, 2), isTrue);
      expect(p.stageLockReason(1, 2), isNull);
    });

    test('같은 스테이지의 하드가 열린다', () {
      expect(p.isDifficultyUnlocked(1, 1, Difficulty.hard), isTrue);
    });

    test('**다음 스테이지의 하드는 열리지 않는다** (난이도는 스테이지 단위다)', () {
      expect(p.isDifficultyUnlocked(1, 2, Difficulty.hard), isFalse);
    });

    test('2지역은 아직 잠겨 있다 — 보스를 깨야 열린다', () {
      expect(p.isRegionUnlocked(2), isFalse);
    });

    test('Ⅲ 스테이지는 아직 잠겨 있다 (한 칸씩만 열린다)', () {
      expect(p.isStageUnlocked(1, 3), isFalse);
    });
  });

  group('검사 3 — 1지역 보스를 보통으로 클리어하면 2지역이 열린다', () {
    final p = after([(1, bossOf1, Difficulty.normal)]);

    test('2지역과 그 첫 스테이지가 열린다', () {
      expect(p.isRegionUnlocked(2), isTrue);
      expect(p.isStageUnlocked(2, 1), isTrue);
      expect(p.isDifficultyUnlocked(2, 1, Difficulty.normal), isTrue);
    });

    test('3지역은 여전히 잠겨 있다', () {
      expect(p.isRegionUnlocked(3), isFalse);
    });

    test('★ 은 보통 한 칸만 차오른다', () {
      expect(p.regionStars(1), [true, false, false]);
    });
  });

  group('검사 4 — 하드 클리어 없이 데스는 안 열린다', () {
    test('보통만 깬 상태: 데스는 잠김', () {
      final p = after([(1, 1, Difficulty.normal)]);
      expect(p.isDifficultyUnlocked(1, 1, Difficulty.hard), isTrue);
      expect(p.isDifficultyUnlocked(1, 1, Difficulty.death), isFalse);
      expect(p.difficultyLockReason(1, 1, Difficulty.death), isNotNull);
    });

    test('하드까지 깨면 데스가 열린다', () {
      final p = after([
        (1, 1, Difficulty.normal),
        (1, 1, Difficulty.hard),
      ]);
      expect(p.isDifficultyUnlocked(1, 1, Difficulty.death), isTrue);
    });

    test('하드만 기록돼 있어도(비정상 저장) 데스는 열리되 보통은 늘 열린다', () {
      final p = after([(1, 1, Difficulty.hard)]);
      expect(p.isDifficultyUnlocked(1, 1, Difficulty.normal), isTrue);
      expect(p.isDifficultyUnlocked(1, 1, Difficulty.death), isTrue);
    });
  });

  group('검사 5 — 클리어 기록이 저장·복원된다', () {
    test('toJson → fromJson 왕복이 기록을 보존한다', () {
      final meta = MetaState.initial()..crystals = 5;
      meta.markCleared(1, 1, Difficulty.normal);
      meta.markCleared(1, bossOf1, Difficulty.hard);
      // 실제 저장 경로와 같게 JSON 문자열을 거쳐서 확인한다
      final restored = MetaState.fromJson(
          jsonDecode(jsonEncode(meta.toJson())) as Map<String, dynamic>);
      expect(restored.clearedStageKeys, meta.clearedStageKeys);
      expect(restored.hasCleared(1, 1, Difficulty.normal), isTrue);
      expect(restored.hasCleared(1, bossOf1, Difficulty.hard), isTrue);
      expect(restored.hasCleared(1, bossOf1, Difficulty.death), isFalse);
      expect(restored.crystals, 5);
    });

    test('같은 클리어를 두 번 기록해도 한 줄만 남는다', () {
      final meta = MetaState.initial();
      expect(meta.markCleared(1, 1, Difficulty.normal), isTrue);
      expect(meta.markCleared(1, 1, Difficulty.normal), isFalse);
      expect(meta.clearedStageKeys.length, 1);
    });
  });

  group('검사 6 — 클리어 기록 칸이 없는 옛 저장 JSON도 읽힌다', () {
    test('옛 형식(칸 자체가 없음)을 읽어도 죽지 않는다', () {
      const old = '{"crystals":300,"hp_level":2,"mana_level":1,'
          '"reroll_level":0,"start_relic_level":0,'
          '"unlocked_spells":["meteor_call"]}';
      final restored =
          MetaState.fromJson(jsonDecode(old) as Map<String, dynamic>);
      expect(restored.crystals, 300);
      expect(restored.hpLevel, 2);
      expect(restored.unlockedSpellIds, {'meteor_call'});
      expect(restored.clearedStageKeys, isEmpty);
      // 그 저장본으로도 잠금 판정이 정상 동작한다
      final p = Progress(data, restored);
      expect(p.isStageUnlocked(1, 1), isTrue);
      expect(p.isStageUnlocked(1, 2), isFalse);
      expect(p.isRegionUnlocked(2), isFalse);
    });

    test('완전히 빈 JSON 도 읽힌다', () {
      final restored = MetaState.fromJson({});
      expect(restored.clearedStageKeys, isEmpty);
      expect(Progress(data, restored).isStageUnlocked(1, 1), isTrue);
    });
  });

  group('보스 스테이지 순번은 데이터의 stage_count 와 같다', () {
    test('12지역 전부', () {
      final p = fresh();
      for (final r in data.regions) {
        expect(p.bossStageIndexOf(r.id), r.stageCount, reason: '${r.id}지역');
        // 그 순번의 스테이지가 실제로 보스 스테이지여야 한다
        expect(data.stage(r.id, r.stageCount).isBossStage, isTrue,
            reason: '${r.id}지역');
      }
    });
  });
}
