/// 지역 × 난이도 조합 하나를 도는 실행기 (WORK_ORDER_SIM2 작업 3).
///
/// `sim_core.dart` 의 `playRun` 은 「지역 1 · 스테이지 1 · 보통 · 성장 없음」
/// 고정이라 재측정에 쓸 수 없다. 여기서는 **가정 성장 프로필**을 씌우고
/// 지역·스테이지·난이도를 받아 돈다. 전투 로직·리롤 정책은 `runBattle` 을
/// 그대로 쓰므로 봇의 행동은 기준선과 같다.
///
/// 유물·패시브·각인은 넣지 않는다 — 변인을 늘리면 원인을 못 가린다.
library;

import 'dart:math';

import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/relic_powers.dart';
import 'package:surge_wizard/core/stage_runner.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/enemy.dart';
import 'package:surge_wizard/models/region.dart';
import 'package:surge_wizard/models/spell.dart';
import 'package:surge_wizard/models/stage.dart';

import 'measure_condition.dart';
import 'measure_growth.dart';
import 'measure_profile.dart';
import 'sim_core.dart';

/// 지역 × 난이도 한 조합의 집계
class ComboResult {
  ComboResult({
    required this.region,
    required this.stage,
    required this.difficulty,
    required this.profile,
    required this.deck,
    this.policy = BotPolicy.utility,
    this.upgrade = BookUpgrade.none,
    this.condition = kAdoptedCondition,
  });

  final Region region;
  final Stage stage;
  final Difficulty difficulty;
  final GrowthProfile profile;

  /// 이 조합에서 쓴 **덱** (보고서에 그대로 적는다).
  /// 손패는 매 턴 여기서 3장씩 뽑힌다 (GAME_DESIGN 4.2절).
  final List<Spell> deck;

  /// 이 조합을 돌린 봇 정책 (WORK_ORDER_DECK_FIX 작업 3).
  /// 같은 실행 안에서 greedy·utility 를 나란히 돌리므로 조합의 속성이다.
  final BotPolicy policy;

  /// 이 조합에 씌운 마법서 강화 수준 (WORK_ORDER_GROWTH_SIM 작업 1).
  /// 정책과 같은 이유로 조합의 속성이다 — 한 번의 실행에서 하한·상한을 다 돈다.
  final BookUpgrade upgrade;

  /// 이 조합을 돌린 측정 조건 (WORK_ORDER_FINAL_TUNE 3-A).
  /// 12지역 층수를 새 값으로 쓰는지가 여기 들어 있다.
  final MeasureCondition condition;

  /// 굴림·턴·폭주·자해는 기존 집계기를 그대로 쓴다
  final Tally tally = Tally();

  /// 일반 층에 실제로 선 변종의 등장 수 (작업 1 검증 — 보스는 세지 않는다)
  final Map<String, int> variantCounts = {};

  /// 보조 측정 — 보스 전투만 따로 잰 집계.
  ///
  /// 본 측정에서는 3지역 이후 **보스 층까지 가지 못해 표본이 0**이 된다.
  /// 그러면 3-B의 「보스 평균 턴」이 비어 층수 상한을 판단할 수 없다.
  /// 그래서 같은 보스를 **최대 체력에서 바로** 상대하는 전투를 따로 돌린다.
  final Tally bossOnly = Tally();
  int bossOnlyRuns = 0;
  int bossOnlyWins = 0;

  /// 이 조합에서 실제로 선 보스의 최종 HP (변종·난이도 배율까지 적용된 값)
  int bossHp = 0;

  int runs = 0;
  int cleared = 0;

  /// ★ 소모전 지표 (WORK_ORDER_ATTRITION 3-B) — 상점 층에 **도달한** 판 수.
  /// 「전투당 피해 %」는 개선될수록 깊은 층이 표본에 섞여 도로 올라가므로
  /// (검토 19) 소모전은 **판 단위**로 잰다.
  int shopReached = 0;

  /// 그 판들이 상점 층에 **들어설 때** 남아 있던 체력의 합
  /// (그 층의 전투 전 · 상점 회복 전 값이다)
  int shopHpSum = 0;

  /// 도달 층 합계 (완주면 스테이지 층수)
  int floorSum = 0;

  /// ★ 판 하나가 끝날 때까지 돈 **전투 턴의 총합** (WORK_ORDER_FINAL_TUNE 3-C 5번).
  /// 층수를 줄이면 한 판이 얼마나 짧아지는지는 전투당 턴이 아니라 **판당 턴**으로
  /// 봐야 한다 — 원칙 6(한 판 10분)이 재는 단위가 판이기 때문이다.
  /// **죽어서 끝난 판도 그대로 넣는다** (실제로 사람이 앉아 있던 시간이다).
  final List<int> runTurns = [];

  double get bossOnlyWinRate => bossOnlyRuns == 0 ? 0 : bossOnlyWins / bossOnlyRuns;

  double get clearRate => runs == 0 ? 0 : cleared / runs;

  /// 상점 층 도달률
  double get shopReachRate => runs == 0 ? 0 : shopReached / runs;

  /// 도달했을 때 남은 체력 비율. **도달하지 못한 판은 평균에서 뺀다** (3-B).
  double get shopHpShare =>
      shopReached == 0 ? 0 : shopHpSum / (profile.maxHp * shopReached);
  double get avgFloor => runs == 0 ? 0 : floorSum / runs;

