/// 길 옆 물체 — 걸어가는 연출 (`GAME_DESIGN.md` 6.7절 ①).
///
/// **배경 판은 움직이지 않는다.** 스테이지를 넘길 때 캐릭터가 앞으로 걸어가고,
/// 그동안 좌우의 나무·바위가 **원근 길을 따라 내려오며 커진다.**
/// 참고 게임 실측에서도 달·산·지평선·길·보스는 고정이고 좌우 기둥만 움직였다.
///
/// 그림 전체를 위아래로 미는 옛 방식은 폐기됐다 — 원근 그림을 밀면 작게 그린
/// 먼 물체가 가까운 자리로 내려와 크기가 틀린 것이 드러난다.
library;

import 'dart:math';

import 'package:flutter/material.dart';

import '../core/layout.dart';
import 'art_sprite.dart';

/// 길 옆에 세우는 물체의 종류. 원화가 들어오면 [kRoadsideAssets]만 채우면 된다.
enum RoadsideKind { tree, rock, bush }

/// 종류 → 원화 경로. **아직 비어 있다** (`ART_REQUEST_LAYERS.md`로 발주 예정).
/// 비어 있으면 단색 사각형으로 그린다 — 경로·크기·속도는 진짜와 똑같이 움직인다.
const Map<RoadsideKind, String> kRoadsideAssets = {};

/// 원화가 없을 때 쓰는 임시 색 (판정용). 원화가 들어오면 안 쓰인다.
const Map<RoadsideKind, Color> kRoadsidePlaceholder = {
  RoadsideKind.tree: Color(0xFF2E5B3A),
  RoadsideKind.rock: Color(0xFF5A5A64),
  RoadsideKind.bush: Color(0xFF3E7A46),
};

/// 물체 하나. **거리 하나만 들고 나머지는 전부 계산이다.**
class RoadsideObject {
  const RoadsideObject({
    required this.kind,
    required this.onLeft,
    required this.distance,
  });

  final RoadsideKind kind;

  /// 길의 왼쪽에 서 있나 (아니면 오른쪽)
  final bool onLeft;

  /// 카메라에서의 거리. [kRoadsideNear]에서 가장 가깝고 [kRoadsideFar]에서 가장 멀다.
  final double distance;

  /// 원근 진행도. 0 = 소실점(아주 멀다) · 1 = 화면 아래(가장 가깝다).
  double get t => roadsideT(distance);
}

/// 거리 → 원근 진행도.
///
/// **거리의 역수다.** 화면 세로 위치와 크기가 둘 다 거리의 역수에 비례하므로,
/// 이렇게 잡으면 물체가 **소실점에서 뻗어 나오는 직선**을 따라 움직인다.
/// 별도 보정이 필요 없다.
///
/// 🔴 **거리를 등속으로 줄이면 t는 뒤로 갈수록 빨라진다.** 가까워질수록 빨리
/// 스쳐 가는 것이 실제로 그렇게 보인다. **t를 직접 등속으로 올리지 마라.**
double roadsideT(double distance) =>
    (kRoadsideNear / max(distance, kRoadsideNear)).clamp(0.0, 1.0);

/// 진행도 → 물체 **밑동**이 놓이는 세로 위치 (무대 상자 높이의 비율, 위가 0).
double roadsideBottomY(double t) =>
    kRoadHorizonY + (1.0 - kRoadHorizonY) * t.clamp(0.0, 1.0);

/// 진행도 → 물체의 **안쪽 가장자리**가 가운데에서 벌어진 거리
/// (무대 상자 **가로**의 비율). 소실점에서는 0이고 가까울수록 벌어진다.
double roadsideSpread(double t) => kRoadNearSpread * t.clamp(0.0, 1.0);

/// 진행도 → 물체 높이 (무대 상자 높이의 비율).
double roadsideHeight(double t) => kRoadNearHeight * t.clamp(0.0, 1.0);

/// 한 바퀴 길이. 이만큼 걸으면 물체가 맨 뒤에서 맨 앞까지 한 번 지나간다.
const double _cycle = kRoadsideFar - kRoadsideNear;

/// [phase]인 물체가 [walked]만큼 걸어온 시점의 거리.
///
/// 나머지 연산으로 **자동으로 되돌아오므로** 물체를 지우고 새로 만들 필요가 없다.
/// 개수가 항상 일정하다.
double roadsideDistance(double phase, double walked) {
  final within = (phase + walked * kRoadsideStep) % _cycle;
  return kRoadsideFar - within;
}

