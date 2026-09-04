/// 진행 구조(지역·스테이지·변종·난이도) 단위 테스트.
/// 근거: ENEMIES.md 3~6절 · STAGES.md 2·5절 · WORK_ORDER_PROGRESSION 5-A.
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/core/enemy_builder.dart';
import 'package:surge_wizard/core/stage_runner.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/enemy.dart';
import 'package:surge_wizard/models/run_state.dart';
import 'package:surge_wizard/screens/run_controller.dart';

String readData(String name) => File('assets/data/$name').readAsStringSync();

void main() {
  final data = GameDataParser.parseAll(readData);
  final normal = data.variant('normal');
  final hungry = data.variant('hungry');

  /// 행동 종류별 값을 뽑아 비교하기 쉽게 한다
  List<int> valuesOf(Enemy e, String action) =>
      e.pattern.where((a) => a.action == action).map((a) => a.value).toList();

  group('1. 모델·데이터', () {
    test('지역 12 · 스테이지 100 · 변종 6이 전부 파싱된다', () {
      expect(data.regions.length, 12);
      expect(data.stages.length, 100);
      expect(data.variants.length, 6);
    });

    test('지역별 스테이지 수가 regions.json의 stage_count와 맞는다', () {
      for (final r in data.regions) {
        final count = data.stages.where((s) => s.regionId == r.id).length;
        expect(count, r.stageCount, reason: '지역 ${r.id}');
      }
    });

    test('2. Enemy.region은 지역 보스 12종에만 있다', () {
      final withRegion = data.enemies.where((e) => e.region != null).toList();
      expect(withRegion.length, 12);
      expect(withRegion.every((e) => e.isBoss), isTrue);
      expect(withRegion.map((e) => e.region).toSet(),
          {for (var i = 1; i <= 12; i++) i});
      // 일반 적과 미배정 보스(주사위 포식자)는 값이 없다
      expect(data.enemies.where((e) => !e.isBoss && e.region != null), isEmpty);
      expect(
          data.enemies.firstWhere((e) => e.id == 'boss_dice_devourer').region,
          isNull);
    });
  });

  group('배율', () {
    test('3. 변종 hungry: HP ×0.8 · 공격 ×1.3', () {
      final base = data.enemies.firstWhere((e) => e.id == 'orc_warrior');
      final built = buildEnemy(base, hungry, 1.0, 1.0, Difficulty.normal);
      expect(built.hp, (base.hp * 0.8).round());
      for (final action in ['attack', 'charge']) {
        expect(
            valuesOf(built, action),
            valuesOf(base, action).map((v) => (v * 1.3).round()).toList(),
            reason: action);
      }
      // 방어·회복에는 HP 배율이 붙는다
      for (final action in ['defend', 'heal']) {
        expect(
            valuesOf(built, action),
            valuesOf(base, action).map((v) => max(1, (v * 0.8).round())),
            reason: action);
      }
    });

    test('4. 지역 배율은 보스에 붙지 않는다 — 체력도 공격도 (12지역 ×3.35 / ×1.45)', () {
      final boss =
          data.enemies.firstWhere((e) => e.id == 'boss_inferno_dragon');
      final built = buildEnemy(boss, normal, 3.35, 1.45, Difficulty.normal);
      expect(boss.hp, 405);
      expect(built.hp, 405);
      // ENEMIES.md 3절 표가 최종값이다 — 공격 18 · 강타 38이 그대로여야 한다
      expect(valuesOf(built, 'attack'), valuesOf(boss, 'attack'));
      expect(valuesOf(built, 'attack'), [18]);
      expect(valuesOf(built, 'charge'), valuesOf(boss, 'charge'));
      expect(valuesOf(built, 'charge'), [38]);
      expect(valuesOf(built, 'defend'), valuesOf(boss, 'defend'));
      // 2페이즈도 마찬가지다
      expect(built.phase2Pattern!.map((a) => a.value).toList(),
          boss.phase2Pattern!.map((a) => a.value).toList());
    });

    test('5. 지역 배율은 일반 적에 붙는다 — 체력 ×3.35 · 공격 ×1.45 (12지역)', () {
      final base = data.enemies.firstWhere((e) => !e.isBoss && e.tier == 5);
      final built = buildEnemy(base, normal, 3.35, 1.45, Difficulty.normal);
      expect(built.hp, (base.hp * 3.35).round());
      // 공격·강타에는 **공격 배율만** 붙는다 (체력 배율이 새면 보스보다 아파진다)
      for (final action in ['attack', 'charge']) {
        expect(
            valuesOf(built, action),
            valuesOf(base, action).map((v) => max(1, (v * 1.45).round())),
            reason: action);
      }
      // 방어·회복은 화력이 아니므로 체력 배율을 따른다
      for (final action in ['defend', 'heal']) {
        expect(
            valuesOf(built, action),
            valuesOf(base, action).map((v) => max(1, (v * 3.35).round())),
            reason: action);
      }
    });

    test('6. 변종 적용 후 phase2HpThreshold == hp ~/ 2', () {
      for (final boss in data.enemies.where((e) => e.isBoss)) {
        for (final v in data.variants) {
          final built = buildEnemy(boss, v, 1.0, 1.0, Difficulty.hard);
          expect(built.phase2HpThreshold, built.hp ~/ 2, reason: boss.id);
        }
      }
      // 일반 적은 2페이즈가 없으므로 null 그대로다
      final rat = data.enemies.firstWhere((e) => e.id == 'cave_rat');
      final builtRat = buildEnemy(rat, hungry, 2.0, 1.1, Difficulty.normal);
      expect(builtRat.phase2HpThreshold, isNull);
    });

    test('7. 변종 이름 접두어 — 기본 변종은 붙지 않는다', () {
      final orc = data.enemies.firstWhere((e) => e.id == 'orc_warrior');
      expect(buildEnemy(orc, hungry, 1.0, 1.0, Difficulty.normal).name,
          '굶주린 ${orc.name}');
      expect(
          buildEnemy(orc, normal, 1.0, 1.0, Difficulty.normal).name, orc.name);
    });

    test('9. 난이도 배율이 HP·공격에 곱해진다', () {
      final base = data.enemies.firstWhere((e) => e.id == 'orc_warrior');
      for (final d in Difficulty.values) {
        final scale = kDifficultyScales[d]!;
        final built = buildEnemy(base, normal, 1.0, 1.0, d);
        expect(built.hp, (base.hp * scale.hpMul).round(), reason: d.name);
        expect(
            valuesOf(built, 'attack'),
            valuesOf(base, 'attack')
                .map((v) => (v * scale.atkMul).round())
                .toList(),
            reason: d.name);
      }
    });

    // ★ 이번 사고(측정 14 · 검토 14)를 테스트가 잡게 만든다.
    // 지역 배율 하나를 HP와 공격에 똑같이 곱했더니 12지역 일반 적 공격이
    // 41.5로 부풀어 **보스(18)보다 2.3배 아팠다.** 사람이 표를 다시 보지 않아도
    // 데이터가 어긋나면 여기서 즉시 걸린다.
    test('S5. 12지역 전부에서 보스 공격 ≥ 그 지역 일반 적 평균 공격', () {
      /// 행동 값의 평균. 그 행동이 없으면 0.
      double meanOf(List<num> v) =>
          v.isEmpty ? 0 : v.fold<double>(0, (a, b) => a + b) / v.length;

      for (final region in data.regions) {
        // 일반 적: tier 풀 가중치로 평균 공격을 낸다 (기본 변종 · 보통 난이도)
        var weighted = 0.0;
        var weightSum = 0;
        for (final entry in region.tierPool.entries) {
          final tier = int.parse(entry.key);
          final pool = data.enemies
              .where((e) => !e.isBoss && e.tier == tier)
              .map((e) => buildEnemy(e, normal, region.hpScale,
                  region.atkScale, Difficulty.normal))
              .toList();
          expect(pool, isNotEmpty, reason: '지역 ${region.id} tier $tier 풀이 비었다');
          weighted += entry.value *
              meanOf([for (final e in pool) meanOf(valuesOf(e, 'attack'))]);
          weightSum += entry.value;
        }
        final normalAttack = weighted / weightSum;

        final bossBase =
            data.enemies.firstWhere((e) => e.id == region.bossId);
        final boss = buildEnemy(bossBase, normal, region.hpScale,
            region.atkScale, Difficulty.normal);
        final bossAttack = meanOf(valuesOf(boss, 'attack'));

        expect(bossAttack, greaterThanOrEqualTo(normalAttack),
            reason: '지역 ${region.id} ${region.name}: '
                '보스 공격 $bossAttack < 일반 적 평균 $normalAttack');
      }
    });
  });

  group('층 이벤트 배치', () {
    test('8. 스테이지 100개 전부에서 배치 규칙이 성립한다', () {
      for (final stage in data.stages) {
        final events = [
          for (var f = 1; f <= stage.floors; f++) floorEvent(f, stage.floors),
        ];
        expect(events.length, stage.floors, reason: stage.id);
        expect(events.where((e) => e == FloorEvent.boss).length, 1,
            reason: '${stage.id}: 보스 층은 정확히 1개');
        expect(events.last, FloorEvent.boss, reason: '${stage.id}: 마지막 층');
        expect(events[stage.floors - 2], FloorEvent.shop,
            reason: '${stage.id}: 상점은 보스 앞 층');
        expect(events.where((e) => e == FloorEvent.shop).length, 1,
            reason: '${stage.id}: 상점도 1개');
        expect(events.where((e) => e == FloorEvent.relicReward).length,
            lessThanOrEqualTo(1),
            reason: '${stage.id}: 유물 보상은 많아야 1개');
      }
    });

    test('3층 스테이지에는 유물 보상이 없다 (도입 지역은 짧다)', () {
      expect(floorEvent(1, 3), FloorEvent.battle);
      expect(floorEvent(2, 3), FloorEvent.shop);
      expect(floorEvent(3, 3), FloorEvent.boss);
    });

    test('층수별 배치 — 5·8·10층', () {
      List<FloorEvent> layout(int floors) =>
          [for (var f = 1; f <= floors; f++) floorEvent(f, floors)];
      expect(layout(5), [
        FloorEvent.battle,
        FloorEvent.battle,
        FloorEvent.relicReward,
        FloorEvent.shop,
        FloorEvent.boss,
      ]);
      expect(layout(8), [
        FloorEvent.battle,
        FloorEvent.battle,
        FloorEvent.spellReward,
        FloorEvent.relicReward,
        FloorEvent.battle,
        FloorEvent.spellReward,
        FloorEvent.shop,
        FloorEvent.boss,
      ]);
      expect(layout(10), [
        FloorEvent.battle,
        FloorEvent.battle,
        FloorEvent.spellReward,
        FloorEvent.battle,
        FloorEvent.relicReward,
        FloorEvent.spellReward,
        FloorEvent.battle,
        FloorEvent.battle,
        FloorEvent.shop,
        FloorEvent.boss,
      ]);
    });
  });

  group('적 뽑기·판 진행', () {
    test('10. 보스 변종은 난이도로 고정된다 (normal/shadow/ancient)', () {
      final region = data.region(1);
      final stage = data.stage(1, 1);
      const prefixes = {
        Difficulty.normal: '',
        Difficulty.hard: '그림자',
        Difficulty.death: '고대의',
      };
      for (final d in Difficulty.values) {
        final boss = pickEnemy(data, region, stage, stage.floors, d, Random(1));
        expect(boss.id, region.bossId);
        expect(boss.name.startsWith(prefixes[d]!), isTrue, reason: d.name);
        // 배율도 그 변종의 것이 붙는다
        final base = data.enemies.firstWhere((e) => e.id == region.bossId);
        final variant = data.variant(kBossVariantIds[d]!);
        final scale = kDifficultyScales[d]!;
        expect(boss.hp, (base.hp * variant.hpMul * scale.hpMul).round(),
            reason: d.name);
      }
    });

    test('일반 층 적은 지역 tier 풀 안에서만 나온다', () {
      final region = data.region(7);
      final stage = data.stage(7, 1);
      final random = Random(20260902);
      for (var i = 0; i < 200; i++) {
        final e = pickEnemy(data, region, stage, 1, Difficulty.normal, random);
        expect(e.isBoss, isFalse);
        expect(region.tierPool.keys, contains('${e.tier}'));
      }
    });

    test('11. 한 스테이지를 끝까지 돈다 — 마지막 층 적이 보스', () {
      final run = RunController(
          data: data, random: Random(3), regionId: 6, stageIndex: 5)
        ..startRun();
      expect(run.floors, greaterThan(1));
      for (var f = 1; f <= run.floors; f++) {
        expect(run.state.floor, f);
        expect(run.isCleared, isFalse);
        if (f == run.floors) {
          expect(run.currentEnemy.isBoss, isTrue);
          expect(run.currentEnemy.id, run.region.bossId);
        } else {
          expect(run.currentEnemy.isBoss, isFalse, reason: '$f층');
        }
        run.advanceFloor();
      }
      expect(run.isCleared, isTrue);
    });

    test('13. 난이도 보정이 실제 추첨에도 반영된다 — 1지역 데스에 「고대의」가 나온다', () {
      final region = data.region(1);
      final stage = data.stage(1, 1);
      final random = Random(20260902);
      var ancient = 0;
      for (var i = 0; i < 400; i++) {
        final e = pickEnemy(data, region, stage, 1, Difficulty.death, random);
        if (e.name.startsWith('고대의')) ancient++;
      }
      // 보정 후 가중치 20% — 표본 400이면 0일 수 없다
      expect(ancient, greaterThan(0));
      // 보통 난이도에서는 1지역에 「고대의」가 없다
      final normalRandom = Random(20260902);
      for (var i = 0; i < 400; i++) {
        final e =
            pickEnemy(data, region, stage, 1, Difficulty.normal, normalRandom);
        expect(e.name.startsWith('고대의'), isFalse);
      }
    });

    test('12. RunState toJson → fromJson 왕복이 값을 보존한다', () {
      final s = RunState.initial(
          regionId: 9, stageIndex: 4, difficulty: Difficulty.hard)
        ..floor = 6
        ..hp = 17
        ..charge = 1;
      s.relicIds.add('loaded_die');
      final r = RunState.fromJson(s.toJson());
      expect(r.regionId, 9);
      expect(r.stageIndex, 4);
      expect(r.difficulty, Difficulty.hard);
      expect(r.floor, 6);
      expect(r.hp, 17);
      expect(r.charge, 1);
      expect(r.handIds, s.handIds);
      expect(r.relicIds, ['loaded_die']);
    });
  });

  // WORK_ORDER_SIM2 작업 1 — ENEMIES.md 5.3절 마지막 줄의 난이도 보정
  group('난이도별 변종 보정', () {
    int sumOf(Map<String, int> w) => w.values.fold(0, (a, b) => a + b);

    test('S1. 12지역 × 3난이도 = 36가지 전부 가중치 합이 100이다', () {
      for (final r in data.regions) {
        expect(sumOf(r.variantWeights), 100, reason: '지역 ${r.id} 원본');
        for (final d in Difficulty.values) {
          final w = difficultyVariantWeights(r.variantWeights, d);
          expect(sumOf(w), 100, reason: '지역 ${r.id} / ${d.name}');
        }
      }
    });

    test('S2. 하드는 「고대의」가 원래 +10, 데스는 +20이다', () {
      for (final r in data.regions) {
        final before = r.variantWeights[kAncientVariantId] ?? 0;
        for (final d in Difficulty.values) {
          final w = difficultyVariantWeights(r.variantWeights, d);
          expect(w[kAncientVariantId] ?? 0, before + kAncientVariantBonus[d]!,
              reason: '지역 ${r.id} / ${d.name}');
        }
      }
    });

    test('S3. 「고대의」가 0인 1~7지역에도 하드 10 · 데스 20이 생긴다', () {
      for (var id = 1; id <= 7; id++) {
        final base = data.region(id).variantWeights;
        expect(base[kAncientVariantId] ?? 0, 0, reason: '지역 $id 원본');
        expect(
            difficultyVariantWeights(base, Difficulty.hard)[kAncientVariantId],
            10,
            reason: '지역 $id 하드');
        expect(
            difficultyVariantWeights(base, Difficulty.death)[kAncientVariantId],
            20,
            reason: '지역 $id 데스');
      }
    });

    test('S4. 「기본」이 모자라면 비중이 큰 변종에서 빠지고 음수가 안 생긴다', () {
      // 12지역: 기본 15 < 데스 보정 20 → 기본 0, 나머지 5는 그림자(25)에서
      final r12 = data.region(12).variantWeights;
      final death = difficultyVariantWeights(r12, Difficulty.death);
      expect(death[kNormalVariantId], 0);
      expect(death['shadow'], r12['shadow']! - 5);
      expect(death[kAncientVariantId], r12[kAncientVariantId]! + 20);
      // 나머지 변종은 건드리지 않는다
      for (final id in ['hungry', 'rotten', 'frozen']) {
        expect(death[id], r12[id], reason: id);
      }
      // 36가지 전부 음수가 없다
      for (final r in data.regions) {
        for (final d in Difficulty.values) {
          final w = difficultyVariantWeights(r.variantWeights, d);
          for (final e in w.entries) {
            expect(e.value, greaterThanOrEqualTo(0),
                reason: '지역 ${r.id} / ${d.name} / ${e.key}');
          }
        }
      }
    });
  });
}
