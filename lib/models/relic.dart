import 'effect.dart';

/// 유물 (assets/data/relics.json 의 항목 1개)
class Relic {
  const Relic({
    required this.id,
    required this.name,
    required this.icon,
    required this.rarity,
    required this.description,
    required this.effect,
  });

  final String id;
  final String name;
  final String icon;

  /// 등급: common / rare / epic
  final String rarity;

  final String description;

  /// 유물 효과 (대부분 판정 확률 관련)
  final GameEffect effect;

  factory Relic.fromJson(Map<String, dynamic> json) => Relic(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        rarity: json['rarity'] as String,
        description: json['description'] as String,
        effect: GameEffect.fromJson(json['effect'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'rarity': rarity,
        'description': description,
        'effect': effect.toJson(),
      };
}
