/// 적 조립: 기본 적 데이터에 지역 배율·변종 배율·난이도 배율을 곱해
/// 실제로 화면에 설 적을 만든다 (ENEMIES.md 5.2·6절).
///
/// 데이터를 156줄 만들지 않는다. 변종 6줄을 규칙으로 두고 런타임에 곱한다.
library;

import 'dart:math';

import '../models/enemy.dart';
import '../models/enemy_variant.dart';
import 'constants.dart';

/// 배율을 곱하고 반올림한다. 0이 되면 안 되는 값들이라 최소 1을 보장한다.
int _scaled(int value, double mul) => max(1, (value * mul).round());

/// 행동 목록에 배율을 적용한다.
/// 공격·강타에는 공격 배율을, 방어·회복에는 체력 배율을 곱한다
/// (방어와 회복은 화력이 아니라 생존력이므로 — ENEMIES.md 5.2절).
List<EnemyAction> _scalePattern(
        List<EnemyAction> pattern, double atkMul, double hpMul) =>
    [
      for (final a in pattern)
        EnemyAction(
          action: a.action,
          value: _scaled(
              a.value, a.action == 'attack' || a.action == 'charge'
                  ? atkMul
                  : hpMul),
          label: a.label,
        ),
    ];

/// 최종 적을 만든다. **원본 [base]는 건드리지 않고 새 인스턴스를 돌려준다.**
///
/// 최종 수치 = 기본값 × 지역 배율 × 변종 배율 × 난이도 배율.
/// **지역 배율은 체력([regionHpScale])과 공격([regionAtkScale])이 따로다** —
/// tier가 이미 공격을 올리고 있어 하나로 묶으면 일반 적이 보스보다 아프다
/// (ENEMIES.md 6절, 2026-09-02 개정).
///
/// 단 **보스에는 지역 배율을 둘 다 곱하지 않는다** — ENEMIES.md 3절 표가 최종값이다.
/// 변종·난이도 배율은 보스에도 그대로 붙는다.
Enemy buildEnemy(
  Enemy base,
  EnemyVariant variant,
  double regionHpScale,
  double regionAtkScale,
  Difficulty difficulty,
) {
  final d = kDifficultyScales[difficulty]!;
  final regionHp = base.isBoss ? 1.0 : regionHpScale;
  final regionAtk = base.isBoss ? 1.0 : regionAtkScale;
  final hpMul = regionHp * variant.hpMul * d.hpMul;
  final atkMul = regionAtk * variant.atkMul * d.atkMul;

  final hp = _scaled(base.hp, hpMul);
  return Enemy(
    id: base.id,
    name: variant.namePrefix.isEmpty
        ? base.name
        : '${variant.namePrefix} ${base.name}',
    icon: base.icon,
    hp: hp,
    tier: base.tier,
    isBoss: base.isBoss,
    variantId: variant.id,
    region: base.region,
    pattern: _scalePattern(base.pattern, atkMul, hpMul),
    // HP를 올렸으면 임계값도 같이 올려야 2페이즈가 열린다 (ENEMIES.md 3절)
    phase2HpThreshold: base.phase2HpThreshold == null ? null : hp ~/ 2,
    phase2Pattern: base.phase2Pattern == null
        ? null
        : _scalePattern(base.phase2Pattern!, atkMul, hpMul),
  );
}
