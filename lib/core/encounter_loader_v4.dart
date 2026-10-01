import 'dart:convert';

import 'combat_board_v4.dart';
import 'combat_engine_v4.dart';
import 'combat_state_v4.dart';
import 'encounter_data_v4.dart';
import 'dungeon_run_state_v4.dart';
import 'hex_coord_v4.dart';
import 'vertical_slice_catalog_v4.dart';

class EncounterLoaderV4 {
  const EncounterLoaderV4();

  List<EncounterDefinitionV4> decode(String source) {
    final root = jsonDecode(source) as Map<String, dynamic>;
    final entries = root['encounters'] as List<dynamic>;

    return [
      for (final raw in entries)
        _decodeEncounter(raw as Map<String, dynamic>),
    ];
  }

  EncounterDefinitionV4 _decodeEncounter(Map<String, dynamic> raw) {
    final map = raw['map'] as Map<String, dynamic>;
    final terrain = <HexCoord, TerrainV4>{};

    final terrainRaw =
        raw['terrain'] as Map<String, dynamic>? ?? const {};

    for (final entry in terrainRaw.entries) {
      final type = _terrain(entry.key);
      final cells = entry.value as List<dynamic>;
      for (final cell in cells) {
        final pair = cell as List<dynamic>;
        terrain[HexCoord(pair[0] as int, pair[1] as int)] = type;
      }
    }

    final spawns = <EncounterSpawnV4>[
      for (final enemy in raw['enemies'] as List<dynamic>)
        _spawn(enemy as Map<String, dynamic>),
    ];

    final rewards =
        raw['rewards'] as Map<String, dynamic>? ?? const {};

    return EncounterDefinitionV4(
      id: raw['id'] as String,
      name: raw['name'] as String,
      columns: map['columns'] as int,
      rows: map['rows'] as int,
      partyIds:
          List<String>.from(raw['party'] as List<dynamic>),
      enemies: spawns,
      terrain: terrain,
      gold: rewards['gold'] as int? ?? 0,
      essence: rewards['essence'] as int? ?? 0,
      optional: raw['optional'] as bool? ?? false,
      boss: raw['boss'] as bool? ?? false,
    );
  }

  EncounterSpawnV4 _spawn(Map<String, dynamic> raw) {
    final position = raw['position'] as List<dynamic>;
    return EncounterSpawnV4(
      instanceId: raw['instanceId'] as String,
      templateId: raw['templateId'] as String,
      anchor: HexCoord(
        position[0] as int,
        position[1] as int,
      ),
    );
  }

  TerrainV4 _terrain(String value) => switch (value) {
        'cover' => TerrainV4.cover,
        'forest' => TerrainV4.forest,
        'water' => TerrainV4.water,
        'fire' => TerrainV4.fire,
        'block' => TerrainV4.block,
        _ => TerrainV4.normal,
      };

  CombatEngineV4 buildEngine(
    EncounterDefinitionV4 encounter, {
    required int seed,
    DungeonCarryStateV4? carry,
  }) {
    final units = VerticalSliceCatalogV4.partyFor(
      encounter.partyIds,
    );

    carry?.applyTo(units);

    for (final spawn in encounter.enemies) {
      units.add(VerticalSliceCatalogV4.enemy(
        spawn.templateId,
        spawn.instanceId,
        spawn.anchor,
      ));
    }

    return CombatEngineV4(
      units: units,
      seed: seed,
      board: CombatBoardV4(
        columns: encounter.columns,
        rows: encounter.rows,
        terrain: Map.of(encounter.terrain),
      ),
    );
  }
}
