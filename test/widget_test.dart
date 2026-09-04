/// 화면 스모크 테스트: 타이틀 → 지역 선택 → 스테이지 선택 → 지도 →
/// 전투 진입 → 주문 선택 → 굴림 → 시전까지 실제 흐름이 끊기지 않는지 확인한다.
/// (WORK_ORDER_SCREENS 작업 4 검사 8)
///
/// 전투 화면은 배경 별빛이 계속 반복 재생되므로 `pumpAndSettle`을 쓰면
/// 영원히 안 끝난다. 전투에 들어간 뒤로는 `pump(시간)`으로 넘긴다.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surge_wizard/main.dart';
import 'package:surge_wizard/widgets/dice_widget.dart';

void main() {
  testWidgets('타이틀 → 지역 → 스테이지 → 지도 → 전투 한 턴 스모크 테스트',
      (tester) async {
    SharedPreferences.setMockInitialValues({}); // 저장소를 빈 상태로 흉내
    await tester.pumpWidget(const SurgeWizardApp());
    await tester.pumpAndSettle(); // 게임 데이터(JSON)·저장 로드 대기

    // 타이틀 화면: 영구 강화 진입 버튼도 보인다
    expect(find.text('폭주 마법사'), findsOneWidget);
    expect(find.textContaining('영구 강화'), findsOneWidget);
    await tester.tap(find.text('모험 시작'));
    await tester.pumpAndSettle();

    // 지역 선택: 1지역은 열려 있고 2지역은 해금 조건이 보인다
    expect(find.text('지역'), findsOneWidget);
    expect(find.text('마나의 숲'), findsOneWidget);
    expect(find.textContaining('잠김'), findsWidgets);
    await tester.tap(find.text('마나의 숲'));
    await tester.pumpAndSettle();

    // 스테이지 선택: 난이도 3탭 + 스테이지 격자. 하드·데스는 잠겨 있다
    expect(find.text('보통'), findsOneWidget);
    expect(find.text('하드 잠김'), findsOneWidget);
    expect(find.text('데스 잠김'), findsOneWidget);
    await tester.tap(find.text('I'));
    await tester.pumpAndSettle();

    // 지도 화면: 「n / m층」 진행 막대와 들어가기 버튼이 있다
    expect(find.textContaining('마나의 숲 I'), findsOneWidget);
    expect(find.text('1 / 3층'), findsOneWidget);
    expect(find.text('다음 상대'), findsOneWidget);
    await tester.tap(find.textContaining('들어가기'));
    // 여기서부터는 배경 애니메이션이 계속 돌아 settle 되지 않는다
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // 전투 화면: 자원 표시와 시작 손패가 보인다
    expect(find.textContaining('마나'), findsWidgets);
    expect(find.text('화염구'), findsOneWidget);
    expect(find.text('마력방패'), findsOneWidget);

    // 주문 선택 → 주사위 굴리기 (굴림 애니메이션이 끝날 시간을 준다)
    await tester.tap(find.text('화염구'));
    await tester.pump();
    await tester.tap(find.text('주사위 굴리기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byType(DiceWidget), findsNWidgets(3));
    // 리롤 버튼이 이번 회차 비용(1 → 2 → 3 체증)을 표시한다
    expect(find.textContaining('리롤'), findsOneWidget);

    // 시전 확정 — 마법 이펙트가 재생될 시간을 준다
    await tester.tap(find.text('시전!'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    // 실패(폭주)였다면 팝업을 닫는다
    final dismiss = find.text('이런...');
    if (dismiss.evaluate().isNotEmpty) {
      await tester.tap(dismiss);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    // 턴 종료 버튼(계속) 또는 전투 종료 버튼(한 방에 끝난 경우)이 보인다
    final canContinue = find.text('턴 종료').evaluate().isNotEmpty;
    final isOver = find.text('승리!').evaluate().isNotEmpty ||
        find.text('쓰러졌다...').evaluate().isNotEmpty;
    expect(canContinue || isOver, isTrue);
  });
}
