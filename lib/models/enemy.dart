import '../core/constants.dart';

/// 적의 행동 1개 (고정 패턴의 한 칸)
class EnemyAction {
  const EnemyAction({
    required this.action,
    required this.value,
    required this.label,
  });

  /// 행동 종류: attack / charge / defend / heal
  final String action;

  /// 행동 수치 (공격력, 방어막량, 회복량)
  final int value;

  /// 화면에 예고로 표시할 문구
  final String label;

  factory EnemyAction.fromJson(Map<String, dynamic> json) => EnemyAction(
        action: json['action'] as String,
        value: (json['value'] as num).toInt(),
        label: json['label'] as String,
      );

  Map<String, dynamic> toJson() =>
      {'action': action, 'value': value, 'label': label};
}

/// 적 (assets/data/enemies.json 의 항목 1개)
class Enemy {
  const Enemy({
    required this.id,
    required this.name,
    required this.icon,
    required this.hp,
    required this.tier,
    required this.isBoss,
    required this.pattern,
    this.variantId = kNormalVariantId,
    this.region,
    this.phase2HpThreshold,
    this.phase2Pattern,
  });

  final String id;
  final String name;
  final String icon;

  /// 최대 체력
  final int hp;

  /// 난이도 단계 1~5
  final int tier;

  final bool isBoss;

  /// 고정 순환 패턴 (랜덤 없음)
  final List<EnemyAction> pattern;

  /// 어느 변종으로 조립됐는가 (buildEnemy 가 채운다).
  /// **원본 데이터에는 없는 값이라** JSON에서 읽지 않고 기본 변종으로 시작한다.
  /// 경험치 변종 배수가 이 값을 본다 (GROWTH.md 1.3절).
  final String variantId;

  /// 이 적이 맡은 지역 번호 1~12.
  /// 지역 보스만 값이 있다 — 일반 적 26종과 미배정 보스(주사위 포식자)는 null이다
  final int? region;

  /// 보스 전용: HP가 이 값 이하가 되면 2페이즈로 전환
  final int? phase2HpThreshold;

  /// 보스 전용: 2페이즈 패턴
  final List<EnemyAction>? phase2Pattern;

  factory Enemy.fromJson(Map<String, dynamic> json) => Enemy(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        hp: (json['hp'] as num).toInt(),
        tier: (json['tier'] as num).toInt(),
        isBoss: json['is_boss'] as bool? ?? false,
        pattern: (json['pattern'] as List)
            .map((e) => EnemyAction.fromJson(e as Map<String, dynamic>))
            .toList(),
        region: (json['region'] as num?)?.toInt(),
        phase2HpThreshold: (json['phase2_hp_threshold'] as num?)?.toInt(),
        phase2Pattern: json['phase2_pattern'] == null
            ? null
            : (json['phase2_pattern'] as List)
                .map((e) => EnemyAction.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'hp': hp,
        'tier': tier,
        'is_boss': isBoss,
        'pattern': pattern.map((e) => e.toJson()).toList(),
        if (region != null) 'region': region,
        if (phase2HpThreshold != null)
          'phase2_hp_threshold': phase2HpThreshold,
        if (phase2Pattern != null)
          'phase2_pattern': phase2Pattern!.map((e) => e.toJson()).toList(),
      };
}
