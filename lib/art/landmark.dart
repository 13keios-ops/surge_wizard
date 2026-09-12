/// 길 끝의 **목표 건물(성)** 과 그 앞의 **보스 음영** (`GAME_DESIGN.md` 6.7절 ②).
///
/// 목적지가 1층부터 눈에 보여야 「저기까지 간다」가 성립한다.
///
/// 🔴 **음영은 커지지 않는다.** 옛 문서에 있던 「층이 오를수록 그림자가 커지고
/// 내려온다」는 2026-09-12에 틀린 것으로 판명됐다 — 사용자가 요구한 적이 없고,
/// 참고 게임 실측에서도 보스 실루엣은 두 화면이 크기·위치·눈까지 같았다.
/// 음영은 **예고**일 뿐 진행도를 나타내지 않는다.
library;

import 'package:flutter/material.dart';

import '../core/layout.dart';
import 'art_sprite.dart';

/// 성 원화. **아직 없다** (`ART_REQUEST_LAYERS.md`로 발주 예정).
/// 비어 있으면 단색 실루엣으로 그린다 — 자리와 크기는 진짜와 같다.
const Map<int, String> kArtLandmarks = {};

/// 원화가 없을 때 쓰는 성 실루엣 색 (안개 너머라 배경보다 한 단계 어둡다)
const Color kLandmarkPlaceholder = Color(0x99101826);

/// 길 끝의 목표 건물. **고정이다** — 층이 올라도 안 움직인다.
class LandmarkView extends StatelessWidget {
  const LandmarkView({super.key, required this.regionId});

  final int regionId;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, box) {
          final h = box.maxHeight * kLandmarkHeight;
          final art = kArtLandmarks[regionId];
          return Stack(
            children: [
              Positioned(
                top: box.maxHeight * kLandmarkBottomY - h,
                left: 0,
                right: 0,
                child: Center(
                  child: art == null
                      ? Container(
                          width: h * 1.2,
                          height: h,
                          color: kLandmarkPlaceholder,
                        )
                      : Image.asset(art,
                          height: h, filterQuality: kArtFilter),
                ),
              ),
            ],
          );
        },
      );
}

/// 성 앞의 **보스 음영**. 몸을 검게 칠하고 **눈 두 점만 빛난다.**
///
/// 🔴 **보스 층에서는 그리지 않는다** — 실물이 그 자리에 섰다.
class BossShadowView extends StatefulWidget {
  const BossShadowView({
    super.key,
    required this.art,
    required this.eyes,
  });

  /// 보스 원화 경로. `null`이면 아무것도 안 그린다
  final String? art;

  /// 눈 두 점의 캔버스 비율 `[x1, y1, x2, y2]`. `null`이면 눈을 안 그린다
  final List<double>? eyes;

  @override
  State<BossShadowView> createState() => _BossShadowViewState();
}

class _BossShadowViewState extends State<BossShadowView>
    with SingleTickerProviderStateMixin {
  /// 눈 깜빡임 — 살아 있는 것이 저기 있다는 신호다.
  ///
  /// 🔴 `late final` 로 두면 안 된다. 원화가 없어 한 번도 안 쓰인 채 화면이 닫히면
  /// **`dispose` 에서 처음 만들어지면서 터진다** (테스트에서 잡혔다).
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
        vsync: this, duration: kBossEyeBlink, lowerBound: 0.35)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final art = widget.art;
    if (art == null) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (_, box) {
        final size = box.maxHeight * kBossShadowHeight;
        return Stack(
          children: [
            Positioned(
              top: box.maxHeight * kBossShadowBottomY - size,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Stack(children: [
                    // 몸은 통째로 검게 — 그림자와 실제 보스가 반드시 같은 모양이 된다
                    ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                          Color(0xFF0B0F1A), BlendMode.srcATop),
                      child: Image.asset(art,
                          width: size,
                          height: size,
                          filterQuality: kArtFilter),
                    ),
                    ..._eyeDots(size),
                  ]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _eyeDots(double size) {
    final e = widget.eyes;
    if (e == null || e.length < 4) return const [];
    return [
      for (var i = 0; i + 1 < e.length; i += 2)
        Positioned(
          left: e[i] * size - kBossEyeSize / 2,
          top: e[i + 1] * size - kBossEyeSize / 2,
          child: FadeTransition(
            opacity: _blink,
            child: Container(
              width: kBossEyeSize,
              height: kBossEyeSize,
              decoration: const BoxDecoration(
                color: kBossEyeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: kBossEyeColor, blurRadius: 6, spreadRadius: 1)
                ],
              ),
            ),
          ),
        ),
    ];
  }
}
