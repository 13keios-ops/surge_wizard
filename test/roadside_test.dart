import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/art/roadside.dart';
import 'package:surge_wizard/core/layout.dart';

/// 길 옆 물체의 원근 경로 (`WORK_ORDER_ROADSIDE.md` 6절).
///
/// **배경 판은 안 움직인다.** 여기서 재는 것은 좌우 물체가 소실점에서 화면
/// 아래로 내려오며 커지는 길이다.
void main() {
  group('원근 경로', () {
    test('1. 소실점(t=0)에서는 지평선에 서고 크기가 0이다', () {
      expect(roadsideBottomY(0), kRoadHorizonY);
      expect(roadsideHeight(0), 0);
      expect(roadsideSpread(0), 0);
    });

    test('2. 가장 가까울 때(t=1) 화면 바닥에 서고 크기가 최대다', () {
      expect(roadsideBottomY(1), 1.0);
      expect(roadsideHeight(1), kRoadNearHeight);
      expect(roadsideSpread(1), kRoadNearSpread);
    });

    test('3. t가 커지면 세로 위치·크기·좌우 벌어짐이 모두 단조 증가한다', () {
      for (var i = 0; i < 10; i++) {
        final a = i / 10, b = (i + 1) / 10;
        expect(roadsideBottomY(b), greaterThan(roadsideBottomY(a)));
        expect(roadsideHeight(b), greaterThan(roadsideHeight(a)));
        expect(roadsideSpread(b), greaterThan(roadsideSpread(a)));
      }
    });

    test('4. 거리를 등속으로 줄이면 t는 가까울수록 더 많이 는다', () {
      // 4→3 보다 2→1 에서 더 크게 는다. 가까워질수록 빨리 스쳐 간다
      final far = roadsideT(3) - roadsideT(4);
      final near = roadsideT(1) - roadsideT(2);
      expect(near, greaterThan(far));
    });

    test('5. 가장 먼 거리는 t가 작고, 그보다 멀어도 1을 넘지 않는다', () {
      expect(roadsideT(kRoadsideFar), lessThan(0.25));
      expect(roadsideT(kRoadsideNear), 1.0);
      // 너무 가까워도 t는 1에서 멈춘다 (화면 밖으로 커지지 않는다)
      expect(roadsideT(kRoadsideNear / 2), 1.0);
    });
  });

  group('흐름과 재활용', () {
    test('6. 걸어도 거리가 항상 [가까움, 멂] 안에 있다 — 되돌아온다', () {
      for (var w = 0.0; w < 40; w += 0.13) {
        final d = roadsideDistance(1.7, w);
        expect(d, inInclusiveRange(kRoadsideNear, kRoadsideFar));
      }
    });

    test('7. 층이 올라도 물체 개수가 변하지 않는다', () {
      for (var floor = 1; floor <= 30; floor++) {
        expect(roadsideLayout(1, floor.toDouble()).length, kRoadsidePerSide * 2);
      }
    });

    test('8. 걸으면 가까워진다 (되돌아오는 순간이 아니면)', () {
      const phase = 0.0;
      final before = roadsideDistance(phase, 0);
      final after = roadsideDistance(phase, 0.5);
      expect(after, lessThan(before));
    });

    test('9. 좌우가 반씩 나뉜다', () {
      final objects = roadsideLayout(3, 4);
      final left = objects.where((o) => o.onLeft).length;
      expect(left, kRoadsidePerSide);
      expect(objects.length - left, kRoadsidePerSide);
    });
  });

  group('결정성', () {
    test('10. 같은 (지역, 층)은 항상 같은 배치다', () {
      final a = roadsideLayout(2, 5);
      final b = roadsideLayout(2, 5);
      expect(a.map((o) => o.distance).toList(),
          b.map((o) => o.distance).toList());
    });

    test('11. 지역이 다르면 배치도 다르다', () {
      final a = roadsideLayout(1, 5).map((o) => o.distance).toList();
      final b = roadsideLayout(2, 5).map((o) => o.distance).toList();
      expect(a, isNot(equals(b)));
    });

    test('12. 층이 1뿐인 스테이지도 터지지 않는다', () {
      // 옛 방식은 (floor-1)/(floors-1) 이라 0으로 나눌 위험이 있었다.
      // 지금은 총 층수를 아예 안 쓴다 — 걸어온 거리만 본다
      expect(() => roadsideLayout(1, 1), returnsNormally);
      expect(roadsideLayout(1, 1).length, kRoadsidePerSide * 2);
    });
  });
}
