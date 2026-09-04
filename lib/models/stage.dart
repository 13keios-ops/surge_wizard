/// 스테이지 (assets/data/stages.json 의 항목 1개).
/// 「스테이지 하나 클리어 = 한 판 끝」이므로 층수가 곧 한 판의 길이다 (STAGES.md 1절).
class Stage {
  const Stage({
    required this.id,
    required this.regionId,
    required this.index,
    required this.floors,
    required this.recommendedLevel,
    required this.isBossStage,
    this.subtitle,
  });

  /// "r1_s1" 형태의 고유 id
  final String id;

  /// 속한 지역 번호
  final int regionId;

  /// 지역 안에서의 순번 1~(지역의 stage_count)
  final int index;

  /// 이 스테이지의 층 수 3~10. 마지막 층이 보스다
  final int floors;

  /// 권장 레벨 (레벨 시스템은 아직 없다 — 표시용)
  final int recommendedLevel;

  /// 지역 보스가 나오는 마지막 스테이지인가
  final bool isBossStage;

  /// 부제 (있는 스테이지만)
  final String? subtitle;

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
        id: json['id'] as String,
        regionId: (json['region_id'] as num).toInt(),
        index: (json['index'] as num).toInt(),
        floors: (json['floors'] as num).toInt(),
        recommendedLevel: (json['recommended_level'] as num).toInt(),
        isBossStage: json['is_boss_stage'] as bool? ?? false,
        subtitle: json['subtitle'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'region_id': regionId,
        'index': index,
        if (subtitle != null) 'subtitle': subtitle,
        'floors': floors,
        'recommended_level': recommendedLevel,
        'is_boss_stage': isBossStage,
      };
}
