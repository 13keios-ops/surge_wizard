import 'package:flutter/material.dart';

import '../art/sprite_map.dart';
import '../models/relic.dart';
import '../models/spell.dart';
import '../widgets/pixel_ui.dart';
import '../widgets/reward_banner_card.dart';
import 'run_controller.dart';

/// 등급별 표시 색 (카드 바탕색으로 쓴다)
const Map<String, Color> kRarityColors = {
  'common': Color(0xFF5E7BA8),
  'rare': Color(0xFF3F8FD4),
  'epic': Color(0xFFB05FD9),
};

/// 보상 화면: 주문 3장 중 1택(+손패 교체) 또는 유물 3개 중 1택.
/// 가로 배너 카드를 세로로 쌓는 구성 (refs/DICERO_ANALYSIS.md §5).
class RewardScreen extends StatefulWidget {
  const RewardScreen.spells({super.key, required this.run}) : isSpell = true;

  const RewardScreen.relics({super.key, required this.run}) : isSpell = false;

  final RunController run;
  final bool isSpell;

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  int? _picked; // 선택한 보상 인덱스

  @override
  Widget build(BuildContext context) {
    // 화면 전체를 보상 색조로 물들인다
    final tint = widget.isSpell ? kGold : kCharge;
    return Scaffold(
      backgroundColor: kBgDeep,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.4),
            radius: 1.1,
            colors: [tint.withValues(alpha: 0.30), kBgDeep],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: widget.isSpell ? _buildSpellReward() : _buildRelicReward(),
          ),
        ),
      ),
    );
  }

  /// 장식선이 좌우로 뻗은 헤더
  Widget _header(String title, String hint) => Column(
        children: [
          Row(
            children: [
              const Expanded(child: Divider(color: kBorderDim, thickness: 2)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: kGold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
              ),
              const Expanded(child: Divider(color: kBorderDim, thickness: 2)),
            ],
          ),
          const SizedBox(height: 2),
          Text(hint, style: const TextStyle(fontSize: 12, color: kTextDim)),
        ],
      );

  // ── 주문 보상 ──

  Widget _buildSpellReward() {
    final run = widget.run;
    final offers = run.spellOffers;
    // 가장 센 주문을 추천으로 표시
    var best = 0;
    for (var i = 1; i < offers.length; i++) {
      if (offers[i].baseDamage > offers[best].baseDamage) best = i;
    }
    return Column(
      children: [
        _header('주문 보상',
            _picked == null ? '배울 주문을 하나 고르세요' : '어느 주문과 바꿀까요?'),
        const SizedBox(height: 14),
        for (var i = 0; i < offers.length; i++)
          RewardBannerCard(
            sprite: spellLook(offers[i]).sprite,
            tint: spellLook(offers[i]).tint,
            name: offers[i].name,
            description: _spellDesc(offers[i]),
            rarityColor: kRarityColors[offers[i].rarity] ?? kManaBlue,
            selected: _picked == i,
            badge: i == best ? '추천' : null,
            onTap: () => setState(() => _picked = i),
          ),
        if (_picked != null) ...[
          const SizedBox(height: 18),
          const Text('교체할 손패를 고르세요',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: kTextMain)),
          const SizedBox(height: 6),
          for (var slot = 0; slot < run.hand.length; slot++)
            RewardBannerCard(
              sprite: spellLook(run.hand[slot]).sprite,
              tint: spellLook(run.hand[slot]).tint,
              name: run.hand[slot].name,
              description: _spellDesc(run.hand[slot]),
              rarityColor: kBgPanelLit,
              selected: false,
              onTap: () => _confirmSpell(offers[_picked!], slot),
            ),
        ],
        const Spacer(),
        PixelButton(
          label: '건너뛰기',
          height: 42,
          color: kBgPanelLit,
          onPressed: () {
            widget.run.skipSpellReward();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  String _spellDesc(Spell s) => s.baseDamage > 0
      ? '위력 ${s.baseDamage}'
          '${s.dcModifier > 0 ? ' · 난이도 +${s.dcModifier}' : ''}'
          ' · ${s.description}'
      : s.description;

  void _confirmSpell(Spell chosen, int slot) {
    widget.run.takeSpell(chosen, slot);
    Navigator.of(context).pop();
  }

  // ── 유물 보상 ──

  Widget _buildRelicReward() {
    final offers = widget.run.relicOffers;
    const rank = {'epic': 2, 'rare': 1, 'common': 0};
    var best = 0;
    for (var i = 1; i < offers.length; i++) {
      if (rank[offers[i].rarity]! > rank[offers[best].rarity]!) best = i;
    }
    return Column(
      children: [
        _header('유물 보상', '하나를 골라 가져갈 수 있다'),
        const SizedBox(height: 14),
        for (var i = 0; i < offers.length; i++)
          RewardBannerCard(
            sprite: relicLook(offers[i]).sprite,
            tint: relicLook(offers[i]).tint,
            name: offers[i].name,
            description: offers[i].description,
            rarityColor: kRarityColors[offers[i].rarity] ?? kManaBlue,
            selected: _picked == i,
            badge: i == best ? '추천' : null,
            onTap: () => setState(() => _picked = i),
          ),
        const SizedBox(height: 18),
        if (_picked != null)
          SizedBox(
            width: 220,
            child: PixelButton(
              label: '가져간다',
              height: 48,
              fontSize: 20,
              onPressed: () {
                widget.run.takeRelic(offers[_picked!]);
                Navigator.of(context).pop();
              },
            ),
          ),
        const Spacer(),
        PixelButton(
          label: '건너뛰기',
          height: 42,
          color: kBgPanelLit,
          onPressed: () {
            widget.run.skipRelicReward();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

/// 다른 화면에서 쓰는 유물 타일 (등급 색 유지)
class RelicTile extends StatelessWidget {
  const RelicTile({super.key, required this.relic});

  final Relic relic;

  @override
  Widget build(BuildContext context) {
    final look = relicLook(relic);
    return RewardBannerCard(
      sprite: look.sprite,
      tint: look.tint,
      name: relic.name,
      description: relic.description,
      rarityColor: kRarityColors[relic.rarity] ?? kManaBlue,
      selected: false,
    );
  }
}
