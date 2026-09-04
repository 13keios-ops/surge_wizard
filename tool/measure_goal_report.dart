/// ★ 곡선 조건 판정 A·B1·B2·C (WORK_ORDER_FINAL_TUNE2 0-1 · 3-C).
///
/// **구간별 밴드를 버렸다** (GAME_DESIGN 6.2절 재개정 · 검토 21).
/// 실측 곡선은 매끄럽게 단조 감소하는데, 거기에 계단 모양 목표를 씌우면
/// 경계(4·7지역)에서 반드시 어긋난다. 그래서 「구간마다 몇 %」가 아니라
/// **「곡선의 모양」**을 요구한다.
///
///   A   상한이 **단조 감소**하고 인접 낙차가 **20%p 이내**
///   B1  **11지역 상한이 25~45%**
///   B2  **12지역 상한이 15~25%** — 최종 지역은 곡선의 가장 낮은 점이다
///   C   도입(1~3) 하한 **70%+** · 5~10지역 하한·상한 **간격 30%p 이상**
///
/// ★ B가 B1·B2로 쪼개진 이유 (검토 22 · GAME_DESIGN 6.2절): 11지역이 이미
/// 27.7%로 밴드 바닥이라, 12지역까지 25% 위로 올리라는 것은 최종 지역을 앞
/// 지역과 같은 난이도로 만들라는 뜻이 되어 **조건 A(단조 감소)와 양립할 수
/// 없었다.** 목표를 낮춘 것이 아니라 **모순을 없앤 것**이다.
///
/// 하한 = 마법서 강화 없음 · 상한 = 마법서 만강.
///
///   6-A  곡선과 낙차 (표 1)
///   6-B  조건 판정 A·B1·B2·C (표 2) — 이번 측정의 결론
///
/// 6-C(보스만 승률)·6-D(판당 턴)는 `measure_final_report.dart` 에 있다
/// (파일 300줄 규칙 때문에 갈랐다).
library;

import 'package:surge_wizard/core/constants.dart';

import 'measure_growth.dart';
import 'measure_growth_report.dart';
import 'measure_stage_report.dart';
import 'measure_stage_run.dart';
import 'measure_stats.dart';
import 'sim_core.dart';

/// 조건 A — 인접 지역 사이에 허용하는 상한 낙차 (GAME_DESIGN 6.2절)
const double kMaxDropPerRegion = 20.0;

/// 조건 A의 「단조 감소」를 볼 때 무시하는 상승 폭 (표본 흔들림).
///
/// 도입 지역은 조합당 300판이므로 상한이 99% 근처일 때 1σ가 0.6%p 안팎이다.
/// 그보다 작은 상승은 곡선이 올라간 것이 아니라 **표본이 흔들린 것**이다.
/// 검토 21도 같은 자리(1→2지역 +0.3%p)를 「표본 흔들림」으로 보고 A를 통과로
/// 판정했다 — 그 판정 기준을 그대로 잇는다. 이 선을 넘는 상승은 아래에서
/// 「엄격 판정」으로 따로 찍으므로 **감춰지지 않는다.**
const double kMonotoneNoise = 1.0;

/// 조건 B1 — **11지역** 상한이 들어야 하는 구간 (종반이 「오래 걸리되 뚫린다」)
const int kLateRegionId = 11;
const double kLateHighMin = 25.0;
const double kLateHighMax = 45.0;

/// 조건 B2 — **12지역** 상한이 들어야 하는 구간.
/// 최종 지역은 곡선의 가장 낮은 점이므로 앞 지역과 같은 밴드에 못 들어간다.
const double kFinalHighMin = 15.0;
const double kFinalHighMax = 25.0;

/// 조건 C — 도입(1~3) 하한이 넘어야 하는 선
const double kIntroLowMin = 70.0;

/// 조건 C — 하한·상한 간격을 요구하는 지역과 그 최소 간격
const List<int> kFarmRegions = [5, 6, 7, 8, 9, 10];
const double kMinFarmGap = 30.0;

