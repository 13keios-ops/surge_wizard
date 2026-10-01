import 'combat_board_v4.dart';
import 'combat_engine_v4.dart';
import 'combat_state_v4.dart';
import 'hex_coord_v4.dart';
import 'spell_catalog_v4.dart';
import 'target_resolver_v4.dart';

part 'balanced_auto_wizard_kael_v4.dart';
part 'balanced_auto_nera_scoring_v4.dart';

enum BalancedIntentKindV4 {
  wizardFireball,
  wizardFireBolt,
  wizardDart,
  wizardBind,
  wizardShield,
  kaelQuick,
  kaelHeavy,
  kaelPull,
  kaelGuard,
  neraVital,
  neraExpose,
  neraSmoke,
  wait,
}

class BalancedIntentV4 {
  const BalancedIntentV4({
    required this.kind,
    required this.score,
    this.targetId,
    this.targetHex,
  });

  final BalancedIntentKindV4 kind;
  final double score;
  final String? targetId;
  final HexCoord? targetHex;
}

class BalancedAutoPlannerV4 {
  const BalancedAutoPlannerV4();

  BalancedIntentV4 choose(
    CombatEngineV4 engine,
    CombatUnitV4 actor,
  ) {
    final enemies = engine.units
        .where((u) => !u.isKo && u.team != actor.team)
        .toList(growable: false);
    if (enemies.isEmpty) {
      return const BalancedIntentV4(
        kind: BalancedIntentKindV4.wait,
        score: 0,
      );
    }

    final candidates = switch (actor.id) {
      'wizard' => _wizardCandidates(engine, actor, enemies),
      'kael' => _kaelCandidates(engine, actor, enemies),
      'nera' => _neraCandidates(engine, actor, enemies),
      _ => const <BalancedIntentV4>[],
    };

    if (candidates.isEmpty) {
      return const BalancedIntentV4(
        kind: BalancedIntentKindV4.wait,
        score: 0,
      );
    }

    final sorted = candidates.toList()
      ..sort((a, b) {
        final score = b.score.compareTo(a.score);
        if (score != 0) return score;
        return a.kind.index.compareTo(b.kind.index);
      });
    return sorted.first;
  }
}
