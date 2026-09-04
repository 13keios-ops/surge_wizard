/// 〔측정용 가정〕 성장 프로필 — WORK_ORDER_SIM2 작업 2.
///
/// ⚠ **게임 코드가 아니다.** 레벨·패시브·장비가 아직 없어 플레이어가 체력 20에
/// 머무는데, 지역 12 일반 적은 HP 225다. 그대로 재면 후반이 전부 전멸이라
/// 아무것도 알 수 없다. 그래서 「이 정도로 컸다고 치자」는 발판을 깔고 잰다.
///
/// 값의 출처는 지시서가 지정한 표 그대로다 (STAGES.md 4절 권장 레벨 기준,
/// 체력은 Lv1 20 → Lv99 70 선형 보간, 서클은 SPELL_CIRCLES.md 부록 슬롯 개방표).
/// **설계 확정이 아니다.** 곡선을 고칠지 적을 고칠지는 기획 창이 정한다.
///
/// 여기에 **패시브 최대 체력과 마법서 강화**가 얹힌다
/// (WORK_ORDER_GROWTH_SIM 작업 1·2 — 계산은 `measure_growth.dart`).
library;

import 'dart:convert';
import 'dart:io';

import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/models/spell.dart';

import 'measure_growth.dart';

/// 지역 하나에 들어설 때의 가정 성장치
class GrowthProfile {
  const GrowthProfile({
    required this.regionId,
    required this.level,
    required this.baseMaxHp,
    required this.topCircle,
    required this.maxMana,
  });

  /// 지역 번호 1~12
  final int regionId;

  /// STAGES.md 4절의 진입 권장 레벨 (표시·근거용)
  final int level;

  /// 패시브를 빼고 본 최대 체력 — 측정 17까지 쓰던 값이다
  final int baseMaxHp;

  /// 패시브 트리에서 얻는다고 가정한 최대 체력 (작업 2)
  int get passiveHp => passiveMaxHp(level);

  /// 실제로 전투에 들어가는 최대 체력 — 폭주 자해 상한도 이 값에서 나온다.
  /// **강화 하한·상한 두 열에 똑같이 적용한다** (변인은 강화 하나뿐이다).
  int get maxHp => baseMaxHp + passiveHp;

  /// 이 시점에 손에 들 수 있는 최고 서클
  final int topCircle;

  /// 최대 마나
  final int maxMana;
}

/// 지시서 작업 2의 표를 그대로 옮긴 것. 순서는 지역 1~12.
const List<GrowthProfile> kGrowthProfiles = [
  GrowthProfile(regionId: 1, level: 1, baseMaxHp: 20, topCircle: 1, maxMana: 3),
  GrowthProfile(regionId: 2, level: 8, baseMaxHp: 24, topCircle: 1, maxMana: 3),
  GrowthProfile(regionId: 3, level: 16, baseMaxHp: 28, topCircle: 2, maxMana: 3),
  GrowthProfile(regionId: 4, level: 25, baseMaxHp: 32, topCircle: 3, maxMana: 3),
  GrowthProfile(regionId: 5, level: 35, baseMaxHp: 37, topCircle: 4, maxMana: 4),
  GrowthProfile(regionId: 6, level: 45, baseMaxHp: 42, topCircle: 5, maxMana: 4),
  GrowthProfile(regionId: 7, level: 55, baseMaxHp: 48, topCircle: 5, maxMana: 4),
  GrowthProfile(regionId: 8, level: 65, baseMaxHp: 53, topCircle: 6, maxMana: 4),
  GrowthProfile(regionId: 9, level: 72, baseMaxHp: 56, topCircle: 6, maxMana: 5),
  GrowthProfile(regionId: 10, level: 80, baseMaxHp: 60, topCircle: 7, maxMana: 5),
  GrowthProfile(regionId: 11, level: 87, baseMaxHp: 64, topCircle: 7, maxMana: 5),
  GrowthProfile(regionId: 12, level: 94, baseMaxHp: 67, topCircle: 8, maxMana: 5),
];

GrowthProfile profileOf(int regionId) =>
    kGrowthProfiles.firstWhere((p) => p.regionId == regionId);

/// 폭주 자해 상한 — 최대 체력의 40% (SurgeSystem 과 같은 식)
int selfDamageCapOf(int maxHp) => (maxHp * kSurgeSelfDamageMaxRatio).floor();

/// `circle` 은 Spell 모델에 없는 필드라 JSON 을 직접 읽는다
/// (test/spell_circle_test.dart 도 같은 방식이다).
Map<String, int> loadSpellCircles() {
  final raw = File('assets/data/spells.json').readAsStringSync();
  return {
    for (final s in (jsonDecode(raw) as List).cast<Map<String, dynamic>>())
      s['id'] as String: (s['circle'] as num).toInt(),
  };
}

/// ── 덱 구성 (WORK_ORDER_DECK_SIM 작업 2) ─────────────────────────
///
/// 측정 14·15는 손패를 「그 지역 최고 서클 3장」으로 고정했는데, 그건 실제
/// 규칙이 아니다. v2 4.2절은 **덱에서 매 턴 3장을 뽑는다**고 정했으므로
/// 여기서는 지역별 **덱**을 만든다.

