import 'dart:math';

import 'package:flutter/material.dart';

import '../art/art_sprite.dart';
import '../art/pixel_sprite.dart';
import '../art/spell_fx.dart';
import '../art/sprite_map.dart';
import '../art/sprites_characters.dart';
import '../core/battle.dart';
import '../core/check.dart';
import '../core/constants.dart';
import '../screens/battle_controller.dart';
import 'battle_popup.dart';
import 'stage_layers.dart';
import 'battle_overlay.dart';
import 'battle_stage_hud.dart';
import 'pixel_ui.dart';

/// 전투 무대. 원근 구도 + 배경 아트 + 마법 이펙트를 한 화면에 합친다.
/// 적은 위쪽에 작게(멀리), 마법사는 아래쪽에 크게(가까이) 뒷모습으로 선다.
class BattleStage extends StatefulWidget {
  const BattleStage(
      {super.key,
      required this.controller,
      this.regionId,
      this.floor,
      this.floors});

  final BattleController controller;

  /// 현재 지역 — 배경 원화가 있는 지역이면 그것을 깐다
  final int? regionId;

  /// 현재 층 — 배경 테마와 좌측 노드 트랙에 쓴다
  final int? floor;

  /// 이 스테이지의 총 층수. 마지막 층이 보스다
  final int? floors;

  @override
  State<BattleStage> createState() => _BattleStageState();
}

