import 'package:flutter/material.dart';

import '../core/constants.dart';

/// 게임용 원화 에셋 경로. **캔버스 크기는 그림마다 다르다** (마법사·적 1024,
/// 보스 848) — 정사각이고 발바닥이 [kArtFootLine] 비율에 있기만 하면 된다.
const kArtWizardBack = 'assets/art/wizard/body_back.webp';

/// 적 id → 원화. **여기 없는 적은 기존 픽셀 스프라이트로 나온다** (Phase 1.5는 1종뿐).
///
/// 보스도 같은 맵을 쓴다 — `battle_stage.dart` 가 `isBoss` 로 상자 크기를
/// `kBossSize`(180dp)로 갈라 놓았고, 보스 캔버스(848)는 정사각에 발바닥 비율이
/// 같아서 그리는 쪽이 구분할 것이 없다 (`reports/32_원화v3_검수_REVIEW.md` 9-2절).
const Map<String, String> kArtEnemies = {
  'goblin_scout': 'assets/art/enemy/goblin_scout.webp',
  'boss_elder_slime': 'assets/art/boss/elder_slime.webp',
};

/// 지역 id → 배경 원화. **여기 없는 지역은 코드 배경(`StageBackdrop`)을 쓴다.**
const Map<int, String> kArtRegionBackdrops = {
  1: 'assets/art/bg/forest.webp',
};

/// 캔버스에서 발바닥이 놓인 높이 비율 (1024는 y=953, 보스 848은 y=789).
/// **비율이라 캔버스 크기가 달라도 그대로 쓴다.** 캐릭터를 땅에 세울 때 쓴다.
const double kArtFootLine = 477 / 512;

/// 캐릭터 원화를 줄일 때의 보간.
///
/// 🔴 **2026-09-13에 `none` 에서 바뀌었다** (검토 41 승인). 예전에는 원화를
/// 정사각 블록으로 격자화해 두고 최근접으로 줄였는데, 그 격자가 **세부를 6.2배
/// 깎고 있었다** — 참고 게임은 블록을 강제하지 않는다(같은 색이 1px씩 53%).
/// 격자를 없앴으므로 **부드럽게 줄여야** 한다. 최근접으로 줄이면 깨진다.
const FilterQuality kArtFilter = FilterQuality.medium;

/// 배경 원화의 보간. **배경은 예전 그대로 2px 블록**이라 최근접을 유지한다.
const FilterQuality kArtBgFilter = FilterQuality.none;

/// 원화 한 장을 캐릭터 자리에 세운다.
///
/// 정규화 캔버스를 통째로 [size] 정사각에 맞춰 그린다. 모든 원화가
/// 같은 규약(UI_DESIGN 1-3절)을 지키므로 코드가 위치를 계산하지 않아도
/// 발이 같은 자리에 선다 — Phase 2의 장비 레이어도 같은 상자에 겹치면 된다.
///
/// 에셋을 못 읽으면 [fallback](기존 픽셀 스프라이트)으로 떨어진다.
class ArtSpriteView extends StatelessWidget {
  const ArtSpriteView(
    this.asset, {
    super.key,
    required this.fallback,
    this.size = 64,
    this.shadow = false,
    this.flashAmount = 0,
  });

  final String asset;

  /// 원화를 못 읽을 때 대신 그릴 것
  final Widget fallback;

  final double size;

  /// 발밑에 타원 그림자를 깐다 (땅에 서 있는 느낌)
  final bool shadow;

  /// 0~1. 1에 가까울수록 하얗게 물든다 (피격 연출)
  final double flashAmount;

  @override
  Widget build(BuildContext context) {
    final view = Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: kArtFilter,
      // 색조는 입히지 않는다 — 원화가 제 색을 갖고 있다. 피격 번쩍임만 얹는다
      color: flashAmount > 0
          ? Colors.white.withValues(alpha: flashAmount)
          : null,
      colorBlendMode: BlendMode.srcATop,
      errorBuilder: (_, _, _) => fallback,
    );
    if (!shadow) return view;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 발바닥 기준선(y=477/512)에 타원 중심을 맞춘다
          Positioned(
            bottom: size * (1 - kArtFootLine) - size * 0.0375,
            child: Container(
              width: size * 0.40,
              height: size * 0.075,
              decoration: BoxDecoration(
                gradient: RadialGradient(colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.0),
                ]),
                borderRadius:
                    BorderRadius.all(Radius.elliptical(size, size)),
              ),
            ),
          ),
          view,
        ],
      ),
    );
  }
}

