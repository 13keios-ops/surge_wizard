/// 전투 화면의 주문 슬롯 5칸.
/// (`battle_overlay.dart` 가 300줄을 넘어 갈라 냈다 — 내용은 그대로다)
library;

import 'package:flutter/material.dart';

import '../art/pixel_sprite.dart';
import '../art/sprite_map.dart';
import '../art/sprites_items.dart';
import '../core/constants.dart';
import '../models/spell.dart';
import 'pixel_ui.dart';

/// 주문 슬롯 5칸. 손패가 채우는 만큼 열리고 **나머지는 잠금 표시**다
/// (GAME_DESIGN 4.2절 「화면 규칙」). 잠긴 칸을 누르면 안내를 띄운다.
///
/// ⚠ 엔진은 아직 「손패」라 슬롯이 매 턴 돌지 않는다. **자리와 잠금 표시만**
/// 먼저 만들어 둔 것이고, 슬롯머신 추첨은 다음 지시서다.
class SpellSlots extends StatelessWidget {
  const SpellSlots({
    super.key,
    required this.hand,
    required this.selected,
    required this.sealedIds,
    required this.onTap,
  });

  final List<Spell> hand;
  final int? selected;
  final Set<String> sealedIds;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kSlotsHeight,
      child: Row(
        children: [
          for (var i = 0; i < kSpellSlotCount; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: i < hand.length
                  ? _OpenSlot(
                      spell: hand[i],
                      selected: selected == i,
                      sealed: sealedIds.contains(hand[i].id),
                      onTap: () => onTap(i),
                    )
                  : const _LockedSlot(),
            ),
          ],
        ],
      ),
    );
  }
}

class _OpenSlot extends StatelessWidget {
  const _OpenSlot({
    required this.spell,
    required this.selected,
    required this.sealed,
    required this.onTap,
  });

  final Spell spell;
  final bool selected;
  final bool sealed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final look = spellLook(spell);
    return Opacity(
      opacity: sealed ? 0.42 : 1,
      child: GestureDetector(
        onTap: sealed ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected
                ? kBgPanelLit.withValues(alpha: 0.82)
                : kBgPanel.withValues(alpha: 0.66),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
                color: selected ? kBorderLit : kBorderDim, width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0x59000000), blurRadius: 6,
                  offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: kSpellIconBox,
                child: Center(
                  child: PixelSpriteView(look.sprite,
                      size: kSpellIconSize, tint: look.tint),
                ),
              ),
              Text(
                spell.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: kFont11, fontSize: 12, height: 1,
                    color: kTextMain),
              ),
              const SizedBox(height: 2),
              Text(
                sealed ? '봉인' : '◆ ${spell.baseDamage}',
                style: TextStyle(
                    fontFamily: kFont11, fontSize: 12, height: 1,
                    color: sealed ? kHpRed : kTextDim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 잠긴 칸 — **글자를 쓰지 않는다** (검토 31 · 2-3절).
/// `GAME_DESIGN.md` 4.2절이 「유료」임을 보이는 곳을 **스킬 탭**으로 갈라 놨으므로
/// 전투 화면에는 **금색 자물쇠 하나**만 둔다. 금색은 이 게임에서
/// **「구매로만 열린다」**는 뜻이고(회색은 레벨·진행), 그래서 문구 없이도 읽힌다.
class _LockedSlot extends StatelessWidget {
  const _LockedSlot();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('스킬 탭에서 슬롯을 확장할 수 있습니다',
                style: TextStyle(fontFamily: kFont9, fontSize: 10)),
            duration: Duration(milliseconds: 1400),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: kBgWell.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: kBorderDim, width: 2),
          ),
          // 머티리얼 벡터 아이콘은 픽셀 톤에서 튄다 — 도트 자물쇠를 쓴다
          child: const Center(
            child: PixelSpriteView(kIconLock, size: 24, tint: kGold),
          ),
        ),
      ),
    );
  }
}
