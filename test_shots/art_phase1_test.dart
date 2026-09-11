/// 그래픽 Phase 1 비교 그림 만들기 (테스트가 아니다).
///
///   flutter test test_shots/art_phase1_test.dart --dart-define=SHOT_STAGE=before
///   flutter test test_shots/art_phase1_test.dart --dart-define=SHOT_STAGE=after
///
/// `before` 는 `lib/art/art_sprite.dart` 의 `kArtWizardBack` 을 없는 경로로
/// 잠깐 바꿔 두고 찍는다 (= 기존 픽셀 스프라이트 fallback).
/// 결과는 `reports/img/art_phase1/<stage>.png` · `<stage>_hit.png`.
///
/// ⚠ 두 번째 그림(피격)에서 효과음 플러그인이 테스트에 없는 이벤트 채널을
/// 열어 두는 바람에 **다 찍고 나서 프로세스가 안 끝난다.** 그림은 이미
/// 파일로 떨어진 뒤이므로 `timeout 120 flutter test ...` 로 돌리면 된다.
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

const _stage = String.fromEnvironment('SHOT_STAGE', defaultValue: 'after');

/// 실제 기기 비율 (HANDOFF 6절 함정 4)
const _size = Size(400, 860);
const _outDir = 'reports/img/art_phase1';

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

Widget _host(Widget child) => shotHost(
      ChangeNotifierProvider<MetaController>.value(
        value: _meta,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _theme(),
          home: child,
        ),
      ),
      _size,
    );

/// 위젯 테스트는 그림을 실제로 읽지 않는다 (진짜 비동기라 `pump` 로는 안 끝난다).
/// 미리 읽어 캐시에 넣어 둬야 원화가 화면에 나온다.
Future<void> _precacheArt(WidgetTester tester) async {
  await tester.runAsync(() async {
    final ctx = tester.element(find.byType(MaterialApp));
    try {
      await precacheImage(const AssetImage(kArtWizardBack), ctx);
    } catch (_) {
      // 없는 파일(before)이면 그대로 대체 스프라이트가 나온다
    }
  });
}

/// 적이 실제로 때릴 때까지 턴을 돌린다 (피격 연출을 찍으려면 필요하다)
Future<bool> _playUntilPlayerHit(WidgetTester tester, BattleController bc) async {
  for (var turn = 0; turn < 12; turn++) {
    final before = bc.battle.playerHp;
    bc.selectSpell(0);
    await tester.pump();
    bc.rollDice();
    await tester.pump(const Duration(milliseconds: 400));
    bc.confirmCast();
    await tester.pump(const Duration(milliseconds: 1000));
    if (bc.phase != BattlePhase.result) return false; // 전투가 끝났다
    bc.endTurn();
    await tester.pump(const Duration(milliseconds: 60));
    if (bc.battle.playerHp < before) return true;
    await tester.pump(const Duration(milliseconds: 400));
  }
  return false;
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
    _meta = MetaController(MetaState.initial());
  });

  testWidgets('전투 화면', (tester) async {
    prepareShot(tester, _size);
    final run = RunController(data: _data, random: Random(5))..startRun();
    final bc = run.buildBattleController();
    await tester.pumpWidget(
        _host(BattleScreen(controller: bc, floor: 1, floors: run.floors)));
    await _precacheArt(tester);
    await tester.pump(const Duration(milliseconds: 100));
    await shoot(tester, _outDir, _stage);
  });

  testWidgets('전투 화면 — 피격 순간', (tester) async {
    prepareShot(tester, _size);
    final run = RunController(data: _data, random: Random(5))..startRun();
    final bc = run.buildBattleController();
    await tester.pumpWidget(
        _host(BattleScreen(controller: bc, floor: 1, floors: run.floors)));
    await _precacheArt(tester);
    await tester.pump(const Duration(milliseconds: 100));
    // 효과음 플러그인이 매번 새 이름의 이벤트 채널을 열어 이름으로는 못 막는다.
    // 그림만 찍으면 되므로 이 화면에서는 플러그인 예외를 흘려보낸다
    FlutterError.onError = (d) => debugPrint('무시: ${d.exception}');
    expect(await _playUntilPlayerHit(tester, bc), isTrue,
        reason: '적이 때리는 순간을 못 잡았다');
    await shoot(tester, _outDir, '${_stage}_hit');
  });
}