/// 마법사 걷기 프레임. **아직 없다** — 에셋이 들어오면
/// [kArtWizardWalkReady]를 `true`로 바꾸는 **한 줄**이 연출을 켠다.
const List<String> kArtWizardWalk = [
  'assets/art/wizard/back_walk_1.webp',
  'assets/art/wizard/back_walk_2.webp',
  'assets/art/wizard/back_walk_3.webp',
  'assets/art/wizard/back_walk_4.webp',
];

/// 걷기 프레임이 `assets/art/wizard/`에 구워져 있으면 `true`로.
/// ✅ **2026-09-13에 구웠다** (검토 42) — 격자화를 빼면서 함께 넣었다.
/// `false`면 미는 동안에도 정지 그림을 그대로 쓴다 (없는 파일을 매 프레임
/// 찾아 로그를 더럽히지 않기 위해 런타임 탐색 대신 이 한 줄로 가른다).
const bool kArtWizardWalkReady = true;

/// 0~1 진행도 → 걷기 프레임 경로. 미는 동안 두 걸음 걷는다.
String wizardWalkFrame(double t) =>
    kArtWizardWalk[(t * kArtWizardWalk.length * 2).floor() %
        kArtWizardWalk.length];

/// 배경 원화를 무대 상자에 깐다. **움직이지 않는다.**
///
/// 배경 판은 고정이고 **좌우의 나무·바위만 흐른다** (`lib/art/roadside.dart`).
/// 그림이 화면보다 세로로 기니 **아래 정렬**로 자른다 — 가운데 정렬하면
/// 캐릭터가 설 앞쪽 땅이 날아간다 (`reports/28_에셋검수_Phase1_5.md` 3-1절).
///
/// 에셋을 못 읽으면 [fallback](코드로 그리는 `StageBackdrop`)으로 떨어진다.
class ArtBackdropView extends StatelessWidget {
  const ArtBackdropView(this.asset, {super.key, required this.fallback});

  final String asset;
  final Widget fallback;

  @override
  Widget build(BuildContext context) => Image.asset(
        asset,
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
        filterQuality: kArtBgFilter,
        errorBuilder: (_, _, _) => fallback,
      );
}

/// 마법사 뒷모습. 층이 오른 직후 [kWalkTransition] 동안 걷기 프레임을 돌리고,
/// 프레임이 없으면([kArtWizardWalkReady]가 `false`) 정지 그림을 그대로 쓴다.
class WalkingWizardView extends StatefulWidget {
  const WalkingWizardView(
      {super.key,
      required this.floor,
      required this.size,
      required this.flashAmount,
      required this.fallback});

  /// 지금 층 (1층은 걷지 않는다 — 방금 들어왔다)
  final int floor;
  final double size;
  final double flashAmount;

  /// 원화를 못 읽을 때 대신 그릴 것 (기존 픽셀 스프라이트)
  final Widget fallback;

  @override
  State<WalkingWizardView> createState() => _WalkingWizardViewState();
}

class _WalkingWizardViewState extends State<WalkingWizardView>
    with SingleTickerProviderStateMixin {
  /// 걷지 않을 때는 아예 만들지 않는다
  AnimationController? _walk;

  @override
  void initState() {
    super.initState();
    if (kArtWizardWalkReady && widget.floor > 1) {
      _walk = AnimationController(vsync: this, duration: kWalkTransition)
        ..forward();
    }
  }

  @override
  void dispose() {
    _walk?.dispose();
    super.dispose();
  }

  Widget _view(String asset, Widget fallback) => ArtSpriteView(asset,
      size: widget.size,
      shadow: true,
      flashAmount: widget.flashAmount,
      fallback: fallback);

  @override
  Widget build(BuildContext context) {
    final walk = _walk;
    final still = _view(kArtWizardBack, widget.fallback);
    if (walk == null) return still;
    return AnimatedBuilder(
      animation: walk,
      builder: (_, _) => walk.isAnimating
          ? _view(wizardWalkFrame(walk.value), still)
          : still,
    );
  }
}
