import 'package:flutter/material.dart';

import '../art/pixel_sprite.dart';
import '../art/sprite_map.dart';
import '../core/constants.dart';
import 'pixel_ui.dart';

/// 층 종류 → (기호, 색). **지도 화면과 전투 화면의 노드 트랙이 같이 쓴다** —
/// 두 곳에 따로 적으면 반드시 어긋나므로 여기 하나만 둔다.
///
/// 기호는 **갈무리 폰트에 들어 있는 글자만** 쓴다. 없는 글자를 쓰면 시스템
/// 폰트로 대체돼 혼자 매끈하게 보인다. (칼 ⚔ · 자물쇠 🔒 · 왕관 👑 은 없다)
(String, Color) floorEventLook(int floor, int floors) =>
    switch (floorEvent(floor, floors)) {
      FloorEvent.boss => ('⚠', kHpRed), // ⚠ 보스
      FloorEvent.spellReward => ('★', kGold), // ★ 주문 보상
      FloorEvent.relicReward => ('◈', kCharge), // ◈ 유물 보상
      FloorEvent.shop => ('♥', kHpGreen), // ♥ 상점
      // 평범한 전투 — 특별한 층이 돋보이게 눌러둔다
      FloorEvent.battle => ('◆', kBorderDim), // ◆ 전투
    };

/// 층 종류의 이름. 평범한 전투는 빈 문자열이다.
String floorEventLabel(int floor, int floors) =>
    switch (floorEvent(floor, floors)) {
      FloorEvent.boss => '보스',
      FloorEvent.spellReward => '주문 보상',
      FloorEvent.relicReward => '유물 보상',
      FloorEvent.shop => '상점',
      FloorEvent.battle => '',
    };

/// 지도의 층 한 칸. 아래에서 위로 오르는 경로의 한 마디다.
class FloorTile extends StatelessWidget {
  const FloorTile({
    super.key,
    required this.floor,
    required this.floors,
    required this.isCurrent,
    required this.isCleared,
    this.enemyName,
    this.enemyId,
    this.height,
  });

  final int floor;
  final int floors;
  final bool isCurrent;
  final bool isCleared;
  final String? enemyName;
  final String? enemyId;

  /// 칸 하나의 **전체 높이**(바깥 여백 포함). 지도가 층수에 맞춰 계산해 넘긴다.
  /// null 이면 내용이 정하는 자연 높이를 쓴다.
  final double? height;

  /// 칸이 커지면 적 그림도 같이 커진다 (칸만 늘리면 빈 막대가 된다).
  /// 칸이 하한일 때는 [kFloorThumbMinSize] = 지금 크기 그대로다.
  double get _thumbSize {
    final h = height;
    if (h == null) return kFloorThumbMinSize;
    return (h - kFloorTileChrome)
        .clamp(kFloorThumbMinSize, kFloorThumbMaxSize);
  }

  @override
  Widget build(BuildContext context) {
    final event = floorEventLook(floor, floors);
    final tile = Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: _decoration(),
      child: Row(
        children: [
          // 지금 층을 가리키는 화살표 (자리는 늘 잡아 둬 칸이 안 흔들린다)
          SizedBox(
            width: 14,
            child: Text(isCurrent ? '▶' : '',
                style: const TextStyle(fontSize: 12, color: kGold)),
          ),
          _FloorNumber(floor: floor, current: isCurrent, cleared: isCleared),
          const SizedBox(width: 4),
          _EventChip(icon: event.$1, color: event.$2, dim: isCleared),
          const SizedBox(width: 6),
          if (enemyId != null)
            _EnemyThumb(enemyId: enemyId!, size: _thumbSize),
          Expanded(child: _label()),
          _badge(event.$2),
        ],
      ),
    );
    return height == null ? tile : SizedBox(height: height, child: tile);
  }

  BoxDecoration _decoration() => BoxDecoration(
        color: isCurrent ? kBgPanelLit : kBgPanel,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: isCurrent ? kBorderLit : kBorderDim,
            width: isCurrent ? 2 : 1.5),
        boxShadow: isCurrent
            ? [BoxShadow(color: kGold.withValues(alpha: 0.22), blurRadius: 10)]
            : null,
      );

  Widget _label() => Text(
        isCleared ? '통과' : (enemyName ?? '???'),
        style: TextStyle(
            fontSize: 12, color: isCleared ? kTextDim : kTextMain),
        overflow: TextOverflow.ellipsis,
      );

  /// 층 종류 이름 (평범한 전투면 아무것도 안 쓴다)
  Widget _badge(Color color) {
    final text = floorEventLabel(floor, floors);
    if (text.isEmpty) return const SizedBox.shrink();
    return Text(text,
        style: TextStyle(
            fontFamily: kFont9,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isCleared ? kTextDim : color));
  }
}

/// 칸 왼쪽의 층 번호
class _FloorNumber extends StatelessWidget {
  const _FloorNumber(
      {required this.floor, required this.current, required this.cleared});

  final int floor;
  final bool current;
  final bool cleared;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      child: Text('$floor',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: kFont9,
              fontSize: 20,
              // 픽셀 폰트는 기본 줄간격이 넉넉해서 줄을 눌러줘야 칸이 안 커진다
              height: 1,
              fontWeight: FontWeight.w900,
              color: cleared ? kTextDim : (current ? kGold : kTextMain))),
    );
  }
}

/// 지금 층에 서 있는 적의 작은 그림
class _EnemyThumb extends StatelessWidget {
  const _EnemyThumb({required this.enemyId, required this.size});

  final String enemyId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final look = enemyLook(enemyId);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child:
          PixelSpriteView(look.sprite, size: size, tint: look.tint, flip: true),
    );
  }
}

/// 층 종류 기호를 담는 작은 네모
class _EventChip extends StatelessWidget {
  const _EventChip({required this.icon, required this.color, required this.dim});

  final String icon;
  final Color color;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final c = dim ? kBorderDim : color;
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kBgWell,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: c, width: 1.5),
      ),
      child: Text(icon, style: TextStyle(fontSize: 12, color: c, height: 1)),
    );
  }
}
