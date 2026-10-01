import 'combat_state_v4.dart';

bool isNegativeStatusV4(StatusTypeV4 type) => switch (type) {
      StatusTypeV4.burning ||
      StatusTypeV4.bleeding ||
      StatusTypeV4.poisoned ||
      StatusTypeV4.slowed ||
      StatusTypeV4.rooted ||
      StatusTypeV4.stunned ||
      StatusTypeV4.exposed ||
      StatusTypeV4.weakened ||
      StatusTypeV4.disrupted => true,
      _ => false,
    };

int maxStacksV4(StatusTypeV4 type) => switch (type) {
      StatusTypeV4.burning => 3,
      StatusTypeV4.bleeding => 3,
      StatusTypeV4.poisoned => 2,
      _ => 1,
    };

bool isStackingV4(StatusTypeV4 type) =>
    maxStacksV4(type) > 1;

String? bossConversionV4(
  CombatUnitV4 target,
  StatusTypeV4 type,
) {
  final profile = target.controlProfile;

  if (type == StatusTypeV4.stunned &&
      (profile == ControlProfileV4.boss ||
          profile == ControlProfileV4.hugeBoss)) {
    return 'STAGGER_40';
  }

  if (type == StatusTypeV4.rooted) {
    if (profile == ControlProfileV4.hugeBoss) return 'SLOW_25';
    if (profile == ControlProfileV4.boss) return 'SLOW_25';
  }

  return null;
}

void applyStatusV4({
  required CombatUnitV4 target,
  required StatusTypeV4 type,
  required int duration,
  int stacks = 1,
  int potency = 0,
  int tickPower = 0,
  String? sourceId,
}) {
  if (target.immunities.contains(type)) return;

  final conversion = bossConversionV4(target, type);
  if (conversion == 'SLOW_25') {
    applyStatusV4(
      target: target,
      type: StatusTypeV4.slowed,
      duration: duration,
      potency: 25,
      sourceId: sourceId,
    );
    return;
  }

  if (conversion == 'STAGGER_40') return;

  final existing = target.status(type);
  if (existing == null) {
    target.statuses.add(StatusV4(
      type: type,
      remainingActivations: duration,
      stacks: stacks.clamp(1, maxStacksV4(type)).toInt(),
      potency: potency,
      sourceId: sourceId,
      tickPower: tickPower,
    ));
    return;
  }

  if (isStackingV4(type)) {
    existing.stacks =
        (existing.stacks + stacks).clamp(1, maxStacksV4(type)).toInt();
  }
  existing.remainingActivations =
      existing.remainingActivations > duration
          ? existing.remainingActivations
          : duration;

  if (potency > existing.potency) existing.potency = potency;
  if (tickPower > existing.tickPower) existing.tickPower = tickPower;
  if (sourceId != null) existing.sourceId = sourceId;
}

void clearOnKoV4(CombatUnitV4 unit) {
  unit.statuses.removeWhere(
    (status) =>
        isNegativeStatusV4(status.type) ||
        status.type == StatusTypeV4.marked,
  );
  unit.barriers.clear();
}

int poisonHealingPenaltyPercentV4(CombatUnitV4 unit) {
  final poison = unit.status(StatusTypeV4.poisoned);
  if (poison == null) return 0;
  return (poison.stacks * 20).clamp(0, 40).toInt();
}
