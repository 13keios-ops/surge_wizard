import 'package:flutter/material.dart';

import '../art/pixel_sprite.dart';
import '../art/sprite_map.dart';
import '../core/constants.dart';
import '../screens/run_controller.dart';
import 'pixel_ui.dart';

/// 지도 화면의 플레이어 요약: 체력 · 마력 축적 · 손패 · 유물.
/// (map_screen.dart 에서 갈라 냈다 — 내용은 그대로다)
class RunSummary extends StatelessWidget {
  const RunSummary({super.key, required this.run});

  final RunController run;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('체력 ',
                  style: TextStyle(
                      fontFamily: kFont9, fontSize: 10, color: kTextDim)),
              Expanded(
                child: PixelBar(
                  value: run.state.hp / run.maxHp,
                  color: kHpGreen,
                  height: 14,
                  label: '${run.state.hp} / ${run.maxHp}',
                ),
              ),
              const SizedBox(width: 10),
              PixelPips(
                  filled: run.state.charge,
                  total: kChargeThreshold,
                  color: kCharge,
                  size: 10),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final s in run.hand)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: PixelSpriteView(spellLook(s).sprite,
                      size: 20, tint: spellLook(s).tint),
                ),
              if (run.relics.isNotEmpty) ...[
                const Text('  |  ',
                    style: TextStyle(
                        fontFamily: kFont9, fontSize: 10, color: kTextDim)),
                for (final r in run.relics)
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: PixelSpriteView(relicLook(r).sprite,
                        size: 18, tint: relicLook(r).tint),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
