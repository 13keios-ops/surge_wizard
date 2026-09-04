/// 적 변종 (assets/data/variants.json 의 항목 1개).
/// 적 26종을 그림 추가 없이 156가지로 늘리는 장치다 (ENEMIES.md 5절).
class EnemyVariant {
  const EnemyVariant({
    required this.id,
    required this.namePrefix,
    required this.hpMul,
    required this.atkMul,
    this.tint,
  });

  final String id;

  /// 이름 앞에 붙는 수식어. 기본 변종은 빈 문자열이다
  final String namePrefix;

  /// 색조 "#RRGGBB". 색 변환은 화면 쪽에서 한다
  /// (models/ 가 Flutter에 의존하면 tool/ 이 죽는다 — CLAUDE.md LESSONS)
  final String? tint;

  /// 체력 배율 (방어·회복 값에도 같이 곱한다)
  final double hpMul;

  /// 공격 배율 (공격·강타 값에 곱한다)
  final double atkMul;

  factory EnemyVariant.fromJson(Map<String, dynamic> json) => EnemyVariant(
        id: json['id'] as String,
        namePrefix: json['name_prefix'] as String? ?? '',
        tint: json['tint'] as String?,
        hpMul: (json['hp_mul'] as num).toDouble(),
        atkMul: (json['atk_mul'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_prefix': namePrefix,
        'tint': tint,
        'hp_mul': hpMul,
        'atk_mul': atkMul,
      };
}
