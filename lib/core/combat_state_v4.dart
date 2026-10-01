import 'hex_coord_v4.dart';

enum CombatTeamV4 { party, enemy }

enum UnitSizeV4 { normal, large3, huge7 }

enum DefenseV4 { evasion, fortitude, resolve, brace }

enum DamageTypeV4 {
  physical,
  arcane,
  fire,
  frost,
  lightning,
  holy,
  poison,
}

enum TerrainV4 { normal, cover, forest, water, fire, block }

enum StatusTypeV4 {
  burning,
  bleeding,
  poisoned,
  slowed,
  rooted,
  stunned,
  exposed,
  weakened,
  disrupted,
  guarded,
  haste,
  marked,
}

enum ControlProfileV4 { normal, elite, boss, hugeBoss }

class UnitStatsV4 {
  const UnitStatsV4({
    required this.maxHp,
    required this.speed,
    required this.move,
    required this.evasion,
    required this.fortitude,
    required this.resolve,
    required this.brace,
    this.maxMp = 0,
    this.armor = 0,
    this.magicResist = 0,
  });

  final int maxHp;
  final int maxMp;
  final int speed;
  final int move;
  final int evasion;
  final int fortitude;
  final int resolve;
  final int brace;
  final int armor;
  final int magicResist;

  int defense(DefenseV4 defense) => switch (defense) {
        DefenseV4.evasion => evasion,
        DefenseV4.fortitude => fortitude,
        DefenseV4.resolve => resolve,
        DefenseV4.brace => brace,
      };
}

class StatusV4 {
  StatusV4({
    required this.type,
    required this.remainingActivations,
    this.stacks = 1,
    this.potency = 0,
    this.sourceId,
    this.tickPower = 0,
  });

  final StatusTypeV4 type;
  int remainingActivations;
  int stacks;
  int potency;
  String? sourceId;

  /// DOT snapshot from the moment the status was applied.
  int tickPower;
}

class BarrierV4 {
  BarrierV4({
    required this.amount,
    required this.remainingActivations,
    required this.sourceId,
  });

  int amount;
  int remainingActivations;
  final String sourceId;
}

class CombatUnitV4 {
  CombatUnitV4({
    required this.id,
    required this.name,
    required this.team,
    required this.stats,
    required this.anchor,
    this.size = UnitSizeV4.normal,
    this.controlProfile = ControlProfileV4.normal,
    this.primaryModifier = 0,
    this.secondaryModifier = 0,
    this.weaponPower = 0,
    this.mastery = 0,
    this.equipmentAccuracy = 0,
    this.weaknesses = const {},
    this.resistances = const {},
    this.immunities = const {},
    int? hp,
    int? mp,
  })  : hp = hp ?? stats.maxHp,
        mp = mp ?? stats.maxMp;

  final String id;
  final String name;
  final CombatTeamV4 team;
  final UnitStatsV4 stats;
  HexCoord anchor;
  final UnitSizeV4 size;
  final ControlProfileV4 controlProfile;

  final int primaryModifier;
  final int secondaryModifier;
  final int weaponPower;
  final int mastery;
  final int equipmentAccuracy;

  /// Mutable encounter mechanic hook. Bone Heap Fractured Core uses +1.
  int incomingAccuracyBonus = 0;

  final Set<DamageTypeV4> weaknesses;
  final Set<DamageTypeV4> resistances;
  final Set<StatusTypeV4> immunities;

  int hp;
  int mp;
  int nextActionTime = 0;
  bool reactionAvailable = true;

  final List<StatusV4> statuses = [];
  final List<BarrierV4> barriers = [];

  bool get isKo => hp <= 0;

  StatusV4? status(StatusTypeV4 type) {
    for (final value in statuses) {
      if (value.type == type) return value;
    }
    return null;
  }

  bool has(StatusTypeV4 type) => status(type) != null;

  int get barrierTotal => barriers.fold(0, (sum, value) => sum + value.amount);

  Iterable<HexCoord> get occupiedHexes {
    switch (size) {
      case UnitSizeV4.normal:
        return <HexCoord>[anchor];
      case UnitSizeV4.large3:
        final n = anchor.neighbors();
        return <HexCoord>[
          anchor,
          if (n.isNotEmpty) n[0],
          if (n.length > 1) n[1],
        ];
      case UnitSizeV4.huge7:
        return <HexCoord>[anchor, ...anchor.neighbors()];
    }
  }
}


class CombatEventV4 {
  const CombatEventV4({
    required this.time,
    required this.kind,
    required this.actorId,
    this.targetId,
    this.value,
    this.message,
    this.dice = const [],
  });

  final int time;
  final String kind;
  final String actorId;
  final String? targetId;
  final int? value;
  final String? message;
  final List<int> dice;
}

class AttackResultV4 {
  const AttackResultV4({
    required this.hit,
    required this.critical,
    required this.damage,
    required this.dice,
    required this.total,
    required this.targetDefense,
  });

  final bool hit;
  final bool critical;
  final int damage;
  final List<int> dice;
  final int total;
  final int targetDefense;
}

class EffectResultV4 {
  const EffectResultV4({
    required this.success,
    required this.dice,
    required this.total,
    required this.targetDefense,
    this.convertedTo,
  });

  final bool success;
  final List<int> dice;
  final int total;
  final int targetDefense;
  final String? convertedTo;
}
