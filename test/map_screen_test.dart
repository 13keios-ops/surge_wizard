/// 지도 화면 검산 (WORK_ORDER_SCREENS 작업 4 검사 7).
///
/// **층수가 3~10으로 가변**이므로 칸 수가 스테이지마다 달라야 한다.
/// 가장 짧은 스테이지(3층)와 가장 긴 스테이지(10층) 양끝을 확인한다.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/meta_state.dart';
import 'package:surge_wizard/screens/map_screen.dart';
import 'package:surge_wizard/screens/meta_controller.dart';
import 'package:surge_wizard/widgets/floor_tile.dart';
import 'package:surge_wizard/widgets/next_enemy_card.dart';

String readData(String name) => File('assets/data/$name').readAsStringSync();

void main() {
  final data = GameDataParser.parseAll(readData);

  Widget host(int regionId, int stageIndex) {
    SharedPreferences.setMockInitialValues({});
    return ChangeNotifierProvider(
      create: (_) => MetaController(MetaState.initial()),
      child: MaterialApp(
        home: MapScreen(
          data: data,
          regionId: regionId,
          stageIndex: stageIndex,
          difficulty: Difficulty.normal,
        ),
      ),
    );
  }

  /// 층 칸이 몇 개 그려졌는지 — ListView 가 다 그리도록 화면을 넉넉히 키운다
  Future<int> tileCount(
      WidgetTester tester, int regionId, int stageIndex) async {
    tester.view.physicalSize = const Size(500, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(regionId, stageIndex));
    await tester.pump();
    return find.byType(FloorTile).evaluate().length;
  }

  testWidgets('3층 스테이지(1지역 Ⅰ)는 칸이 3개다', (tester) async {
    expect(data.stage(1, 1).floors, 3); // 전제가 바뀌면 여기서 먼저 걸린다
    expect(await tileCount(tester, 1, 1), 3);
    expect(find.text('1 / 3층'), findsOneWidget);
  });

  testWidgets('10층 스테이지(7지역 Ⅹ)는 칸이 10개다', (tester) async {
    expect(data.stage(7, 10).floors, 10);
    expect(await tileCount(tester, 7, 10), 10);
    expect(find.text('1 / 10층'), findsOneWidget);
  });

  testWidgets('지도가 다음 상대를 이름·HP·공격력으로 미리 보여준다', (tester) async {
    await tileCount(tester, 1, 1);
    expect(find.byType(NextEnemyCard), findsOneWidget);
    expect(find.text('다음 상대'), findsOneWidget);
    expect(find.textContaining('HP '), findsWidgets);
  });

  /// 층 칸 높이가 남는 공간에 맞춰 커지는지 (WORK_ORDER_SCREENS2 작업 2).
  /// **화면을 실제 세로 기기 크기로 두고** 잰다 — 넉넉히 키우면 늘 상한에 걸린다.
  Future<List<double>> tileHeights(
      WidgetTester tester, int regionId, int stageIndex) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(regionId, stageIndex));
    await tester.pump();
    return find
        .byType(FloorTile)
        .evaluate()
        .map((e) => e.size!.height)
        .toList();
  }

  testWidgets('3층 스테이지는 칸이 커지고, 상·하한 안에 있다', (tester) async {
    final h = await tileHeights(tester, 1, 1);
    expect(h.length, 3);
    // 칸 높이가 전부 같고 상한에 걸려 있다 (3층은 자리가 남아돈다)
    expect(h.toSet().length, 1);
    expect(h.first, kFloorTileMaxHeight);
  });

  testWidgets('10층 스테이지는 하한 근처로 내려가고 화면을 안 넘는다', (tester) async {
    final h = await tileHeights(tester, 7, 10);
    expect(h.length, 10);
    expect(h.toSet().length, 1);
    // 자리가 빠듯하므로 3층보다 훨씬 작다 = 「지금 크기」로 돌아온다
    expect(h.first, lessThan(kFloorTileMaxHeight));
    expect(h.first, greaterThanOrEqualTo(kFloorTileMinHeight));
    expect(tester.takeException(), isNull); // 넘치면 여기서 잡힌다
  });

  testWidgets('머리글에 스테이지 이름과 난이도가 보인다', (tester) async {
    await tileCount(tester, 1, 8); // 1지역 보스 스테이지 (부제가 있다)
    expect(find.textContaining('마나의 숲 VIII'), findsOneWidget);
    expect(find.textContaining('보통'), findsWidgets);
  });
}
