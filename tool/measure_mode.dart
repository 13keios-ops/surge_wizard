/// 측정 모드 3종과 한 모드의 실행 결과.
///
/// 3.4절 확률표는 **보정 0 · 리롤 없음**의 순수 분포다. 그런데 봇은 성공이
/// 뜰 때까지 리롤하고 유물 보정을 받으므로, 실제 플레이(C)를 표와 그대로
/// 비교하면 안 된다. 그래서 리롤과 유물을 따로 끄고 켜서 세 번 잰다.
library;

import 'sim_tally.dart';

enum SimMode {
  /// A. 순수 — 리롤도 유물도 없다. 3.4절 확률표와 직접 비교할 수 있는 유일한 모드
  pure('A. 순수', useRerolls: false, useRelics: false),

  /// B. 리롤만 — 리롤이 분포를 얼마나 미는지 본다
  rerollOnly('B. 리롤만', useRerolls: true, useRelics: false),

  /// C. 전체 — 실제 플레이. 기존 simulate.dart 와 같은 조건이다
  full('C. 전체', useRerolls: true, useRelics: true);

  const SimMode(this.label, {required this.useRerolls, required this.useRelics});

  final String label;
  final bool useRerolls;
  final bool useRelics;
}

/// 한 모드를 지정 판 수만큼 돌린 결과
class ModeResult {
  ModeResult({
    required this.mode,
    required this.tally,
    required this.clearRate,
    required this.avgFloor,
  });

  final SimMode mode;
  final Tally tally;

  /// 완주율 (참고용 — 모드마다 게임 난이도가 다르다는 것을 보여준다)
  final double clearRate;

  /// 평균 도달 층수
  final double avgFloor;
}
