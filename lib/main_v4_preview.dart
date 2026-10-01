import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/vertical_slice_battle_host_v4.dart';
Future<void> main() async{WidgetsFlutterBinding.ensureInitialized();await SystemChrome.setPreferredOrientations(const[DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight]);runApp(const SurgeWizardV4PreviewApp());}
class SurgeWizardV4PreviewApp extends StatelessWidget{const SurgeWizardV4PreviewApp({super.key});@override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Surge Wizard v4 Vertical Slice',theme:ThemeData(brightness:Brightness.dark,useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFF7B6BD6),brightness:Brightness.dark)),home:const VerticalSliceBattleHostV4());}
