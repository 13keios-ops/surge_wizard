/// 보고서 25 용 화면 캡처 (테스트가 아니다 — `flutter test` 는 `test/` 만 훑는다).
///
/// 쓰는 법:  flutter test test_shots/screens2_test.dart
/// 결과는 `reports/img/25_run/` 에 **가로 480px 그대로** 떨어진다
/// (CLAUDE.md 토큰 절약 — 원본 1080폭은 4배 비싸다).
///
/// 실제 앱에서는 7지역 10스테이지가 잠겨 있어 눌러서 갈 수 없다. 그래서
/// 10층 지도는 화면을 직접 세워 찍는다.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/meta_state.dart';
import 'package:surge_wizard/screens/map_screen.dart';
import 'package:surge_wizard/screens/meta_controller.dart';
import 'package:surge_wizard/screens/region_select_screen.dart';
import 'package:surge_wizard/screens/result_screen.dart';
import 'package:surge_wizard/screens/stage_select_screen.dart';
import 'package:surge_wizard/widgets/pixel_ui.dart';

import 'shot_support.dart';

/// **실제 세로 기기 크기**로 그린다. 화면을 필요 이상으로 길게 잡으면
/// 「칸이 화면을 채우는가」를 잘못 판단하게 된다.
const _size = Size(400, 860);

/// 저장할 때만 키운다 — 보고서 그림은 가로 480px 규격이다 (400 × 1.2 = 480)
const _shotScale = 1.2;

final _outDir = Directory('reports/img/25_run');

late GameData _data;
late MetaController _meta;

ThemeData _theme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF9C6ADE),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: kBgDeep,
    useMaterial3: true,
  );
  return base
      .copyWith(textTheme: base.textTheme.apply(fontFamily: kFont11));
}

Widget _host(Widget child) => shotHost(
      ChangeNotifierProvider<MetaController>.value(
        value: _meta,
        child: MaterialApp(
            debugShowCheckedModeBanner: false, theme: _theme(), home: child),
      ),
      _size,
    );

Future<void> _shoot(WidgetTester tester, Widget screen, String name) async {
  prepareShot(tester, _size);
  await tester.pumpWidget(_host(screen));
  await tester.pump(const Duration(milliseconds: 100));
  await shoot(tester, _outDir.path, name, pixelRatio: _shotScale);
}

void main() {
  setUpAll(() async {
    await loadShotFonts();
    _data = GameDataParser.parseAll(
        (name) => File('assets/data/$name').readAsStringSync());
    // 아무것도 안 깬 새 저장 = **1지역만 열린 상태** (작업 1 검산)
    _meta = MetaController(MetaState.initial()..crystals = 42);
  });

  testWidgets('1 지역 선택 — 1지역만 열려 있다', (tester) async {
    await _shoot(tester, RegionSelectScreen(data: _data), '1_region');
  });

  testWidgets('2 스테이지 선택 — 1지역 8칸', (tester) async {
    await _shoot(
        tester, StageSelectScreen(data: _data, regionId: 1), '2_stage');
  });

  testWidgets('3 지도 — 3층 (1지역 Ⅰ)', (tester) async {
    expect(_data.stage(1, 1).floors, 3);
    await _shoot(
        tester,
        MapScreen(
            data: _data,
            regionId: 1,
            stageIndex: 1,
            difficulty: Difficulty.normal),
        '3_map_3floors');
  });

  testWidgets('4 지도 — 10층 (7지역 Ⅹ)', (tester) async {
    expect(_data.stage(7, 10).floors, 10);
    await _shoot(
        tester,
        MapScreen(
            data: _data,
            regionId: 7,
            stageIndex: 10,
            difficulty: Difficulty.normal),
        '4_map_10floors');
  });

  testWidgets('5 결과 — 스테이지 클리어', (tester) async {
    await _shoot(
        tester,
        const ResultScreen(
            cleared: true,
            floor: 3,
            totalFloors: 3,
            crystalsEarned: 65,
            expEarned: 425,
            levelsGained: 2,
            level: 9),
        '5_result');
  });
}
