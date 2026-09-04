import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/meta_state.dart';
import '../services/save_service.dart';

/// 영구 강화 종류
enum MetaUpgrade { maxHp, maxMana, startReroll, startRelic }

/// 강화별 단계 비용표 조회
extension MetaUpgradeCosts on MetaUpgrade {
  List<int> get costs => switch (this) {
        MetaUpgrade.maxHp => kMetaHpCosts,
        MetaUpgrade.maxMana => kMetaManaCosts,
        MetaUpgrade.startReroll => kMetaRerollCosts,
        MetaUpgrade.startRelic => kMetaStartRelicCosts,
      };

  int get maxLevel => costs.length;

  String get label => switch (this) {
        MetaUpgrade.maxHp => '최대 체력 +$kMetaHpBonusPerLevel',
        MetaUpgrade.maxMana => '최대 마나 +1',
        MetaUpgrade.startReroll => '시작 리롤 +1',
        MetaUpgrade.startRelic => '시작 유물 1개',
      };
}

/// 영구 강화 상태 관리. 바뀔 때마다 즉시 저장한다.
class MetaController extends ChangeNotifier {
  MetaController(this._state, {SaveService? save})
      : _save = save ?? SaveService();

  final MetaState _state;
  final SaveService _save;

  MetaState get state => _state;
  int get crystals => _state.crystals;

  /// 현재 강화 단계
  int levelOf(MetaUpgrade u) => switch (u) {
        MetaUpgrade.maxHp => _state.hpLevel,
        MetaUpgrade.maxMana => _state.manaLevel,
        MetaUpgrade.startReroll => _state.rerollLevel,
        MetaUpgrade.startRelic => _state.startRelicLevel,
      };

  /// 다음 단계 비용. 이미 최대면 null.
  int? nextCost(MetaUpgrade u) {
    final level = levelOf(u);
    return level >= u.maxLevel ? null : u.costs[level];
  }

  bool canBuy(MetaUpgrade u) {
    final cost = nextCost(u);
    return cost != null && _state.crystals >= cost;
  }

  /// 강화 구매. 성공하면 true.
  bool buy(MetaUpgrade u) {
    if (!canBuy(u)) return false;
    _state.crystals -= nextCost(u)!;
    switch (u) {
      case MetaUpgrade.maxHp:
        _state.hpLevel++;
      case MetaUpgrade.maxMana:
        _state.manaLevel++;
      case MetaUpgrade.startReroll:
        _state.rerollLevel++;
      case MetaUpgrade.startRelic:
        _state.startRelicLevel++;
    }
    _persist();
    return true;
  }

  /// epic 주문 해금. 성공하면 true.
  bool unlockSpell(String spellId) {
    if (_state.unlockedSpellIds.contains(spellId)) return false;
    if (_state.crystals < kSpellUnlockCost) return false;
    _state.crystals -= kSpellUnlockCost;
    _state.unlockedSpellIds.add(spellId);
    _persist();
    return true;
  }

  /// 스테이지 클리어를 기록한다 (**끝까지 깼을 때만** 부른다).
  /// 처음 기록하는 것이면 저장하고 화면에 알린다 — 잠금이 그 자리에서 풀린다.
  void markStageCleared(int regionId, int stageIndex, Difficulty difficulty) {
    if (_state.markCleared(regionId, stageIndex, difficulty)) _persist();
  }

  /// 전투 승리 경험치를 준다. **전투를 이긴 그 자리에서 즉시** 부른다 —
  /// 그 판이 뒤에 실패해도 이미 받은 경험치는 남는다 (GAME_DESIGN 6.6절).
  /// 오른 레벨 수를 돌려준다 (결과 화면 표시용).
  int gainExp(int amount) {
    final levelsGained = _state.gainExp(amount);
    _persist();
    return levelsGained;
  }

  /// 판 종료 보상: 돌파한 층 × 층당 지급 + 보스 클리어 보너스.
  /// 지급된 양을 돌려준다 (결과 화면 표시용).
  int earnRunReward({required int clearedFloors, required bool clearedBoss}) {
    final earned = clearedFloors * kCrystalPerFloor +
        (clearedBoss ? kBossClearCrystalBonus : 0);
    _state.crystals += earned;
    _persist();
    return earned;
  }

  void _persist() {
    // 저장 실패해도 게임은 계속돼야 하므로 기다리지 않는다
    _save.saveMeta(_state);
    notifyListeners();
  }
}