ComboResult _combo(UpgradeTables t, BookUpgrade u, int id) =>
    t[u]![BotPolicy.utility]![id]![Difficulty.normal]!;

double _clear(UpgradeTables t, BookUpgrade u, int id) =>
    _combo(t, u, id).clearRate * 100;

double _low(UpgradeTables t, int id) => _clear(t, BookUpgrade.none, id);
double _high(UpgradeTables t, int id) => _clear(t, BookUpgrade.full, id);

String _signed(double v) => '${v >= 0 ? '+' : ''}${fix(v, 1)}';

/// 6-A. 표 1 — 곡선과 낙차
List<String> sectionCurve(UpgradeTables adopted) {
  final lines = <String>[
    '',
    '── 6-A. 표 1 — 곡선과 낙차 (보통 · utility · 채택 조건) ─',
    '  하한 = 강화 없음 · 상한 = 마법서 만강. 패시브 체력만 · 유물/장비/각인 없음.',
    '  「상한 낙차」는 **앞 지역 상한 − 이 지역 상한**이다 (양수면 내려갔다는 뜻).',
    '  ${pad('지역', 20)}${pad('하한', 10)}${pad('상한', 10)}'
        '${pad('상한 낙차', 12)}${pad('간격(상−하)', 14)}',
  ];
  double? prev;
  for (final id in kRegionIds) {
    final low = _low(adopted, id);
    final high = _high(adopted, id);
    final drop = prev == null ? null : prev - high;
    lines.add('  ${pad('$id ${_combo(adopted, BookUpgrade.full, id).region.name}', 20)}'
        '${pad('${fix(low, 1)}%', 10)}${pad('${fix(high, 1)}%', 10)}'
        '${pad(drop == null ? '—' : '${fix(drop, 1)}%p', 12)}'
        '${pad('${fix(high - low, 1)}%p', 14)}');
    prev = high;
  }
  return lines;
}

/// 6-B. ★ 표 2 — 조건 판정 A·B1·B2·C. **이번 측정의 결론이다.**
List<String> sectionCurveConditions(UpgradeTables adopted) {
  final a = _conditionA(adopted);
  final b1 = _conditionBand('B1', kLateRegionId, kLateHighMin, kLateHighMax,
      adopted);
  final b2 = _conditionBand('B2', kRegionIds.last, kFinalHighMin,
      kFinalHighMax, adopted);
  final c = _conditionC(adopted);
  final all = [a, b1, b2, c];
  final verdict = all.map((r) => '${r.name}${r.ok ? '✅' : '❌'}').join(' ');
  return [
    '',
    '── 6-B. ★ 표 2 — 곡선 조건 판정 (GAME_DESIGN 6.2절 재개정) ─',
    '  구간 밴드는 더 내지 않는다 — 매끄러운 곡선에 계단 목표를 씌우면',
    '  경계에서 반드시 어긋나기 때문이다 (검토 21).',
    '  ${pad('조건', 6)}${pad('요구', 42)}${pad('실측', 34)}${pad('판정', 10)}',
    for (final r in all)
      '  ${pad(r.name, 6)}${pad(r.want, 42)}${pad(r.got, 34)}'
          '${pad(r.ok ? '✅ 통과' : '❌ 미달', 10)}',
    '',
    '  ★ 한 줄 답 — $verdict',
    ...a.detail,
    ...c.detail,
  ];
}

/// 조건 하나의 판정 결과
class _CondResult {
  _CondResult(this.name, this.want, this.got, this.ok, [this.detail = const []]);

  final String name;
  final String want;
  final String got;
  final bool ok;
  final List<String> detail;
}

