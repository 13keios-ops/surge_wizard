/// 시뮬레이션 집계기. sim_core.dart 가 전투를 돌리며 여기에 숫자를 쌓는다.
///
/// ⚠ 이 파일은 **측정만 한다.** 밸런스 수치·확률·데이터를 건드리지 않는다.
/// 대부분의 값은 `lib/` 수정 없이 도구 쪽에서 셀 수 있다. 유일한 예외가
/// 폭주 자해 상한인데, 그건 SurgeSystem 안에서 잘리므로 Battle 의 통계 블록
/// (`surgeSelfDamageRaw` / `surgeSelfDamageApplied`)을 읽어 쓴다.
library;

import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/check.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/core/dice.dart';

/// 시전 직전에 찍어 두는 스냅숏. 시전 뒤 값과 빼서 「이번 시전 1회분」을 얻는다.
class CastProbe {
  CastProbe._(this.grades, this.selfRaw, this.selfApplied, this.chargeForced);

  /// 시전 직전의 등급 카운터 사본
  final Map<CheckGrade, int> grades;

  /// 시전 직전의 자해 누적 (상한 전 / 상한 후)
  final int selfRaw;
  final int selfApplied;

  /// 이번 시전이 마력 축적 3칸에 의한 「확정 대성공」인가.
  /// resolveCheck 와 같은 조건을 시전 전에 미리 본다.
  final bool chargeForced;

  /// 이번 시전에 걸린 주문의 DC 보정 (spell.dcModifier)
  int dcModifier = 0;

  /// 주사위를 굴리기 「전」에 주사위 추가 효과가 걸려 있었는가.
  /// 굴림 자체가 4개 중 상위 3개가 되므로 3d6 분포가 아니다.
  bool extraDie = false;

  /// 3.4절 확률표와 같은 조건(보정 0 · 3d6 · 확정 대성공 아님)인가.
  /// pendingCheckBonus 는 castSpell 이 소비하므로 시전 직전 값을 본다.
  bool get isUnmodified =>
      !chargeForced && !extraDie && dcModifier == 0 && _pendingBonus == 0;

  late final int _pendingBonus;

  factory CastProbe.of(Battle b) {
    final probe = CastProbe._(
      Map.of(b.gradeCounts),
      b.surgeSelfDamageRaw,
      b.surgeSelfDamageApplied,
      b.charge >= kChargeThreshold,
    );
    return probe.._pendingBonus = b.pendingCheckBonus;
  }
}

/// 판정 등급·폭주·굴림 집계 (Battle의 통계 카운터를 그대로 합산)
class Tally {
  int crit = 0, success = 0, graze = 0, fail = 0, surge = 0, casts = 0;

  /// 실제로 시전된 주문 id별 횟수.
  /// 덱에서 손패를 뽑게 된 뒤 「무엇이 손에 잡혀 실제로 쓰였나」를 보려고 센다.
  final Map<String, int> castSpellCounts = {};

  /// 시전 강도별 횟수 (개정 효과 확인용 — 전력을 실제로 쓰는지)
  final Map<CastIntensity, int> intensityCasts = {
    for (final it in CastIntensity.values) it: 0,
  };

  // ── 굴림·리롤 (지시서 2-A) ──

  /// 굴림 총 횟수 = 판정마다 (초기 굴림 1 + 리롤 횟수)
  int rolls = 0;

  /// 판정 횟수 (= 주사위를 새로 굴려 시전을 시도한 횟수)
  int checks = 0;

  /// 리롤 총 횟수 (무료 포함)
  int rerolls = 0;

  /// 그중 마나를 낸 리롤
  int paidRerolls = 0;

  /// 전투 하나가 끝날 때마다 그 전투의 굴림 횟수를 담는다
  final List<int> rollsPerBattle = [];

  /// 200턴 안전장치(kMaxBattleTurns)에 걸려 끝난 전투 수.
  /// 「적을 깎을 주문이 없어 교착했다」는 뜻이므로 **0이어야 한다**
  /// (WORK_ORDER_DECK_FIX 4-E).
  int turnLimitBattles = 0;

  // ── 턴 수 (지시서 2-B) ──

  final List<int> normalTurns = [];
  final List<int> bossTurns = [];

  // ── 피해·방어막·회복 (WORK_ORDER_HEAL_FIX 4-B·4-C) ──

  /// 방어막이 막아 낸 피해 총량
  int shieldAbsorbed = 0;

  /// 방어막을 뚫고 **실제로 체력을 깎은** 피해 총량 (= 4-B의 「받은 피해」)
  int hpDamageTaken = 0;

  /// 그중 일반 전투에서만 받은 몫. 4-B 표는 일반 전투 기준이라 따로 센다
  int normalHpDamage = 0;

  /// 전투 중 실제로 회복된 체력 총량 (주문 회복·유물 회복)
  int healed = 0;

  int get battles => normalTurns.length + bossTurns.length;

  // ── 등급 분포 (지시서 2-C) ──

  /// 시전 1회의 「원래 판정」 등급만 강도별로 센다.
  /// 폭주 force_reroll 의 재적용분은 여기서 빠진다 (아래 addCast 참조).
  final Map<CastIntensity, Map<CheckGrade, int>> primaryGrades = {
    for (final it in CastIntensity.values)
      it: {for (final g in CheckGrade.values) g: 0},
  };

  /// 위와 같되 「마력 축적에 의한 확정 대성공」을 뺀 것.
  /// 3.4절 확률표와 직접 비교할 수 있는 쪽은 이것이다.
  final Map<CastIntensity, Map<CheckGrade, int>> pureGrades = {
    for (final it in CastIntensity.values)
      it: {for (final g in CheckGrade.values) g: 0},
  };

