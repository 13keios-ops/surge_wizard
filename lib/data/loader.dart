import 'package:flutter/services.dart' show rootBundle;

import 'parser.dart';

export 'parser.dart' show GameData, GameDataParser;

/// 앱 실행 시 assets/data/ 에서 게임 데이터를 로드한다.
class GameDataLoader {
  static const _spellsPath = 'assets/data/spells.json';
  static const _surgesPath = 'assets/data/surges.json';
  static const _enemiesPath = 'assets/data/enemies.json';
  static const _relicsPath = 'assets/data/relics.json';
  static const _regionsPath = 'assets/data/regions.json';
  static const _stagesPath = 'assets/data/stages.json';
  static const _variantsPath = 'assets/data/variants.json';
  static const _circleSlotsPath = 'assets/data/circle_slots.json';

  /// 8개 파일을 전부 읽어 GameData 로 돌려준다.
  static Future<GameData> loadAll() async {
    final results = await Future.wait([
      rootBundle.loadString(_spellsPath),
      rootBundle.loadString(_surgesPath),
      rootBundle.loadString(_enemiesPath),
      rootBundle.loadString(_relicsPath),
      rootBundle.loadString(_regionsPath),
      rootBundle.loadString(_stagesPath),
      rootBundle.loadString(_variantsPath),
      rootBundle.loadString(_circleSlotsPath),
    ]);
    return GameData(
      spells: GameDataParser.parseSpells(results[0]),
      surges: GameDataParser.parseSurges(results[1]),
      enemies: GameDataParser.parseEnemies(results[2]),
      relics: GameDataParser.parseRelics(results[3]),
      regions: GameDataParser.parseRegions(results[4]),
      stages: GameDataParser.parseStages(results[5]),
      variants: GameDataParser.parseVariants(results[6]),
      circleSlots: GameDataParser.parseCircleSlots(results[7]),
    );
  }
}
