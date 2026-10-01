import 'dart:math' as math;

import 'combat_board_v4.dart';
import 'combat_state_v4.dart';
import 'hex_coord_v4.dart';
import 'spell_action_v4.dart';

class TargetResolverV4 {
  const TargetResolverV4();

  Set<HexCoord> resolveHexes({
    required SpellActionV4 spell,
    required CombatUnitV4 caster,
    required HexCoord target,
    required CombatBoardV4 board,
  }) {
    if (!board.valid(target)) return {};
    return switch (spell.shape) {
      TargetShapeV4.self => {caster.anchor}, TargetShapeV4.single => {target},
      TargetShapeV4.burst7 => {target,...board.neighbors(target)},
      TargetShapeV4.line => _line(from:caster.anchor,toward:target,length:math.max(1,spell.range),board:board),
      TargetShapeV4.cone => _cone(from:caster.anchor,toward:target,length:math.max(1,spell.range),board:board),
      TargetShapeV4.row => _row(center:target,from:caster.anchor,width:spell.maxTargets??5,board:board),
      TargetShapeV4.chain => {target},
      TargetShapeV4.all => {for(var c=0;c<board.columns;c++) for(var r=0;r<board.rows;r++) HexCoord(c,r)},
    };
  }

  List<CombatUnitV4> resolveUnits({required SpellActionV4 spell,required CombatUnitV4 caster,required HexCoord target,required CombatBoardV4 board,required List<CombatUnitV4> units}) {
    if(spell.shape==TargetShapeV4.chain) return _chainUnits(spell:spell,caster:caster,target:target,board:board,units:units);
    final hexes=resolveHexes(spell:spell,caster:caster,target:target,board:board);
    final result=<CombatUnitV4>[];
    for(final unit in units){
      if(unit.isKo) continue;
      if(!spell.friendlyFire&&spell.category!=SpellCategoryV4.defense&&unit.team==caster.team) continue;
      if(spell.category==SpellCategoryV4.defense&&unit.team!=caster.team) continue;
      if(unit.occupiedHexes.any(hexes.contains)) result.add(unit);
    }
    if(spell.maxTargets!=null&&result.length>spell.maxTargets!){
      result.sort((a,b){final da=caster.anchor.distanceTo(a.anchor),db=caster.anchor.distanceTo(b.anchor);return da!=db?da.compareTo(db):a.id.compareTo(b.id);});
      return result.take(spell.maxTargets!).toList(growable:false);
    }
    return result;
  }

  bool inRange({required CombatUnitV4 caster,required HexCoord target,required SpellActionV4 spell}) => spell.shape==TargetShapeV4.self||spell.shape==TargetShapeV4.all||caster.anchor.distanceTo(target)<=spell.range;

  Set<HexCoord> _line({required HexCoord from,required HexCoord toward,required int length,required CombatBoardV4 board}){
    if(from==toward)return {from}; final d=_bestDirection(from,toward,board); if(d==null)return {};
    final result=<HexCoord>{}; var cur=from; for(var i=0;i<length;i++){final n=_stepDirection(cur,d);if(!board.valid(n))break;result.add(n);cur=n;} return result;
  }
  Set<HexCoord> _cone({required HexCoord from,required HexCoord toward,required int length,required CombatBoardV4 board}){
    final line=_line(from:from,toward:toward,length:length,board:board).toList(); final result=<HexCoord>{};
    for(var i=0;i<line.length;i++){final c=line[i];result.add(c);if(i>=1){for(final n in board.neighbors(c)){if(from.distanceTo(n)==i+1)result.add(n);}}} return result.where(board.valid).toSet();
  }
  Set<HexCoord> _row({required HexCoord center,required HexCoord from,required int width,required CombatBoardV4 board}){
    final result=<HexCoord>{center};final candidates=board.neighbors(center);for(final c in candidates){if(result.length>=width)break;if((from.distanceTo(c)-from.distanceTo(center)).abs()<=1)result.add(c);}for(final c in candidates){if(result.length>=width)break;result.add(c);}return result;
  }
  List<CombatUnitV4> _chainUnits({required SpellActionV4 spell,required CombatUnitV4 caster,required HexCoord target,required CombatBoardV4 board,required List<CombatUnitV4> units}){
    final enemies=units.where((u)=>!u.isKo&&u.team!=caster.team).toList();CombatUnitV4? first;for(final u in enemies){if(u.occupiedHexes.contains(target)){first=u;break;}}if(first==null)return[];final result=<CombatUnitV4>[first];final max=spell.maxTargets??3;while(result.length<max){final last=result.last;final c=enemies.where((u)=>!result.contains(u)).toList()..sort((a,b)=>last.anchor.distanceTo(a.anchor).compareTo(last.anchor.distanceTo(b.anchor)));if(c.isEmpty||last.anchor.distanceTo(c.first.anchor)>2)break;result.add(c.first);}return result;
  }
  int? _bestDirection(HexCoord from,HexCoord toward,CombatBoardV4 board){final ns=board.neighbors(from);if(ns.isEmpty)return null;var bi=0,bd=1<<30;for(var i=0;i<ns.length;i++){final d=ns[i].distanceTo(toward);if(d<bd){bd=d;bi=i;}}return _directionIndex(from,ns[bi]);}
  int _directionIndex(HexCoord from,HexCoord neighbor){final all=from.neighbors();for(var i=0;i<all.length;i++){if(all[i]==neighbor)return i;}return 0;}
  HexCoord _stepDirection(HexCoord from,int direction){final all=from.neighbors();return all[direction.clamp(0,all.length-1).toInt()];}
}