/// 지역별 서클 슬롯 수 — [0]이 1서클, 마지막 칸이 가장 높은 서클이다.
/// `SPELL_CIRCLES.md` 부록 개방표에서 **그 지역 진입 레벨 이하의 마지막 행**.
const Map<int, List<int>> kDeckSlots = {
  1: [3],
  2: [3],
  3: [3, 1],
  4: [3, 2, 1],
  5: [4, 2, 1, 1],
  6: [4, 3, 2, 1, 1],
  7: [4, 3, 2, 1, 1],
  8: [4, 3, 2, 2, 1, 1],
  9: [4, 3, 2, 2, 1, 1],
  10: [5, 3, 3, 2, 2, 1, 1],
  11: [5, 3, 3, 2, 2, 1, 1],
  12: [5, 4, 3, 2, 2, 1, 1, 1],
};

/// 1서클 칸을 채우는 순서 — **「위력을 지킨 유틸」 먼저**
/// (WORK_ORDER_DECK_FIX 작업 2 · `SPELL_CIRCLES.md` 1서클 절).
///
/// 앞의 셋은 1서클 공격 주문과 **위력이 같으면서(5) 효과가 덤인** 주문이라
/// 덱의 주력이 된다. 위력 0인 두 장(치유 약초·마력방패)을 먼저 넣으면
/// 3칸짜리 초기 덱에 적을 깎을 주문이 한 장만 남아 **전투가 교착한다**
/// (측정 16에서 200턴 안전장치가 실제로 걸렸다).
/// 1서클 슬롯이 5칸이 되는 후반에는 위력 0 두 장도 자연히 들어온다.
const List<String> kCircle1Priority = [
  'cinder_shield', // 위력 5 + 방어막 4
  'chill_touch', // 위력 5 + 적 지연 1
  'soul_nip', // 위력 5 + 회복 2
  'healing_herb', // 위력 0 + 회복 5
  'mana_shield', // 위력 0 + 방어막 6
];

/// 「유틸」로 세는 효과 — 보고서의 유틸 비중 표가 쓴다
const Set<String> kUtilityEffectTypes = {
  'heal',
  'shield',
  'delay_enemy',
  'mana_restore',
  'check_bonus',
  'extra_die',
};

bool isUtilitySpell(Spell s) =>
    s.effect != null && kUtilityEffectTypes.contains(s.effect!.type);

/// 지역 [regionId]에 들어설 때의 덱. 슬롯표대로 서클을 섞어 만든다.
/// [upgrade] 는 마법서 강화 수준이다. **뽑기는 언제나 원본 위력으로 하고
/// 강화는 뽑은 뒤에 씌운다** — 그래야 하한과 상한의 덱 구성이 완전히 같아
/// 「강화만 달라졌다」는 비교가 성립한다.
List<Spell> profileDeck(List<Spell> all, Map<String, int> circles, int regionId,
    {BookUpgrade upgrade = BookUpgrade.none}) {
  final slots = kDeckSlots[regionId]!;
  return [
    for (var i = 0; i < slots.length; i++)
      for (final s in _pickCircle(all, circles, i + 1, slots[i]))
        upgradedSpell(s, i + 1, upgrade),
  ];
}

/// 서클 하나에서 [count]장을 고른다.
/// 1서클은 유틸 우선 순서, 2서클 이상은 위력 큰 순 + 속성이 겹치지 않게.
List<Spell> _pickCircle(
    List<Spell> all, Map<String, int> circles, int circle, int count) {
  final ordered = _circleOrder(all, circles, circle);
  final picked = <Spell>[];
  final usedElements = <String>{};
  for (final s in ordered) {
    if (picked.length >= count) break;
    // 1서클은 「유틸 먼저」가 우선이라 속성 제약을 걸지 않는다
    if (circle == 1 || usedElements.add(s.element)) picked.add(s);
  }
  // 속성 제약 때문에 자리가 남으면 순서대로 메운다 (지금 데이터에선 안 걸린다)
  for (final s in ordered) {
    if (picked.length >= count) break;
    if (!picked.contains(s)) picked.add(s);
  }
  return picked;
}

/// 한 서클 안의 후보를 고르는 순서대로 줄 세운다.
/// 기본은 위력 큰 순(같으면 id 순 — 실행할 때마다 같은 덱이 나온다),
/// 1서클만 kCircle1Priority 를 앞에 세운다.
List<Spell> _circleOrder(
    List<Spell> all, Map<String, int> circles, int circle) {
  final pool = all.where((s) => circles[s.id] == circle).toList()
    ..sort((a, b) {
      final byPower = b.baseDamage.compareTo(a.baseDamage);
      return byPower != 0 ? byPower : a.id.compareTo(b.id);
    });
  if (circle != 1) return pool;
  final byId = {for (final s in pool) s.id: s};
  return [
    for (final id in kCircle1Priority)
      if (byId.containsKey(id)) byId[id]!,
    for (final s in pool)
      if (!kCircle1Priority.contains(s.id)) s,
  ];
}
