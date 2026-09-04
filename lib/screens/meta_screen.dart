import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../art/pixel_sprite.dart';
import '../art/sprite_map.dart';
import '../art/sprites_items.dart';
import '../core/constants.dart';
import '../data/parser.dart';
import '../models/spell.dart';
import '../widgets/pixel_ui.dart';
import 'meta_controller.dart';

/// 강화별 아이콘
const Map<MetaUpgrade, PixelSprite> _upgradeIcons = {
  MetaUpgrade.maxHp: kIconHeart,
  MetaUpgrade.maxMana: kIconPotion,
  MetaUpgrade.startReroll: kIconHourglass,
  MetaUpgrade.startRelic: kIconRing,
};

/// 영구 강화 화면: 마력 결정으로 강화를 사고 epic 주문을 해금한다.
class MetaScreen extends StatelessWidget {
  const MetaScreen({super.key, required this.data});

  final GameData data;

  @override
  Widget build(BuildContext context) {
    final meta = context.watch<MetaController>();
    final lockedEpics = data.spells
        .where((s) =>
            s.rarity == 'epic' && !meta.state.unlockedSpellIds.contains(s.id))
        .toList();

    return Scaffold(
      backgroundColor: kBgDeep,
      appBar: AppBar(
        backgroundColor: kBgPanel,
        title: const Text('영구 강화',
            style: TextStyle(
                fontFamily: kFont9,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(
              children: [
                const PixelSpriteView(kIconGem, size: 20, tint: kCharge),
                const SizedBox(width: 6),
                Text('${meta.crystals}',
                    style: const TextStyle(
                        fontFamily: kFont9,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: kCharge)),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('강화',
              style: TextStyle(
                  fontFamily: kFont9,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: kGold)),
          const SizedBox(height: 8),
          for (final u in MetaUpgrade.values) _UpgradeTile(upgrade: u),
          const SizedBox(height: 22),
          const Text('주문 해금',
              style: TextStyle(
                  fontFamily: kFont9,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: kGold)),
          const SizedBox(height: 4),
          Text('해금한 주문은 전투 보상에 등장한다  (각 $kSpellUnlockCost)',
              style: const TextStyle(
                  fontFamily: kFont9, fontSize: 10, color: kTextDim)),
          const SizedBox(height: 8),
          if (lockedEpics.isEmpty)
            const PixelPanel(
              child: Text('모든 주문을 해금했다!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kGold)),
            ),
          for (final s in lockedEpics) _SpellUnlockTile(spell: s),
        ],
      ),
    );
  }
}

/// 강화 1줄
class _UpgradeTile extends StatelessWidget {
  const _UpgradeTile({required this.upgrade});

  final MetaUpgrade upgrade;

  @override
  Widget build(BuildContext context) {
    final meta = context.watch<MetaController>();
    final level = meta.levelOf(upgrade);
    final cost = meta.nextCost(upgrade);
    final maxed = cost == null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: PixelPanel(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        borderColor: maxed ? kGold.withValues(alpha: 0.5) : kBorderDim,
        child: Row(
          children: [
            PixelSpriteView(_upgradeIcons[upgrade]!, size: 28, tint: kGold),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(upgrade.label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: kTextMain)),
                  const SizedBox(height: 3),
                  PixelPips(
                      filled: level,
                      total: upgrade.maxLevel,
                      color: kGold,
                      size: 9),
                ],
              ),
            ),
            if (maxed)
              const Text('MAX',
                  style: TextStyle(
                      fontWeight: FontWeight.w900, color: kGold))
            else
              SizedBox(
                width: 76,
                child: PixelButton(
                  label: '$cost',
                  height: 34,
                  fontSize: 12,
                  icon: const PixelSpriteView(kIconGem, size: 14, tint: kCharge),
                  onPressed: meta.canBuy(upgrade)
                      ? () => context.read<MetaController>().buy(upgrade)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// epic 주문 해금 1줄
class _SpellUnlockTile extends StatelessWidget {
  const _SpellUnlockTile({required this.spell});

  final Spell spell;

  @override
  Widget build(BuildContext context) {
    final meta = context.watch<MetaController>();
    final look = spellLook(spell);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: PixelPanel(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        borderColor: look.tint.withValues(alpha: 0.4),
        child: Row(
          children: [
            PixelSpriteView(look.sprite, size: 28, tint: look.tint),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spell.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: kTextMain)),
                  Text('위력 ${spell.baseDamage} · ${spell.description}',
                      style: const TextStyle(
                          fontFamily: kFont9, fontSize: 10, color: kTextDim)),
                ],
              ),
            ),
            SizedBox(
              width: 76,
              child: PixelButton(
                label: '$kSpellUnlockCost',
                height: 34,
                fontSize: 12,
                icon: const PixelSpriteView(kIconGem, size: 14, tint: kCharge),
                onPressed: meta.crystals >= kSpellUnlockCost
                    ? () =>
                        context.read<MetaController>().unlockSpell(spell.id)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
