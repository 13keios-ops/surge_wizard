import 'combat_board_v4.dart';
import 'combat_state_v4.dart';
import 'hex_coord_v4.dart';

enum AutoIntentKindV4 { attack, move, wait }

class AutoIntentV4 {
  const AutoIntentV4._({
    required this.kind,
    this.targetId,
    this.destination,
  });

  const AutoIntentV4.attack(String targetId)
      : this._(kind: AutoIntentKindV4.attack, targetId: targetId);

  const AutoIntentV4.move(HexCoord destination)
      : this._(kind: AutoIntentKindV4.move, destination: destination);

  const AutoIntentV4.wait()
      : this._(kind: AutoIntentKindV4.wait);

  final AutoIntentKindV4 kind;
  final String? targetId;
  final HexCoord? destination;
}

/// Minimal deterministic AUTO used by the first Vertical Slice.
///
/// It intentionally does not know the full spell catalog yet:
/// 1) attack an adjacent enemy, preferring killable/low-HP targets;
/// 2) otherwise move toward the nearest enemy;
/// 3) otherwise wait.
class AutoPlannerV4 {
  const AutoPlannerV4();

  AutoIntentV4 choose({
    required CombatUnitV4 actor,
    required List<CombatUnitV4> units,
    required CombatBoardV4 board,
  }) {
    final enemies = units
        .where((u) => !u.isKo && u.team != actor.team)
        .toList(growable: false);

    if (enemies.isEmpty) return const AutoIntentV4.wait();

    final adjacent = enemies
        .where((u) => board.adjacent(actor.anchor, u.anchor))
        .toList()
      ..sort((a, b) {
        final hp = a.hp.compareTo(b.hp);
        if (hp != 0) return hp;
        return a.id.compareTo(b.id);
      });

    if (adjacent.isNotEmpty) {
      return AutoIntentV4.attack(adjacent.first.id);
    }

    final reachable = board.reachable(
      unit: actor,
      units: units,
    );
    if (reachable.length <= 1) return const AutoIntentV4.wait();

    final sortedDestinations = reachable.keys
        .where((coord) => coord != actor.anchor)
        .toList();

    sortedDestinations.sort((a, b) {
      int nearestDistance(HexCoord c) => enemies
          .map((enemy) => c.distanceTo(enemy.anchor))
          .reduce((x, y) => x < y ? x : y);

      final da = nearestDistance(a);
      final db = nearestDistance(b);
      if (da != db) return da.compareTo(db);

      final ca = reachable[a] ?? 999;
      final cb = reachable[b] ?? 999;
      if (ca != cb) return ca.compareTo(cb);

      if (a.col != b.col) return a.col.compareTo(b.col);
      return a.row.compareTo(b.row);
    });

    return AutoIntentV4.move(sortedDestinations.first);
  }
}

