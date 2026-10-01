import 'combat_state_v4.dart';
import 'encounter_data_v4.dart';
import 'hex_coord_v4.dart';
abstract final class VerticalSliceCatalogV4 {
  static CombatUnitV4 wizard()=>CombatUnitV4(id:'wizard',name:'Wizard',team:CombatTeamV4.party,anchor:const HexCoord(1,3),stats:const UnitStatsV4(maxHp:60,maxMp:126,speed:106,move:2,evasion:12,fortitude:12,resolve:14,brace:12,armor:1,magicResist:1),primaryModifier:3,secondaryModifier:1,weaponPower:7,mastery:1,equipmentAccuracy:1);
  static CombatUnitV4 kael()=>CombatUnitV4(id:'kael',name:'Kael',team:CombatTeamV4.party,anchor:const HexCoord(1,2),stats:const UnitStatsV4(maxHp:102,speed:104,move:2,evasion:12,fortitude:14,resolve:11,brace:14,armor:3),primaryModifier:3,secondaryModifier:1,weaponPower:8,mastery:2);
  static CombatUnitV4 nera()=>CombatUnitV4(id:'nera',name:'Nera',team:CombatTeamV4.party,anchor:const HexCoord(1,4),stats:const UnitStatsV4(maxHp:72,speed:114,move:3,evasion:14,fortitude:12,resolve:12,brace:12,armor:1),primaryModifier:3,secondaryModifier:1,weaponPower:6,mastery:2);
  static CombatUnitV4 enemy(String t,String id,HexCoord a)=>switch(t){
    'enemy_goblin_scout'=>CombatUnitV4(id:id,name:'Goblin Scout',team:CombatTeamV4.enemy,anchor:a,stats:const UnitStatsV4(maxHp:34,speed:110,move:3,evasion:13,fortitude:11,resolve:11,brace:11,armor:1),primaryModifier:2,weaponPower:6,mastery:2),
    'enemy_skeleton_apprentice'=>CombatUnitV4(id:id,name:'Skeleton Apprentice',team:CombatTeamV4.enemy,anchor:a,stats:const UnitStatsV4(maxHp:40,speed:98,move:2,evasion:11,fortitude:12,resolve:13,brace:12,armor:1,magicResist:2),primaryModifier:2,weaponPower:7,mastery:2,immunities:const{StatusTypeV4.bleeding,StatusTypeV4.poisoned}),
    'enemy_cursed_armor'=>CombatUnitV4(id:id,name:'Cursed Armor',team:CombatTeamV4.enemy,anchor:a,stats:const UnitStatsV4(maxHp:58,speed:88,move:2,evasion:10,fortitude:14,resolve:11,brace:15,armor:4,magicResist:1),primaryModifier:3,weaponPower:11,mastery:1,immunities:const{StatusTypeV4.bleeding,StatusTypeV4.poisoned}),
    'enemy_stone_gargoyle'=>CombatUnitV4(id:id,name:'Stone Gargoyle',team:CombatTeamV4.enemy,anchor:a,stats:const UnitStatsV4(maxHp:50,speed:95,move:3,evasion:12,fortitude:13,resolve:11,brace:13,armor:3,magicResist:2),primaryModifier:3,weaponPower:8,mastery:1,immunities:const{StatusTypeV4.poisoned}),
    'boss_bone_heap'=>CombatUnitV4(id:id,name:'Bone Heap',team:CombatTeamV4.enemy,anchor:a,size:UnitSizeV4.large3,controlProfile:ControlProfileV4.boss,stats:const UnitStatsV4(maxHp:180,speed:90,move:2,evasion:10,fortitude:15,resolve:13,brace:16,armor:3,magicResist:2),primaryModifier:3,weaponPower:7,mastery:2,weaknesses:const{DamageTypeV4.fire,DamageTypeV4.holy},resistances:const{DamageTypeV4.frost},immunities:const{StatusTypeV4.bleeding,StatusTypeV4.poisoned}),
    _=>throw ArgumentError('Unknown enemy template: $t')};
  static List<CombatUnitV4> partyFor(List<String> ids)=>[for(final id in ids)switch(id){'wizard'=>wizard(),'kael'=>kael(),'nera'=>nera(),_=>throw ArgumentError('Unknown party fixture: $id')}];
}
