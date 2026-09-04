/// 화면 칸 크기 상수 (WORK_ORDER_SCREENS2 작업 2).
///
/// `constants.dart` 가 이 파일을 그대로 내보내므로 **쓰는 쪽은 지금처럼
/// `core/constants.dart` 하나만 import 하면 된다.** 갈라 낸 이유는
/// `constants.dart` 가 300줄을 넘어서다 (CLAUDE.md 코딩 규칙).
library;

// ── 화면 칸 크기 (WORK_ORDER_SCREENS2 작업 2) ───────────
//
// 스테이지 층수가 3~10으로 가변이라 **칸 수가 적으면 화면이 텅 빈다.**
// 도입 지역(1~3)이 3~7층이라 유저가 초반 내내 그 화면을 본다 (검토 24 3-2절).
// 그래서 남는 세로 공간을 칸 수로 나눠 칸을 키우되, 아래 상·하한으로 묶는다.

/// 지도 층 칸의 **하한** — 지금 「현재 층」 칸의 높이다.
/// 층이 10개라 자리가 빠듯할 때 이 값이 걸리고, 그때 화면은 지금과 같아진다.
const double kFloorTileMinHeight = 46.0;

/// 지도 층 칸의 **상한** — 3층짜리 스테이지에서 칸이 우스꽝스럽게 커지지 않게 막는다
const double kFloorTileMaxHeight = 120.0;

/// 칸 높이에서 여백·테두리·안쪽 여백이 먹는 몫. 나머지가 내용이 쓸 높이다.
const double kFloorTileChrome = 20.0;

/// 지도 칸의 적 그림 크기 — 하한은 지금 크기, 상한은 칸이 커졌을 때의 크기다.
/// 칸만 늘리고 내용을 그대로 두면 **키만 큰 빈 막대**가 된다.
const double kFloorThumbMinSize = 26.0;
const double kFloorThumbMaxSize = 72.0;

/// 스테이지 격자 칸의 가로세로 비 (폭 ÷ 높이). **이 비율에서 나온 높이가 하한**이라,
/// 자리가 빠듯하면 화면이 지금과 같아진다.
const double kStageTileAspect = 1.25;

/// 스테이지 격자 칸의 **상한** 가로세로 비 = 정사각형.
/// 더 키우면 칸이 세로로 길쭉해져 글자만 가운데 뜬 빈 칸이 된다.
const double kStageTileMaxAspect = 1.0;

/// 스테이지 격자의 칸 사이 간격
const double kStageGridSpacing = 8.0;
