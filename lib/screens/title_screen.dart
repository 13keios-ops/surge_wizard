import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../art/pixel_sprite.dart';
import '../art/sprites_characters.dart';
import '../art/sprites_items.dart';
import '../data/parser.dart';
import '../widgets/pixel_ui.dart';
import 'region_select_screen.dart';
import 'meta_controller.dart';
import 'meta_screen.dart';

/// 타이틀 화면: 모험 시작 + 영구 강화 진입.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.data});

  final GameData data;

  @override
  Widget build(BuildContext context) {
    final crystals = context.watch<MetaController>().crystals;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBgPanel, kBgDeep],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PixelSpriteView(kSpriteWizard,
                    size: 128, tint: kWizardTint),
                const SizedBox(height: 16),
                const Text(
                  '폭주 마법사',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: kTextMain,
                    shadows: [
                      Shadow(color: kCharge, blurRadius: 16),
                      Shadow(color: Colors.black, blurRadius: 3),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '주사위 3개, 주문 하나, 사고는 덤',
                  style: TextStyle(fontSize: 12, color: kTextDim),
                ),
                const SizedBox(height: 44),
                SizedBox(
                  width: 230,
                  child: PixelButton(
                    label: '모험 시작',
                    height: 54,
                    fontSize: 24,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RegionSelectScreen(data: data),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 230,
                  child: PixelButton(
                    label: '영구 강화   $crystals',
                    height: 48,
                    fontSize: 20,
                    color: kBgPanel,
                    icon: const PixelSpriteView(kIconGem,
                        size: 20, tint: kCharge),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MetaScreen(data: data),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '지역 12곳 · 스테이지 100개 · 난이도 3단계',
                  style: TextStyle(
                      fontFamily: kFont9, fontSize: 10, color: kTextDim),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
