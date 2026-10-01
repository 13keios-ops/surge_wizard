import 'combat_engine_v4.dart';
import 'combat_state_v4.dart';
import 'encounter_data_v4.dart';
import 'encounter_loader_v4.dart';
import 'headless_policy_v4.dart';

class HeadlessRunnerV4 {
  const HeadlessRunnerV4({
    this.maxActivations = 400,
  });

  final int maxActivations;

  EncounterRunTelemetryV4 run({
    required EncounterDefinitionV4 encounter,
    required int seed,
  }) {
    final engine = const EncounterLoaderV4().buildEngine(
      encounter,
      seed: seed,
    );
    const policy = HeadlessPolicyV4();

    var activations = 0;
    var playerActivations = 0;
    var enemyActivations = 0;

    while (!engine.battleOver && activations < maxActivations) {
      final actor = engine.beginNextActivation();
      if (actor == null) break;

      if (!engine.activationOpen) continue;

      activations++;
      if (actor.team == CombatTeamV4.party) {
        playerActivations++;
      } else {
        enemyActivations++;
      }

      policy.takeActivation(engine);
    }

    final party = engine.units
        .where((u) => u.team == CombatTeamV4.party)
        .toList(growable: false);

    final wizard =
        party.where((u) => u.id == 'wizard').first;

    final surgeCount = engine.log
        .where((e) => e.kind == 'cast_surge')
        .length;
    final unstableCount = engine.log
        .where((e) => e.kind == 'cast_unstable')
        .length;

    final hpRatio = party.isEmpty
        ? 0.0
        : party
                .map((u) => u.hp / u.stats.maxHp)
                .fold<double>(0, (a, b) => a + b) /
            party.length;

    return EncounterRunTelemetryV4(
      encounterId: encounter.id,
      seed: seed,
      won: engine.winner == CombatTeamV4.party,
      activations: activations,
      playerActivations: playerActivations,
      enemyActivations: enemyActivations,
      partyKo: party.where((u) => u.isKo).length,
      wizardMpRemaining: wizard.mp,
      surgeCount: surgeCount,
      unstableCount: unstableCount,
      partyHpRatio: hpRatio,
    );
  }
}
