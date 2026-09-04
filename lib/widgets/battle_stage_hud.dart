/// 전투 무대 위에 얹히는 정보 조각 — 층 트랙 · 적 머리글 · 내 체력.
/// (battle_stage.dart 가 300줄을 넘어 갈라 냈다 — 내용은 그대로다)
library;

import 'package:flutter/material.dart';

import '../core/battle.dart';
import 'floor_tile.dart';
import 'pixel_ui.dart';

/// 좌측 세로 노드 트랙 — 앞으로 올 층을 아이콘으로 보여준다
class NodeTrack extends StatelessWidget {
  const NodeTrack(
      {super.key, required this.floor, required this.floors});

  final int floor;
  final int floors;

  @override
  Widget build(BuildContext context) {
    final shown = <int>[
      for (var f = floor; f <= floor + 2 && f < floors; f++) f,
      floors,
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      decoration: BoxDecoration(
        color: kBgWell.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: kBorderDim, width: 1),
      ),
      child: Column(
        children: [
          for (final f in shown.reversed) ...[
            _NodeChip(
                floor: f, current: f == floor, style: floorEventLook(f, floors)),
            if (f != shown.first)
              const Text('·',
                  style: TextStyle(
                      fontFamily: kFont9, fontSize: 10, color: kTextDim)),
          ],
        ],
      ),
    );
  }
}

class _NodeChip extends StatelessWidget {
  const _NodeChip({
    required this.floor,
    required this.current,
    required this.style,
  });

  final int floor;
  final bool current;
  final (String, Color) style;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: current ? style.$2 : kBgTray,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
                color: current ? Colors.white : style.$2, width: 1.5),
          ),
          child: Text(style.$1, style: const TextStyle(fontSize: 12)),
        ),
        Text('$floor',
            style: TextStyle(
                fontFamily: kFont9,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: current ? Colors.white : kTextDim)),
      ],
    );
  }
}

/// 화면 상단의 적 이름 + 체력 + 다음 행동 예고
class EnemyHeader extends StatelessWidget {
  const EnemyHeader({super.key, required this.battle});

  final Battle battle;

  @override
  Widget build(BuildContext context) {
    final enemy = battle.enemy;
    final t = battle.telegraph;
    final showValue = t.action == 'attack' || t.action == 'charge';
    final icon = switch (t.action) {
      'attack' => '⚠',
      'charge' => '◎',
      'defend' => '◈',
      _ => '♥',
    };
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                enemy.isBoss ? '★ ${enemy.name}' : enemy.name,
                style: const TextStyle(
                  fontFamily: kFont9,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 4),
                    Shadow(color: Colors.black, offset: Offset(1, 1)),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (battle.enemyShield > 0)
              Text('◈${battle.enemyShield}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: kManaBlue)),
          ],
        ),
        const SizedBox(height: 2),
        PixelBar(
          value: battle.enemyHp / enemy.hp,
          color: kHpRed,
          height: 14,
          label: '${battle.enemyHp} / ${enemy.hp}',
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: kBgWell.withValues(alpha: 0.87),
            border: Border.all(color: kGold, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            '$icon ${t.label}${showValue ? ' ${t.value}' : ''}'
            '${battle.enemyDelayTurns > 0 ? '  (지연됨)' : ''}',
            style: const TextStyle(
                fontFamily: kFont9,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: kGold),
          ),
        ),
      ],
    );
  }
}

/// 우측 하단 플레이어 체력
class PlayerStatus extends StatelessWidget {
  const PlayerStatus({super.key, required this.battle});

  final Battle battle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (battle.shield > 0)
            Text('◈ 방어막 ${battle.shield}',
                style: const TextStyle(
                  fontFamily: kFont9,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: kManaBlue,
                  shadows: [Shadow(color: Colors.black, blurRadius: 3)],
                )),
          const SizedBox(height: 2),
          PixelBar(
            value: battle.playerHp / battle.playerMaxHp,
            color: kHpGreen,
            height: 14,
            label: '${battle.playerHp} / ${battle.playerMaxHp}',
          ),
        ],
      ),
    );
  }
}
