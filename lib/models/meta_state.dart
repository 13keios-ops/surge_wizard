import '../core/constants.dart';

/// 클리어 기록 하나를 가리키는 키 — 「지역-스테이지-난이도」.
/// 이 문자열 하나로 잠금·별표 판정이 전부 나온다 (WORK_ORDER_SCREENS 1-A).
String stageClearKey(int regionId, int stageIndex, Difficulty difficulty) =>
    '$regionId-$stageIndex-${difficulty.name}';

/// 영구 강화 상태 (판이 끝나도 유지, shared_preferences에 저장).
/// GAME_DESIGN 5.5절.
class MetaState {
  MetaState({
    required this.crystals,
    required this.hpLevel,
    required this.manaLevel,
    required this.rerollLevel,
    required this.startRelicLevel,
    required this.unlockedSpellIds,
    required this.clearedStageKeys,
    this.level = kStartLevel,
    this.exp = 0,
    this.passivePoints = 0,
  });

  /// 처음 시작 상태 (아무 강화 없음)
  factory MetaState.initial() => MetaState(
        crystals: 0,
        hpLevel: 0,
        manaLevel: 0,
        rerollLevel: 0,
        startRelicLevel: 0,
        unlockedSpellIds: {},
        clearedStageKeys: {},
      );

  /// 보유 마력 결정 (메타 재화)
  int crystals;

  /// ★ 캐릭터 레벨 1~99 (GROWTH.md 1절).
  /// **아래 hpLevel 등 v1 영구 강화 레벨과는 다른 것이다** — 그것들은 나중에
  /// 패시브 트리로 흡수된다
  int level;

  /// 현재 레벨에서 쌓인 경험치 (다음 레벨까지 남은 몫은 expToNextLevel 로 잰다)
  int exp;

  /// 레벨업으로 받은 패시브 포인트. **쓰는 화면은 아직 없다** (패시브 지시서)
  int passivePoints;

  /// 최대 체력 강화 단계 (0~5, 단계당 +3)
  int hpLevel;

  /// 최대 마나 강화 단계 (0~2, 단계당 +1)
  int manaLevel;

  /// 시작 리롤 강화 단계 (0~2, 단계당 리롤 +1)
  int rerollLevel;

  /// 시작 유물 단계 (0~1, 1이면 판 시작 시 무작위 common 유물 1개)
  int startRelicLevel;

  /// 해금한 epic 주문 id (해금해야 보상 추첨에 등장)
  final Set<String> unlockedSpellIds;

  /// 클리어한 「지역-스테이지-난이도」 키 모음 (stageClearKey 로 만든다).
  /// **판을 끝까지 깼을 때만** 들어간다 — 죽거나 나가면 기록하지 않는다.
  final Set<String> clearedStageKeys;

  /// 그 스테이지를 그 난이도로 깼는가
  bool hasCleared(int regionId, int stageIndex, Difficulty difficulty) =>
      clearedStageKeys.contains(stageClearKey(regionId, stageIndex, difficulty));

  /// 경험치를 받는다. **레벨업이 여러 번 일어날 수 있고**, 오른 레벨 수를 돌려준다.
  /// 레벨업 1회마다 패시브 포인트가 1개 쌓인다 (GROWTH.md 2절).
  /// 만렙에서는 더 받아도 아무 일도 일어나지 않는다.
  int gainExp(int amount) {
    if (level >= kMaxLevel || amount <= 0) return 0;
    exp += amount;
    var levelsGained = 0;
    for (var need = expToNextLevel(level);
        need != null && exp >= need;
        need = expToNextLevel(level)) {
      exp -= need;
      level++;
      levelsGained++;
      passivePoints += kPassivePointPerLevel;
    }
    if (level >= kMaxLevel) exp = 0; // 만렙에서는 남은 경험치를 들고 있지 않는다
    return levelsGained;
  }

  /// 클리어를 기록한다. 처음 기록하는 것이면 true (저장할 값이 생겼다는 뜻).
  bool markCleared(int regionId, int stageIndex, Difficulty difficulty) =>
      clearedStageKeys.add(stageClearKey(regionId, stageIndex, difficulty));

  factory MetaState.fromJson(Map<String, dynamic> json) => MetaState(
        crystals: (json['crystals'] as num?)?.toInt() ?? 0,
        hpLevel: (json['hp_level'] as num?)?.toInt() ?? 0,
        manaLevel: (json['mana_level'] as num?)?.toInt() ?? 0,
        rerollLevel: (json['reroll_level'] as num?)?.toInt() ?? 0,
        startRelicLevel: (json['start_relic_level'] as num?)?.toInt() ?? 0,
        unlockedSpellIds:
            ((json['unlocked_spells'] as List?) ?? const []).cast<String>().toSet(),
        // 옛 저장 파일에는 이 칸이 없다 — 없으면 빈 집합으로 읽는다
        clearedStageKeys:
            ((json['cleared_stages'] as List?) ?? const []).cast<String>().toSet(),
        // 레벨 칸도 마찬가지다 — 없으면 갓 시작한 것으로 읽는다
        level: (json['level'] as num?)?.toInt() ?? kStartLevel,
        exp: (json['exp'] as num?)?.toInt() ?? 0,
        passivePoints: (json['passive_points'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'crystals': crystals,
        'hp_level': hpLevel,
        'mana_level': manaLevel,
        'reroll_level': rerollLevel,
        'start_relic_level': startRelicLevel,
        'unlocked_spells': unlockedSpellIds.toList(),
        'cleared_stages': clearedStageKeys.toList(),
        'level': level,
        'exp': exp,
        'passive_points': passivePoints,
      };
}
