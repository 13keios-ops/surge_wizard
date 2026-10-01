import 'dart:math' as math;
import 'dart:ui';

import 'hex_coord_v4.dart';
export 'hex_coord_v4.dart';

/// v4 Landscape battle layout constants.
///
/// Reference coordinate: 800 × 450 logical dp.
/// Runtime uses the actual board rectangle; these values are authoring anchors,
/// not fixed physical pixels.
abstract final class BattleLayoutV4 {
  static const double referenceWidth = 800;
  static const double referenceHeight = 450;
  static const double pitchDegrees = 42;

  static const int columns = 9;
  static const int rows = 7;

  static const double minTouchTarget = 44;
  static const double radialRadius = 58;
  static const double radialButtonVisual = 40;

  static const Rect boardRef = Rect.fromLTWH(62, 56, 676, 302);
  static const Rect timelineRef = Rect.fromLTWH(174, 8, 432, 46);
  static const Rect speedRef = Rect.fromLTWH(620, 8, 168, 44);
  static const Rect bossBarRef = Rect.fromLTWH(230, 55, 340, 20);
  static const Rect partyHudRef = Rect.fromLTWH(12, 360, 208, 80);
  static const Rect previewRef = Rect.fromLTWH(580, 314, 208, 124);
  static const Rect toastRef = Rect.fromLTWH(240, 414, 320, 28);
}

/// Flat-top hex geometry compressed vertically to emulate the locked 42°
/// orthographic battle camera.
class HexGeometryV4 {
  HexGeometryV4(
    this.size, {
    this.columns = BattleLayoutV4.columns,
    this.rows = BattleLayoutV4.rows,
  })  : hexWidth = _hexWidthFor(size, columns, rows),
        hexHeight = _hexWidthFor(size, columns, rows) * 0.62 {
    final contentWidth = hexWidth * (1 + (columns - 1) * 0.75);
    final contentHeight = hexHeight * (rows + 0.5);
    origin = Offset(
      (size.width - contentWidth) / 2 + hexWidth / 2,
      (size.height - contentHeight) / 2 + hexHeight / 2,
    );
  }

  final Size size;
  final int columns;
  final int rows;
  final double hexWidth;
  final double hexHeight;
  late final Offset origin;

  static double _hexWidthFor(
    Size size,
    int columns,
    int rows,
  ) {
    final colsSpan = 1 + (columns - 1) * 0.75;
    final byWidth = size.width / (colsSpan + 0.25);
    final byHeight = size.height / ((rows + 0.5) * 0.62);
    return math.min(byWidth, byHeight);
  }

  Offset center(HexCoord coord) {
    final x = origin.dx + coord.col * hexWidth * 0.75;
    final y = origin.dy +
        (coord.row + (coord.col.isOdd ? 0.5 : 0.0)) * hexHeight;
    return Offset(x, y);
  }

  Path path(HexCoord coord, {double inset = 0}) {
    final c = center(coord);
    final rx = math.max(2.0, hexWidth / 2 - inset);
    final ry = math.max(2.0, hexHeight / 2 - inset);
    final points = <Offset>[];

    for (final degree in <double>[0, 60, 120, 180, 240, 300]) {
      final a = degree * math.pi / 180;
      points.add(Offset(
        c.dx + rx * math.cos(a),
        c.dy + ry * math.sin(a),
      ));
    }

    return Path()
      ..moveTo(points.first.dx, points.first.dy)
      ..addPolygon(points, true);
  }

  HexCoord? hitTest(Offset localPosition) {
    HexCoord? best;
    var bestDistance = double.infinity;

    for (var col = 0; col < columns; col++) {
      for (var row = 0; row < rows; row++) {
        final coord = HexCoord(col, row);
        final p = path(coord);
        if (p.contains(localPosition)) return coord;

        final distance = (center(coord) - localPosition).distanceSquared;
        if (distance < bestDistance) {
          bestDistance = distance;
          best = coord;
        }
      }
    }

    if (best == null) return null;
    return bestDistance <= math.pow(hexWidth * 0.62, 2) ? best : null;
  }

  List<HexCoord> neighbors(HexCoord c) => c
      .neighbors()
      .where((n) => n.isValidFor(columns, rows))
      .toList(growable: false);

  Set<HexCoord> burst7(HexCoord centerCoord) => {
        centerCoord,
        ...neighbors(centerCoord),
      };
}
