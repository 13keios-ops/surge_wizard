import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/battle.dart';
import '../core/constants.dart';
import '../core/relic_powers.dart';
import '../core/stage_runner.dart';
import '../data/parser.dart';
import '../models/enemy.dart';
import '../models/meta_state.dart';
import '../models/region.dart';
import '../models/relic.dart';
import '../models/run_state.dart';
import '../models/spell.dart';
import '../models/stage.dart';
import 'battle_controller.dart';
import 'meta_controller.dart';

/// 한 판(= 스테이지 하나)의 진행을 관리한다: 층 이동, 전투 구성, 보상, 상점.
/// 전투 자체는 BattleController/Battle에 위임한다.
class RunController extends ChangeNotifier {
  RunController({
    required this.data,
    MetaState? meta,
    Random? random,
    this.regionId = kEntryRegionId,
    this.stageIndex = kEntryStageIndex,
    this.difficulty = kEntryDifficulty,
  })  : meta = meta ?? MetaState.initial(),
        _random = random ?? Random();

  final GameData data;

  /// 이 판이 도는 지역·스테이지·난이도.
  /// 선택 화면이 생기기 전까지는 임시 진입 상수가 들어온다
  final int regionId;
  final int stageIndex;
  final Difficulty difficulty;

  /// 영구 강화 상태 (판 시작 시점의 스냅샷, 판 중에는 안 바뀐다)
  final MetaState meta;

  final Random _random;

  late RunState state;

  /// 이번 층에서 싸울 적 (층 진입 시 결정, 지도에 미리 보여준다)
  late Enemy currentEnemy;

  /// 진행 중인 보상 선택지 (보상 층에서만 채워진다)
  List<Spell> spellOffers = [];
  List<Relic> relicOffers = [];

  /// 이번 판에서 받은 경험치 누계 · 오른 레벨 수 (결과 화면 표시용)
  int expEarned = 0;
  int levelsGained = 0;

  // ── 파생값 ──

  List<Spell> get hand => state.handIds
      .map((id) => data.spells.firstWhere((s) => s.id == id))
      .toList();

  List<Relic> get relics => state.relicIds
      .map((id) => data.relics.firstWhere((r) => r.id == id))
      .toList();

  /// 유물 효과 + 메타 영구 강화(체력·리롤) 합산
  RelicPowers get powers => RelicPowers.fromRelics(relics).add(
        maxHpUp: meta.hpLevel * kMetaHpBonusPerLevel,
        extraRerolls: meta.rerollLevel,
      );

  /// 최대 체력 = 기본치 + 유물 + 영구 강화
  int get maxHp => kPlayerStartHp + powers.maxHpUp;

  /// 최대 마나 = 기본치 + 영구 강화
  int get maxMana => kPlayerStartMaxMana + meta.manaLevel;

  /// 이 판이 도는 지역
  Region get region => data.region(state.regionId);

  /// 이 판이 도는 스테이지
  Stage get stage => data.stage(state.regionId, state.stageIndex);

  /// 이 스테이지의 층 수 (3~10으로 가변)
  int get floors => stage.floors;

  bool get isBossFloor => state.floor == floors;

  /// 이번 층 전투를 이기면 받는 경험치 (GROWTH.md 1.3절)
  int get battleExpReward => battleExp(
        regionExp: region.exp,
        isBoss: currentEnemy.isBoss,
        isVariant: currentEnemy.variantId != kNormalVariantId,
        difficulty: state.difficulty,
      );

  /// 스테이지를 끝까지 돌았는가
  bool get isCleared => state.isCleared(floors);

  /// 현재 층에서 전투 뒤에 일어나는 일
  FloorEvent get currentEvent => floorEvent(state.floor, floors);

  /// 화면 상단에 띄우는 스테이지 이름 (「마나의 숲 I」)
  String get stageTitle =>
      '${region.name} ${kStageRomans[state.stageIndex - 1]}';

  /// 스테이지 부제 (있는 스테이지만 — 대개 보스 스테이지다)
  String? get stageSubtitle => stage.subtitle;

  // ── 판 진행 ──

