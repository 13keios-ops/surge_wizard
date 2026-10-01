import 'dart:io';

import 'package:surge_wizard/core/encounter_loader_v4.dart';
import 'package:surge_wizard/core/headless_dungeon_runner_v4.dart';

Future<void> main(List<String> args) async {
  final runs = args.isEmpty ? 5000 : int.parse(args.first);
  final source = await File('assets/data/v4_vertical_slice_encounters.json').readAsString();
  final encounters = const EncounterLoaderV4().decode(source);
  const runner = HeadlessDungeonRunnerV4();
  stdout.writeln('route,runs,completion_rate,avg_cleared,avg_hp,avg_wizard_mp,avg_potions_left,avg_potions_used,avg_surge,avg_unstable');
  for (final optional in [false,true]) {
    var completed=0,cleared=0,mp=0,potionsLeft=0,potionsUsed=0,surge=0,unstable=0; var hp=0.0;
    for(var i=0;i<runs;i++){final result=runner.run(allEncounters:encounters,seed:23092026+i,includeOptionalB04:optional);if(result.completed)completed++;cleared+=result.encountersCleared;hp+=result.partyHpRatio;mp+=result.wizardMpRemaining;potionsLeft+=result.potionsRemaining;potionsUsed+=result.potionsUsed;surge+=result.surgeCount;unstable+=result.unstableCount;}
    stdout.writeln([optional?'B02-B03-B04-B05':'B02-B03-B05',runs,(completed/runs).toStringAsFixed(4),(cleared/runs).toStringAsFixed(3),(hp/runs).toStringAsFixed(4),(mp/runs).toStringAsFixed(2),(potionsLeft/runs).toStringAsFixed(3),(potionsUsed/runs).toStringAsFixed(3),(surge/runs).toStringAsFixed(3),(unstable/runs).toStringAsFixed(3)].join(','));
  }
}
