/// 원화 v3 확인 — **일반 적(고블린)과 보스(태고의 슬라임)**를 각각 세워 찍는다.
///
/// `ui6a_test.dart` 는 층 추첨에 맡기므로 고블린·보스가 안 나올 수 있다.
/// 여기서는 적을 직접 지정한다. 테스트가 아니다 (보고서용 그림을 만든다).
///
///   flutter test test_shots/art_v3_test.dart
///
/// 결과: `reports/img/art_v3/screen_<이름>.png`
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

const _outDir = 'reports/img/art_v3';
const _size = Size(360, 640);

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
    // 효과음 플러그인은 테스트에 없다 — 채널을 막지 않으면 예외가 화면을 죽인다
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

  for (final (name, enemyId) in const [
    ('enemy_goblin', 'goblin_scout'),
    ('boss_elder_slime', 'boss_elder_slime'),
  ]) {
    testWidgets('$name 을 무대에 세운다', (tester) async {
      prepareShot(tester, _size);
      final bc = BattleController(data: _data, random: Random(5))
        ..startBattle(
          enemy: _data.enemies.firstWhere((e) => e.id == enemyId),
          hand: _run.hand,
          hp: 40,
          maxHp: 50,
        );
      await tester.pumpWidget(_host(BattleScreen(
        controller: bc,
        title: _run.stageTitle,
        regionId: 1,
        floor: 1,
        floors: _run.floors,
      )));
      // 위젯 테스트는 그림을 실제로 읽지 않는다 — 미리 캐시에 넣어야 원화가 나온다
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
      await tester.pump(const Duration(milliseconds: 100));

      // 원화가 실제로 걸렸는지 — 대체 픽셀 스프라이트로 떨어지면 여기서 잡힌다
      final art = kArtEnemies[enemyId]!;
      expect(
          find.byWidgetPredicate(
              (w) => w is Image && '${w.image}'.contains(art)),
          findsOneWidget,
          reason: '$art 가 화면에 없다');

      await shoot(tester, _outDir, 'screen_$name');
    });
  }
}
