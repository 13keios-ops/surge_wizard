/// 밸런싱 상수 모음.
/// 모든 수치의 출처는 GAME_DESIGN.md 이다. 코드 다른 곳에 숫자를 직접 쓰지 말 것.
library;

/// 갈라 낸 상수 파일은 여기서 그대로 내보낸다 — 쓰는 쪽은 이 파일만 import 한다.
export 'layout.dart';
export 'level.dart';

// ── 주사위 ──────────────────────────────────────────────

/// 주사위 개수 (3d6)
const int kDiceCount = 3;

/// 주사위 면 수
const int kDiceSides = 6;

// ── 시전 강도 (GAME_DESIGN v2 3.3절 — 2단계) ───────────

/// 3.4절 확률표 검증용 낮은 DC(7). 시전 강도가 아니다.
/// v2에서 「약하게」 강도는 삭제됐지만, 3.4절 확률표 검증
/// (test/check_test.dart · tool/mc_report.dart)이 DC 7·10·13 세 지점을
/// 대조하므로 DC 값으로서 계속 필요하다.
const int kDcLow = 7;

/// 보통 시전의 목표치(DC)
const int kDcNormal = 10;

/// 전력 시전의 목표치(DC)
const int kDcFull = 13;

/// 보통 시전의 위력 배율
const double kPowerNormal = 1.0;

/// 전력 시전의 위력 배율
const double kPowerFull = 3.0;

/// 보통 시전의 마나 비용 (v2에서 1 → 0)
const int kManaCostNormal = 0;

/// 전력 시전의 마나 비용
const int kManaCostFull = 2;

// ── 판정 결과 경계 (GAME_DESIGN 3.4절 확률표 기준) ─────

/// 대성공 경계: 판정값 ≥ DC + kCritMargin
///
/// 주의: 3.2절 본문은 +5라고 적혀 있으나 3.4절 확률표(밸런싱 기준)의
/// 수치는 +3으로 계산해야 정확히 일치한다. CLAUDE.md 절대 규칙 3번에 따라
/// 3.4절 표를 기준으로 +3을 채택했다. 상세는 BLOCKERS.md 판단 1 참조.
const int kCritMargin = 3;

/// 아슬아슬 경계: 판정값 ≥ DC − kGrazeMargin (이면서 DC 미만)
const int kGrazeMargin = 3;

// ── 판정 결과 효과 (GAME_DESIGN 3.2절) ─────────────────

/// 대성공 시 주문 위력 배율
const double kCritDamageMultiplier = 2.0;

/// 대성공 시 마나 환급량 — 시전 강도별 (GAME_DESIGN v2 3.3절)
const int kCritManaRefundNormal = 1;
const int kCritManaRefundFull = 2;

/// 대성공 시 적 행동 지연 턴 수
const int kCritEnemyDelay = 1;

/// 적 행동 지연의 누적 상한 (DICE_DESIGN 1절 개정 2).
/// 대성공·주문 효과·폭주 등 어느 경로로 들어와도 이 값을 넘지 않는다.
const int kMaxEnemyDelayStack = 2;

/// 아슬아슬 시 주문 위력 배율 (50%)
const double kGrazePowerMultiplier = 0.5;

/// 아슬아슬 반동: 체력 감소량
const int kGrazeBacklashHpLoss = 2;

/// 아슬아슬 반동의 종류 수 (체력/마나/봉인/앞당김 — 무작위 1개 선택)
const int kGrazeBacklashKinds = 4;

// ── 족보 (GAME_DESIGN 3.5절) ───────────────────────────

/// 페어 성립 시 판정값 보너스
const int kPairBonus = 3;

/// 뱀눈(1이 2개 이상) 성립 시 마력 축적 증가량
const int kSnakeEyesChargeGain = 2;

// ── 마력 축적 (GAME_DESIGN 3.7절) ──────────────────────

/// 실패/폭주 1회당 마력 축적 증가량
const int kFailChargeGain = 1;

/// 마력 축적 최대치. 이 값에 도달하면 다음 시전이 무조건 대성공.
const int kChargeThreshold = 3;

// ── 리롤 (GAME_DESIGN 3.6절) ───────────────────────────

/// 리롤 마나 비용 체증 (DICE_DESIGN 1절 개정 5).
/// n번째(0부터) 리롤의 비용이 kRerollManaCosts[n] 이다.
const List<int> kRerollManaCosts = [1, 2, 3];

/// [rerollIndex]번째(0부터) 리롤에 드는 마나.
/// 메타 강화로 리롤 횟수가 표보다 늘어나면 마지막 값을 유지한다.
int rerollManaCost(int rerollIndex) => rerollIndex < kRerollManaCosts.length
    ? kRerollManaCosts[rerollIndex]
    : kRerollManaCosts.last;

