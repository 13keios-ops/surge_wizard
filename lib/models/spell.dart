import 'effect.dart';

/// 주문 (assets/data/spells.json 의 항목 1개)
class Spell {
  const Spell({
    required this.id,
    required this.name,
    required this.icon,
    required this.element,
    required this.rarity,
    required this.baseDamage,
    required this.dcModifier,
    required this.effect,
    required this.description,
    required this.surgeTags,
  });

  final String id;
  final String name;
  final String icon;

  /// 속성: fire / frost / arcane / shadow / nature
  final String element;

  /// 등급: common / rare / epic
  final String rarity;

  /// 기본 대미지. 강도 배율 × 결과 배율을 곱해 최종 대미지가 된다.
  final int baseDamage;

  /// 주문 고유의 시전 난이도 보정 (DC에 더해짐)
  final int dcModifier;

  /// 특수 효과. 없으면 null.
  final GameEffect? effect;

  final String description;

  /// 실패 시 어떤 폭주가 나올지 필터링에 쓰는 태그
  final List<String> surgeTags;

  factory Spell.fromJson(Map<String, dynamic> json) => Spell(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        element: json['element'] as String,
        rarity: json['rarity'] as String,
        baseDamage: (json['base_damage'] as num).toInt(),
        dcModifier: (json['dc_modifier'] as num).toInt(),
        effect: json['effect'] == null
            ? null
            : GameEffect.fromJson(json['effect'] as Map<String, dynamic>),
        description: json['description'] as String,
        surgeTags: (json['surge_tags'] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'element': element,
        'rarity': rarity,
        'base_damage': baseDamage,
        'dc_modifier': dcModifier,
        'effect': effect?.toJson(),
        'description': description,
        'surge_tags': surgeTags,
      };
}
