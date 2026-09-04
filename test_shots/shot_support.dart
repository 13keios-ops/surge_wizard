/// 캡처 도구 공용 부분 (테스트가 아니다 — 보고서용 그림을 만든다).
///
/// `flutter test` 는 `test/` 만 훑으므로 `test_shots/` 는 평소에 돌지 않는다.
/// 화면 캡처(`capture_test.dart`)와 스프라이트 시트(`pilot_wizard_test.dart`)가
/// 이 파일을 함께 쓴다.
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 개정 전(시스템 폰트) 화면을 재현할 때 쓰는 글꼴 이름
const kShotSystemFont = 'ShotSystem';
const _sysFontPath = r'C:\Windows\Fonts\malgun.ttf';

/// 폰트를 파일에서 직접 읽어 등록한다.
/// (위젯 테스트는 pubspec 의 폰트를 자동으로 싣지 않는다)
Future<void> loadFontFile(String family, String path) async {
  final file = File(path);
  if (!file.existsSync()) return;
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  await loader.load();
}

/// 게임이 쓰는 픽셀 폰트 + 개정 전 재현용 시스템 폰트를 모두 등록한다.
Future<void> loadShotFonts() async {
  await loadFontFile(kShotSystemFont, _sysFontPath);
  for (final f in const [
    ('Galmuri11', 'assets/fonts/Galmuri11.ttf'),
    ('Galmuri11', 'assets/fonts/Galmuri11-Bold.ttf'),
    ('Galmuri9', 'assets/fonts/Galmuri9.ttf'),
  ]) {
    await loadFontFile(f.$1, f.$2);
  }
}

/// 지금 화면을 PNG 파일로 떨군다.
///
/// 그림 저장은 **진짜 비동기**라 `runAsync` 안에서 해야 한다. 밖에서 하면
/// 테스트가 영원히 안 끝난다 (한 번 크게 데였다).
Future<void> shoot(WidgetTester tester, String dir, String name,
    {double pixelRatio = 1.0}) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byType(RepaintBoundary).first);
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory(dir).createSync(recursive: true);
    File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

/// 캡처할 위젯을 감싼다: 크기를 고정하고 바깥에 RepaintBoundary 를 두른다.
Widget shotHost(Widget child, Size size) => RepaintBoundary(
      child: MediaQuery(
        data: MediaQueryData(size: size, devicePixelRatio: 1),
        child: Directionality(textDirection: TextDirection.ltr, child: child),
      ),
    );

/// 테스트 화면 크기를 캡처 크기에 맞춘다.
void prepareShot(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
