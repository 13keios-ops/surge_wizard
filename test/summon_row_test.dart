import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/core/surge.dart';
import 'package:surge_wizard/widgets/summon_row.dart';

/// 소환수 표시 (`WORK_ORDER_SUMMONS_UI.md` 3절).
///
/// **이게 없어서 맞는 이유가 화면에 안 보였다.** 하드의 호위가 매 턴 때리는데
/// 원인이 화면에 없었다.
void main() {
  Future<void> show(WidgetTester tester, List<SummonUnit> summons) =>
      tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(children: [SummonRow(summons: summons)]),
      ));

  /// 그려진 소환수 몸통(원)의 개수
  int chips(WidgetTester tester) => tester
      .widgetList<Container>(find.byType(Container))
      .where((c) => (c.decoration as BoxDecoration?)?.shape == BoxShape.circle)
      .length;

  testWidgets('1. 없으면 아무것도 안 그린다', (tester) async {
    await show(tester, []);
    expect(chips(tester), 0);
  });

  testWidgets('2. 아군 1체가 그려진다', (tester) async {
    await show(tester, [SummonUnit(power: 5)]);
    expect(chips(tester), 1);
    expect(find.text('5'), findsOneWidget, reason: '위력을 보여 준다');
  });

  testWidgets('3. 적대 1체가 그려진다 (호위)', (tester) async {
    await show(tester, [SummonUnit(power: -4, turnsLeft: 999)]);
    expect(chips(tester), 1);
    expect(find.text('4'), findsOneWidget, reason: '위력은 절댓값으로 보여 준다');
  });

  testWidgets('4. 아군과 적대가 섞여도 개수만큼 그려진다', (tester) async {
    await show(tester, [
      SummonUnit(power: 5),
      SummonUnit(power: 3),
      SummonUnit(power: -4, turnsLeft: 999),
    ]);
    expect(chips(tester), 3);
  });

  testWidgets('5. 🔴 호위(999턴)는 남은 턴을 안 보여 준다', (tester) async {
    await show(tester, [SummonUnit(power: -4, turnsLeft: 999)]);
    expect(find.text('999'), findsNothing, reason: '사실상 무한이라 숫자가 어지럽다');
  });

  testWidgets('6. 폭주 소환수는 남은 턴을 보여 준다', (tester) async {
    await show(tester, [SummonUnit(power: 5, turnsLeft: 2)]);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('7. 아군과 적대가 화면에서 좌우로 갈린다', (tester) async {
    await show(tester, [SummonUnit(power: 5), SummonUnit(power: -4)]);
    final xs = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => (c.decoration as BoxDecoration?)?.shape == BoxShape.circle)
        .map((c) => tester.getCenter(find.byWidget(c)).dx)
        .toList();
    expect(xs.length, 2);
    expect(xs[0], isNot(xs[1]), reason: '같은 자리에 겹치면 안 된다');
  });
}
