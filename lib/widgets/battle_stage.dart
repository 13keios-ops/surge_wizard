import 'dart:math';

import 'package:flutter/material.dart';

import '../art/pixel_sprite.dart';
import '../art/spell_fx.dart';
import '../art/sprite_map.dart';
import '../art/sprites_characters.dart';
import '../art/stage_backdrop.dart';
import '../core/battle.dart';
import '../core/check.dart';
import '../screens/battle_controller.dart';
import 'battle_popup.dart';
import 'battle_stage_hud.dart';
import 'pixel_ui.dart';

/// 전투 무대. 원근 구도 + 배경 아트 + 마법 이펙트를 한 화면에 합친다.
/// 적은 위쪽에 작게(멀리), 마법사는 아래쪽에 크게(가까이) 뒷모습으로 선다.
class BattleStage extends StatefulWidget {
  const BattleStage(
      {super.key, required this.controller, this.floor, this.floors});

  final BattleController controller;

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
            from: const Offset(0.5, 0.74),
            to: failed ? const Offset(0.5, 0.70) : const Offset(0.5, 0.34),
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => _buildStage(constraints.maxHeight),
    );
  }

  Widget _buildStage(double h) {
    final battle = _battle;
    final look = enemyLook(battle.enemy.id);
    final palette = BackdropPalette.forFloor(widget.floor ?? 1);
    final enemyLine = h * 0.52;
    final enemySize =
        (h * (battle.enemy.isBoss ? 0.44 : 0.37)).clamp(50.0, 118.0);
    final wizardSize = (h * 0.50).clamp(64.0, 142.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: h,
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [_ambient, _fx, _enemyHit, _playerHit]),
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
            final knock = _enemyHit.isAnimating
                ? -(1 - _enemyHit.value) * 7
                : 0.0;
            return Stack(
              children: [
                Positioned.fill(
                  child: StageBackdrop(
                      palette: palette, time: _ambient.value),
                ),
                // 적 — 위쪽, 단 위에
                Positioned(
                  top: enemyLine - enemySize + 4 + knock + enemyBreathe,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Transform.scale(
                      // 맞는 순간 살짝 찌그러진다
                      scaleY: _enemyHit.isAnimating
                          ? 1 - (1 - _enemyHit.value) * 0.14
                          : 1,
                      child: PixelSpriteView(
                        look.sprite,
                        size: enemySize,
                        tint: look.tint,
                        halo: kSpriteHalo,
                        shadow: true,
                        flashAmount: _enemyHit.isAnimating
                            ? (1 - _enemyHit.value) * 0.85
                            : 0,
                      ),
                    ),
                  ),
                ),
                // 마법사 — 아래쪽 뒷모습
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, castLean + breathe),
                      child: PixelSpriteView(
                        kSpriteWizardBack,
                        size: wizardSize,
                        tint: kWizardTint,
                        halo: kSpriteHalo,
                        shadow: true,
                        flashAmount: _playerHit.isAnimating
                            ? (1 - _playerHit.value) * 0.7
                            : 0,
                      ),
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
                // 적 정보
                Positioned(
                  left: 8,
                  right: 8,
                  top: 6,
                  child: EnemyHeader(battle: battle),
                ),
                if (widget.floor != null)
                  Positioned(
                    left: 6,
                    top: h * 0.30,
                    child: NodeTrack(
                        floor: widget.floor!,
                        floors: widget.floors ?? widget.floor!),
                  ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: PlayerStatus(battle: battle),
                ),
                for (final p in _popups)
                  PopupText(key: ValueKey(p.id), popup: p),
              ],
            );
          },
        ),
      ),
    );
  }
}
