/// 〔측정용 가정〕 성장 시스템 — 마법서 강화와 패시브 최대 체력.
/// WORK_ORDER_GROWTH_SIM 작업 1·2.
///
/// ⚠ **게임 코드가 아니다.** `lib/` 에는 마법서·강화·패시브가 아직 없다.
/// 측정 17에서 후반 완주율 0%의 원인이 「마법서 강화가 프로필에 없어서」로
/// 좁혀졌으므로, **강화 없음(하한)** 과 **전부 만강(상한)** 두 끝을 함께 재려고
/// 여기에 가정을 모아 둔다. 값의 출처는 `SPELL_CIRCLES.md` 4절과
/// `PASSIVE_TREE.md` 이며, 지시서가 지정한 표 그대로다.
library;

import 'package:surge_wizard/models/effect.dart';
import 'package:surge_wizard/models/spell.dart';

// ── 마법서 강화 (SPELL_CIRCLES.md 4절) ────────────────────

/// 강화 1단계당 오르는 위력 비율 — 원본 대비 합산이다
const double kUpgradeStepRatio = 0.10;

/// 강화 상한 = `kUpgradeCapBase − 서클` 단계 (1서클 10강 … 9서클 2강)
const int kUpgradeCapBase = 11;

/// 프로필에 씌울 강화 수준. **두 끝만 잰다** — 사이를 재면 원인이 다시 흐려진다.
enum BookUpgrade {
  /// 하한 — 측정 17과 같은 조건이라 직접 비교된다
  none('강화 없음(하한)'),

  /// 상한 — 성장 시스템을 최대로 갖춘 플레이어
  full('만강(상한)');

  const BookUpgrade(this.label);

  /// 표에 찍을 이름
  final String label;
}

/// 서클 [circle] 의 강화 상한 단계 수
int upgradeStepsOf(int circle) => kUpgradeCapBase - circle;

/// 서클 [circle] 을 [upgrade] 수준까지 올렸을 때의 위력 배수.
/// 만강 배수는 1서클 ×2.00 … 9서클 ×1.20 이다.
double upgradeMultiplier(int circle, BookUpgrade upgrade) =>
    upgrade == BookUpgrade.none
        ? 1.0
        : 1 + kUpgradeStepRatio * upgradeStepsOf(circle);

/// 강화가 위력과 **함께** 올리는 효과 (WORK_ORDER_HEAL_FIX 작업 1).
///
/// 저서클 유틸의 절대값(방어막 6·회복 5)이 그대로인 채 적 공격만 3.4 → 12로
/// 올라 후반에 무의미해졌다 (검토 18). 그래서 회복·방어막은 위력과 같은
/// 배수로 함께 올린다 — 마력방패 6 → 12 가 12지역 적 공격 12를 한 턴 막는다.
///
/// 나머지는 지시서가 명시적으로 제외했다. `check_bonus`·`extra_die` 는 3.4절
/// 확률표에 직접 개입하고, `delay_enemy` 는 지연 누적 상한 2턴(3.2절)과
/// 충돌하며, `mana_restore` 는 최대 마나가 3~5뿐이라 의미가 없다.
const Set<String> kUpgradableEffectTypes = {'heal', 'shield'};

/// 강화를 씌운 주문 사본.
///
/// **위력(`base_damage`)과 회복·방어막이 같은 배수로 오른다.**
/// `dc_modifier` 와 나머지 효과는 원본을 그대로 물려준다.
Spell upgradedSpell(Spell spell, int circle, BookUpgrade upgrade) {
  if (upgrade == BookUpgrade.none) return spell;
  final multiplier = upgradeMultiplier(circle, upgrade);
  return Spell(
    id: spell.id,
    name: spell.name,
    icon: spell.icon,
    element: spell.element,
    rarity: spell.rarity,
    baseDamage: (spell.baseDamage * multiplier).round(),
    dcModifier: spell.dcModifier,
    effect: upgradedEffect(spell.effect, multiplier),
    description: spell.description,
    surgeTags: spell.surgeTags,
  );
}

/// 효과 강화 — 회복·방어막만 **위력과 같은 배수·같은 반올림**으로 오른다.
GameEffect? upgradedEffect(GameEffect? effect, double multiplier) =>
    effect == null || !kUpgradableEffectTypes.contains(effect.type)
        ? effect
        : GameEffect(
            type: effect.type, value: (effect.value * multiplier).round());

// ── 패시브 최대 체력 (PASSIVE_TREE.md) ────────────────────

/// 만렙에서 패시브로 얻는다고 가정한 최대 체력 총량.
///
/// 트리 전체는 250p인데 99레벨로는 99p뿐이라 체력 노드를 전부 찍을 수 없다.
/// 그래서 **체력에만 몰지 않는 현실적인 빌드**를 가정해 +20으로 잡았다
/// (지시서 작업 2).
const int kPassiveMaxHpAtCap = 20;

/// 만렙
const int kMaxLevel = 99;

/// 레벨 [level] 시점의 패시브 최대 체력 — 1레벨 0에서 만렙 +20까지 선형이다.
int passiveMaxHp(int level) =>
    (kPassiveMaxHpAtCap * (level - 1) / (kMaxLevel - 1)).round();