class _BattleStageState extends State<BattleStage>
    with TickerProviderStateMixin {
  final List<DamagePopup> _popups = [];
  late int _prevEnemyHp;
  late int _prevPlayerHp;
  int _seenCastId = 0;

  /// 배경 별·안개 흔들림용 (아주 느리게 반복)
  late final AnimationController _ambient = AnimationController(
      vsync: this, duration: const Duration(seconds: 6))
    ..repeat();

  /// 마법 이펙트 1회 재생
  late final AnimationController _fx = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 950));

  /// 피격 번쩍임 (적)
  late final AnimationController _enemyHit = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 260));

  /// 피격 번쩍임 (플레이어)
  late final AnimationController _playerHit = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 260));

  SpellFxSpec? _fxSpec;

  Battle get _battle => widget.controller.battle;

  @override
  void initState() {
    super.initState();
    _prevEnemyHp = _battle.enemyHp;
    _prevPlayerHp = _battle.playerHp;
    _seenCastId = widget.controller.castId;
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _ambient.dispose();
    _fx.dispose();
    _enemyHit.dispose();
    _playerHit.dispose();
    super.dispose();
  }

  void _onChange() {
    final c = widget.controller;

    // 시전이 일어났으면 마법 이펙트를 쏜다
    if (c.castId != _seenCastId) {
      _seenCastId = c.castId;
      final spell = c.lastCastSpell;
      if (spell != null) {
        final failed = _battle.lastResult?.grade == CheckGrade.failure;
        final style = fxStyleFor(failed ? 'surge' : spell.element);
        setState(() {
          _fxSpec = SpellFxSpec(
            // 마법사 손끝 → 적 몸통
            from: const Offset(0.5, 0.55),
            to: failed ? const Offset(0.5, 0.52) : const Offset(0.5, 0.33),
            shape: failed ? SpellFxShape.skull : style.shape,
            core: failed ? const Color(0xFFE8D6FF) : style.core,
            glow: failed ? const Color(0xFF9A4FD0) : style.glow,
            power: c.lastCastPower.clamp(0.6, 3.0),
          );
        });
        _fx.forward(from: 0);
      }
    }

    // 체력 변화 → 숫자 팝업 + 피격 번쩍임
    final enemyDiff = _battle.enemyHp - _prevEnemyHp;
    final playerDiff = _battle.playerHp - _prevPlayerHp;
    _prevEnemyHp = _battle.enemyHp;
    _prevPlayerHp = _battle.playerHp;
    if (enemyDiff != 0) {
      _spawn(enemyDiff > 0 ? '+$enemyDiff' : '${-enemyDiff}',
          enemyDiff > 0 ? kHpGreen : kGold, true);
      if (enemyDiff < 0) _enemyHit.forward(from: 0);
    }
    if (playerDiff != 0) {
      _spawn(playerDiff > 0 ? '+$playerDiff' : '${-playerDiff}',
          playerDiff > 0 ? kHpGreen : kHpRed, false);
      if (playerDiff < 0) _playerHit.forward(from: 0);
    }
  }

  void _spawn(String text, Color color, bool onEnemy) {
    final p = DamagePopup(text, color, onEnemy);
    setState(() => _popups.add(p));
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _popups.remove(p));
    });
  }

  @override
  Widget build(BuildContext context) => _buildStage();

  /// 원화가 있는 적은 원화로, 없으면 기존 픽셀 스프라이트로 그린다.
  Widget _enemyView(String? art, SpriteLook look, double size, double flash) {
    final dots = PixelSpriteView(
      look.sprite,
      size: size,
      tint: look.tint,
      halo: kSpriteHalo,
      shadow: true,
      flashAmount: flash,
    );
    if (art == null) return dots;
    // 색조를 입히지 않는다 — 원화가 제 색을 갖고 있다
    return ArtSpriteView(art,
        size: size, shadow: true, flashAmount: flash, fallback: dots);
  }

  /// 발 높이(화면 아래 dp)를 **상자 아래끝 높이**로 바꾼다. 원화는 캔버스 안
  /// 발바닥선(477/512)이 발이라 상자 아래에 여백이 남고, 픽셀 스프라이트는 상자
  /// 아랫변에서 4dp 위가 발이다. 안 맞추면 원화만 땅에 파묻힌다.
  double _boxBottom(double foot, double size, bool isArt) =>
      foot - (isArt ? size * (1 - kArtFootLine) : 4.0);

  /// 무대 = **화면 전체**. v3에서 어두운 트레이 상자를 없앴으므로 배경이 아래까지
  /// 흐르고 조작부가 그 위에 뜬다. 캐릭터 자리는 전부 `layout.dart` 의
  /// 「화면 아래에서 몇 dp」 상수로 잡는다 — 기기 비율이 달라져도 관계가 안 변한다.
  Widget _buildStage() {
    final battle = _battle;
    final look = enemyLook(battle.enemy.id);
    final bgArt = kArtRegionBackdrops[widget.regionId];
    final enemyArt = kArtEnemies[battle.enemy.id];
    final isBoss = battle.enemy.isBoss;
    final foeSize = isBoss ? kBossSize : kEnemySize;
    final foeFoot = isBoss ? kBossFoot : kFoeFrontFoot;

    return AnimatedBuilder(
      animation: Listenable.merge([_ambient, _fx, _enemyHit, _playerHit]),
      builder: (context, _) {
        // 시전 중이면 마법사가 살짝 뒤로 젖혔다 앞으로 나간다
        final castLean = _fx.isAnimating
            ? (_fx.value < 0.25
                ? -_fx.value * 12
                : (_fx.value < 0.4 ? (_fx.value - 0.25) * 60 - 3 : 0.0))
            : 0.0;
        // 숨쉬기 — 위아래로 아주 천천히 흔들린다 (살아 있는 느낌)
        final breathe = sin(_ambient.value * 2 * pi) * 2.0;
        final enemyBreathe = sin(_ambient.value * 2 * pi + 1.4) * 2.6;
        // 적은 맞으면 뒤로 밀린다
        final knock = _enemyHit.isAnimating ? (1 - _enemyHit.value) * 7 : 0.0;
        final enemyFlash =
            _enemyHit.isAnimating ? (1 - _enemyHit.value) * 0.85 : 0.0;
        final playerFlash =
            _playerHit.isAnimating ? (1 - _playerHit.value) * 0.7 : 0.0;

        return Stack(
          children: [
            Positioned.fill(
              child: StageLayers(
                  art: bgArt,
                  time: _ambient.value,
                  regionId: widget.regionId ?? 1,
                  floor: widget.floor ?? 1,
                  summons: battle.surge.summons,
                  data: widget.controller.data,
                  onBossFloor: isBoss),
            ),
            // 적 — 길 위쪽에 선다
            Positioned(
              bottom: _boxBottom(foeFoot, foeSize, enemyArt != null) +
                  knock -
                  enemyBreathe,
              left: 0,
              right: 0,
              child: Center(
                child: Transform.scale(
                  // 맞는 순간 살짝 찌그러진다
                  scaleY: _enemyHit.isAnimating
                      ? 1 - (1 - _enemyHit.value) * 0.14
                      : 1,
                  child: _enemyView(enemyArt, look, foeSize, enemyFlash),
                ),
              ),
            ),
            // 적 상태 — 보스는 발밑에 체력바를 두지 않는다 (화면 맨 위에 있다)
            Positioned(
              bottom: foeFoot - (isBoss ? 20 : kUnitPlateHeight + 20) - 2,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isBoss)
                    UnitPlate(
                      width: foeSize * 0.8,
                      ratio: battle.enemyHp / battle.enemy.hp,
                      color: kHpRed,
                      label: '${battle.enemyHp} / ${battle.enemy.hp}',
                    ),
                  TelegraphChip(battle: battle),
                ],
              ),
            ),
            // 마법사 — 주문 슬롯 바로 위에 뒷모습으로 선다
            Positioned(
              bottom: _boxBottom(kHeroFoot, kWizardSize, true) -
                  castLean -
                  breathe,
              left: 0,
              right: 0,
              child: Center(
                child: WalkingWizardView(
                  floor: widget.floor ?? 1,
                  size: kWizardSize,
                  flashAmount: playerFlash,
                  fallback: PixelSpriteView(
                    kSpriteWizardBack,
                    size: kWizardSize,
                    tint: kWizardTint,
                    halo: kSpriteHalo,
                    flashAmount: playerFlash,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: kHeroFoot - kUnitPlateHeight - 2,
              left: 0,
              right: 0,
              child: Center(
                child: UnitPlate(
                  width: kWizardSize * 0.9,
                  ratio: battle.playerHp / battle.playerMaxHp,
                  color: kHpGreen,
                  label: '${battle.playerHp} / ${battle.playerMaxHp}'
                      '${battle.shield > 0 ? '  ◈${battle.shield}' : ''}',
                ),
              ),
            ),
            // 마법 이펙트 (캐릭터 위에 그린다)
            if (_fx.isAnimating && _fxSpec != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: SpellFxPainter(_fxSpec!, _fx.value),
                  ),
                ),
              ),
            for (final p in _popups) PopupText(key: ValueKey(p.id), popup: p),
          ],
        );
      },
    );
  }
}
