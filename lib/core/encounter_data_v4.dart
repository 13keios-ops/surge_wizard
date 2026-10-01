import 'combat_state_v4.dart';
import 'hex_coord_v4.dart';

class EncounterSpawnV4 {
  const EncounterSpawnV4({
    required this.instanceId,
    required this.templateId,
    required this.anchor,
  });

  final String instanceId;
  final String templateId;
  final HexCoord anchor;
}

class EncounterDefinitionV4 {
  const EncounterDefinitionV4({
    required this.id,
    required this.name,
    required this.columns,
    required this.rows,
    required this.partyIds,
    required this.enemies,
    required this.terrain,
    required this.gold,
    required this.essence,
    this.optional = false,
    this.boss = false,
  });

  final String id;
  final String name;
  final int columns;
  final int rows;
  final List<String> partyIds;
  final List<EncounterSpawnV4> enemies;
  final Map<HexCoord, TerrainV4> terrain;
  final int gold;
  final int essence;
  final bool optional;
  final bool boss;
}

class EncounterRunTelemetryV4 {
  const EncounterRunTelemetryV4({
    required this.encounterId,
    required this.seed,
    required this.won,
    required this.activations,
    required this.playerActivations,
    required this.enemyActivations,
    required this.partyKo,
    required this.wizardMpRemaining,
    required this.surgeCount,
    required this.unstableCount,
    required this.partyHpRatio,
  });

  final String encounterId;
  final int seed;
  final bool won;
  final int activations;
  final int playerActivations;
  final int enemyActivations;
  final int partyKo;
  final int wizardMpRemaining;
  final int surgeCount;
  final int unstableCount;
  final double partyHpRatio;
}
