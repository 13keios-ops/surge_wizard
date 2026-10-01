/// Pure-Dart hex coordinate used by CombatEngineV4.
///
/// Odd-q vertical layout: odd columns are shifted down by half a hex.
class HexCoord {
  const HexCoord(this.col, this.row);

  final int col;
  final int row;

  bool isValidFor(int columns, int rows) =>
      col >= 0 && row >= 0 && col < columns && row < rows;

  List<HexCoord> neighbors() {
    final offsets = col.isEven
        ? const [
            [-1, -1],
            [-1, 0],
            [0, -1],
            [0, 1],
            [1, -1],
            [1, 0],
          ]
        : const [
            [-1, 0],
            [-1, 1],
            [0, -1],
            [0, 1],
            [1, 0],
            [1, 1],
          ];

    return [
      for (final d in offsets) HexCoord(col + d[0], row + d[1]),
    ];
  }

  /// Hex distance via odd-q -> cube conversion.
  int distanceTo(HexCoord other) {
    final a = _cube();
    final b = other._cube();
    return ((a.$1 - b.$1).abs() +
            (a.$2 - b.$2).abs() +
            (a.$3 - b.$3).abs()) ~/
        2;
  }

  (int, int, int) _cube() {
    final x = col;
    final z = row - ((col - (col & 1)) ~/ 2);
    final y = -x - z;
    return (x, y, z);
  }

  @override
  bool operator ==(Object other) =>
      other is HexCoord && other.col == col && other.row == row;

  @override
  int get hashCode => Object.hash(col, row);

  @override
  String toString() => 'HexCoord($col, $row)';
}