/// 한 판정당 최대 리롤 횟수
const int kMaxRerollsPerCheck = 3;

// ── 폭주 효과 (BLOCKERS.md 판단 6 규약) ────────────────

/// 소환수(summon_ally)가 유지되는 턴 수
const int kSummonDuration = 3;

/// 역류(self_damage_spell)의 최저 기준 위력 (SURGE_DESIGN 4절 4번).
/// base_damage 가 0인 보조 주문(마력방패·치유 약초)이 「실패해도 안전한」
/// 지배 전략이 되는 것을 막는다.
const int kBacklashMinPower = 4;

/// 백분율 효과값(self_damage_spell 의 value)의 분모
const int kPercentBase = 100;

/// 한 번의 폭주에서 발생한 자해 피해 「총합」의 상한 (최대 체력 대비 비율).
/// SURGE_DESIGN 4절 2번 — 개별 효과가 아니라 폭주 전체에 건다.
const double kSurgeSelfDamageMaxRatio = 0.4;

// ── 런 진행 — 지역·스테이지 구조 (GAME_DESIGN v2 6절) ──

/// 난이도 3단계. 지역·스테이지와 함께 한 판을 시작할 때 고른다.
enum Difficulty { normal, hard, death }

/// 난이도 배율 한 벌.
/// HP를 공격보다 크게 올린다 — 공격을 올리면 즉사가 늘어 좌절이 되고,
/// HP를 올리면 「불가능이 아니라 오래 걸림」이 된다 (GAME_DESIGN v2 6.2절).
class DifficultyScale {
  const DifficultyScale({
    required this.hpMul,
    required this.atkMul,
    required this.rewardMul,
    required this.expMul,
  });

  /// 적 체력 배율
  final double hpMul;

  /// 적 공격 배율
  final double atkMul;

  /// 보상 배율 (HP 배율보다 커야 어려운 난이도를 도는 이유가 생긴다)
  final double rewardMul;

  /// 경험치 배율
  final double expMul;
}

/// 난이도별 배율표. 보상 배율은 아직 지급에 안 붙었다 (WORK_ORDER_PROGRESSION 2-C).
/// **경험치 배율은 GROWTH.md 1.3절 확정값 1.5 / 2.0** — 옛 1.6 / 2.5는 임시값이었다.
const Map<Difficulty, DifficultyScale> kDifficultyScales = {
  Difficulty.normal:
      DifficultyScale(hpMul: 1.0, atkMul: 1.0, rewardMul: 1.0, expMul: 1.0),
  Difficulty.hard:
      DifficultyScale(hpMul: 1.5, atkMul: 1.25, rewardMul: 1.8, expMul: 1.5),
  Difficulty.death:
      DifficultyScale(hpMul: 2.2, atkMul: 1.5, rewardMul: 3.0, expMul: 2.0),
};

/// 난이도별 보스 변종 — 유저가 화면만 보고 난이도를 안다 (ENEMIES.md 4절)
const Map<Difficulty, String> kBossVariantIds = {
  Difficulty.normal: 'normal',
  Difficulty.hard: 'shadow',
  Difficulty.death: 'ancient',
};

/// 「고대의」 변종 id — 난이도 보정이 비중을 올리는 대상 (ENEMIES.md 5.3절)
const String kAncientVariantId = 'ancient';

/// 「기본」 변종 id — 난이도 보정이 비중을 먼저 빼는 대상
const String kNormalVariantId = 'normal';

/// 난이도별 「고대의」 가중치 가산량(%p).
/// 같은 양을 「기본」에서 빼고, 모자라면 다음으로 비중이 큰 변종에서 마저 뺀다.
/// 금빛 적이 섞이는 것이 「난이도가 올랐다」는 가장 빠른 신호다 (ENEMIES.md 5.3절).
const Map<Difficulty, int> kAncientVariantBonus = {
  Difficulty.normal: 0,
  Difficulty.hard: 10,
  Difficulty.death: 20,
};

/// 난이도 표시 이름
const Map<Difficulty, String> kDifficultyLabels = {
  Difficulty.normal: '보통',
  Difficulty.hard: '하드',
  Difficulty.death: '데스',
};

// ── 기본 진입 지점 ─────────────────────────────────────
// 화면에서는 이제 유저가 지역·스테이지·난이도를 직접 고른다(지시서 G 완료).
// 이 세 상수는 **화면 없이 도는 쪽**의 기본값으로 남는다 —
// RunState 의 기본 인자, 옛 저장본 복원, tool/sim_core.dart 의 측정 기준점.

const int kEntryRegionId = 1;
const int kEntryStageIndex = 1;
const Difficulty kEntryDifficulty = Difficulty.normal;

