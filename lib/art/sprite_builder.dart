import 'dart:math';

import 'pixel_sprite.dart';

/// 도형을 쌓아 스프라이트를 만드는 생성기.
///
/// 손으로 도트를 하나씩 찍는 대신 타원·다각형·사각형을 겹쳐 실루엣을 만들고,
/// [shade] 가 **빛 방향(왼쪽 위)** 기준으로 5단계 명암을 자동으로 칠한다.
/// [outline] 은 실루엣 바깥에 색조를 머금은 테두리를 두른다.
/// 눈·금속 같은 고정색 부분은 명암을 칠한 뒤 [paint] 로 덮어쓴다.
class SpriteBuilder {
  SpriteBuilder(this.w, this.h)
      : _g = List.generate(h, (_) => List.filled(w, '.'));

  final int w;
  final int h;
  final List<List<String>> _g;

  /// 명암을 자동으로 칠할 자리를 뜻하는 임시 글자
  static const body = '#';

  bool _inside(int x, int y) => x >= 0 && y >= 0 && x < w && y < h;

  void _set(int x, int y, String ch) {
    if (_inside(x, y)) _g[y][x] = ch;
  }

  String _at(int x, int y) => _inside(x, y) ? _g[y][x] : '.';

  /// 타원 채우기 (중심 cx,cy / 반지름 rx,ry — 픽셀 단위)
  void ellipse(double cx, double cy, double rx, double ry,
      {String ch = body}) {
    for (var y = (cy - ry).floor(); y <= (cy + ry).ceil(); y++) {
      for (var x = (cx - rx).floor(); x <= (cx + rx).ceil(); x++) {
        final dx = (x + 0.5 - cx) / rx, dy = (y + 0.5 - cy) / ry;
        if (dx * dx + dy * dy <= 1.0) _set(x, y, ch);
      }
    }
  }

  /// 사각형 채우기
  void rect(num x0, num y0, num x1, num y1, {String ch = body}) {
    for (var y = y0.round(); y <= y1.round(); y++) {
      for (var x = x0.round(); x <= x1.round(); x++) {
        _set(x, y, ch);
      }
    }
  }

  /// 볼록/오목 다각형 채우기 (짝수-홀수 규칙)
  void polygon(List<Point<double>> pts, {String ch = body}) {
    var minY = h.toDouble(), maxY = 0.0;
    for (final p in pts) {
      minY = min(minY, p.y);
      maxY = max(maxY, p.y);
    }
    for (var y = minY.floor(); y <= maxY.ceil(); y++) {
      final yc = y + 0.5;
      final xs = <double>[];
      for (var i = 0; i < pts.length; i++) {
        final a = pts[i], b = pts[(i + 1) % pts.length];
        if ((a.y <= yc && b.y > yc) || (b.y <= yc && a.y > yc)) {
          xs.add(a.x + (yc - a.y) / (b.y - a.y) * (b.x - a.x));
        }
      }
      xs.sort();
      for (var i = 0; i + 1 < xs.length; i += 2) {
        for (var x = xs[i].round(); x <= xs[i + 1].round(); x++) {
          _set(x, y, ch);
        }
      }
    }
  }

  /// 위가 좁고 아래가 넓은 사다리꼴 (모자·망토용)
  void trapezoid(double cx, double topY, double topHalf, double botY,
      double botHalf, {String ch = body}) {
    polygon([
      Point(cx - topHalf, topY),
      Point(cx + topHalf, topY),
      Point(cx + botHalf, botY),
      Point(cx - botHalf, botY),
    ], ch: ch);
  }

  /// 좌우 대칭으로 같은 도형을 하나 더 찍는다
  void mirrorX(void Function(double cx) draw, double cx, double offset) {
    draw(cx - offset);
    draw(cx + offset);
  }

  /// 지정한 자리를 고정색으로 덮어쓴다 (눈·이빨 등)
  void paint(num x0, num y0, num x1, num y1, String ch) =>
      rect(x0, y0, x1, y1, ch: ch);

  /// [body] 로 칠해진 영역에 빛 방향 기준 명암을 입힌다.
  ///
  /// 각 픽셀에서 가장 가까운 바깥 픽셀을 찾아 그 반대 방향을 표면 법선으로
  /// 삼고, 빛 벡터와의 각도로 밝기를 정한다. 안쪽 깊은 곳은 기본색으로 눕힌다.
  void shade({double lightX = -0.55, double lightY = -0.84}) {
    // 바깥에서 시작하는 너비 우선 탐색으로 각 픽셀의 '가장 가까운 바깥점'을 찾는다
    final nearX = List.generate(h, (_) => List.filled(w, -1));
    final nearY = List.generate(h, (_) => List.filled(w, -1));
    final queue = <int>[];
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (_g[y][x] == '.') {
          nearX[y][x] = x;
          nearY[y][x] = y;
          queue.add(y * w + x);
        }
      }
    }
    // 스프라이트가 화면 끝에 닿아 있으면 바깥이 없을 수 있으니 테두리도 씨앗으로
    for (var x = 0; x < w; x++) {
      for (final y in [0, h - 1]) {
        if (nearX[y][x] == -1) {
          nearX[y][x] = x;
          nearY[y][x] = y;
          queue.add(y * w + x);
        }
      }
    }
    var head = 0;
    const dirs = [[1, 0], [-1, 0], [0, 1], [0, -1]];
    final dist = List.generate(h, (_) => List.filled(w, 1 << 20));
    for (final i in queue) {
      dist[i ~/ w][i % w] = 0;
    }
    while (head < queue.length) {
      final cur = queue[head++];
      final cx = cur % w, cy = cur ~/ w;
      for (final d in dirs) {
        final nx = cx + d[0], ny = cy + d[1];
        if (!_inside(nx, ny)) continue;
        if (dist[ny][nx] <= dist[cy][cx] + 1) continue;
        dist[ny][nx] = dist[cy][cx] + 1;
        nearX[ny][nx] = nearX[cy][cx];
        nearY[ny][nx] = nearY[cy][cx];
        queue.add(ny * w + nx);
      }
    }

    var maxD = 1;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (_g[y][x] == body) maxD = max(maxD, dist[y][x]);
      }
    }

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (_g[y][x] != body) continue;
        // 바깥점 → 픽셀 방향이 곧 표면 법선
        var nx = (x - nearX[y][x]).toDouble();
        var ny = (y - nearY[y][x]).toDouble();
        final len = sqrt(nx * nx + ny * ny);
        var bright = 0.0;
        if (len > 0) {
          nx /= len;
          ny /= len;
          bright = nx * lightX + ny * lightY; // -1 ~ 1
        }
        // 안쪽 깊은 곳은 명암을 눕혀 얼룩지지 않게
        final depth = (dist[y][x] / maxD).clamp(0.0, 1.0);
        bright *= 1.0 - depth * 0.55;
        _g[y][x] = switch (bright) {
          > 0.52 => '5',
          > 0.20 => '4',
          > -0.18 => '3',
          > -0.52 => '2',
          _ => '1',
        };
      }
    }
  }

  /// 실루엣 바깥에 한 겹 테두리를 두른다 (명암 칠한 뒤 호출)
  void outline({String ch = '0'}) {
    final add = <Point<int>>[];
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (_g[y][x] != '.') continue;
        for (final d in const [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
          if (_at(x + d[0], y + d[1]) != '.') {
            add.add(Point(x, y));
            break;
          }
        }
      }
    }
    for (final p in add) {
      _set(p.x, p.y, ch);
    }
  }

  PixelSprite build() => PixelSprite([for (final row in _g) row.join()]);
}
