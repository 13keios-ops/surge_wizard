import 'effect.dart';

/// 폭주 사건 (assets/data/surges.json 의 항목 1개)
class SurgeEvent {
  const SurgeEvent({
    required this.id,
    required this.name,
    required this.text,
    required this.category,
    required this.weight,
    required this.tags,
    required this.effects,
  });

  final String id;
  final String name;

  /// 사고 묘사 문장 (연출용)
  final String text;

  /// 갈래: backlash(역류) / misfire(오발) / fizzle(불발) /
  /// amplify(증폭) / summon(소환) / chain(연쇄) — SURGE_DESIGN 2절
  final String category;

  /// 추첨 가중치. 흔한 사고일수록 높다.
  final int weight;

  /// 발생 조건 태그. ["any"] 이면 모든 주문에서 발생 가능.
  final List<String> tags;

  /// 적용 효과 목록 (여러 개 가능)
  final List<GameEffect> effects;

  /// 이 폭주가 주어진 주문 태그에서 발생할 수 있는지
  bool matchesTags(List<String> spellTags) {
    if (tags.contains('any')) return true;
    return tags.any(spellTags.contains);
  }

  factory SurgeEvent.fromJson(Map<String, dynamic> json) => SurgeEvent(
        id: json['id'] as String,
        name: json['name'] as String,
        text: json['text'] as String,
        category: json['category'] as String? ?? 'unknown',
        weight: (json['weight'] as num).toInt(),
        tags: (json['tags'] as List).cast<String>(),
        effects: (json['effects'] as List)
            .map((e) => GameEffect.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'text': text,
        'category': category,
        'weight': weight,
        'tags': tags,
        'effects': effects.map((e) => e.toJson()).toList(),
      };
}