// ── 층 이벤트 배치 (WORK_ORDER_PROGRESSION 3-C) ────────

/// 한 층에서 전투 뒤에 일어나는 일
enum FloorEvent { battle, spellReward, relicReward, shop, boss }

/// 주문 보상이 나오는 층 간격
const int kSpellRewardInterval = 3;

/// 스테이지 층수가 3~10으로 가변이라 고정 층 번호를 쓸 수 없다.
/// 비율 규칙으로 배치하고, 겹치면 위에서부터 우선한다.
/// 층수가 3인 스테이지에는 유물 보상이 없다 — 도입 지역은 짧다 (정상 동작).
FloorEvent floorEvent(int floor, int floors) {
  if (floor == floors) return FloorEvent.boss;
  if (floor == floors - 1) return FloorEvent.shop;
  if (floor == (floors / 2).round()) return FloorEvent.relicReward;
  if (floor % kSpellRewardInterval == 0) return FloorEvent.spellReward;
  return FloorEvent.battle;
}

/// 스테이지 순번을 로마 숫자로 (「마나의 숲 I」). 지역당 최대 10 스테이지다
const List<String> kStageRomans = [
  'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X',
];

/// 상점 회복 비율 — 최대 체력의 30% (WORK_ORDER_HEAL_FIX 작업 2).
///
/// 옛 고정값 10은 최대 체력 20 시절의 50%였는데, 후반 체력 86에서는 12%밖에
/// 안 돼 층 사이 회복이 사실상 사라졌다 (검토 18). 그래서 비율로 바꿨다.
const double kShopHealRatio = 0.30;

/// 최대 체력 [maxHp] 일 때 상점이 회복시키는 양.
/// 화면·전투·시뮬레이터가 모두 이 하나를 쓴다 (값이 어긋나지 않게).
int shopHealAmount(int maxHp) => (maxHp * kShopHealRatio).round();

/// 전투 승리 회복 비율 — 최대 체력의 12% (WORK_ORDER_ATTRITION 작업 1).
///
/// 상점은 한 판에 한 번뿐이라 층마다 쌓이는 소모를 못 따라간다 (검토 19).
/// 그래서 **일반 전투를 이길 때마다** 같은 처방을 조금씩 넣는다.
/// 초반에는 체력이 거의 안 깎여 이미 만피라 효과가 없고, 후반에만 듣는다.
const double kBattleWinHealRatio = 0.12;

/// 최대 체력 [maxHp] 일 때 전투 승리로 회복하는 양.
/// **보스 층에서는 주지 않는다** — 보스를 깨면 스테이지가 끝나 의미가 없다.
/// 유물 「전투 후 회복」(healAfterBattle)을 대체하지 않고 **그 위에 더한다**.
int battleWinHealAmount(int maxHp) => (maxHp * kBattleWinHealRatio).round();

/// 보상 선택지 수 (3장/3개 중 1택)
const int kRewardChoiceCount = 3;

/// 시작 손패 주문 id (GAME_DESIGN 4.2절)
const List<String> kStarterSpellIds = [
  'fireball', 'frost_arrow', 'mana_shield',
];

// ── 메타 성장 (GAME_DESIGN 5.5절) ──────────────────────
// 4·5단계 비용(170, 230)과 리롤 2단계 비용(300)은 기획서에 없어
// 증가폭을 연장한 권장안이다 — BLOCKERS.md 판단 11.

/// 최대 체력 강화: 단계당 +3, 단계별 비용
const int kMetaHpBonusPerLevel = 3;
const List<int> kMetaHpCosts = [50, 80, 120, 170, 230];

/// 최대 마나 강화: 단계당 +1, 단계별 비용
const List<int> kMetaManaCosts = [100, 200];

/// 시작 리롤 강화: 단계당 +1, 단계별 비용
const List<int> kMetaRerollCosts = [150, 300];

/// 시작 유물(무작위 common 1개) 비용, 1단계뿐
const List<int> kMetaStartRelicCosts = [300];

/// 신규 주문(epic) 해금 비용 (각각)
const int kSpellUnlockCost = 80;

/// 마력 결정: 돌파한 층당 지급량
const int kCrystalPerFloor = 5;

/// 마력 결정: 보스 클리어 보너스
const int kBossClearCrystalBonus = 50;

// ── 플레이어 초기 스탯 (GAME_DESIGN 4.2절) ─────────────

/// 시작 체력
const int kPlayerStartHp = 20;

/// 시작 최대 마나
const int kPlayerStartMaxMana = 3;

/// 턴 시작 시 마나 회복량
const int kManaRegenPerTurn = 1;

/// 손패 주문 슬롯 수
const int kHandSize = 3;

