/// 지역 (assets/data/regions.json 의 항목 1개).
/// 전투 구성에 필요한 값을 전부 들고 있다 — ENEMIES.md 5·6절, STAGES.md 2절.
class Region {
  const Region({
    required this.id,
    required this.name,
    required this.theme,
    required this.bossId,
    required this.stageCount,
    required this.exp,
    required this.hpScale,
    required this.atkScale,
    required this.tierPool,
    required this.variantWeights,
  });

  /// 지역 번호 1~12
  final int id;

  final String name;

  /// 배경 테마: forest / dungeon / desert / tower
  final String theme;

  /// 이 지역 마지막 층에 서는 보스의 id
  final String bossId;

  /// 이 지역에 속한 스테이지 수
  final int stageCount;

  /// 이 지역의 일반 적 하나가 주는 경험치 (GROWTH.md 1.3절).
  /// **지역 하나에 값 하나다** — tier로 나누지 않는다. 보스·변종·난이도가 여기에 곱해진다
  final int exp;

  /// 지역 체력 배율 — 일반 적의 hp·방어·회복에 곱한다 (보스는 제외).
  /// ENEMIES.md 6절: 1.00 → 5.00
  final double hpScale;

  /// 지역 공격 배율 — 일반 적의 공격·강타에 곱한다 (보스는 제외).
  /// tier가 이미 공격을 2.4배 올리므로 체력 배율보다 훨씬 완만하다 (1.00 → 1.45).
  /// 하나로 묶으면 일반 적이 보스보다 아파진다 — ENEMIES.md 6절
  final double atkScale;

  /// tier 가중치. 키는 tier 번호의 문자열("1"~"5"), 값은 가중치 (합 100)
  final Map<String, int> tierPool;

  /// 변종 가중치. 키는 변종 id, 값은 가중치 (합 100)
  final Map<String, int> variantWeights;

  /// JSON의 `{"1": 90}` 형태를 `Map<String, int>`로 옮긴다
  static Map<String, int> _weights(Object? raw) =>
      (raw as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toInt()));

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        theme: json['theme'] as String,
        bossId: json['boss_id'] as String,
        stageCount: (json['stage_count'] as num).toInt(),
        exp: (json['exp'] as num).toInt(),
        hpScale: (json['hp_scale'] as num).toDouble(),
        atkScale: (json['atk_scale'] as num).toDouble(),
        tierPool: _weights(json['tier_pool']),
        variantWeights: _weights(json['variant_weights']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'theme': theme,
        'boss_id': bossId,
        'stage_count': stageCount,
        'exp': exp,
        'hp_scale': hpScale,
        'atk_scale': atkScale,
        'tier_pool': tierPool,
        'variant_weights': variantWeights,
      };
}
