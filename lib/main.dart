import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/loader.dart';
import 'models/meta_state.dart';
import 'screens/meta_controller.dart';
import 'screens/title_screen.dart';
import 'services/save_service.dart';
import 'widgets/pixel_ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 모바일에서 세로 방향 고정 (데스크톱에서는 무시된다)
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const SurgeWizardApp());
}

/// 공통 다크 테마.
/// 기본 글꼴은 한글 픽셀 폰트 Galmuri11 (12px 기준). 픽셀 폰트는 정수 배율에서만
/// 또렷하므로 화면들은 12·24·36·48·84(Galmuri11) 또는 10·20·30(Galmuri9)만 쓴다.
ThemeData _buildTheme() => ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF9C6ADE),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: kBgDeep,
      fontFamily: kFont11,
      useMaterial3: true,
    );

/// 시작 데이터 묶음: 게임 데이터(JSON) + 영구 강화 저장본
class _Boot {
  const _Boot(this.data, this.meta);

  final GameData data;
  final MetaState meta;
}

/// 앱 루트. 데이터를 다 읽으면 MetaController를 **MaterialApp 위에**
/// 공급한다 — Navigator로 이동한 모든 화면에서 보여야 하기 때문.
class SurgeWizardApp extends StatefulWidget {
  const SurgeWizardApp({super.key});

  @override
  State<SurgeWizardApp> createState() => _SurgeWizardAppState();
}

class _SurgeWizardAppState extends State<SurgeWizardApp> {
  late final Future<_Boot> _future = _load();

  Future<_Boot> _load() async {
    final data = await GameDataLoader.loadAll();
    final meta = await SaveService().loadMeta();
    return _Boot(data, meta);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Boot>(
      future: _future,
      builder: (context, snapshot) {
        final boot = snapshot.data;
        if (boot == null) {
          // 로딩 또는 에러 화면
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(),
            home: Scaffold(
              body: Center(
                child: snapshot.hasError
                    ? Text('데이터 로드 실패: ${snapshot.error}')
                    : const CircularProgressIndicator(),
              ),
            ),
          );
        }
        return ChangeNotifierProvider(
          create: (_) => MetaController(boot.meta),
          child: MaterialApp(
            title: '폭주 마법사',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(),
            home: TitleScreen(data: boot.data),
          ),
        );
      },
    );
  }
}
