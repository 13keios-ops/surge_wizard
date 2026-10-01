part of 'battle_preview_controller_v4.dart';

extension BattlePreviewTextV4 on BattlePreviewControllerV4 {
  V4TargetPreview get preview {
    final actor = activeCombatUnit;
    if (actor == null) {
      return V4TargetPreview(
        title: didWin ? '승리' : '전투 종료',
        lines: ['Gold ${encounter.gold}', 'Essence ${encounter.essence}'],
      );
    }

    if (interactionMode == V4InteractionMode.command) {
      return V4TargetPreview(
        title: '${actor.name} · 행동 선택',
        lines: [
          '공격 / 제어 / 방어 / 도구',
          if (canEnterMoveMode) 'MOVE: 이동 후 행동 가능',
          'Potion $hpPotions',
        ],
      );
    }

    if (interactionMode == V4InteractionMode.move) {
      final cost = engine.board.reachable(
        unit: actor,
        units: engine.units,
      )[selectedTarget];
      return V4TargetPreview(
        title: 'MOVE · ${selectedTarget.col},${selectedTarget.row}',
        lines: [
          if (cost != null) 'Move Cost $cost / ${actor.stats.move}',
          if (selectedMoveOpportunityCount > 0)
            '⚠ Opportunity ×$selectedMoveOpportunityCount',
          if (selectedMoveOpportunityCount == 0) 'Opportunity 없음',
          '파란 Hex를 탭하면 즉시 이동',
        ],
      );
    }

    final skill = selectedSkillId;
    if (skill == null) {
      return const V4TargetPreview(title: '스킬 선택', lines: []);
    }
    final spell = _spellForSkill(skill);
    if (spell != null) {
      return V4TargetPreview(
        title: '${spell.name} · ${spell.shape.name}',
        lines: [
          'MP ${spell.manaCost} · Delay ${spell.baseDelay}',
          'Stability DC ${9 + spell.circle}',
          'Stable / Unstable / Surge',
          if (spell.shape == TargetShapeV4.burst7) 'Burst7 고정',
        ],
      );
    }

    return switch (skill) {
      'item.hp_potion' => V4TargetPreview(
          title: 'HP Potion ×$hpPotions',
          lines: const ['24 + MaxHP 15%', 'Delay 90', '전투 중 실제 소모'],
        ),
      'kael.quick' => const V4TargetPreview(
          title: '빠른 베기', lines: ['Accuracy +1', 'Delay 90']),
      'kael.heavy' => const V4TargetPreview(
          title: '강타', lines: ['Power +5', 'Accuracy -1', 'Delay 130']),
      'kael.pull' => const V4TargetPreview(
          title: '갈고리 끌기', lines: ['Range 3', 'vs BRACE', '1 Hex Pull']),
      'kael.guard' => const V4TargetPreview(
          title: '방어 자세', lines: ['Guarded 20%', '2 Activations', 'Delay 95']),
      'nera.vital' => const V4TargetPreview(
          title: '급소 찌르기', lines: ['Exposed 시 Power +10', 'Delay 110']),
      'nera.expose' => const V4TargetPreview(
          title: '약점 노출', lines: ['Range 3', 'vs EVASION', 'Exposed 2']),
      'nera.smoke' => const V4TargetPreview(
          title: '연막 이동', lines: ['Range 3', 'Opportunity 무시', 'Guarded 15%']),
      _ => const V4TargetPreview(title: '알 수 없는 행동', lines: []),
    };
  }

  String get latestLog {
    if (engine.log.isEmpty) return '${encounter.name} 시작';
    final e = engine.log.last;
    final value = e.value == null ? '' : ' ${e.value}';
    return '${e.kind}$value';
  }
}
