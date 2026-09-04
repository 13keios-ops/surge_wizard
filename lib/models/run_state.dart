import '../core/constants.dart';

/// 한 판(run)의 진행 상태 = 「지역·스테이지 하나를 도는 중」.
/// 최대 체력은 저장하지 않는다 — 기본치 + 유물 효과로 계산되는 파생값이다.
class RunState {
  RunState({
    required this.regionId,
    required this.stageIndex,
    required this.difficulty,
    required this.floor,
    required this.hp,
    required this.charge,
    required this.handIds,
    required this.relicIds,
  });

  /// 새 판 시작 상태 (GAME_DESIGN v2 4.2·6절)
  factory RunState.initial({
    int regionId = kEntryRegionId,
    int stageIndex = kEntryStageIndex,
    Difficulty difficulty = kEntryDifficulty,
  }) =>
      RunState(
        regionId: regionId,
        stageIndex: stageIndex,
        difficulty: difficulty,
        floor: 1,
        hp: kPlayerStartHp,
        charge: 0,
        handIds: List.of(kStarterSpellIds),
        relicIds: [],
      );

  /// 지역 번호 1~12
  int regionId;

  /// 지역 안에서의 스테이지 순번 1~(지역의 stage_count)
  int stageIndex;

  /// 이 판의 난이도
  Difficulty difficulty;

  /// 현재 층 (1~스테이지의 floors)
  int floor;

  /// 현재 체력 (전투 사이에 유지된다)
  int hp;

  /// 마력 축적 게이지 (판 동안 유지)
  int charge;

  /// 손패 주문 id 3칸
  final List<String> handIds;

  /// 보유 유물 id 목록
  final List<String> relicIds;

  /// 스테이지를 끝까지 돌았는가. 층수는 스테이지마다 다르므로 밖에서 받는다
  bool isCleared(int floors) => floor > floors;

  /// 옛 저장본 호환은 하지 않는다 — 필드가 없으면 기본값으로 새 판이 된다
  factory RunState.fromJson(Map<String, dynamic> json) => RunState(
        regionId: (json['region_id'] as num?)?.toInt() ?? kEntryRegionId,
        stageIndex: (json['stage_index'] as num?)?.toInt() ?? kEntryStageIndex,
        difficulty: Difficulty.values.firstWhere(
          (d) => d.name == json['difficulty'],
          orElse: () => kEntryDifficulty,
        ),
        floor: (json['floor'] as num).toInt(),
        hp: (json['hp'] as num).toInt(),
        charge: (json['charge'] as num).toInt(),
        handIds: (json['hand_ids'] as List).cast<String>(),
        relicIds: (json['relic_ids'] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'region_id': regionId,
        'stage_index': stageIndex,
        'difficulty': difficulty.name,
        'floor': floor,
        'hp': hp,
        'charge': charge,
        'hand_ids': handIds,
        'relic_ids': relicIds,
      };
}
