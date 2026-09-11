import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/art/art_sprite.dart';

/// 원화 표시와 대체(fallback) 동작만 본다. 그림 자체의 규격은
/// `tool/bake_art.py` 가 구울 때 잰다.
void main() {
  Widget host(String asset) => Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: ArtSpriteView(
            asset,
            size: 120,
            shadow: true,
            flashAmount: 0.5,
            fallback: const SizedBox(
                key: ValueKey('fallback'), width: 120, height: 120),
          ),
        ),
      );

  testWidgets('원화 경로가 잘못돼도 화면이 죽지 않고 대체가 나온다',
      (tester) async {
    await tester.pumpWidget(host('assets/art/wizard/없는파일.webp'));
    await tester.pump();
    expect(find.byKey(const ValueKey('fallback')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('구워 둔 원화는 그대로 그려진다', (tester) async {
    for (final asset in [
      kArtWizardBack,
      ...kArtEnemies.values,
      ...kArtRegionBackdrops.values,
    ]) {
      await tester.pumpWidget(host(asset));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: asset);
      expect(find.byKey(const ValueKey('fallback')), findsNothing,
          reason: asset);
    }
  });

  testWidgets('배경 원화를 못 읽어도 코드 배경으로 떨어진다', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ArtBackdropView('assets/art/bg/없는파일.webp',
          fallback: const SizedBox(key: ValueKey('fallback'))),
    ));
    await tester.pump();
    expect(find.byKey(const ValueKey('fallback')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
