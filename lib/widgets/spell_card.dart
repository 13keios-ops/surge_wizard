import 'package:flutter/material.dart';

import '../art/pixel_sprite.dart';
import '../art/sprite_map.dart';
import '../models/spell.dart';
import 'pixel_ui.dart';

/// 손패의 주문 카드 1장.
///
/// **속성색을 카드 전체에 칠하지 않는다.** 예전에는 카드 바탕이 통째로
/// 주황·파랑·보라라서 화면에서 가장 튀었고, 주인공이어야 할 주사위보다
/// 시선을 끌었다 (GAME_DESIGN 9.5절 1번). 지금은 바탕을 무채색 패널로 두고
/// 속성색은 **아이콘과 위쪽 띠**에만 남긴다.
class SpellCard extends StatelessWidget {
  const SpellCard({
    super.key,
    required this.spell,
    required this.selected,
    required this.sealed,
    this.width = 104,
    this.onTap,
  });

  final Spell spell;
  final bool selected;
  final bool sealed; // 이번 전투 동안 봉인됨
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final look = spellLook(spell);
    final tint = look.tint;
    return Opacity(
      opacity: sealed ? 0.4 : 1,
      child: GestureDetector(
        onTap: sealed ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: width,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            // 바깥 테두리 = 선택 표시. 고를 때만 금색으로 밝아진다.
            color: selected ? kBorderLit : kBorderDim,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              if (selected)
                BoxShadow(color: kGold.withValues(alpha: 0.45), blurRadius: 12),
              const BoxShadow(
                  color: Color(0x77000000), blurRadius: 0, offset: Offset(0, 3)),
            ],
          ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: selected
                    ? const [kBgPanelLit, kBgPanel]
                    : const [kBgPanel, kBgTray],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 속성 띠 — 카드에서 속성색이 남는 유일한 면
                Container(height: 4, color: tint),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 아이콘 — 뒤에 속성색 원광을 옅게 깐다
                      SizedBox(
                        height: 42,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(colors: [
                                  tint.withValues(alpha: 0.35),
                                  tint.withValues(alpha: 0.0),
                                ]),
                              ),
                            ),
                            PixelSpriteView(look.sprite, size: 38, tint: tint),
                          ],
                        ),
                      ),
                      Text(
                        spell.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: kTextMain,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 3),
                      // 위력 표시 — 어두운 알약 안에
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: kBgWell,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          sealed
                              ? '봉인'
                              : spell.baseDamage > 0
                                  ? '◆ ${spell.baseDamage}'
                                      '${spell.dcModifier > 0 ? '  +${spell.dcModifier}' : ''}'
                                  : '보조',
                          style: TextStyle(
                            fontFamily: kFont9,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: sealed ? kHpRed : kTextMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
