/// 측정 조건 — 이번 지시서의 변경(12지역 체력 배율)을 **껐다 켜서** 기여를 가른다
/// (WORK_ORDER_FINAL_TUNE2 3-B).
///
/// 조건은 `const` 가 아니라 **인자**로 흐른다 — 그래서 상수를 고쳐 두 번
/// 돌리지 않고 **한 번의 실행**으로 두 조건을 모두 낸다.
///
/// ⚠ 이 파일은 측정 전용이다. 게임이 실제로 쓰는 값은
/// `assets/data/regions.json` 에 있다.
library;

import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/region.dart';

/// 하향 **전** 12지역 체력 배율 = 측정 22가 돌던 값 (기준 조건을 재현하기 위한 값).
/// 새 값(3.35)은 regions.json 에 들어 있고, 여기 값은 「기준」에서만 쓴다.
/// **바뀐 것은 12지역 한 칸뿐이다** (3.50 → 3.35).
const double kOldRegion12HpScale = 3.50;

/// 배율을 되돌릴 지역 — 12지역 하나뿐이다
const int kScaleChangedRegion = 12;

/// 한 번의 측정에서 돌릴 조건 하나
class MeasureCondition {
  const MeasureCondition(this.label, {required this.newScale});

  /// 표에 찍을 이름
  final String label;

  /// 12지역 체력 배율을 새 값(작업 1)으로 쓸 것인가.
  /// false 면 kOldRegion12HpScale 을 쓴다 (= 측정 22 재현).
  final bool newScale;
}

const MeasureCondition kCondBase =
    MeasureCondition('기준(측정22 재현)', newScale: false);
const MeasureCondition kCondScale =
    MeasureCondition('새 배율 3.35(채택)', newScale: true);

/// 표에 나올 순서 그대로
const List<MeasureCondition> kConditions = [
  kCondBase,
  kCondScale,
];

/// 상세 표를 뽑을 조건 — 실제로 채택한 「새 배율」이다
const MeasureCondition kAdoptedCondition = kCondScale;

/// 조건이 「옛 배율」이면 **12지역의 hp_scale 만** 되돌린 데이터 사본을
/// 돌려준다. atk_scale·tier 풀·변종 가중치·1~11지역은 한 칸도 건드리지 않는다.
GameData dataFor(GameData data, MeasureCondition condition) =>
    condition.newScale
        ? data
        : GameData(
            spells: data.spells,
            surges: data.surges,
            enemies: data.enemies,
            relics: data.relics,
            regions: data.regions.map(_withOldHpScale).toList(),
            stages: data.stages,
            variants: data.variants,
            circleSlots: data.circleSlots,
          );

/// 12지역만 옛 체력 배율로 되돌린다 (그 밖은 원본 그대로).
Region _withOldHpScale(Region r) {
  if (r.id != kScaleChangedRegion) return r;
  return Region(
    id: r.id,
    name: r.name,
    theme: r.theme,
    bossId: r.bossId,
    stageCount: r.stageCount,
    exp: r.exp,
    hpScale: kOldRegion12HpScale,
    atkScale: r.atkScale,
    tierPool: r.tierPool,
    variantWeights: r.variantWeights,
  );
}