  /// 위와 같되 3.4절 확률표와 **완전히 같은 조건**만 남긴 것.
  /// 주문 DC 보정 0 · 주문 check_bonus 없음 · 주사위 추가 없음 · 확정 대성공 아님.
  /// 정합성 검사(측정 코드가 맞는가)는 이 표로 한다.
  final Map<CastIntensity, Map<CheckGrade, int>> unmodifiedGrades = {
    for (final it in CastIntensity.values)
      it: {for (final g in CheckGrade.values) g: 0},
  };

  /// 마력 축적 3칸으로 확정 대성공이 된 시전 수
  int chargeForcedCasts = 0;

  /// 폭주 force_reroll 로 등급이 한 번 더 적용된 횟수
  int forcedRerollApplies = 0;

  /// 시전에 쓰인 주문의 DC 보정별 횟수 (봇이 어떤 주문을 고르는지 보여준다)
  final Map<int, int> dcModifierCasts = {};

  // ── 폭주 갈래 (지시서 2-D) ──

  final Map<String, int> surgeCategories = {};

  // ── 폭주 자해 상한 (지시서 2-E) ──

  /// 자해가 1 이상 발생한 폭주 수
  int selfDamageSurges = 0;

  /// 그중 상한에 잘린 폭주 수
  int selfDamageCapped = 0;

  /// 상한 전 / 상한 후 자해 합계
  int selfDamageRawSum = 0;
  int selfDamageAppliedSum = 0;

  int get intensityTotal => intensityCasts.values.fold(0, (a, b) => a + b);

  int get resolutions => crit + success + graze + fail;

  /// 상한 때문에 사라진 피해 총량
  int get selfDamageLostSum => selfDamageRawSum - selfDamageAppliedSum;

  void addIntensity(CastIntensity it) =>
      intensityCasts.update(it, (v) => v + 1);

  /// 시전에 실제로 쓰인 주문을 센다 (덱 측정용)
  void addCastSpell(String spellId) =>
      castSpellCounts.update(spellId, (v) => v + 1, ifAbsent: () => 1);

  void addBattle(Battle b) {
    crit += b.gradeCounts[CheckGrade.critSuccess] ?? 0;
    success += b.gradeCounts[CheckGrade.success] ?? 0;
    graze += b.gradeCounts[CheckGrade.graze] ?? 0;
    fail += b.gradeCounts[CheckGrade.failure] ?? 0;
    surge += b.surgeCount;
    casts += b.castCount;
  }

  /// 판정 1회분의 굴림·리롤을 더한다. rollWithRerolls 가 끝난 시점에 부른다.
  void addRolls(DicePool pool) {
    checks++;
    rolls += 1 + pool.rerollCount;
    rerolls += pool.rerollCount;
    paidRerolls += pool.paidRerollCount;
  }

  /// 시전 1회분의 등급·폭주·자해를 [probe] 와의 차이로 뽑아 더한다.
  void addCast(Battle b, CastIntensity it, CastProbe probe) {
    final delta = <CheckGrade, int>{};
    b.gradeCounts.forEach((g, c) {
      final d = c - (probe.grades[g] ?? 0);
      if (d > 0) delta[g] = d;
    });
    _addGrades(delta, it, probe);
    _addSurge(b);
    _addSelfDamage(b, probe);
  }

  /// 「원래 판정」의 등급을 고른다.
  ///
  /// 한 시전에서 등급이 두 번 기록되는 유일한 경로가 폭주 `force_reroll` 이고,
  /// 그 재굴림은 실패면 아예 기록되지 않는다. 따라서 delta 에 실패가 있으면
  /// 그것이 원래 판정이고, 나머지는 재적용분이다.
  void _addGrades(
      Map<CheckGrade, int> delta, CastIntensity it, CastProbe probe) {
    if (delta.isEmpty) return;
    final primary = delta.containsKey(CheckGrade.failure)
        ? CheckGrade.failure
        : delta.keys.first;
    final total = delta.values.fold(0, (a, b) => a + b);
    forcedRerollApplies += total - 1;
    primaryGrades[it]!.update(primary, (v) => v + 1);
    if (probe.chargeForced) {
      chargeForcedCasts++;
    } else {
      pureGrades[it]!.update(primary, (v) => v + 1);
    }
    if (probe.isUnmodified) unmodifiedGrades[it]!.update(primary, (v) => v + 1);
    dcModifierCasts.update(probe.dcModifier, (v) => v + 1, ifAbsent: () => 1);
  }

  void _addSurge(Battle b) {
    final s = b.surge.lastSurge;
    if (s == null) return;
    surgeCategories.update(s.category, (v) => v + 1, ifAbsent: () => 1);
  }

  void _addSelfDamage(Battle b, CastProbe probe) {
    final raw = b.surgeSelfDamageRaw - probe.selfRaw;
    final applied = b.surgeSelfDamageApplied - probe.selfApplied;
    if (raw <= 0) return;
    selfDamageSurges++;
    selfDamageRawSum += raw;
    selfDamageAppliedSum += applied;
    if (raw > applied) selfDamageCapped++;
  }

  /// 전투 하나가 끝났을 때의 집계 (굴림 횟수·턴 수·피해·회복).
  void endBattle(Battle b, int rollsThisBattle) {
    rollsPerBattle.add(rollsThisBattle);
    (b.enemy.isBoss ? bossTurns : normalTurns).add(b.turnCount);
    shieldAbsorbed += b.shieldAbsorbed;
    hpDamageTaken += b.hpDamageTaken;
    healed += b.healedTotal;
    if (!b.enemy.isBoss) normalHpDamage += b.hpDamageTaken;
  }
}