  /// 한 판의 평균 턴 수 (완주·전멸을 모두 넣은 값)
  double get avgRunTurns => runTurns.isEmpty
      ? 0
      : runTurns.fold(0, (a, b) => a + b) / runTurns.length;

  int get variantTotal => variantCounts.values.fold(0, (a, b) => a + b);
}

/// 적 이름 접두어로 변종을 되짚는 표 (「굶주린 오크 전사」 → hungry).
Map<String, String> variantByPrefix(GameData data) => {
      for (final v in data.variants)
        if (v.namePrefix.isNotEmpty) v.namePrefix: v.id,
    };

String variantIdOf(Enemy e, Map<String, String> byPrefix) {
  for (final entry in byPrefix.entries) {
    if (e.name.startsWith('${entry.key} ')) return entry.value;
  }
  return kNormalVariantId;
}

/// 한 판: 스테이지 하나의 1층 ~ 마지막 층(보스).
///
/// 층 이벤트 중 **상점 회복만** 적용한다. 주문 보상은 프로필이 정한 덱을
/// 흐트러뜨리고, 유물 보상은 「유물 없음」 전제를 깬다.
void playStageRun(
  GameData data,
  ComboResult combo,
  Map<String, String> byPrefix,
  Random random,
) {
  const powers = RelicPowers();
  final maxHp = combo.profile.maxHp;
  var hp = maxHp;
  var charge = 0;
  var runTurns = 0;
  combo.runs++;

  for (var floor = 1; floor <= combo.stage.floors; floor++) {
    final event = floorEvent(floor, combo.stage.floors);
    if (event == FloorEvent.shop) {
      // ★ 상점 층에 「들어설 때」의 체력을 찍는다 (전투 전 · 상점 회복 전)
      combo.shopReached++;
      combo.shopHpSum += hp;
    }
    final battle = _floorBattle(
        data, combo, byPrefix, random, floor, hp, maxHp, charge);
    runBattle(battle, powers, random,
        tally: combo.tally, policy: combo.policy);
    combo.tally.addBattle(battle);
    runTurns += battle.turnCount;

    if (!battle.playerWon) {
      combo.floorSum += floor;
      combo.runTurns.add(runTurns);
      return;
    }
    hp = _hpAfterVictory(battle, event, maxHp);
    charge = battle.charge;
  }
  combo.cleared++;
  combo.floorSum += combo.stage.floors;
  combo.runTurns.add(runTurns);
}

/// 이 층에 설 적을 뽑아 전투를 조립한다 (변종 집계도 여기서 한다).
Battle _floorBattle(
  GameData data,
  ComboResult combo,
  Map<String, String> byPrefix,
  Random random,
  int floor,
  int hp,
  int maxHp,
  int charge,
) {
  final enemy = pickEnemy(
      data, combo.region, combo.stage, floor, combo.difficulty, random);
  if (!enemy.isBoss) {
    combo.variantCounts.update(variantIdOf(enemy, byPrefix), (v) => v + 1,
        ifAbsent: () => 1);
  }
  return Battle(
    enemy: enemy,
    // 덱이 있으므로 손패는 첫 턴 시작 때 채워진다
    hand: const [],
    deck: combo.deck,
    surgePool: data.surges,
    playerHp: hp,
    playerMaxHp: maxHp,
    maxMana: combo.profile.maxMana,
    relics: const RelicPowers(),
    random: random,
  )..charge = charge;
}

/// 승리 뒤의 체력 — **유물 회복 + 전투 승리 회복**을 더하고,
/// 상점 층이면 상점 회복까지 얹는다. 최대 체력을 넘지 않는다.
///
/// 전투 승리 회복은 **보스 층에서는 주지 않는다** (WORK_ORDER_ATTRITION 1-B).
/// 측정 20에서 채택돼 이제 게임의 규칙이므로 조건과 무관하게 언제나 준다.
int _hpAfterVictory(Battle battle, FloorEvent event, int maxHp) {
  const powers = RelicPowers();
  final winHeal = event != FloorEvent.boss ? battleWinHealAmount(maxHp) : 0;
  var hp = min(maxHp, battle.playerHp + powers.healAfterBattle + winHeal);
  if (event == FloorEvent.shop) {
    hp = min(maxHp, hp + shopHealAmount(maxHp));
  }
  return hp;
}

/// 보조 측정: 그 지역 보스와 **최대 체력·마력 축적 0에서 바로** 붙는다.
/// 층을 거치며 깎인 체력이 섞이지 않으므로 「보스 자체가 몇 턴짜리인가」만 남는다.
void playBossOnly(GameData data, ComboResult combo, Random random) {
  const powers = RelicPowers();
  final battle = Battle(
    enemy: pickEnemy(data, combo.region, combo.stage, combo.stage.floors,
        combo.difficulty, random),
    hand: const [],
    deck: combo.deck,
    surgePool: data.surges,
    playerHp: combo.profile.maxHp,
    playerMaxHp: combo.profile.maxHp,
    maxMana: combo.profile.maxMana,
    relics: powers,
    random: random,
  );
  combo.bossHp = battle.enemy.hp;
  runBattle(battle, powers, random,
      tally: combo.bossOnly, policy: combo.policy);
  combo.bossOnly.addBattle(battle);
  combo.bossOnlyRuns++;
  if (battle.playerWon) combo.bossOnlyWins++;
}
