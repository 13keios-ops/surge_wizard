import 'constants.dart';

/// 시전 강도 (GAME_DESIGN v2 3.3절 — 2단계).
/// v1의 「약하게」는 삭제됐다. 마나 0에 대성공률까지 높아 지배 전략이 됐기
/// 때문이다. 이제 마나는 「위험과 재시도를 사는 돈」 하나의 뜻만 갖는다.
enum CastIntensity { normal, full }

/// 강도별 수치 조회 (enum 순서 = normal, full 고정에 의존).
/// 리스트 순서가 한 칸만 어긋나도 전력이 보통 값을 쓴다 —
/// test/intensity_test.dart 가 이를 검사한다.
extension CastIntensityValues on CastIntensity {
  /// 목표치(DC)
  int get dc => const [kDcNormal, kDcFull][index];

  /// 위력 배율
  double get power => const [kPowerNormal, kPowerFull][index];

  /// 마나 비용 (보통은 0이므로 언제나 시전할 수 있다)
  int get manaCost => const [kManaCostNormal, kManaCostFull][index];

  /// 대성공 시 마나 환급량
  int get critManaRefund =>
      const [kCritManaRefundNormal, kCritManaRefundFull][index];

  /// 화면 표시용 이름
  String get label => const ['보통', '전력'][index];
}