/// [regionId]·[floor]의 배치. **같은 값이면 항상 같은 배치**여야 한다 —
/// 화면을 다시 그릴 때마다 나무가 옮겨 다니면 안 되므로 시드를 고정한다.
///
/// [floor]는 소수를 받는다. 층을 넘기는 동안 이전 층에서 지금 층으로 이어 흐른다.
List<RoadsideObject> roadsideLayout(int regionId, double floor) {
  final phases = _phasesFor(regionId);
  return [
    for (var i = 0; i < phases.length; i++)
      RoadsideObject(
        kind: RoadsideKind.values[i % RoadsideKind.values.length],
        onLeft: i.isEven,
        distance: roadsideDistance(phases[i], floor),
      ),
  ];
}

/// 지역마다 고정된 위상. 지역이 달라지면 배치도 달라진다.
List<double> _phasesFor(int regionId) {
  final random = Random(regionId * 7919);
  return [
    for (var i = 0; i < kRoadsidePerSide * 2; i++) random.nextDouble() * _cycle,
  ];
}

/// 길 옆 물체 겹. 배경 판 **위**, 몬스터 **아래**에 깐다.
///
/// 전투 화면은 층마다 새로 열리므로 **뜰 때 한 번** 이전 층 자리에서 지금 층
/// 자리로 흘린다. 1층은 이전 자리가 없어 안 흐른다.
class RoadsideLayer extends StatefulWidget {
  const RoadsideLayer({
    super.key,
    required this.regionId,
    required this.floor,
  });

  final int regionId;

  /// 지금 층 (1부터)
  final int floor;

  @override
  State<RoadsideLayer> createState() => _RoadsideLayerState();
}

class _RoadsideLayerState extends State<RoadsideLayer>
    with SingleTickerProviderStateMixin {
  late final _walk =
      AnimationController(vsync: this, duration: kWalkTransition);
  late final Animation<double> _eased =
      CurvedAnimation(parent: _walk, curve: Curves.easeInOut);

  /// 1층은 걷지 않는다 — 방금 이 지역에 들어왔다
  late double _from = (widget.floor - 1).toDouble();
  late double _to = widget.floor.toDouble();

  double get _now => _from + (_to - _from) * _eased.value;

  @override
  void initState() {
    super.initState();
    _walk.forward();
  }

  @override
  void didUpdateWidget(RoadsideLayer old) {
    super.didUpdateWidget(old);
    if (widget.floor == old.floor && widget.regionId == old.regionId) return;
    _from = _now;
    _to = widget.floor.toDouble();
    _walk.forward(from: 0);
  }

  @override
  void dispose() {
    _walk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _eased,
        builder: (_, _) =>
            RoadsideView(regionId: widget.regionId, floor: _now),
      );
}

/// 한 순간의 배치를 그린다. 흐르지 않는 순수 그림이라 테스트가 이것을 쓴다.
class RoadsideView extends StatelessWidget {
  const RoadsideView({
    super.key,
    required this.regionId,
    required this.floor,
  });

  final int regionId;

  /// 걸어온 층. 소수를 넣으면 층과 층 사이의 한 순간이 된다
  final double floor;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, box) {
          final objects = roadsideLayout(regionId, floor)
            // 먼 것부터 그려야 가까운 것이 위에 온다
            ..sort((a, b) => a.t.compareTo(b.t));
          return Stack(
            children: [
              for (final o in objects) _positioned(o, box.maxWidth, box.maxHeight),
            ],
          );
        },
      );

  Widget _positioned(RoadsideObject o, double w, double h) {
    final t = o.t;
    final height = roadsideHeight(t) * h;
    final offset = roadsideSpread(t) * w;
    // 🔴 **안쪽 가장자리**를 기준으로 놓는다. 중심으로 놓으면 물체가 커질 때
    // 가운데 길을 덮는다 — 화면에서 잡혔다 (2026-09-13)
    return Positioned(
      // 밑동이 길 위에 닿게 놓는다
      top: roadsideBottomY(t) * h - height,
      left: o.onLeft ? w / 2 - offset - height : w / 2 + offset,
      width: height,
      height: height,
      child: _art(o, height),
    );
  }

  /// 원화가 있으면 그것을, 없으면 단색 사각형을 그린다.
  /// **그림이 들어오면 이 함수 하나만 바뀐다.**
  Widget _art(RoadsideObject o, double size) {
    final asset = kRoadsideAssets[o.kind];
    if (asset != null) {
      return Image.asset(asset,
          height: size, filterQuality: kArtFilter, fit: BoxFit.contain);
    }
    return DecoratedBox(
      decoration: BoxDecoration(color: kRoadsidePlaceholder[o.kind]),
    );
  }
}
