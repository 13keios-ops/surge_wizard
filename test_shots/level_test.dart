/// 보고서 26 용 화면 캡처 (테스트가 아니다 — `flutter test` 는 `test/` 만 훑는다).
///
/// 쓰는 법:  flutter test test_shots/level_test.dart
/// 결과는 `reports/img/26_run/` 에 **가로 480px 그대로** 떨어진다.
///
/// 결과 화면의 경험치는 **손으로 넣은 값이 아니다** — 진짜 RunController 로
/// 1지역 Ⅰ 3층을 한 층씩 이겨(= MapScreen 이 부르는 grantExp) 나온 값이다.
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/meta_state.dart';
import 'package:surge_wizard/screens/meta_controller.dart';
import 'package:surge_wizard/screens/region_select_screen.dart';
import 'package:surge_wizard/screens/result_screen.dart';
import 'package:surge_wizard/screens/run_controller.dart';
import 'package:surge_wizard/widgets/pixel_ui.dart';

import 'shot_support.dart';

/// **실제 세로 기기 크기** (보고서 25와 같은 규격)
const _size = Size(400, 860);

/// 저장할 때만 키운다 — 보고서 그림은 가로 480px 규격이다 (400 × 1.2 = 480)
const _shotScale = 1.2;

final _outDir = Directory('reports/img/26_run');

late GameData _data;
late MetaController _meta;
late RunController _run;

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
  return base.copyWith(textTheme: base.textTheme.apply(fontFamily: kFont11));
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
    // 저장 플러그인 흉내. test_shots/ 는 분석기가 「테스트」로 안 보지만
    // 실제로는 테스트 러너로만 도는 캡처 도구다
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    await loadShotFonts();
    _data = GameDataParser.parseAll(
        (name) => File('assets/data/$name').readAsStringSync());
    _meta = MetaController(MetaState.initial()..crystals = 42);
    // 1지역 Ⅰ(3층)을 한 층씩 이긴다 — 경험치는 여기서 실제로 쌓인다
    _run = RunController(
        data: _data,
        meta: _meta.state,
        random: Random(1),
        regionId: 1,
        stageIndex: 1)
      ..startRun();
    for (var floor = 1; floor <= _run.floors; floor++) {
      _run.grantExp(_meta);
      if (floor < _run.floors) _run.advanceFloor();
    }
  });

  testWidgets('1 결과 — 경험치와 레벨업', (tester) async {
    await _shoot(
        tester,
        ResultScreen(
            cleared: true,
            floor: _run.floors,
            totalFloors: _run.floors,
            crystalsEarned: 65,
            expEarned: _run.expEarned,
            levelsGained: _run.levelsGained,
            level: _meta.state.level),
        '1_result_exp');
  });

  testWidgets('2 지역 선택 — 머리에 「내 레벨」이 뜬다', (tester) async {
    await _shoot(tester, RegionSelectScreen(data: _data), '2_region_level');
  });
}
