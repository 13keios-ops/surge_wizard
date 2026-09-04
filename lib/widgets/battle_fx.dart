import 'dart:math';

import 'package:flutter/material.dart';

import '../core/check.dart';
import '../core/combo.dart';
import '../screens/battle_controller.dart';
import '../services/sfx_service.dart';
import 'pixel_ui.dart';

/// 판정 결과에 따른 연출 총괄 (GAME_DESIGN 6절 + refs/DICERO_ANALYSIS.md §4):
/// - **모든 타격**에서 화면이 번쩍인다 (대성공은 더 세게·오래)
/// - 폭주: 화면 흔들림 (좌우 8px, 300ms) + 진동 2회
/// - 족보 완성: 화면 가운데 팝업이 팡 터진다
/// - 적에게 들어간 피해: 화면 **오른쪽 가장자리 배너**로 표시
class BattleFx extends StatefulWidget {
  const BattleFx({super.key, required this.controller, required this.child});

  final BattleController controller;
  final Widget child;

  @override
  State<BattleFx> createState() => _BattleFxState();
}

class _BattleFxState extends State<BattleFx> with TickerProviderStateMixin {
  late final AnimationController _flash = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 160));
  late final AnimationController _shake = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));
  late final AnimationController _combo = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  late final AnimationController _dmg = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000));

  CheckResult? _seenResult;
  String _comboText = '';
  double _flashStrength = 0.5;
  int _dealtDamage = 0;
  late int _prevEnemyHp;

  @override
  void initState() {
    super.initState();
    _seenResult = widget.controller.battle.lastResult;
    _prevEnemyHp = widget.controller.battle.enemyHp;
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _flash.dispose();
    _shake.dispose();
    _combo.dispose();
    _dmg.dispose();
    super.dispose();
  }

  static const Map<ComboType, String> _comboLabels = {
    ComboType.pair: '페어!',
    ComboType.triple: '트리플!!',
    ComboType.straight: '스트레이트!',
    ComboType.snakeEyes: '뱀눈...',
  };

  /// 새 판정 결과가 나오면 등급·족보에 맞는 연출을 튼다
  void _onChange() {
    final battle = widget.controller.battle;

    // 적 체력이 줄었으면 피해 배너를 띄운다
    final dealt = _prevEnemyHp - battle.enemyHp;
    _prevEnemyHp = battle.enemyHp;
    if (dealt > 0) {
      _dealtDamage = dealt;
      _dmg.forward(from: 0);
    }

    final result = battle.lastResult;
    if (result == null || identical(result, _seenResult)) return;
    _seenResult = result;

    final comboLabel = _comboLabels[result.combo];
    if (comboLabel != null) {
      _comboText = comboLabel;
      _combo.forward(from: 0);
    }
    // 등급 연출은 실제 적용 등급을 따른다
    switch (battle.lastAppliedGrade ?? result.grade) {
      case CheckGrade.critSuccess:
        SfxService.instance.crit();
        _flashStrength = 1.0; // 대성공은 화면이 완전히 하얘진다
        _flash.forward(from: 0);
      case CheckGrade.failure:
        SfxService.instance.surge();
        _shake.forward(from: 0);
      case CheckGrade.success:
      case CheckGrade.graze:
        SfxService.instance.hit();
        _flashStrength = 0.45; // 일반 타격도 번쩍인다
        _flash.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_flash, _shake, _combo, _dmg]),
      builder: (context, _) {
        // 흔들림: 감쇠하는 사인파로 좌우 최대 8px
        final s = _shake.value;
        final dx = _shake.isAnimating ? sin(s * pi * 6) * 8 * (1 - s) : 0.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Stack(
            children: [
              widget.child,
              if (_flash.isAnimating)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.white.withValues(
                          alpha: (1 - _flash.value) * _flashStrength),
                    ),
                  ),
                ),
              if (_dmg.isAnimating) _buildDamageBanner(),
              if (_combo.isAnimating) _buildComboPopup(),
            ],
          ),
        );
      },
    );
  }

  /// 화면 오른쪽 가장자리에서 슬라이드 인 하는 피해 배너
  Widget _buildDamageBanner() {
    final t = _dmg.value;
    // 앞 15%에 미끄러져 들어오고, 뒤 25%에 빠져나간다
    final slide = t < 0.15
        ? 1 - Curves.easeOut.transform(t / 0.15)
        : (t > 0.75 ? (t - 0.75) / 0.25 : 0.0);
    return Positioned(
      right: 0,
      top: 150,
      child: IgnorePointer(
        child: Transform.translate(
          offset: Offset(slide * 120, 0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 12, 6),
            decoration: BoxDecoration(
              color: kBgWell.withValues(alpha: 0.9),
              border: const Border(
                top: BorderSide(color: kGold, width: 2),
                left: BorderSide(color: kGold, width: 2),
                bottom: BorderSide(color: kGold, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('피해',
                    style: TextStyle(
                        fontFamily: kFont9,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: kTextDim)),
                Text('$_dealtDamage',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: kGold,
                        height: 1.1)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComboPopup() {
    final t = _combo.value;
    final scale =
        t < 0.25 ? Curves.easeOutBack.transform(t / 0.25) : 1.0;
    final fade = t > 0.7 ? 1 - (t - 0.7) / 0.3 : 1.0;
    final isBad = _comboText.contains('뱀눈');
    return Positioned(
      left: 0,
      right: 0,
      top: 210,
      child: IgnorePointer(
        child: Opacity(
          opacity: fade.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale,
            child: Text(
              _comboText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: isBad ? kCharge : kGold,
                shadows: [
                  Shadow(
                      color: (isBad ? kCharge : kGold)
                          .withValues(alpha: 0.8),
                      blurRadius: 16),
                  const Shadow(color: Colors.black, blurRadius: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
