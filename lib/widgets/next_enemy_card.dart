import 'package:flutter/material.dart';

import '../art/pixel_sprite.dart';
import '../art/sprite_map.dart';
import '../models/enemy.dart';
import 'pixel_ui.dart';

/// 지도 아래쪽 「다음 상대」 (UI_DESIGN 5-4).
/// 이름 · HP · 공격력을 미리 보여준다. **변종은 이름 앞머리로 드러난다**
/// (「굶주린 고블린 정찰병」처럼 조립 단계에서 수식어가 붙는다 — enemy_builder.dart).
class NextEnemyCard extends StatelessWidget {
  const NextEnemyCard({super.key, required this.enemy});

  final Enemy enemy;

  /// 패턴에서 가장 센 한 방 (공격·강타 중 최댓값). 없으면 0.
  int get _attack => enemy.pattern
      .where((a) => a.action == 'attack' || a.action == 'charge')
      .fold(0, (m, a) => a.value > m ? a.value : m);

  @override
  Widget build(BuildContext context) {
    final look = enemyLook(enemy.id);
    return PixelPanel(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      borderColor: enemy.isBoss ? kHpRed : kBorderDim,
      child: Row(
        children: [
          PixelSpriteView(look.sprite, size: 40, tint: look.tint, flip: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('다음 상대',
                    style: TextStyle(
                        fontFamily: kFont9, fontSize: 10, color: kTextDim)),
                Text(enemy.name,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: kTextMain),
                    overflow: TextOverflow.ellipsis),
                Text('HP ${enemy.hp}  ·  공격 $_attack',
                    style: const TextStyle(
                        fontFamily: kFont9, fontSize: 10, color: kTextDim)),
              ],
            ),
          ),
          if (enemy.isBoss) const PixelBadge(text: '보스'),
        ],
      ),
    );
  }
}
