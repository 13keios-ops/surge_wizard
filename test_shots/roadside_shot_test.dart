/// 걸어가는 연출 확인 — **길 옆 물체가 층마다 어디에 있나**.
///
/// 원화가 아직 없어 단색 사각형이다. 보려는 것은 그림이 아니라
/// **경로·크기·가운데를 가리는지**다 (`WORK_ORDER_ROADSIDE.md`).
///
///   flutter test test_shots/roadside_shot_test.dart
///
/// 결과: `reports/img/roadside/floor_<N>.png`
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surge_wizard/art/art_sprite.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/meta_state.dart';
import 'package:surge_wizard/screens/battle_controller.dart';
import 'package:surge_wizard/screens/battle_screen.dart';
import 'package:surge_wizard/screens/meta_controller.dart';
import 'package:surge_wizard/screens/run_controller.dart';
import 'package:surge_wizard/widgets/pixel_ui.dart';

import 'shot_support.dart';

const _outDir = 'reports/img/roadside';
const _size = Size(360, 720); // 20:9 에 가까운 요즘 폰

late GameData _data;
late MetaController _meta;
late RunController _run;

Widget _host(Widget child) => shotHost(
      ChangeNotifierProvider<MetaController>.value(
        value: _meta,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: kBgDeep,
            useMaterial3: true,
            fontFamily: 'Galmuri11',
          ),
          home: child,
        ),
      ),
      _size,
    );

void main() {
  setUpAll(() async {
    final msg =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final name in const [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events',
      'xyz.luan/audioplayers',
    ]) {
      msg.setMockMethodCallHandler(MethodChannel(name), (_) async => null);
    }
    await loadShotFonts();
    _data = GameDataParser.parseAll(
        (name) => File('assets/data/$name').readAsStringSync());
    _meta = MetaController(MetaState.initial()..crystals = 42);
    _run = RunController(data: _data, random: Random(5))..startRun();
  });

  for (final floor in const [1, 2, 3]) {
    testWidgets('$floor층의 길 옆 물체', (tester) async {
      prepareShot(tester, _size);
      final bc = BattleController(data: _data, random: Random(5))
        ..startBattle(
          enemy: _data.enemies.firstWhere((e) => e.id == 'goblin_scout'),
          hand: _run.hand,
          hp: 40,
          maxHp: 50,
        );
      await tester.pumpWidget(_host(BattleScreen(
        controller: bc,
        title: _run.stageTitle,
        regionId: 1,
        floor: floor,
        floors: 10,
      )));
      await tester.runAsync(() async {
        final ctx = tester.element(find.byType(MaterialApp));
        for (final a in [
          kArtWizardBack,
          ...kArtEnemies.values,
          ...kArtRegionBackdrops.values,
        ]) {
          await precacheImage(AssetImage(a), ctx);
        }
      });
      // 걷는 연출이 끝난 자리를 본다 (전투 중에는 멈춰 있는 그 자리다)
      await tester.pump(const Duration(milliseconds: 1200));
      await shoot(tester, _outDir, 'floor_$floor');
    });
  }
}
