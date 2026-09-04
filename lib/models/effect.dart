/// 주문·폭주·유물이 공통으로 쓰는 효과 구조 `{ "type": ..., "value": ... }`.
/// 값의 의미 규약은 BLOCKERS.md 판단 6 참조.
class GameEffect {
  const GameEffect({required this.type, required this.value});

  /// 효과 종류 (예: self_damage, heal, shield ...)
  final String type;

  /// 효과 수치. 음수 허용 (마나 소모, 적대 소환 등)
  final int value;

  factory GameEffect.fromJson(Map<String, dynamic> json) => GameEffect(
        type: json['type'] as String,
        value: (json['value'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {'type': type, 'value': value};
}
