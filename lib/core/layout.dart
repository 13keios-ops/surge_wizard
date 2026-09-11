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

// ── 전투 화면 구도 v3 (보고서 31 · 4-8 / 4-9절) ─────────
//
// 🔴 **전부 「화면 아래에서 몇 dp」로 잰다.** 기기 비율이 16:9 ~ 20:9 로 제각각이라
// 위에서 재면 기기마다 구도가 달라진다. 아래에서 재면 화면이 길어져도
// **위쪽 배경만 더 보이고** 조작부·마법사·적의 관계는 그대로다.
// 값은 참고 게임(딸깍 다이스) 화면을 행마다 실측해 옮긴 것이다.

/// 주사위·버튼 줄의 아래끝
const double kCtrlBottom = 8.0;

/// 마나·마력 축적 줄의 아래끝. **마법사 체력바와 같은 높이**다 —
/// 체력바는 가운데, 마나·마력은 좌우 끝이라 겹치지 않는다
/// (`battle_stage.dart` 가 체력바를 `kHeroFoot - kUnitPlateHeight - 2` 에 둔다)
const double kResBottom = 208.0;

/// 주문 슬롯 띠의 아래끝과 높이.
/// 🔴 **144 가 하한이다** — 그 아래는 족보 줄(116~140)이라 더 내리면 겹친다
const double kSlotsBottom = 144.0;
const double kSlotsHeight = 64.0;

/// 마법사 발이 놓이는 높이 — 주문 슬롯 바로 위
const double kHeroFoot = 230.0;

/// 보스 발
const double kBossFoot = 390.0;

/// 앞줄 적 발 · 뒷줄 적 발 (다중 적은 다음 지시서. 지금은 자리만 잡아 둔다)
const double kFoeFrontFoot = 403.0;
const double kFoeBackFoot = 449.0;

/// 배경에서 길이 화면 폭을 다 채우기 시작하는 높이. **이 아래로는 나무가 없다**
const double kRoadOpen = 377.0;

/// 길이 안개에 잠기는 높이
const double kRoadMist = 585.0;

// ── 캐릭터 크기 ────────────────────────────────────────
//
// 「화면 한 칸 = 2.0dp」 규칙(UI_DESIGN 1-2-b)이라 크기는 곧 칸 수다.
// 마법사 56칸 · 일반 적 38칸 · 보스 90칸으로 원화를 다시 뽑아야 한다.

const double kWizardSize = 112.0;
const double kEnemySize = 76.0;
const double kBossSize = 180.0;

/// 캐릭터 밑에 붙는 체력바 + 레벨 줄의 높이 (막대 6 + 여백 1 + 글자 12×1.2)
const double kUnitPlateHeight = 22.0;

// ── 배경 위에 얹히는 UI ────────────────────────────────

/// 상단 띠(던전 이름 · 층 · 일시정지). 터치 최소 44dp
const double kTopBarHeight = 44.0;

/// 보스 체력바 — 화면 맨 위 가로 전체 (일반 적은 발밑에 붙는다)
const double kBossBarTop = 48.0;
const double kBossBarHeight = 20.0;

/// 주문 슬롯 칸 수. 기본 3칸이 열리고 나머지는 잠금 (GAME_DESIGN 4.2절)
const int kSpellSlotCount = 5;

// ── 주사위 트레이 ──────────────────────────────────────

/// 주사위 한 개의 크기와 그 줄의 높이
const double kDiceSize = 64.0;
const double kDiceRowHeight = 104.0;

/// 족보·판정 결과 줄의 높이
const double kComboLineHeight = 24.0;

/// 메인 버튼 높이·글자 크기
const double kCastButtonHeight = 46.0;
const double kCastButtonFont = 24.0;

/// 주문 슬롯 안의 아이콘 상자와 아이콘.
/// 🔴 **아이콘은 16칸 도트라 배율이 정수여야 한다** — 26dp 는 1.625배라
/// 한 도트가 화면에서 들쭉날쭉했다. **32 = 16 × 2.0.**
/// (진짜 해상도를 올리려면 원화 아이콘이 필요하다 — `art_raw/icon/`)
const double kSpellIconBox = 34.0;
const double kSpellIconSize = 32.0;

// ── 걸어가는 연출 (WORK_ORDER_BG_SCROLL) ───────────────

/// 층이 오를 때 배경이 **이전 층 자리 → 지금 층 자리**로 흐르는 시간.
/// 전투 화면이 열릴 때 한 번만 재생한다 (전투 중에는 안 움직인다).
const Duration kBackdropSlide = Duration(milliseconds: 900);
