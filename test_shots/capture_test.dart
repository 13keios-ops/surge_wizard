/// 화면 캡처 도구 (테스트가 아니다 — 보고서용 그림을 만든다).
///
/// `flutter test` 는 `test/` 만 훑으므로 이 파일은 평소에 실행되지 않는다.
/// 쓰는 법:
///   flutter test test_shots/capture_test.dart --dart-define=SHOT_STAGE=before
///   flutter test test_shots/capture_test.dart --dart-define=SHOT_STAGE=after
/// 결과는 `reports/img/_shots/<stage>/NN_이름.png` 로 떨어진다.
///
/// 개정 전(before)은 시스템 폰트를 쓰던 시절을 재현해야 하므로 Windows 의
/// 맑은 고딕을 불러와 기본 글꼴로 삼는다.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/meta_state.dart';
import 'package:surge_wizard/screens/battle_screen.dart';
import 'package:surge_wizard/screens/map_screen.dart';
import 'package:surge_wizard/screens/meta_controller.dart';
import 'package:surge_wizard/screens/result_screen.dart';
import 'package:surge_wizard/screens/region_select_screen.dart';
import 'package:surge_wizard/screens/reward_screen.dart';
import 'package:surge_wizard/screens/run_controller.dart';
import 'package:surge_wizard/screens/stage_select_screen.dart';
import 'package:surge_wizard/screens/title_screen.dart';
import 'package:surge_wizard/widgets/pixel_ui.dart';

import 'dart:math';

import 'shot_support.dart';

const _stage = String.fromEnvironment('SHOT_STAGE', defaultValue: 'after');

/// 캡처 크기 (세로 기기 한 대)
const _size = Size(360, 700);

final _outDir = Directory('reports/img/_shots/$_stage');


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
  // 개정 전은 시스템 폰트, 개정 후는 앱이 쓰는 픽셀 폰트
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: _stage == 'before' ? kShotSystemFont : 'Galmuri11',
    ),
  );
}

Widget _host(Widget child, MetaController meta) {
  final app = ChangeNotifierProvider<MetaController>.value(
    value: meta,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme(),
      home: child,
    ),
  );
  return shotHost(app, _size);
}

Future<void> _shoot(WidgetTester tester, String name) =>
    shoot(tester, _outDir.path, name);

late GameData _data;
late MetaController _meta;

void _prepare(WidgetTester tester) => prepareShot(tester, _size);

void main() {
  setUpAll(() async {
    await loadShotFonts();
    _data = GameDataParser.parseAll(
        (name) => File('assets/data/$name').readAsStringSync());
    _meta = MetaController(MetaState.initial()..crystals = 42);
  });

  testWidgets('1 타이틀', (tester) async {
    _prepare(tester);
    await tester.pumpWidget(_host(TitleScreen(data: _data), _meta));
    await tester.pump(const Duration(milliseconds: 100));
    await _shoot(tester, '1_title');
  });

  testWidgets('2 지역 선택', (tester) async {
    _prepare(tester);
    await tester.pumpWidget(_host(RegionSelectScreen(data: _data), _meta));
    await tester.pump(const Duration(milliseconds: 100));
    await _shoot(tester, '2_region');
  });

  testWidgets('3 스테이지 선택', (tester) async {
    _prepare(tester);
    await tester.pumpWidget(
        _host(StageSelectScreen(data: _data, regionId: 1), _meta));
    await tester.pump(const Duration(milliseconds: 100));
    await _shoot(tester, '3_stage');
  });

  testWidgets('4 지도', (tester) async {
    _prepare(tester);
    await tester.pumpWidget(_host(
        MapScreen(
            data: _data,
            regionId: 1,
            stageIndex: 1,
            difficulty: Difficulty.normal),
        _meta));
    await tester.pump(const Duration(milliseconds: 100));
    await _shoot(tester, '4_map');
  });

  testWidgets('5 전투', (tester) async {
    _prepare(tester);
    final run = RunController(data: _data, random: Random(5))..startRun();
    final bc = run.buildBattleController();
    await tester.pumpWidget(_host(
        BattleScreen(controller: bc, floor: 1, floors: run.floors), _meta));
    await tester.pump(const Duration(milliseconds: 100));
    bc.selectSpell(0);
    await tester.pump();
    bc.rollDice();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await _shoot(tester, '5_battle');
  });

  testWidgets('6 보상', (tester) async {
    _prepare(tester);
    final run = RunController(data: _data, random: Random(9))..startRun();
    run.spellOffers = _data.spells.take(3).toList();
    await tester.pumpWidget(_host(RewardScreen.spells(run: run), _meta));
    await tester.pump(const Duration(milliseconds: 100));
    await _shoot(tester, '6_reward');
  });

  testWidgets('7 결과', (tester) async {
    _prepare(tester);
    await tester.pumpWidget(_host(
        const ResultScreen(
            cleared: false,
            floor: 7,
            totalFloors: 10,
            crystalsEarned: 12,
            expEarned: 305,
            levelsGained: 1,
            level: 5),
        _meta));
    await tester.pump(const Duration(milliseconds: 100));
    await _shoot(tester, '7_result');
  });
}
