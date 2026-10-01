import 'combat_engine_v4.dart';
import 'combat_state_v4.dart';
import 'hex_coord_v4.dart';

CombatEngineV4 buildVerticalSliceFixtureV4({
  int seed = 23092026,
}) {
  final engine = CombatEngineV4(
    seed: seed,
    units: [
      CombatUnitV4(
        id: 'wizard',
        name: 'Wizard',
        team: CombatTeamV4.party,
        anchor: const HexCoord(1, 3),
        stats: const UnitStatsV4(
          maxHp: 60,
          maxMp: 126,
          speed: 106,
          move: 2,
          evasion: 12,
          fortitude: 12,
          resolve: 14,
          brace: 12,
          armor: 1,
          magicResist: 1,
        ),
        primaryModifier: 3,
        secondaryModifier: 1,
        weaponPower: 7,
        mastery: 1,
        equipmentAccuracy: 1,
      ),
      CombatUnitV4(
        id: 'kael',
        name: 'Kael',
        team: CombatTeamV4.party,
        anchor: const HexCoord(1, 2),
        stats: const UnitStatsV4(
          maxHp: 102,
          speed: 104,
          move: 2,
          evasion: 12,
          fortitude: 14,
          resolve: 11,
          brace: 14,
          armor: 3,
        ),
        primaryModifier: 3,
        secondaryModifier: 1,
        weaponPower: 9,
        mastery: 2,
      ),
      CombatUnitV4(
        id: 'nera',
        name: 'Nera',
        team: CombatTeamV4.party,
        anchor: const HexCoord(1, 4),
        stats: const UnitStatsV4(
          maxHp: 72,
          speed: 114,
          move: 3,
          evasion: 14,
          fortitude: 12,
          resolve: 12,
          brace: 12,
          armor: 1,
        ),
        primaryModifier: 3,
        secondaryModifier: 1,
        weaponPower: 7,
        mastery: 2,
      ),
      CombatUnitV4(
        id: 'goblin_a',
        name: 'Goblin A',
        team: CombatTeamV4.enemy,
        anchor: const HexCoord(6, 1),
        stats: const UnitStatsV4(
          maxHp: 36,
          speed: 110,
          move: 3,
          evasion: 13,
          fortitude: 11,
          resolve: 11,
          brace: 11,
          armor: 1,
        ),
        primaryModifier: 2,
        weaponPower: 7,
        mastery: 1,
      ),
      CombatUnitV4(
        id: 'goblin_b',
        name: 'Goblin B',
        team: CombatTeamV4.enemy,
        anchor: const HexCoord(7, 2),
        stats: const UnitStatsV4(
          maxHp: 36,
          speed: 110,
          move: 3,
          evasion: 13,
          fortitude: 11,
          resolve: 11,
          brace: 11,
          armor: 1,
        ),
        primaryModifier: 2,
        weaponPower: 7,
        mastery: 1,
      ),
      CombatUnitV4(
        id: 'elder_slime',
        name: 'Elder Slime',
        team: CombatTeamV4.enemy,
        anchor: const HexCoord(6, 3),
        size: UnitSizeV4.large3,
        controlProfile: ControlProfileV4.boss,
        stats: const UnitStatsV4(
          maxHp: 135,
          speed: 82,
          move: 2,
          evasion: 9,
          fortitude: 14,
          resolve: 11,
          brace: 15,
          magicResist: 1,
        ),
        primaryModifier: 2,
        weaponPower: 9,
        mastery: 1,
        immunities: {
          StatusTypeV4.bleeding,
        },
        weaknesses: {
          DamageTypeV4.frost,
        },
      ),
    ],
  );

  // Vertical Slice preview opens on the protagonist rather than on a speed tie.
  engine.unit('wizard').nextActionTime = 0;
  engine.unit('nera').nextActionTime = 8;
  engine.unit('kael').nextActionTime = 12;
  engine.unit('goblin_a').nextActionTime = 18;
  engine.unit('goblin_b').nextActionTime = 22;
  engine.unit('elder_slime').nextActionTime = 35;
  return engine;
}
