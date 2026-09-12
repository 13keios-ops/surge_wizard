/// 보스 등장 방식 3종 — 전조 · 호위 · 연전 (`GAME_DESIGN.md` 4.4절 · `ENEMIES.md` 4절).
///
/// 이것이 없으면 **하드와 데스가 수치 배율만 다른 똑같은 전투**다.
/// 난이도를 올려도 적이 더 아플 뿐 다르게 싸우지 않는다.
///
/// 🔴 **다중 적은 없다** — `Battle` 은 아직 적 한 마리다. 그래서 「호위」는
/// 진짜 호위 몹이 아니라 **이미 있는 적대 소환수**로 만든다. 다중 적이 들어오는
/// 날 올리면 된다 (`GAME_DESIGN.md` 4.4절 2026-09-13 정정).
library;

import '../models/enemy.dart';
import 'battle.dart';
import 'surge.dart';
import 'constants.dart';

/// 배율을 곱하고 반올림한다. 0이 되면 안 되는 값들이라 최소 1을 보장한다.
int _scaled(int value, double mul) {
  final v = (value * mul).round();
  return v < 1 ? 1 : v;
}

List<EnemyAction> _scalePattern(List<EnemyAction> pattern, double mul) => [
      for (final a in pattern)
        EnemyAction(action: a.action, value: _scaled(a.value, mul), label: a.label),
    ];

/// 이 층에서 **전조**(약화판 보스)를 만나나.
///
/// 지역 8~12에만 넣는다 — 층이 10층을 넘어 길어지는 구간이라 중간에 한 번
/// 마주칠 자리가 있다 (`ENEMIES.md` 4절). 난이도와 무관하게 전 난이도 공통이다.
bool isOmenFloor(int regionId, int floor) =>
    floor == 1 && regionId >= kOmenFirstRegion;

/// 전조로 나오는 **약화판 보스**.
///
/// 체력 [kOmenHpMul] · 공격 [kOmenAtkMul]. 🔴 **2페이즈를 쓰지 않는다** —
/// 40% 체력에서 다시 절반을 가르는 것은 의미가 없다.
Enemy omenOf(Enemy boss) => Enemy(
      id: boss.id,
      name: boss.name,
      icon: boss.icon,
      hp: _scaled(boss.hp, kOmenHpMul),
      tier: boss.tier,
      isBoss: boss.isBoss,
      variantId: boss.variantId,
      region: boss.region,
      pattern: _scalePattern(boss.pattern, kOmenAtkMul),
      phase2HpThreshold: null,
      phase2Pattern: null,
    );

/// 연전(데스)의 **2체째**. 체력만 [kSecondWaveHpMul] 로 줄이고 공격은 그대로다.
/// 2페이즈는 그대로 쓴다 — 줄어든 체력의 절반에서 열린다.
Enemy secondWaveOf(Enemy boss) {
  final hp = _scaled(boss.hp, kSecondWaveHpMul);
  return Enemy(
    id: boss.id,
    name: boss.name,
    icon: boss.icon,
    hp: hp,
    tier: boss.tier,
    isBoss: boss.isBoss,
    variantId: boss.variantId,
    region: boss.region,
    pattern: boss.pattern,
    phase2HpThreshold: boss.phase2HpThreshold == null ? null : hp ~/ 2,
    phase2Pattern: boss.phase2Pattern,
  );
}

/// 호위 소환수의 위력. **음수 = 적대**라는 소환수 규약을 따른다
/// (`surge.dart` `SummonUnit`).
///
/// 보스의 **일반 공격** 값에 [kEscortPowerMul] 을 곱한다. 강타(charge)는 세지만
/// 예고가 붙는 특별한 행동이라 기준으로 삼지 않는다.
int escortPower(Enemy boss) {
  final attack = boss.pattern
      .where((a) => a.action == 'attack')
      .fold<int>(0, (m, a) => a.value > m ? a.value : m);
  if (attack <= 0) return 0;
  return -_scaled(attack, kEscortPowerMul);
}

/// 이 전투에 호위가 붙나. 하드 난이도의 **보스 전투**에만 붙는다.
bool hasEscort(Enemy enemy, Difficulty difficulty) =>
    enemy.isBoss && difficulty == Difficulty.hard;

/// 이 전투가 연전인가. 데스 난이도의 **보스 전투**에만 붙는다.
bool hasSecondWave(Enemy enemy, Difficulty difficulty) =>
    enemy.isBoss && difficulty == Difficulty.death;

/// 연전: 적이 쓰러졌고 다음 물결이 있으면 **같은 전투 안에서** 이어 세운다.
///
/// 플레이어의 체력·마력·손패는 건드리지 않는다 — **회복 없이 이어진다.**
/// 적 대미지의 유일한 통로인 `Battle.dealToEnemy` 가 부른다.
extension BossWaves on Battle {
  /// 호위(하드)를 전투 시작에 세운다. 위력이 음수일 때만 붙는다
  /// (음수 = 적대라는 소환수 규약). 폭주 소환수와 **같은 목록**에 섞인다.
  void seedEscort(int power) {
    if (power >= 0) return;
    surge.summons.add(SummonUnit(power: power, turnsLeft: kEscortTurns));
  }

  void advanceWave() {
    final next = nextWave;
    if (enemyHp > 0 || next == null) return;
    enemy = next;
    enemyHp = next.hp;
    enemyShield = 0;
    nextWave = null;
  }
}
