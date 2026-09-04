/// 절별 표가 함께 쓰는 기준값과 서식.
///
/// 여기 든 확률표·목표 비율은 **기획 문서에서 옮겨 온 비교 기준**일 뿐,
/// 게임이 실제로 쓰는 값이 아니다 (게임 값은 lib/core/constants.dart 에 있다).
library;

import 'package:surge_wizard/core/battle.dart';
import 'package:surge_wizard/core/check.dart';
import 'package:surge_wizard/core/constants.dart';

import 'measure_stats.dart';

/// GAME_DESIGN.md 3.4절 확률표 (족보 포함). 순서는 CheckGrade.values 와 같다.
/// **비교 기준일 뿐 코드가 쓰는 값이 아니다.**
const Map<CastIntensity, List<double>> kDesignTable = {
  CastIntensity.normal: [0.389, 0.361, 0.222, 0.028],
  CastIntensity.full: [0.167, 0.222, 0.361, 0.250],
};

/// SURGE_DESIGN.md 2절이 보장한 갈래별 목표 비율
const Map<String, double> kSurgeTargets = {
  'backlash': 0.25,
  'misfire': 0.20,
  'fizzle': 0.15,
  'amplify': 0.15,
  'summon': 0.15,
  'chain': 0.10,
};

const Map<String, String> kSurgeNames = {
  'backlash': '역류',
  'misfire': '오발',
  'fizzle': '불발',
  'amplify': '증폭',
  'summon': '소환',
  'chain': '연쇄',
};

/// 전투당 굴림 횟수 히스토그램 구간 (지시서 2-A 가 예시로 준 구간)
const List<int> kRollBuckets = [4, 8, 12];

/// 전투당 턴 수 히스토그램 구간
const List<int> kTurnBuckets = [2, 4, 6, 8, 10];

/// ENGRAVINGS.md 3.3·4절의 조건 유형. 확률·상한·전설 1회당 수치는 문서 값이다.
class EngravingKind {
  const EngravingKind(this.label, this.p, this.cap, this.legendary, this.docE,
      this.docBonus);

  final String label;
  final double p; // 1굴림에서 조건이 맞을 확률
  final int cap; // 전투당 적립 상한
  final double legendary; // 전설 등급 1회 적립당 보너스
  final double docE; // ENGRAVINGS.md 가 적어 둔 기대 적립 횟수 (9굴림 가정)
  final double docBonus; // ENGRAVINGS.md 가 적어 둔 기대 보너스
}

const List<EngravingKind> kEngravingKinds = [
  EngravingKind('흔함', 0.5, 4, 0.05, 3.4, 0.17),
  EngravingKind('드묾', 1 / 6, 3, 0.10, 1.4, 0.14),
  EngravingKind('희박(스트레이트)', 0.111, 2, 0.20, 0.9, 0.19),
  EngravingKind('희박(뱀눈)', 0.074, 2, 0.20, 0.6, 0.13),
];

/// 과거 측정의 「전투당 굴림」(36조합 합산). 출처는 각 measure*_output.txt 다.
const Map<String, double> kRollsHistory = {
  '측정 12': 2.40,
  '측정 14': 4.40,
  '측정 15': 5.49,
  '측정 16': 6.66,
  '측정 17': 5.78,
  '측정 18 하한': 6.19,
  '측정 18 상한': 4.39,
  '측정 19 하한': 6.17,
  '측정 19 상한': 4.65,
  '측정 20 하한': 6.02,
  '측정 20 상한': 4.53,
  '측정 21 하한': 5.99,
  '측정 21 상한': 4.49,
  '측정 22 하한': 5.99,
  '측정 22 상한': 4.49,
};

/// ENGRAVINGS.md 4절이 가정한 전투당 굴림 수
const int kDocRollsPerBattle = 9;

const String gradeHeader = '대성공    성공      아슬아슬  실패';

/// 판정 엔진으로 3d6 216가지를 전수 계산한 등급 분포 (보정 0 · 마력 축적 0).
/// **하드코딩이 아니라 resolveCheck 를 그대로 돌린 값**이라, 봇 측정치가 이것과
/// 맞으면 측정 코드가 옳다는 뜻이다.
List<double> exactDistribution(CastIntensity it) {
  final counts = {for (final g in CheckGrade.values) g: 0};
  var total = 0;
  for (var a = 1; a <= kDiceSides; a++) {
    for (var b = 1; b <= kDiceSides; b++) {
      for (var c = 1; c <= kDiceSides; c++) {
        final r = resolveCheck(dice: [a, b, c], dc: it.dc);
        counts.update(r.grade, (v) => v + 1);
        total++;
      }
    }
  }
  return CheckGrade.values.map((g) => counts[g]! / total).toList();
}

String gradeRow(String label, List<double> ratios) {
  final cells = ratios.map((r) => pad('${pct(r)}%', 10)).join();
  return '  ${pad(label, 18)}$cells';
}

