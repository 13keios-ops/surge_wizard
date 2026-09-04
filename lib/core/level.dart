/// 캐릭터 레벨 · 경험치 (GROWTH.md 1·2절).
///
/// `constants.dart` 가 이 파일을 그대로 내보내므로 **쓰는 쪽은 지금처럼
/// `core/constants.dart` 하나만 import 하면 된다.** 갈라 낸 이유는
/// `constants.dart` 가 300줄을 넘어서다 (CLAUDE.md 코딩 규칙).
library;

import 'constants.dart';

/// 시작 레벨
const int kStartLevel = 1;

/// 최대 레벨 (GROWTH.md 1.2절)
const int kMaxLevel = 99;

/// 레벨 L → L+1 에 드는 경험치 = 이 값 × L.
/// 선형이라 「다음 레벨은 조금 더 걸린다」가 바로 느껴진다 (GROWTH.md 1.2절).
const int kExpPerLevelStep = 60;

/// 레벨업 1회가 주는 패시브 포인트 (PASSIVE_TREE.md 1절)
const int kPassivePointPerLevel = 1;

/// 보스가 주는 경험치 배수 (GROWTH.md 1.3절)
const double kBossExpMul = 5.0;

/// 변종(「기본」이 아닌 것)이 주는 경험치 배수
const double kVariantExpMul = 1.5;

/// [level] → [level]+1 에 필요한 경험치. **만렙이면 null.**
int? expToNextLevel(int level) =>
    level >= kMaxLevel ? null : kExpPerLevelStep * level;

/// 전투 하나를 이겨 받는 경험치 (GROWTH.md 1.3절).
///
/// 지역값 하나에 보스·변종·난이도 배수를 곱한다. tier로는 나누지 않는다 —
/// tier 풀이 이미 지역으로 정해져 있어 두 번 나누는 셈이 되기 때문이다.
int battleExp({
  required int regionExp,
  required bool isBoss,
  required bool isVariant,
  required Difficulty difficulty,
}) {
  var value = regionExp.toDouble();
  if (isBoss) value *= kBossExpMul;
  if (isVariant) value *= kVariantExpMul;
  value *= kDifficultyScales[difficulty]!.expMul;
  return value.round();
}
