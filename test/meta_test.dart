/// 메타 성장(영구 강화)·저장 단위 테스트.
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/meta_state.dart';
import 'package:surge_wizard/screens/meta_controller.dart';
import 'package:surge_wizard/screens/run_controller.dart';
import 'package:surge_wizard/services/save_service.dart';

String readData(String name) => File('assets/data/$name').readAsStringSync();

void main() {
  final data = GameDataParser.parseAll(readData);

  group('MetaState 저장 형식', () {
    test('toJson/fromJson 왕복이 값을 보존한다', () {
      final m = MetaState.initial()
        ..crystals = 123
        ..hpLevel = 2
        ..manaLevel = 1
        ..rerollLevel = 1
        ..startRelicLevel = 1;
      m.unlockedSpellIds.addAll(['meteor_call', 'eclipse']);
      final restored = MetaState.fromJson(m.toJson());
      expect(restored.crystals, 123);
      expect(restored.hpLevel, 2);
      expect(restored.manaLevel, 1);
      expect(restored.rerollLevel, 1);
      expect(restored.startRelicLevel, 1);
      expect(restored.unlockedSpellIds, {'meteor_call', 'eclipse'});
    });

    test('빈/부분 JSON도 기본값으로 복원된다', () {
      final restored = MetaState.fromJson({});
      expect(restored.crystals, 0);
      expect(restored.unlockedSpellIds, isEmpty);
    });
  });

  group('SaveService (shared_preferences)', () {
    test('저장 후 다시 읽으면 같은 값이다', () async {
      SharedPreferences.setMockInitialValues({});
      final save = SaveService();
      final m = MetaState.initial()
        ..crystals = 77
        ..hpLevel = 3;
      await save.saveMeta(m);
      final loaded = await save.loadMeta();
      expect(loaded.crystals, 77);
      expect(loaded.hpLevel, 3);
    });

    test('저장된 게 없으면 초기 상태', () async {
      SharedPreferences.setMockInitialValues({});
      final loaded = await SaveService().loadMeta();
      expect(loaded.crystals, 0);
      expect(loaded.hpLevel, 0);
    });
  });

  group('MetaController 구매 규칙', () {
    MetaController make({int crystals = 0}) {
      SharedPreferences.setMockInitialValues({});
      return MetaController(MetaState.initial()..crystals = crystals);
    }

    test('결정이 모자라면 못 산다', () {
      final c = make(crystals: kMetaHpCosts[0] - 1);
      expect(c.canBuy(MetaUpgrade.maxHp), isFalse);
      expect(c.buy(MetaUpgrade.maxHp), isFalse);
      expect(c.levelOf(MetaUpgrade.maxHp), 0);
    });

    test('구매하면 결정이 깎이고 단계가 오르고 비용이 다음 단계로 바뀐다', () {
      final c = make(crystals: 1000);
      expect(c.buy(MetaUpgrade.maxHp), isTrue);
      expect(c.levelOf(MetaUpgrade.maxHp), 1);
      expect(c.crystals, 1000 - kMetaHpCosts[0]);
      expect(c.nextCost(MetaUpgrade.maxHp), kMetaHpCosts[1]);
    });

    test('최대 단계를 넘어 살 수 없다', () {
      final c = make(crystals: 99999);
      for (var i = 0; i < kMetaHpCosts.length; i++) {
        expect(c.buy(MetaUpgrade.maxHp), isTrue);
      }
      expect(c.nextCost(MetaUpgrade.maxHp), isNull);
      expect(c.buy(MetaUpgrade.maxHp), isFalse);
      expect(c.levelOf(MetaUpgrade.maxHp), kMetaHpCosts.length);
    });

    test('주문 해금: 결정 차감, 중복 해금 불가', () {
      final c = make(crystals: kSpellUnlockCost);
      expect(c.unlockSpell('meteor_call'), isTrue);
      expect(c.crystals, 0);
      expect(c.unlockSpell('meteor_call'), isFalse); // 이미 해금
      expect(c.unlockSpell('eclipse'), isFalse); // 결정 부족
    });

    test('판 종료 보상: 층당 지급 + 보스 보너스', () {
      // 층수는 스테이지마다 다르므로(3~10) 임의의 층수 하나로 확인한다
      const floors = 10;
      final c = make();
      expect(c.earnRunReward(clearedFloors: 4, clearedBoss: false),
          4 * kCrystalPerFloor);
      expect(c.earnRunReward(clearedFloors: floors, clearedBoss: true),
          floors * kCrystalPerFloor + kBossClearCrystalBonus);
      expect(
          c.crystals,
          4 * kCrystalPerFloor +
              floors * kCrystalPerFloor +
              kBossClearCrystalBonus);
    });
  });

  group('영구 강화가 런에 반영된다', () {
    RunController makeRun(MetaState meta, {int seed = 1}) =>
        RunController(data: data, meta: meta, random: Random(seed))
          ..startRun();

    test('체력·마나·리롤 강화가 시작 스탯에 적용된다', () {
      final meta = MetaState.initial()
        ..hpLevel = 2
        ..manaLevel = 1
        ..rerollLevel = 1;
      final run = makeRun(meta);
      expect(run.maxHp, kPlayerStartHp + 2 * kMetaHpBonusPerLevel);
      expect(run.state.hp, run.maxHp); // 가득 채우고 시작
      expect(run.maxMana, kPlayerStartMaxMana + 1);
      expect(run.powers.extraRerolls, 1);

      final bc = run.buildBattleController();
      expect(bc.battle.maxMana, kPlayerStartMaxMana + 1);
      expect(bc.pool.maxRerolls, kMaxRerollsPerCheck + 1);
    });

    test('시작 유물 강화: common 유물 1개를 들고 시작한다', () {
      final run = makeRun(MetaState.initial()..startRelicLevel = 1);
      expect(run.relics.length, 1);
      expect(run.relics.first.rarity, 'common');
    });

    test('epic 주문은 해금 전에는 보상에 안 나온다', () {
      // 해금 0개: 보상 추첨을 여러 번 돌려도 epic이 없어야 한다
      for (var seed = 0; seed < 30; seed++) {
        final run = makeRun(MetaState.initial(), seed: seed);
        run.state.floor = 3;
        run.afterVictory(run.buildBattleController().battle..enemyHp = 0);
        expect(run.spellOffers.any((s) => s.rarity == 'epic'), isFalse,
            reason: '시드 $seed');
      }
    });

    test('해금한 epic 주문은 보상에 나올 수 있다', () {
      final meta = MetaState.initial();
      // epic 15종 전부 해금하면 추첨에 등장할 수밖에 없는 시드가 존재한다
      for (final s in data.spells.where((s) => s.rarity == 'epic')) {
        meta.unlockedSpellIds.add(s.id);
      }
      var seen = false;
      for (var seed = 0; seed < 50 && !seen; seed++) {
        final run = makeRun(meta, seed: seed);
        run.state.floor = 3;
        run.afterVictory(run.buildBattleController().battle..enemyHp = 0);
        seen = run.spellOffers.any((s) => s.rarity == 'epic');
      }
      expect(seen, isTrue);
    });
  });
}
