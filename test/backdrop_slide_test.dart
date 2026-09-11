import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/art/art_sprite.dart';
import 'package:surge_wizard/core/constants.dart';

/// 걸어가는 연출 — 층이 오르면 배경이 아래로 흐른다
/// (`WORK_ORDER_BG_SCROLL.md` · `GAME_DESIGN.md` 6.7절 ①).
void main() {
  group('층 → 배경 세로 위치', () {
    test('1층은 그림 아래, 마지막 층은 그림 위', () {
      expect(backdropProgress(1, 5), 0.0);
      expect(backdropProgress(5, 5), 1.0);
    });

    test('중간 층은 그 사이를 고르게 나눈다', () {
      expect(backdropProgress(2, 5), closeTo(0.25, 1e-9));
      expect(backdropProgress(3, 5), closeTo(0.50, 1e-9));
      expect(backdropProgress(4, 5), closeTo(0.75, 1e-9));
    });

    test('🔴 층이 1인 스테이지 — 0으로 나누지 않는다', () {
      expect(backdropProgress(1, 1), 0.0);
      expect(backdropProgress(1, 0), 0.0);
    });

    test('범위를 벗어난 층은 잘린다 (1층의 이전 층 = 0층)', () {
      expect(backdropProgress(0, 5), 0.0);
      expect(backdropProgress(9, 5), 1.0);
    });
  });

  group('세로 위치 → 정렬', () {
    test('0이면 아래끝, 1이면 위끝', () {
      expect(backdropAlignment(0).y, 1.0);
      expect(backdropAlignment(1).y, -1.0);
      expect(backdropAlignment(0.5).y, 0.0);
      expect(backdropAlignment(0.5).x, 0.0);
    });
  });

  group('걷기 프레임', () {
    test('에셋이 아직 없으므로 꺼져 있다', () {
      expect(kArtWizardWalkReady, isFalse);
    });

    test('진행도 어디서든 프레임 하나를 고른다', () {
      for (var i = 0; i <= 20; i++) {
        expect(kArtWizardWalk, contains(wizardWalkFrame(i / 20)));
      }
    });
  });

  group('배경 위젯', () {
    /// 배경 이미지가 실제로 어디에 정렬돼 있는지 읽는다
    Alignment alignmentOf(WidgetTester t) =>
        t.widget<Image>(find.byType(Image)).alignment as Alignment;

    Future<void> show(WidgetTester t, int floor, int floors) async {
      await t.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: ArtBackdropView(kArtRegionBackdrops[1]!,
            floor: floor,
            floors: floors,
            fallback: const SizedBox(key: ValueKey('fallback'))),
      ));
      // 미는 것이 끝난 뒤를 본다
      await t.pump();
      await t.pump(kBackdropSlide + const Duration(milliseconds: 50));
    }

    testWidgets('층이 다르면 배경 위치가 다르다', (tester) async {
      await show(tester, 1, 5);
      final first = alignmentOf(tester);
      await show(tester, 5, 5);
      final last = alignmentOf(tester);
      expect(first.y, 1.0);
      expect(last.y, -1.0);
      expect(first, isNot(last));
    });

    testWidgets('미는 동안에는 이전 층 자리에서 출발한다', (tester) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: ArtBackdropView(kArtRegionBackdrops[1]!,
            floor: 5,
            floors: 5,
            fallback: const SizedBox(key: ValueKey('fallback'))),
      ));
      await tester.pump();
      // 시작 순간은 4층 자리(0.75 → y = -0.5)
      expect(alignmentOf(tester).y, closeTo(-0.5, 1e-9));
      await tester.pump(kBackdropSlide + const Duration(milliseconds: 50));
      expect(alignmentOf(tester).y, closeTo(-1.0, 1e-9));
    });

    testWidgets('1층은 밀지 않는다', (tester) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: ArtBackdropView(kArtRegionBackdrops[1]!,
            floor: 1,
            floors: 5,
            fallback: const SizedBox(key: ValueKey('fallback'))),
      ));
      await tester.pump();
      expect(alignmentOf(tester).y, 1.0);
      await tester.pump(const Duration(milliseconds: 450));
      expect(alignmentOf(tester).y, 1.0);
    });

    testWidgets('층이 1인 스테이지도 죽지 않는다', (tester) async {
      await show(tester, 1, 1);
      expect(alignmentOf(tester).y, 1.0);
      expect(tester.takeException(), isNull);
    });
  });
}
