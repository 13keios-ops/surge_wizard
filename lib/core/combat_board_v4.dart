import 'combat_state_v4.dart';
import 'hex_coord_v4.dart';

class CombatBoardV4 {
  CombatBoardV4({
    this.columns = 9,
    this.rows = 7,
    Map<HexCoord, TerrainV4>? terrain,
  }) : terrain = terrain ?? {};

  final int columns;
  final int rows;
  final Map<HexCoord, TerrainV4> terrain;

  bool valid(HexCoord c) => c.isValidFor(columns, rows);

  TerrainV4 tile(HexCoord c) => terrain[c] ?? TerrainV4.normal;

  bool blocked(
    HexCoord c, {
    required Iterable<CombatUnitV4> units,
    String? ignoreUnitId,
  }) {
    if (!valid(c) || tile(c) == TerrainV4.block) return true;

    for (final unit in units) {
      if (unit.isKo || unit.id == ignoreUnitId) continue;
      if (unit.occupiedHexes.contains(c)) return true;
    }
    return false;
  }

  int movementCost(HexCoord c) => switch (tile(c)) {
        TerrainV4.water => 2,
        TerrainV4.block => 999,
        _ => 1,
      };

  bool providesCover(HexCoord c) =>
      tile(c) == TerrainV4.cover || tile(c) == TerrainV4.forest;

  List<HexCoord> neighbors(HexCoord c) =>
      c.neighbors().where(valid).toList(growable: false);

  Map<HexCoord, int> reachable({
    required CombatUnitV4 unit,
    required Iterable<CombatUnitV4> units,
    int? budget,
  }) {
    final maxCost = budget ?? unit.stats.move;
    final best = <HexCoord, int>{unit.anchor: 0};
    final frontier = <_Node>[_Node(unit.anchor, 0)];

    while (frontier.isNotEmpty) {
      frontier.sort((a, b) => a.cost.compareTo(b.cost));
      final current = frontier.removeAt(0);
      if (current.cost != best[current.coord]) continue;

      for (final next in neighbors(current.coord)) {
        if (blocked(next, units: units, ignoreUnitId: unit.id)) continue;

        final cost = current.cost + movementCost(next);
        if (cost > maxCost) continue;

        if (cost < (best[next] ?? 1 << 30)) {
          best[next] = cost;
          frontier.add(_Node(next, cost));
        }
      }
    }

    return best;
  }

  bool adjacent(HexCoord a, HexCoord b) => a.distanceTo(b) == 1;
}

class _Node {
  const _Node(this.coord, this.cost);

  final HexCoord coord;
  final int cost;
}
