import 'combat_state_v4.dart';

class PartyCarryUnitV4 {
  PartyCarryUnitV4({
    required this.hp,
    required this.mp,
    this.startBarrier = 0,
  });

  int hp;
  int mp;
  int startBarrier;
}

class DungeonCarryStateV4 {
  DungeonCarryStateV4({
    required this.party,
    this.hpPotions = 2,
  });

  final Map<String, PartyCarryUnitV4> party;
  int hpPotions;

  int potionsUsed = 0;

  DungeonCarryStateV4 copy() {
    final clone = DungeonCarryStateV4(
      hpPotions: hpPotions,
      party: {
        for (final entry in party.entries)
          entry.key: PartyCarryUnitV4(
            hp: entry.value.hp,
            mp: entry.value.mp,
            startBarrier: entry.value.startBarrier,
          ),
      },
    );
    clone.potionsUsed = potionsUsed;
    return clone;
  }

  static DungeonCarryStateV4 fromParty(
    Iterable<CombatUnitV4> units, {
    int hpPotions = 2,
  }) {
    return DungeonCarryStateV4(
      hpPotions: hpPotions,
      party: {
        for (final unit in units)
          if (unit.team == CombatTeamV4.party)
            unit.id: PartyCarryUnitV4(
              hp: unit.hp,
              mp: unit.mp,
            ),
      },
    );
  }

  void captureAfterVictory(
    Iterable<CombatUnitV4> units, {
    bool reviveKoToOne = true,
  }) {
    for (final unit in units) {
      if (unit.team != CombatTeamV4.party) continue;

      party.putIfAbsent(
        unit.id,
        () => PartyCarryUnitV4(hp: unit.hp, mp: unit.mp),
      );

      final carry = party[unit.id]!;
      carry.hp = reviveKoToOne && unit.hp <= 0 ? 1 : unit.hp;
      carry.mp = unit.mp;
      carry.startBarrier = 0;
    }
  }

  void applyTo(Iterable<CombatUnitV4> units) {
    for (final unit in units) {
      if (unit.team != CombatTeamV4.party) continue;
      final carry = party[unit.id];
      if (carry == null) continue;

      unit.hp = carry.hp.clamp(0, unit.stats.maxHp).toInt();
      unit.mp = carry.mp.clamp(0, unit.stats.maxMp).toInt();

      if (carry.startBarrier > 0) {
        final cap = (unit.stats.maxHp * 0.50).floor();
        final amount = carry.startBarrier > cap
            ? cap
            : carry.startBarrier;
        unit.barriers.add(BarrierV4(
          amount: amount,
          remainingActivations: 99,
          sourceId: 'ancient_focus',
        ));
        carry.startBarrier = 0;
      }
    }
  }

  void applyBossAntechamberCheckpoint(
    Iterable<CombatUnitV4> partyUnits, {
    int wizardMpFloor = 100,
    int startBarrier = 10,
  }) {
    for (final unit in partyUnits) {
      if (unit.team != CombatTeamV4.party) continue;

      final carry = party[unit.id];
      if (carry == null) continue;

      carry.hp = unit.stats.maxHp;
      carry.startBarrier = startBarrier;
      if (unit.id == 'wizard') {
        carry.mp = carry.mp < wizardMpFloor
            ? wizardMpFloor.clamp(0, unit.stats.maxMp).toInt()
            : carry.mp;
      }
    }
  }

  void applyAncientFocusReward(
    Iterable<CombatUnitV4> partyUnits, {
    int wizardMpBonus = 40,
    int partyBarrier = 25,
  }) {
    for (final unit in partyUnits) {
      if (unit.team != CombatTeamV4.party) continue;
      final carry = party[unit.id];
      if (carry == null) continue;

      if (unit.id == 'wizard') {
        carry.mp = (carry.mp + wizardMpBonus)
            .clamp(0, unit.stats.maxMp)
            .toInt();
      }
      carry.startBarrier = partyBarrier;
    }
  }

  void useBetweenFightPotions(
    Iterable<CombatUnitV4> partyUnits, {
    double triggerRatio = 0.35,
    double stopRatio = 0.45,
  }) {
    if (hpPotions <= 0) return;

    final byId = {
      for (final unit in partyUnits)
        if (unit.team == CombatTeamV4.party) unit.id: unit,
    };

    while (hpPotions > 0) {
      String? lowestId;
      double lowestRatio = 2;

      for (final entry in party.entries) {
        final unit = byId[entry.key];
        if (unit == null) continue;

        final ratio = entry.value.hp / unit.stats.maxHp;
        if (ratio < lowestRatio) {
          lowestRatio = ratio;
          lowestId = entry.key;
        }
      }

      if (lowestId == null || lowestRatio >= triggerRatio) break;

      final unit = byId[lowestId]!;
      final carry = party[lowestId]!;
      final heal = 24 + (unit.stats.maxHp * 0.15).round();

      carry.hp = (carry.hp + heal)
          .clamp(0, unit.stats.maxHp)
          .toInt();

      hpPotions--;
      potionsUsed++;

      final newRatio = carry.hp / unit.stats.maxHp;
      if (newRatio >= stopRatio) continue;
    }
  }
}

class DungeonRunTelemetryV4 {
  const DungeonRunTelemetryV4({
    required this.seed,
    required this.routeId,
    required this.completed,
    required this.encountersCleared,
    required this.potionsRemaining,
    required this.potionsUsed,
    required this.wizardMpRemaining,
    required this.partyHpRatio,
    required this.partyKoAtEnd,
    required this.surgeCount,
    required this.unstableCount,
  });

  final int seed;
  final String routeId;
  final bool completed;
  final int encountersCleared;
  final int potionsRemaining;
  final int potionsUsed;
  final int wizardMpRemaining;
  final double partyHpRatio;
  final int partyKoAtEnd;
  final int surgeCount;
  final int unstableCount;
}