/// A — 상한이 단조 감소하고 인접 낙차가 20%p 이내인가
_CondResult _conditionA(UpgradeTables t) {
  final rises = <_Rise>[];
  final overs = <String>[];
  var worstDrop = 0.0;
  var worstAt = '';
  for (var i = 1; i < kRegionIds.length; i++) {
    final prevId = kRegionIds[i - 1];
    final id = kRegionIds[i];
    final drop = _high(t, prevId) - _high(t, id);
    if (drop < 0) {
      rises.add(_Rise('$prevId→$id (${_signed(-drop)}%p 상승)',
          -drop > kMonotoneNoise));
    }
    if (drop > worstDrop) {
      worstDrop = drop;
      worstAt = '$prevId→$id';
    }
    if (drop > kMaxDropPerRegion) {
      overs.add('$prevId→$id ${fix(drop, 1)}%p');
    }
  }
  final real = rises.where((r) => r.over).toList();
  final ok = real.isEmpty && overs.isEmpty;
  String show(Iterable<_Rise> rs) =>
      rs.isEmpty ? '없음' : rs.map((r) => r.label).join(', ');
  return _CondResult(
    'A',
    '단조 감소 · 낙차 ≤ ${fix(kMaxDropPerRegion, 0)}%p',
    '최대 낙차 ${fix(worstDrop, 1)}%p ($worstAt)',
    ok,
    [
      '  A 상세 — 상한이 올라간 칸 ${show(real)} · '
          '낙차 초과 칸 ${overs.isEmpty ? '없음' : overs.join(', ')}',
      '  A 엄격 판정 — 흔들림(±${fix(kMonotoneNoise, 1)}%p)까지 세면 '
          '올라간 칸 ${show(rises)} → ${rises.isEmpty ? '변화 없음' : '엄격히는 미달'}',
    ],
  );
}

/// 상한이 앞 지역보다 올라간 칸 하나
class _Rise {
  _Rise(this.label, this.over);

  final String label;

  /// 흔들림 선(kMonotoneNoise)을 넘는 진짜 상승인가
  final bool over;
}

/// B1·B2 — 지정한 지역의 상한이 그 지역의 밴드 안에 들었는가.
/// **B2(12지역)가 이번 지시서의 표적이다.**
_CondResult _conditionBand(
    String name, int regionId, double min, double max, UpgradeTables t) {
  final high = _high(t, regionId);
  final ok = high >= min && high <= max;
  final miss = high < min ? high - min : (high > max ? high - max : 0.0);
  return _CondResult(
    name,
    '$regionId지역 상한 ${fix(min, 0)}~${fix(max, 0)}%',
    '${fix(high, 1)}%${ok ? '' : ' (${_signed(miss)}%p)'}',
    ok,
  );
}

/// C — 도입 하한 70%+ · 5~10지역 하한·상한 간격 30%p 이상인가
_CondResult _conditionC(UpgradeTables t) {
  final introLow = <String>[];
  var worstIntro = 100.0;
  for (final id in [1, 2, 3]) {
    final low = _low(t, id);
    if (low < worstIntro) worstIntro = low;
    if (low < kIntroLowMin) introLow.add('$id지역 ${fix(low, 1)}%');
  }
  final narrow = <String>[];
  var worstGap = 100.0;
  var worstGapAt = '';
  for (final id in kFarmRegions) {
    final gap = _high(t, id) - _low(t, id);
    if (gap < worstGap) {
      worstGap = gap;
      worstGapAt = '$id지역';
    }
    if (gap < kMinFarmGap) narrow.add('$id지역 ${fix(gap, 1)}%p');
  }
  final ok = introLow.isEmpty && narrow.isEmpty;
  return _CondResult(
    'C',
    '도입 하한 ${fix(kIntroLowMin, 0)}%+ / '
        '5~10지역 간격 ≥ ${fix(kMinFarmGap, 0)}%p',
    '도입 최저 ${fix(worstIntro, 1)}% · 최소 간격 ${fix(worstGap, 1)}%p',
    ok,
    [
      '  C 상세 — 도입 미달 ${introLow.isEmpty ? '없음' : introLow.join(', ')} · '
          '간격 미달 ${narrow.isEmpty ? '없음' : narrow.join(', ')} '
          '(최소는 $worstGapAt)',
    ],
  );
}
