import 'package:flutter/material.dart';

import '../models/battle_v4_models.dart';

class TargetPreviewV4 extends StatelessWidget {
  const TargetPreviewV4({
    super.key,
    required this.preview,
    this.onCommit,
  });

  final V4TargetPreview preview;
  final VoidCallback? onCommit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xE814151C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x665A5F70)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: DefaultTextStyle(
          style: const TextStyle(fontSize: 11, color: Color(0xFFDAD7E1)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,children:[Text(preview.title,style:const TextStyle(fontSize:13,fontWeight:FontWeight.bold,color:Colors.white)),const SizedBox(height:6),for(final line in preview.lines)Padding(padding:const EdgeInsets.only(bottom:2),child:Text(line,maxLines:1)),const Spacer(),Align(alignment:Alignment.centerRight,child:SizedBox(height:32,child:FilledButton(onPressed:onCommit,child:const Text('실행'))))]),
        ),
      ),
    );
  }
}
class AutoSpeedControlsV4 extends StatelessWidget{const AutoSpeedControlsV4({super.key,required this.auto,required this.speed,required this.onAuto,required this.onSpeed});final bool auto;final int speed;final VoidCallback onAuto;final ValueChanged<int> onSpeed;@override Widget build(BuildContext context)=>Row(mainAxisAlignment:MainAxisAlignment.end,children:[_button('AUTO',auto,onAuto),for(final v in const[1,2,3])_button('${v}×',speed==v,()=>onSpeed(v))]);Widget _button(String label,bool selected,VoidCallback onTap)=>SizedBox(width:44,height:44,child:Padding(padding:const EdgeInsets.all(2),child:Material(color:selected?const Color(0xFF6750A4):const Color(0xC91B1D25),borderRadius:BorderRadius.circular(20),child:InkWell(borderRadius:BorderRadius.circular(20),onTap:onTap,child:Center(child:Text(label,style:const TextStyle(fontSize:10,fontWeight:FontWeight.bold)))))));}
class BossBarV4 extends StatelessWidget{const BossBarV4({super.key,required this.boss});final V4BattleUnit boss;@override Widget build(BuildContext context)=>Column(children:[ClipRRect(borderRadius:BorderRadius.circular(6),child:LinearProgressIndicator(minHeight:9,value:boss.hpRatio.clamp(0.0,1.0).toDouble(),backgroundColor:const Color(0xFF242630),valueColor:const AlwaysStoppedAnimation(Color(0xFFD45E61)))),const SizedBox(height:2),Text(boss.name,style:const TextStyle(fontSize:10,fontWeight:FontWeight.bold,color:Color(0xFFF2D889)))]);}
