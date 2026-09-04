/// 픽셀 게임 공통 색 팔레트와 픽셀 폰트 사다리.
/// 화면 방침은 GAME_DESIGN 9.5절 + refs/DICERO_ANALYSIS.md §9.
/// (pixel_ui.dart 가 300줄을 넘어 갈라 냈다 — 내용은 그대로다)
library;

import 'package:flutter/material.dart';

// ── 색 팔레트 ──
//
// 방침(WORK_ORDER_GRAPHICS 1-A): "전체를 밝게"가 아니라 **명도 대비를 벌린다.**
// 아래 6단계는 인접한 두 단계의 밝기가 확실히 갈라지도록 잡았다. 전투 무대의
// 발밑은 어둡게 유지해야 마법 이펙트가 빛난다.
const kBgWell = Color(0xFF15122B); // 막대·칸 안쪽 (가장 어둡다)
const kBgTray = Color(0xFF1B1838); // 주사위 트레이 — 흰 주사위가 가장 밝게 뜬다
const kBgDeep = Color(0xFF232042); // 화면 바탕
const kBgPanel = Color(0xFF3A3560); // 패널 바탕
const kBgPanelLit = Color(0xFF524B84); // 강조된 패널
const kBorderDim = Color(0xFF6E68A8); // 기본 테두리 (바탕과 갈라지게)
const kBorderLit = Color(0xFFF2C14E); // 선택된 테두리(금색)
const kTextMain = Color(0xFFF2EEFA);
const kTextDim = Color(0xFFB8B0D8); // 설명 글씨가 묻히지 않는 밝기

// ── 강조색 ── 금·빨강·청록 셋이 기본이고, 체력 초록/마나 파랑만 예외로 둔다
// (적 체력=빨강 / 내 체력=초록 은 규칙이 아니라 읽는 습관이라 유지한다)
const kGold = Color(0xFFF2C14E); // 선택·중요
const kHpRed = Color(0xFFE8546B); // 적 체력·피해
const kCharge = Color(0xFF4FD1C5); // 마력 축적 (보라 → 청록. 배경에 묻히지 않는다)
const kManaBlue = Color(0xFF5FC8F0); // 마나
const kHpGreen = Color(0xFF6BD45C); // 플레이어 체력

// 폭주 6갈래 전용 색 (SURGE_DESIGN 2절). 나머지 넷은 위 팔레트를 그대로 쓴다.
const kSurgePurple = Color(0xFFA97BEA); // 오발 — 엉뚱한 곳으로 갔다
const kSurgeGray = Color(0xFF9A93BC); // 불발 — 무채색: 아무 일도 없었다

/// 캐릭터 실루엣 테두리. 배경이 복잡해도 캐릭터가 배경에서 떨어져 보이게 한다.
const kSpriteHalo = Color(0xE60D0A1A);

/// 주인공 마법사의 로브 색. 배경 3테마(푸른 얼음·자줏빛 비전·불타는 하늘)와
/// 색상환에서 가장 멀어 어느 층에서도 실루엣이 뜬다.
const kWizardTint = Color(0xFF45C9C0);

// ── 픽셀 폰트 ──
// 픽셀 폰트는 **기준 픽셀 크기의 정수 배율**에서만 또렷하다. 어중간한 값을 쓰면
// 글자가 뭉갠다. 그래서 화면에서 쓰는 글자 크기를 아래 사다리로 제한한다.
//   Galmuri11 (앱 기본) = 12px 기준 → 12 · 24 · 36 · 48 · 84
//   Galmuri9            = 10px 기준 → 10 · 20 · 30
const kFont11 = 'Galmuri11';
const kFont9 = 'Galmuri9';

/// 글자 크기에 맞는 픽셀 폰트를 고른다.
/// 12의 배수면 Galmuri11, 아니면 Galmuri9(10의 배수)로 본다.
String pixelFontFor(double size) => size % 12 == 0 ? kFont11 : kFont9;
