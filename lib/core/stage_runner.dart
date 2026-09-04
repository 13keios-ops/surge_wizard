/// 스테이지 한 층에 세울 적을 뽑는다.
/// 마지막 층은 지역 보스, 그 밖은 지역의 tier 풀·변종 가중치 추첨이다
/// (ENEMIES.md 4·5.3·6절).
library;

import 'dart:math';

import '../data/parser.dart';
import '../models/enemy.dart';
import '../models/enemy_variant.dart';
import '../models/region.dart';
import '../models/stage.dart';
import 'constants.dart';
import 'enemy_builder.dart';

/// 가중치 맵에서 키 하나를 뽑는다. 가중치 합이 0이면 첫 키를 돌려준다.
String weightedPick(Map<String, int> weights, Random random) {
  final total = weights.values.fold(0, (a, b) => a + b);
  if (total <= 0) return weights.keys.first;
  var roll = random.nextInt(total);
  for (final entry in weights.entries) {
    roll -= entry.value;
    if (roll < 0) return entry.key;
  }
  return weights.keys.last;
}

/// [floor]층에 설 적을 조립해 돌려준다.
///
/// ⚠ 「호위」(소환수 동반)와 「연전」(2체째)은 아직 만들지 않았다.
/// 난이도로 달라지는 것은 **보스 변종과 배율**뿐이다.
Enemy pickEnemy(
  GameData data,
  Region region,
  Stage stage,
  int floor,
  Difficulty difficulty,
  Random random,
) {
  if (floor >= stage.floors) {
    final boss = data.enemies.firstWhere((e) => e.id == region.bossId);
    // 보스 변종은 추첨하지 않고 난이도로 고정한다 (ENEMIES.md 4절)
    final variant = _variantOf(data, kBossVariantIds[difficulty]!);
    return buildEnemy(
        boss, variant, region.hpScale, region.atkScale, difficulty);
  }
  final tier = int.parse(weightedPick(region.tierPool, random));
  final pool = data.enemies.where((e) => !e.isBoss && e.tier == tier).toList();
  // 해당 tier에 적이 하나도 없으면 일반 적 전체에서 뽑는다 (데이터 사고 대비)
  final candidates =
      pool.isNotEmpty ? pool : data.enemies.where((e) => !e.isBoss).toList();
  final base = candidates[random.nextInt(candidates.length)];
  final weights = difficultyVariantWeights(region.variantWeights, difficulty);
  final variant = _variantOf(data, weightedPick(weights, random));
  return buildEnemy(
      base, variant, region.hpScale, region.atkScale, difficulty);
}

/// 난이도별 변종 보정 (ENEMIES.md 5.3절 마지막 줄).
///
/// 하드는 「고대의」 +10%p, 데스는 +20%p를 더하고 **같은 양을 「기본」에서 뺀다.**
/// 기본이 모자라면 다음으로 비중이 큰 변종에서 마저 뺀다.
/// 「고대의」가 0인 지역(1~7)에도 적용한다 — 없던 변종이 생기는 것이 맞다.
/// 합은 언제나 100으로 유지된다.
///
/// ⚠ **보스 변종은 이 보정과 무관하다** (난이도로 고정 — kBossVariantIds).
Map<String, int> difficultyVariantWeights(
    Map<String, int> base, Difficulty difficulty) {
  final result = Map<String, int>.of(base);
  var remain = kAncientVariantBonus[difficulty]!;
  if (remain <= 0) return result;
  result.update(kAncientVariantId, (v) => v + remain, ifAbsent: () => remain);
  for (final id in _deductOrder(base)) {
    if (remain <= 0) break;
    final take = min(result[id] ?? 0, remain);
    result[id] = (result[id] ?? 0) - take;
    remain -= take;
  }
  return result;
}

/// 가중치를 빼는 순서: 「기본」이 먼저, 그다음은 비중이 큰 변종부터.
/// 같은 값이면 id 순으로 갈라 실행할 때마다 같은 결과가 나오게 한다.
List<String> _deductOrder(Map<String, int> base) {
  final others = base.keys
      .where((id) => id != kAncientVariantId && id != kNormalVariantId)
      .toList()
    ..sort((a, b) {
      final byWeight = base[b]!.compareTo(base[a]!);
      return byWeight != 0 ? byWeight : a.compareTo(b);
    });
  return [kNormalVariantId, ...others];
}

/// 변종 id로 변종을 찾는다. 없으면 기본 변종으로 떨어진다.
EnemyVariant _variantOf(GameData data, String id) => data.variants.firstWhere(
      (v) => v.id == id,
      orElse: () => data.variants.first,
    );
