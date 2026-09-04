import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/battle.dart';
import '../core/check.dart';
import '../core/constants.dart';
import '../core/dice.dart';
import '../core/relic_powers.dart';
import '../data/parser.dart';
import '../models/enemy.dart';
import '../models/spell.dart';
import '../models/surge_event.dart';

/// 전투 화면의 진행 단계
enum BattlePhase {
  /// 주문·강도 선택 중
  pick,

  /// 주사위를 굴린 뒤 잠금·리롤 중
  reroll,

  /// 판정 결과 표시 중 (턴 종료 대기)
  result,

  /// 전투 종료
  over,
}

/// 전투 화면 상태 관리 (provider용 ChangeNotifier).
/// 규칙 계산은 전부 core/battle.dart 에 위임하고, 여기는
/// "화면이 지금 뭘 보여줘야 하는가"만 다룬다.
class BattleController extends ChangeNotifier {
  BattleController({required this.data, Random? random})
      : _random = random ?? Random();

  final GameData data;
  final Random _random;

  late Battle battle;
  late DicePool pool;
  BattlePhase phase = BattlePhase.pick;
  int? selectedSpell; // 선택된 손패 인덱스
  CastIntensity intensity = CastIntensity.normal;

  /// 굴림 회차. 바뀔 때마다 주사위 위젯이 굴림 애니메이션을 재생한다.
  int rollId = 0;

  /// 시전 회차. 바뀔 때마다 마법 이펙트가 한 번 재생된다.
  int castId = 0;

  /// 방금 시전한 주문 (이펙트 속성·위력에 쓴다)
  Spell? lastCastSpell;

  /// 방금 시전의 위력 배수 (이펙트 크기)
  double lastCastPower = 1.0;

  /// 방금 적용된 판정 결과 (result 단계 표시용)
  CheckResult? get lastResult => battle.lastResult;

  /// 화면이 보여줘야 할 등급 (실제로 전투에 적용된 값).
  CheckGrade? get appliedGrade => battle.lastAppliedGrade;

  /// 방금 발동한 폭주 (없으면 null)
  SurgeEvent? get lastSurge => battle.surge.lastSurge;

  /// 방금 폭주의 결과 요약 (팝업의 숫자 칸). 불발이면 빈 문자열이다.
  String? get lastSurgeSummary => battle.surge.lastSurgeSummary;

  /// 전투 시작. 런(RunController)이 층 상황에 맞게 구성해 넘겨준다.
  void startBattle({
    required Enemy enemy,
    required List<Spell> hand,
    int? hp,
    int? maxHp,
    int? maxMana,
    RelicPowers relics = const RelicPowers(),
    int charge = 0,
  }) {
    battle = Battle(
      enemy: enemy,
      hand: List.of(hand),
      surgePool: data.surges,
      playerHp: hp,
      playerMaxHp: maxHp,
      maxMana: maxMana,
      relics: relics,
      random: _random,
    )..charge = charge;
    // 주사위 풀: 유물의 리롤 횟수 추가·1눈 보정을 반영한다
    pool = DicePool(
      random: _random,
      maxRerolls: kMaxRerollsPerCheck + relics.extraRerolls,
      faceTransform: relics.rerollOnesTo > 0
          ? (face) => face == 1 ? relics.rerollOnesTo : face
          : null,
    );
    battle.startTurn();
    phase = BattlePhase.pick;
    selectedSpell = null;
    intensity = CastIntensity.normal;
    notifyListeners();
  }

  // ── pick 단계 ──

  void selectSpell(int index) {
    if (phase != BattlePhase.pick) return;
    if (battle.sealedSpellIds.contains(battle.hand[index].id)) return;
    selectedSpell = index;
    notifyListeners();
  }

  void selectIntensity(CastIntensity it) {
    if (phase != BattlePhase.pick) return;
    if (battle.mana < it.manaCost) return;
    intensity = it;
    notifyListeners();
  }

  bool get canRoll =>
      phase == BattlePhase.pick &&
      selectedSpell != null &&
      battle.mana >= intensity.manaCost;

  /// 주사위 굴림 → reroll 단계로
  void rollDice() {
    if (!canRoll) return;
    if (battle.pendingExtraDie) {
      // 주사위 추가 효과: 4개 굴려 상위 3개 (battle.rollDice가 처리)
      pool.seed(battle.rollDice());
    } else {
      pool.rollAll();
    }
    rollId++;
    phase = BattlePhase.reroll;
    notifyListeners();
  }

  // ── reroll 단계 ──

  void toggleLock(int index) {
    if (phase != BattlePhase.reroll) return;
    pool.toggleLock(index);
    notifyListeners();
  }

  /// 다음 리롤이 무료인가 (유물 free_rerolls)
  bool get nextRerollIsFree => battle.freeRerollsLeft > 0;

  /// 다음 리롤의 마나 비용 (1 → 2 → 3 체증). 화면 표시에도 쓴다.
  /// 무료로 굴린 횟수는 회차에 세지 않는다 (검토서 01 수정 요청 2).
  int get nextRerollCost => rerollManaCost(pool.paidRerollCount);

  /// 리롤 가능 여부: 횟수 + (무료 리롤 또는 시전 비용을 남겨둔 마나)
  bool get canReroll =>
      phase == BattlePhase.reroll &&
      pool.canReroll &&
      (nextRerollIsFree ||
          battle.mana - intensity.manaCost >= nextRerollCost);

  void reroll() {
    if (!canReroll) return;
    final free = nextRerollIsFree;
    if (free) {
      battle.freeRerollsLeft--;
    } else {
      battle.mana -= nextRerollCost;
    }
    pool.reroll(free: free);
    rollId++;
    notifyListeners();
  }

  /// 주사위 확정 → 판정 적용 → result 단계로
  void confirmCast() {
    if (phase != BattlePhase.reroll) return;
    final spell = battle.hand[selectedSpell!];
    battle.castSpell(selectedSpell!, intensity, dice: pool.values);
    // 이펙트용 정보 기록 (실패해도 폭주 연출을 위해 남긴다)
    lastCastSpell = spell;
    // 이펙트 크기도 실제 적용 등급을 따른다
    lastCastPower = intensity.power *
        (battle.lastAppliedGrade == CheckGrade.critSuccess ? 1.8 : 1.0);
    castId++;
    phase = battle.isOver ? BattlePhase.over : BattlePhase.result;
    notifyListeners();
  }

  // ── result 단계 ──

  /// 턴 종료: 적 행동 후 다음 턴 준비
  void endTurn() {
    if (phase != BattlePhase.result) return;
    battle.enemyTurn();
    if (battle.isOver) {
      phase = BattlePhase.over;
    } else {
      battle.startTurn();
      phase = BattlePhase.pick;
      selectedSpell = null;
      // 남은 마나로 못 쓰는 강도가 선택돼 있으면 「보통」으로 내린다.
      // (보통은 마나 0이라 언제나 낼 수 있다 — GAME_DESIGN v2 3.3절)
      if (battle.mana < intensity.manaCost) {
        intensity = CastIntensity.normal;
      }
    }
    notifyListeners();
  }
}
