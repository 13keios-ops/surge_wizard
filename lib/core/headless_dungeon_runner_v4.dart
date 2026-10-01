import 'combat_state_v4.dart';
import 'dungeon_run_state_v4.dart';
import 'encounter_data_v4.dart';
import 'encounter_loader_v4.dart';
import 'headless_policy_v4.dart';
import 'vertical_slice_catalog_v4.dart';

class HeadlessDungeonRunnerV4 {
  const HeadlessDungeonRunnerV4({
    this.maxActivationsPerEncounter = 500,
  });

  final int maxActivationsPerEncounter;

  DungeonRunTelemetryV4 run({
    required List<EncounterDefinitionV4> allEncounters,
    required int seed,
    required bool includeOptionalB04,
    int initialHpPotions = 2,
  }) {
    final byId = {
      for (final encounter in allEncounters)
        encounter.id: encounter,
    };

    final route = [
      'VS_B02_RUIN_COURTYARD',
      'VS_B03_ARCHIVE_HALL',
      if (includeOptionalB04) 'VS_B04_OPTIONAL_SEAL_ROOM',
      'VS_B05_BONE_HEAP',
    ];

    final initialParty = [
      VerticalSliceCatalogV4.wizard(),
      VerticalSliceCatalogV4.kael(),
      VerticalSliceCatalogV4.nera(),
    ];

    final carry = DungeonCarryStateV4.fromParty(
      initialParty,
      hpPotions: initialHpPotions,
    );

    var cleared = 0;
    var surgeCount = 0;
    var unstableCount = 0;
    List<CombatUnitV4> lastParty = initialParty;

    for (var index = 0; index < route.length; index++) {
      final encounter = byId[route[index]]!;
      final engine = const EncounterLoaderV4().buildEngine(
        encounter,
        seed: seed + index * 100003,
        carry: carry,
      );
      const policy = HeadlessPolicyV4();

      var activations = 0;

      while (!engine.battleOver &&
          activations < maxActivationsPerEncounter) {
        final actor = engine.beginNextActivation();
        if (actor == null) break;
        if (!engine.activationOpen) continue;

        activations++;
        policy.takeActivation(engine);
      }

      surgeCount += engine.log
          .where((e) => e.kind == 'cast_surge')
          .length;
      unstableCount += engine.log
          .where((e) => e.kind == 'cast_unstable')
          .length;

      lastParty = engine.units
          .where((u) => u.team == CombatTeamV4.party)
          .toList(growable: false);

      if (engine.winner != CombatTeamV4.party) {
        carry.captureAfterVictory(
          lastParty,
          reviveKoToOne: false,
        );
        return _finish(
          seed: seed,
          includeOptionalB04: includeOptionalB04,
          completed: false,
          cleared: cleared,
          carry: carry,
          party: lastParty,
          surgeCount: surgeCount,
          unstableCount: unstableCount,
        );
      }

      cleared++;
      carry.captureAfterVictory(lastParty);

      if (encounter.id == 'VS_B02_RUIN_COURTYARD') {
        carry.useBetweenFightPotions(
          lastParty,
          triggerRatio: 0.55,
          stopRatio: 0.55,
        );
      }

      if (encounter.id == 'VS_B03_ARCHIVE_HALL') {
        carry.applyBossAntechamberCheckpoint(
          lastParty,
          wizardMpFloor: 100,
          startBarrier: 10,
        );
      }

      if (encounter.id == 'VS_B04_OPTIONAL_SEAL_ROOM') {
        carry.applyAncientFocusReward(
          lastParty,
          wizardMpBonus: 40,
          partyBarrier: 25,
        );
      }
    }

    return _finish(
      seed: seed,
      includeOptionalB04: includeOptionalB04,
      completed: true,
      cleared: cleared,
      carry: carry,
      party: lastParty,
      surgeCount: surgeCount,
      unstableCount: unstableCount,
    );
  }

  DungeonRunTelemetryV4 _finish({
    required int seed,
    required bool includeOptionalB04,
    required bool completed,
    required int cleared,
    required DungeonCarryStateV4 carry,
    required List<CombatUnitV4> party,
    required int surgeCount,
    required int unstableCount,
  }) {
    final wizard = party
        .where((u) => u.id == 'wizard')
        .first;

    final hpRatio = party.isEmpty
        ? 0.0
        : party
                .map((u) {
                  final state = carry.party[u.id];
                  final hp = state?.hp ?? u.hp;
                  return hp / u.stats.maxHp;
                })
                .fold<double>(0, (a, b) => a + b) /
            party.length;

    final ko = party
        .where((u) => (carry.party[u.id]?.hp ?? u.hp) <= 0)
        .length;

    return DungeonRunTelemetryV4(
      seed: seed,
      routeId: includeOptionalB04
          ? 'B02-B03-B04-B05'
          : 'B02-B03-B05',
      completed: completed,
      encountersCleared: cleared,
      potionsRemaining: carry.hpPotions,
      potionsUsed: carry.potionsUsed,
      wizardMpRemaining:
          carry.party['wizard']?.mp ?? wizard.mp,
      partyHpRatio: hpRatio,
      partyKoAtEnd: ko,
      surgeCount: surgeCount,
      unstableCount: unstableCount,
    );
  }
}
