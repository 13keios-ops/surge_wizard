import 'package:flutter/material.dart';

import '../art/pixel_sprite.dart';
import 'pixel_ui.dart';

/// 보상 선택용 가로 전체폭 배너 카드 (refs/DICERO_ANALYSIS.md §5).
/// 구조: [아이콘 박스] + [이름 알약] / [설명 한 줄], 우상단에 「추천」 뱃지.
class RewardBannerCard extends StatelessWidget {
  const RewardBannerCard({
    super.key,
    required this.sprite,
    required this.tint,
    required this.name,
    required this.description,
    required this.selected,
    this.badge,
    this.rarityColor = kManaBlue,
    this.onTap,
  });

  final PixelSprite sprite;
  final Color tint;
  final String name;
  final String description;
  final bool selected;

  /// 「추천」 같은 뱃지 문구. null이면 안 그린다.
  final String? badge;

  /// 카드 바탕색을 정하는 등급 색
  final Color rarityColor;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final base = Color.lerp(rarityColor, Colors.black, 0.45)!;
    final lit = Color.lerp(rarityColor, Colors.white, 0.15)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          // 선택되면 바깥 테두리가 금색으로 바뀐다
          color: selected ? kBorderLit : base,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            if (selected)
              BoxShadow(
                  color: rarityColor.withValues(alpha: 0.6), blurRadius: 14),
            const BoxShadow(
                color: Color(0x77000000), blurRadius: 0, offset: Offset(0, 4)),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [lit, rarityColor]
                  : [rarityColor, Color.lerp(rarityColor, base, 0.5)!],
            ),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.white24, width: 1.5),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  // 아이콘 박스
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      border: Border.all(color: Colors.white54, width: 2),
                    ),
                    child: PixelSpriteView(sprite, size: 38, tint: tint),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 이름 알약
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0x44000000),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: kFont9,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 2)
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 2)
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (badge != null)
                Positioned(
                  right: -6,
                  top: -12,
                  child: PixelBadge(text: badge!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