  /// 새 판 시작. 영구 강화(시작 유물·최대 체력)를 반영한다.
  void startRun() {
    state = RunState.initial(
        regionId: regionId,
        stageIndex: stageIndex,
        difficulty: difficulty);
    if (meta.startRelicLevel > 0) {
      final commons =
          data.relics.where((r) => r.rarity == 'common').toList();
      state.relicIds.add(commons[_random.nextInt(commons.length)].id);
    }
    state.hp = maxHp; // 강화·시작 유물로 커진 최대 체력만큼 채우고 시작
    _pickEnemyForFloor();
    notifyListeners();
  }

  /// 현재 층의 적을 정한다. 마지막 층은 지역 보스다.
  void _pickEnemyForFloor() {
    currentEnemy = pickEnemy(
        data, region, stage, state.floor, state.difficulty, _random);
  }

  /// 현재 층 전투용 컨트롤러를 만든다.
  BattleController buildBattleController() {
    return BattleController(data: data, random: _random)
      ..startBattle(
        enemy: currentEnemy,
        hand: hand,
        hp: state.hp,
        maxHp: maxHp,
        maxMana: maxMana,
        relics: powers,
        charge: state.charge,
      );
  }

  /// 전투 승리 경험치를 **그 자리에서 즉시** 지급한다.
  /// 판이 뒤에 실패해도 이미 받은 경험치는 남는다 — 재도전이 곧 파밍이다
  /// (GAME_DESIGN 6.6절 · GROWTH.md 1.3절).
  void grantExp(MetaController meta) {
    final amount = battleExpReward;
    expEarned += amount;
    levelsGained += meta.gainExp(amount);
    notifyListeners();
  }

  /// 전투 승리 반영: 체력·마력 축적을 이어받고 회복을 적용한다.
  /// 회복은 **유물 회복 + 전투 승리 회복**을 더한 값이다 (보스 층은 후자가 0).
  void afterVictory(Battle battle) {
    // 보스 층을 깬 뒤에도 주문 보상을 1회 준다 (스테이지 완주 보상)
    final event = currentEvent;
    final winHeal =
        event == FloorEvent.boss ? 0 : battleWinHealAmount(maxHp);
    state.hp =
        min(maxHp, battle.playerHp + powers.healAfterBattle + winHeal);
    state.charge = battle.charge;
    if (event == FloorEvent.spellReward || event == FloorEvent.boss) {
      _rollSpellOffers();
    }
    if (event == FloorEvent.relicReward) _rollRelicOffers();
    notifyListeners();
  }

  /// 다음 층으로 이동
  void advanceFloor() {
    state.floor++;
    spellOffers = [];
    relicOffers = [];
    if (!isCleared) _pickEnemyForFloor();
    notifyListeners();
  }

  // ── 보상: 주문 3장 중 1택 ──

  void _rollSpellOffers() {
    // epic 주문은 메타에서 해금해야 등장한다 (BLOCKERS.md 판단 11)
    final candidates = data.spells
        .where((s) =>
            !state.handIds.contains(s.id) &&
            (s.rarity != 'epic' || meta.unlockedSpellIds.contains(s.id)))
        .toList()
      ..shuffle(_random);
    spellOffers = candidates.take(kRewardChoiceCount).toList();
  }

  /// 골라온 주문으로 손패 한 칸을 교체한다.
  void takeSpell(Spell chosen, int slotIndex) {
    state.handIds[slotIndex] = chosen.id;
    spellOffers = [];
    notifyListeners();
  }

  /// 주문 보상 건너뛰기
  void skipSpellReward() {
    spellOffers = [];
    notifyListeners();
  }

  // ── 보상: 유물 3개 중 1택 ──

  void _rollRelicOffers() {
    final candidates =
        data.relics.where((r) => !state.relicIds.contains(r.id)).toList()
          ..shuffle(_random);
    relicOffers = candidates.take(kRewardChoiceCount).toList();
  }

  /// 유물 획득. 최대 체력 유물이면 현재 체력도 같이 오른다.
  void takeRelic(Relic chosen) {
    final maxHpBefore = maxHp;
    state.relicIds.add(chosen.id);
    state.hp += maxHp - maxHpBefore;
    relicOffers = [];
    notifyListeners();
  }

  void skipRelicReward() {
    relicOffers = [];
    notifyListeners();
  }

  // ── 상점 (보스 앞 층) — 지금은 휴식 회복만. 경제 설계는 메타 단계에서. ──

  void shopHeal() {
    state.hp = min(maxHp, state.hp + shopHealAmount(maxHp));
    notifyListeners();
  }
}
