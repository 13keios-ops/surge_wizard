/// 화면 잔손질 검산 (WORK_ORDER_SCREENS2 작업 4 검사 1·3).
///
/// 지도 칸 높이(검사 2)는 `map_screen_test.dart` 에 있다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/art/region_art.dart';
import 'package:surge_wizard/screens/result_screen.dart';

/// 사람 눈이 느끼는 밝기 (0~255). 초록이 가장 밝게 보인다.
double _luma(Color c) =>
    0.2126 * (c.r * 255) + 0.7152 * (c.g * 255) + 0.0722 * (c.b * 255);

/// 카드는 위아래 두 색의 그라데이션이라 평균으로 본다
double _cardLuma(RegionLook look) => (_luma(look.top) + _luma(look.bottom)) / 2;

void main() {
  group('작업 1 — 잠긴 지역 카드', () {
    test('잠긴 회색조가 테마 4종보다 모두 어둡다', () {
      final locked = _cardLuma(kLockedRegionLook);
      for (final look in allRegionLooks) {
        expect(locked, lessThan(_cardLuma(look)));
      }
    });

    test('잠긴 카드는 테마와 무관하게 늘 같은 색이다', () {
      // 잠긴 12장의 바탕 밝기 차이가 0이어야 「어디까지 열렸나」가 한눈에 읽힌다
      expect(kLockedRegionLook.top, const Color(0xFF101018));
      expect(kLockedRegionLook.bottom, const Color(0xFF2E2C3A));
    });
  });

  group('작업 3 — 결과 화면 문구', () {
    testWidgets('클리어 문구에 v1 잔재 「탑」이 없다', (tester) async {
      // 결과 화면은 세로로 긴 화면이라 기본 600px 에서는 넘친다
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(
        home: ResultScreen(
            cleared: true,
            floor: 8,
            totalFloors: 8,
            crystalsEarned: 90,
            expEarned: 640,
            levelsGained: 2,
            level: 7),
      ));
      await tester.pump();
      expect(find.text('스테이지 클리어!'), findsOneWidget);
      expect(find.textContaining('탑'), findsNothing);
    });
  });
}
