/// 서클 슬롯표의 한 행 (GROWTH.md 3절 — assets/data/circle_slots.json).
///
/// 「어느 레벨에서 서클 1~9가 각각 몇 칸인가」를 담는다.
/// **표에 없는 레벨은 바로 위 칸(더 낮은 레벨의 행)을 그대로 쓴다** — 조회는
/// GameData.circleSlotsAt 이 한다.
class CircleSlotRow {
  const CircleSlotRow({required this.level, required this.slots});

  /// 이 행이 적용되기 시작하는 레벨
  final int level;

  /// 서클 1~9의 슬롯 수 (**언제나 9칸**, 안 열린 서클은 0)
  final List<int> slots;

  /// 덱 총량 = 슬롯 합계
  int get total => slots.fold(0, (a, b) => a + b);

  factory CircleSlotRow.fromJson(Map<String, dynamic> json) => CircleSlotRow(
        level: (json['level'] as num).toInt(),
        slots: (json['slots'] as List).map((e) => (e as num).toInt()).toList(),
      );

  Map<String, dynamic> toJson() => {'level': level, 'slots': slots};
}
