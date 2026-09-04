import 'package:flutter/material.dart';

import '../art/pixel_sprite.dart';
import '../art/sprites_items.dart';
import '../art/sprites_monsters.dart';
import 'pixel_ui.dart';

/// 상점(휴식) 화면. 대화상자가 아니라 **NPC 그림 + 큰 인터랙션**으로 만든다
/// (refs/DICERO_ANALYSIS.md §6).
class ShopDialog extends StatelessWidget {
  const ShopDialog({super.key, required this.onRest, required this.healAmount});

  final VoidCallback onRest;

  /// 이번 휴식으로 회복되는 체력. 최대 체력의 비율이라 지역마다 다르므로
  /// 화면에 하드코딩하지 않고 받아서 보여준다 (WORK_ORDER_HEAL_FIX 작업 2).
  final int healAmount;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RibbonBanner(text: '떠돌이 상인', color: kGold, fontSize: 24),
          const SizedBox(height: 10),
          PixelPanel(
            color: kBgPanel,
            borderColor: kGold,
            glow: kGold,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // NPC — 로브를 쓴 상인이 화면을 채운다
                PixelSpriteView(kSpriteRobed, size: 132, tint: kHpGreen),
                const SizedBox(height: 12),
                const Text(
                  '"따뜻한 수프 한 그릇 하고 가시게."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: kTextMain),
                ),
                const SizedBox(height: 16),
                // 회복량을 큼직한 타일로
                PixelPanel(
                  color: kBgPanelLit,
                  borderColor: kHpGreen,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PixelSpriteView(kIconPotion,
                          size: 30, tint: kHpGreen),
                      const SizedBox(width: 12),
                      Text('체력 +$healAmount',
                          style: const TextStyle(
                              fontFamily: kFont9,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: kHpGreen)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: PixelButton(
                    label: '쉬어간다',
                    height: 48,
                    fontSize: 20,
                    onPressed: onRest,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
