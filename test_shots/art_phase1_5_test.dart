/// 그래픽 Phase 1.5 비교 그림 만들기 (테스트가 아니다).
///
///   flutter test test_shots/art_phase1_5_test.dart
///
/// 결과는 `reports/img/art_phase1_5/` 에 떨어진다 —
/// `before.png`(코드 도트 + 코드 배경) · `after.png` · `after_hit.png` ·
/// `after_small.png`(작은 기기 640dp).
/// 세 장을 가로 480px 한 장으로 붙이는 것은 `tool/make_sheet.py` 가 한다.
///
/// 「기존」 화면은 **없는 파일로 바꿔치기하지 않고** `assets/art/` 만 못 읽는
/// 번들을 끼워 재현한다. 그래야 프로덕션 코드에 시험용 구멍을 안 뚫는다.
///
/// ⚠ 효과음 플러그인이 테스트에 없는 이벤트 채널을 열어 두는 바람에 **다 찍고
/// 나서 프로세스가 안 끝난다.** 그림은 이미 파일로 떨어진 뒤다.
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:surge_wizard/art/art_sprite.dart';
import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/data/parser.dart';
import 'package:surge_wizard/models/meta_state.dart';
import 'package:surge_wizard/screens/battle_controller.dart';
import 'package:surge_wizard/screens/battle_screen.dart';
import 'package:surge_wizard/screens/meta_controller.dart';
import 'package:surge_wizard/screens/run_controller.dart';
import 'package:surge_wizard/widgets/battle_stage.dart';
import 'package:surge_wizard/widgets/dice_tray.dart';
import 'package:surge_wizard/widgets/pixel_ui.dart';
import 'package:surge_wizard/widgets/spell_card.dart';

import 'shot_support.dart';

/// 실제 기기 비율 (HANDOFF 6절 함정 4). 작은 기기도 함께 본다
const _big = Size(400, 860);
const _small = Size(400, 640);
const _outDir = 'reports/img/art_phase1_5';

late GameData _data;
late MetaController _meta;

/// `assets/art/` 만 못 읽는 번들 — 「원화 이전」 화면을 그대로 재현한다
class _NoArtBundle extends AssetBundle {
  @override
  Future<ByteData> load(String key) {
    if (key.startsWith('assets/art/')) {
      throw FlutterError('원화 없음(재현용): $key');
    }
    return rootBundle.load(key);
  }

  @override
  Future<T> loadStructuredData<T>(
          String key, Future<T> Function(String) parser) =>
      rootBundle.loadStructuredData(key, parser);
}

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

Widget _host(Widget child, Size size, {bool art = true}) {
  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: _theme(),
    home: child,
  );
  return shotHost(
    ChangeNotifierProvider<MetaController>.value(
      value: _meta,
      child: art
          ? app
          : DefaultAssetBundle(bundle: _NoArtBundle(), child: app),
    ),
    size,
  );
}

/// 위젯 테스트는 그림을 실제로 읽지 않는다 (진짜 비동기라 `pump` 로는 안 끝난다).
/// 미리 읽어 캐시에 넣어 둬야 원화가 화면에 나온다.
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

/// 고블린 정찰병이 나오는 판을 찾는다 (Phase 1.5 원화가 있는 유일한 적)
BattleController _goblinBattle() {
  for (var seed = 0; seed < 200; seed++) {
    final run = RunController(data: _data, random: Random(seed))..startRun();
    final bc = run.buildBattleController();
    if (bc.battle.enemy.id == 'goblin_scout') return bc;
  }
  throw StateError('고블린 정찰병이 나오는 판을 못 찾았다');
}

Future<BattleController> _pumpBattle(WidgetTester tester, Size size,
    {bool art = true}) async {
  prepareShot(tester, size);
  final bc = _goblinBattle();
  await tester.pumpWidget(_host(
      BattleScreen(controller: bc, regionId: 1, floor: 1, floors: 5),
      size,
      art: art));
  if (art) await _precacheArt(tester);
  await tester.pump(const Duration(milliseconds: 100));
  _measure(tester, size);
  return bc;
}

/// 무대 상자와 적 그림이 화면 어디에 놓였는지 숫자로 찍는다.
/// (픽셀 밀도·정렬은 눈으로 묻기 전에 먼저 잰다 — 로드맵 23-2절)
void _measure(WidgetTester tester, Size size) {
  final stage = tester.getRect(find.byType(BattleStage));
  final enemy = tester
      .widgetList<Image>(find.byType(Image))
      .where((w) => '${w.image}'.contains('goblin'))
      .isEmpty
      ? null
      : tester.getRect(find.byWidgetPredicate((w) =>
          w is Image && '${w.image}'.contains('goblin')));
  final tray = tester.getRect(find.byType(DiceTray));
  final hand = tester.getRect(find.byType(SpellCard).first);
  final line = stage.bottom - kFoeFrontFoot;
  final ctrl = size.height - hand.top;
  debugPrint('[구도] 화면 ${size.height.toInt()}dp · 무대 '
      '${(stage.height / size.height * 100).toStringAsFixed(0)}% · '
      '손패 ${hand.height.toStringAsFixed(0)} · 트레이 '
      '${tray.height.toStringAsFixed(0)} · 조작부 합 '
      '${ctrl.toStringAsFixed(0)} (${(ctrl / size.height * 100).toStringAsFixed(0)}%)');
  debugPrint('[측정] 기기 ${size.height.toInt()}dp · 무대 '
      '${stage.width.toStringAsFixed(0)}x${stage.height.toStringAsFixed(0)} '
      'top ${stage.top.toStringAsFixed(0)} · 발선 y ${line.toStringAsFixed(1)}'
      '${enemy == null ? '' : ' · 적 상자 ${enemy.top.toStringAsFixed(1)}~'
          '${enemy.bottom.toStringAsFixed(1)} → 발바닥 y '
          '${(enemy.top + enemy.height * kArtFootLine).toStringAsFixed(1)}'}');
}

/// 적이 실제로 때릴 때까지 턴을 돌린다 (피격 연출을 찍으려면 필요하다)
Future<bool> _playUntilPlayerHit(
    WidgetTester tester, BattleController bc) async {
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

  testWidgets('1. 기존 — 코드 도트 + 코드 배경', (tester) async {
    await _pumpBattle(tester, _big, art: false);
    await shoot(tester, _outDir, 'before');
  });

  testWidgets('2. 신규 — 원화 3장', (tester) async {
    await _pumpBattle(tester, _big);
    await shoot(tester, _outDir, 'after');
  });

  testWidgets('3. 신규 — 작은 기기 640dp', (tester) async {
    await _pumpBattle(tester, _small);
    await shoot(tester, _outDir, 'after_small');
  });

  testWidgets('4. 신규 — 피격 순간', (tester) async {
    final bc = await _pumpBattle(tester, _big);
    // 효과음 플러그인이 매번 새 이름의 이벤트 채널을 열어 이름으로는 못 막는다.
    // 그림만 찍으면 되므로 이 화면에서는 플러그인 예외를 흘려보낸다
    FlutterError.onError = (d) => debugPrint('무시: ${d.exception}');
    expect(await _playUntilPlayerHit(tester, bc), isTrue,
        reason: '적이 때리는 순간을 못 잡았다');
    await shoot(tester, _outDir, 'after_hit');
  });
}
