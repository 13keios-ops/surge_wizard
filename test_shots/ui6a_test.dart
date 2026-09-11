/// 6-A 검증 — v3 전투 화면을 세 기기 비율로 찍고 **자리를 실측한다**.
///
/// 테스트가 아니다 (보고서용 그림·수치를 만든다). `flutter test` 는 `test/` 만
/// 훑으므로 평소에 돌지 않는다.
///
///   flutter test test_shots/ui6a_test.dart
///
/// 결과: `reports/img/ui6a/after_<폭>x<높이>.png` + 표준출력에 실측치.
/// 자리를 전부 **화면 아래에서** 재므로 비율이 달라져도 값이 같아야 한다 —
/// 그게 이 파일이 확인하는 것이다.
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surge_wizard/art/art_sprite.dart';
import 'package:surge_wizard/art/pixel_sprite.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/meta_state.dart';
import 'package:surge_wizard/screens/battle_screen.dart';
import 'package:surge_wizard/screens/meta_controller.dart';
import 'package:surge_wizard/screens/run_controller.dart';
import 'package:surge_wizard/widgets/spell_slots.dart';
import 'package:surge_wizard/widgets/dice_tray.dart';
import 'package:surge_wizard/widgets/pixel_ui.dart';

import 'shot_support.dart';

const _outDir = 'reports/img/ui6a';

/// 실제 기기 비율 세 가지 (보고서 31 · 4-9절)
const _devices = [
  ('16:9 iPhone SE', Size(360, 640)),
  ('19.5:9 iPhone 15', Size(393, 852)),
  ('20:9 Pixel·갤럭시', Size(360, 800)),
];

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
  return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: 'Galmuri11'));
}

Widget _host(Widget child, Size size) => shotHost(
      ChangeNotifierProvider<MetaController>.value(
        value: _meta,
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: _theme(),
            home: child),
      ),
      size,
    );

/// 위젯 테스트는 그림을 실제로 읽지 않는다 — 미리 캐시에 넣어야 원화가 나온다
Future<void> _precacheArt(WidgetTester tester) async {
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
}

/// 화면 **아래에서** 잰다. 세 기기에서 같은 값이 나와야 한다.
void _measure(WidgetTester tester, String name, Size size) {
  double up(Rect r) => size.height - r.bottom;
  double top(Rect r) => size.height - r.top;
  final slots = tester.getRect(find.byType(SpellSlots));
  final tray = tester.getRect(find.byType(DiceTray));
  final wiz = tester.getRect(find.byWidgetPredicate(
      (w) => w is Image && '${w.image}'.contains('wizard')));
  final foe = tester.getRect(find.byType(PixelSpriteView).first);
  // ignore: avoid_print
  print('[측정] $name ${size.width.toInt()}×${size.height.toInt()}  '
      '슬롯 ${up(slots).toStringAsFixed(0)}~${top(slots).toStringAsFixed(0)}  '
      '조작부 아래끝 ${up(tray).toStringAsFixed(0)}  '
      '마법사 ${up(wiz).toStringAsFixed(0)}~${top(wiz).toStringAsFixed(0)}  '
      '적 ${up(foe).toStringAsFixed(0)}~${top(foe).toStringAsFixed(0)}  '
      '적↔마법사 ${(up(foe) - top(wiz)).toStringAsFixed(0)}dp');
}

void main() {
  setUpAll(() async {
    // 효과음 플러그인은 테스트에 없다 — 채널을 막지 않으면 예외가 테스트를 죽인다
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
  });

  for (final (label, size) in _devices) {
    testWidgets('전투 화면 $label', (tester) async {
      prepareShot(tester, size);
      final run = RunController(data: _data, random: Random(5))..startRun();
      final bc = run.buildBattleController();
      await tester.pumpWidget(_host(
          BattleScreen(
              controller: bc,
              title: run.stageTitle,
              regionId: 1,
              floor: 1,
              floors: run.floors),
          size));
      await _precacheArt(tester);
      await tester.pump(const Duration(milliseconds: 100));

      bc.selectSpell(0);
      await tester.pump();
      bc.rollDice();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      _measure(tester, label, size);
      await shoot(tester, _outDir,
          'after_${size.width.toInt()}x${size.height.toInt()}');
    });
  }
}
