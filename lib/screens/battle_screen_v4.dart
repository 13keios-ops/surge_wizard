import 'package:flutter/material.dart';

import '../models/battle_v4_models.dart';
import '../widgets/battle_hud_v4.dart';
import '../widgets/hex_board_v4.dart';
import 'battle_preview_controller_v4.dart';

class BattleScreenV4 extends StatelessWidget {
  const BattleScreenV4({super.key, required this.controller});
  final BattlePreviewControllerV4 controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final party = controller.units
            .where((unit) => unit.team == V4Team.party)
            .toList(growable: false);
        final boss = controller.boss;
        return Scaffold(
          backgroundColor: const Color(0xFF17191D),
          body: SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              final compact = constraints.maxHeight < 410;
              return Stack(children: [
                Positioned(
                  left: compact ? 68 : 62,
                  top: compact ? 48 : 56,
                  right: compact ? 68 : 62,
                  bottom: compact ? 76 : 92,
                  child: HexBoardV4(
                    units: controller.units,
                    activeUnit: controller.activeUnit,
                    onBoardTap: controller.handleBoardTap,
                    onCategory: controller.selectCategory,
                    onSkill: controller.selectSkill,
                    onBack: controller.backToCategories,
                    onMove: controller.enterMoveMode,
                    onUnit: controller.selectUnit,
                    columns: controller.boardColumns,
                    rows: controller.boardRows,
                    terrain: controller.terrain,
                    telegraphHexes: controller.telegraphHexes,
                    targetHexes: controller.targetHexes,
                    reachableHexes: controller.reachableHexes,
                    opportunityWarningHexes: controller.opportunityWarningHexes,
                    interactionMode: controller.interactionMode,
                    selectedCategory: controller.selectedCategory,
                    skills: controller.currentSkills,
                    selectedSkillId: controller.selectedSkillId,
                    moveEnabled: controller.canEnterMoveMode,
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 4,
                  width: 48,
                  height: 48,
                  child: _BackButton(onTap: () {
                    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                  }),
                ),
                Positioned(
                  left: constraints.maxWidth * 0.22,
                  right: constraints.maxWidth * 0.24,
                  top: 4,
                  height: compact ? 42 : 46,
                  child: TimelineV4(ids: controller.timeline, units: controller.units),
                ),
                Positioned(
                  right: 8,
                  top: 4,
                  width: 184,
                  height: 46,
                  child: AutoSpeedControlsV4(
                    auto: controller.auto,
                    speed: controller.speed,
                    onAuto: controller.toggleAuto,
                    onSpeed: controller.setSpeed,
                  ),
                ),
                if (boss != null)
                  Positioned(
                    left: constraints.maxWidth * 0.29,
                    right: constraints.maxWidth * 0.29,
                    top: compact ? 48 : 54,
                    height: compact ? 18 : 20,
                    child: BossBarV4(boss: boss),
                  ),
                Positioned(
                  left: 10,
                  bottom: 8,
                  width: compact ? 220 : 232,
                  height: compact ? 70 : 82,
                  child: PartyHudV4(party: party),
                ),
                Positioned(
                  right: 10,
                  bottom: 8,
                  width: compact ? 216 : 228,
                  height: compact ? 112 : 126,
                  child: TargetPreviewV4(
                    preview: controller.preview,
                    onCommit: controller.canCommit ? controller.commit : null,
                  ),
                ),
                Positioned(
                  left: constraints.maxWidth * 0.34,
                  right: constraints.maxWidth * 0.34,
                  bottom: 5,
                  height: 28,
                  child: _CombatToast(text: controller.latestLog),
                ),
              ]);
            }),
          ),
        );
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xC91B1D25),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Icon(Icons.pause, size: 22),
        ),
      );
}

class _CombatToast extends StatelessWidget {
  const _CombatToast({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xAD111319),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            maxLines: 1,
            style: const TextStyle(fontSize: 10, color: Color(0xFFDAD7E1)),
          ),
        ),
      );
}
