import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/art/landmark.dart';
import 'package:surge_wizard/core/layout.dart';

/// 성 · 보스 음영 겹 (`WORK_ORDER_LANDMARK.md` 5절).
///
/// 🔴 **음영은 커지지 않는다.** 층이 올라도 크기도 자리도 같다 —
/// 2026-09-12 에 「층마다 커진다」가 틀린 것으로 판명됐다.
void main() {
  Future<void> show(WidgetTester tester, Widget child) => tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(width: 360, height: 720, child: child),
        ),
      );

  group('성', () {
    testWidgets('1. 원화가 없어도 실루엣이 그려진다', (tester) async {
      await show(tester, const LandmarkView(regionId: 1));
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('2. 지평선보다 위에 선다 (길이 안개에 잠기는 자리)', (tester) async {
      expect(kLandmarkBottomY, lessThan(kRoadHorizonY + 0.05));
    });
  });

  group('보스 음영', () {
    testWidgets('3. 원화가 없으면 아무것도 안 그린다', (tester) async {
      await show(tester, const BossShadowView(art: null, eyes: null));
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('4. 눈 좌표가 없으면 음영만 그리고 터지지 않는다', (tester) async {
      await show(
          tester,
          const BossShadowView(
              art: 'assets/art/boss/elder_slime.webp', eyes: null));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('5. 눈 좌표가 있으면 두 점이 그려진다', (tester) async {
      await show(
          tester,
          const BossShadowView(
              art: 'assets/art/boss/elder_slime.webp',
              eyes: [0.37, 0.62, 0.62, 0.62]));
      await tester.pump();
      final dots = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) =>
              (c.decoration as BoxDecoration?)?.shape == BoxShape.circle)
          .length;
      expect(dots, 2);
    });
  });

  group('데이터', () {
    final raw = File('assets/data/enemies.json').readAsStringSync();
    final enemies = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

    test('6. 눈 좌표가 적힌 보스는 네 값이고 전부 0~1 안이다', () {
      var found = 0;
      for (final e in enemies) {
        final eyes = e['eyes'] as List?;
        if (eyes == null) continue;
        found++;
        expect(eyes.length, 4, reason: '${e['id']}: 두 점 = 네 값');
        for (final v in eyes) {
          expect(v, inInclusiveRange(0.0, 1.0), reason: '${e['id']}: 비율이다');
        }
      }
      expect(found, greaterThan(0), reason: '적어도 하나는 적혀 있어야 한다');
    });

    test('7. 🔴 원화가 없는 보스에 눈을 추측으로 채우지 않았다', () {
      // 지금 원화가 있는 보스는 boss_elder_slime 하나뿐이다
      final withEyes =
          enemies.where((e) => e['eyes'] != null).map((e) => e['id']).toList();
      expect(withEyes, ['boss_elder_slime']);
    });
  });
}
