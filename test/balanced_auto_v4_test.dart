import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/core/balanced_auto_v4.dart';
import 'package:surge_wizard/core/combat_engine_v4.dart';
import 'package:surge_wizard/core/hex_coord_v4.dart';
import 'package:surge_wizard/core/vertical_slice_catalog_v4.dart';
void main(){const planner=BalancedAutoPlannerV4();test('low HP engaged Kael values Guard',(){final kael=VerticalSliceCatalogV4.kael();kael.hp=25;final enemy=VerticalSliceCatalogV4.enemy('enemy_cursed_armor','armor',const HexCoord(2,2));final engine=CombatEngineV4(seed:1,units:[kael,enemy]);expect(planner.choose(engine,kael).kind,BalancedIntentKindV4.kaelGuard);});test('Nera can select Expose against a durable target in range',(){final nera=VerticalSliceCatalogV4.nera();final enemy=VerticalSliceCatalogV4.enemy('enemy_cursed_armor','armor',const HexCoord(3,4));final engine=CombatEngineV4(seed:2,units:[nera,enemy]);expect(planner.choose(engine,nera).kind,BalancedIntentKindV4.neraExpose);});}
