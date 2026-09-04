import 'dart:convert';

import '../models/circle_slots.dart';
import '../models/enemy.dart';
import '../models/enemy_variant.dart';
import '../models/region.dart';
import '../models/relic.dart';
import '../models/spell.dart';
import '../models/stage.dart';
import '../models/surge_event.dart';

/// 게임 데이터 8종을 한 번에 담는 컨테이너.
class GameData {
  const GameData({
    required this.spells,
    required this.surges,
    required this.enemies,
    required this.relics,
    required this.regions,
    required this.stages,
    required this.variants,
    required this.circleSlots,
  });

  final List<Spell> spells;
  final List<SurgeEvent> surges;
  final List<Enemy> enemies;
  final List<Relic> relics;
  final List<Region> regions;
  final List<Stage> stages;
  final List<EnemyVariant> variants;

  /// 서클 슬롯표 (GROWTH.md 3절). 레벨 오름차순으로 들어온다
  final List<CircleSlotRow> circleSlots;

  /// 지역 번호로 지역을 찾는다
  Region region(int id) => regions.firstWhere((r) => r.id == id);

  /// 지역 번호 + 순번으로 스테이지를 찾는다
  Stage stage(int regionId, int index) =>
      stages.firstWhere((s) => s.regionId == regionId && s.index == index);

  /// 변종 id로 변종을 찾는다
  EnemyVariant variant(String id) => variants.firstWhere((v) => v.id == id);

  /// [level] 에서 열려 있는 서클 1~9의 슬롯 수 (GROWTH.md 3절).
  /// **표에 없는 레벨은 바로 위 칸을 그대로 쓴다** — 레벨 44는 레벨 30 행이다.
  List<int> circleSlotsAt(int level) => circleSlots
      .lastWhere((r) => r.level <= level, orElse: () => circleSlots.first)
      .slots;
}

/// JSON 문자열 → 모델 리스트 파서 모음.
/// Flutter 의존성이 없어 단위 테스트·CLI 시뮬레이터에서 그대로 쓴다.
class GameDataParser {
  /// 리스트 형태의 JSON을 [build]로 하나씩 옮긴다
  static List<T> _parseList<T>(
          String jsonText, T Function(Map<String, dynamic>) build) =>
      (jsonDecode(jsonText) as List)
          .map((e) => build(e as Map<String, dynamic>))
          .toList();

  static List<Spell> parseSpells(String jsonText) =>
      _parseList(jsonText, Spell.fromJson);

  static List<SurgeEvent> parseSurges(String jsonText) =>
      _parseList(jsonText, SurgeEvent.fromJson);

  static List<Enemy> parseEnemies(String jsonText) =>
      _parseList(jsonText, Enemy.fromJson);

  static List<Relic> parseRelics(String jsonText) =>
      _parseList(jsonText, Relic.fromJson);

  static List<Region> parseRegions(String jsonText) =>
      _parseList(jsonText, Region.fromJson);

  static List<Stage> parseStages(String jsonText) =>
      _parseList(jsonText, Stage.fromJson);

  static List<EnemyVariant> parseVariants(String jsonText) =>
      _parseList(jsonText, EnemyVariant.fromJson);

  static List<CircleSlotRow> parseCircleSlots(String jsonText) =>
      _parseList(jsonText, CircleSlotRow.fromJson);

  /// 8개 파일을 한 번에 옮긴다. [read]는 "spells.json" 같은 파일 이름을 받아
  /// 그 내용을 돌려준다 — 단위 테스트·CLI 도구가 디스크에서 직접 읽을 때 쓴다.
  static GameData parseAll(String Function(String fileName) read) => GameData(
        spells: parseSpells(read('spells.json')),
        surges: parseSurges(read('surges.json')),
        enemies: parseEnemies(read('enemies.json')),
        relics: parseRelics(read('relics.json')),
        regions: parseRegions(read('regions.json')),
        stages: parseStages(read('stages.json')),
        variants: parseVariants(read('variants.json')),
        circleSlots: parseCircleSlots(read('circle_slots.json')),
      );
}
