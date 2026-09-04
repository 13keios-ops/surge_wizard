/// 파일럿 시트 만들기 (테스트가 아니다 — 보고서용 그림을 만든다).
///
///   flutter test test_shots/pilot_wizard_test.dart
///
/// 결과: `reports/img/04_pilot_wizard.png` (가로 480px 한 장)
///
/// 3안(A 기준선 / B 혼합 / C 전면 손도트)을 3열로 늘어놓는다:
///   ① 실제 게임 크기  ② 4배 확대  ③ 전투 배경 위
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surge_wizard/art/pilot_wizard.dart';
import 'package:surge_wizard/art/pixel_sprite.dart';
import 'package:surge_wizard/art/stage_backdrop.dart';
import 'package:surge_wizard/widgets/pixel_ui.dart';

import 'shot_support.dart';

// ── 시트 치수 ──
const _colGame = 126.0; // ① 실제 게임 크기
const _colZoom = 196.0; // ② 4배 확대 (48 × 4 = 192)
const _colStage = 152.0; // ③ 전투 배경 위
const _gap = 3.0;
const _rowH = 200.0;
const _headH = 20.0;
const _labelH = 17.0;

const _sheetW = _colGame + _colZoom + _colStage + _gap * 2; // = 480
const _sheetH = _headH + (_labelH + _rowH) * 3;

/// 전투 화면에서 마법사가 실제로 그려지는 크기.
/// `battle_stage.dart`: `(무대높이 * 0.50).clamp(64, 142)` → 360×700 기기에서 120 언저리.
const _gameSize = 120.0;

class _Option {
  const _Option(this.title, this.note, this.sprite, {this.extra});

  final String title;
  final String note;
  final PixelSprite sprite;
  final Map<String, Color>? extra;
}

const _stageBg = Color(0xFF1B1838);

void main() {
  setUpAll(loadShotFonts);

  testWidgets('마법사 파일럿 3안 시트', (tester) async {
    const size = Size(_sheetW, _sheetH);
    prepareShot(tester, size);

    final options = <_Option>[
      _Option('A  기준선', '지금 방식 — 도형 + 자동 명암만', kPilotWizardA),
      _Option('B  혼합', '자동 명암으로 부피 + 특징을 손으로 덧찍기', kPilotWizardB),
      _Option('C  전면 손도트', '한 칸씩 직접 + 색 26가지 + 제한적 안티앨리어싱',
          kPilotWizardC,
          extra: kPilotExtraPalette),
    ];

    await tester.pumpWidget(shotHost(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: kFont11,
          scaffoldBackgroundColor: kBgDeep,
          useMaterial3: true,
        ),
        home: Scaffold(
          backgroundColor: kBgDeep,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: _headH, child: _Header()),
              for (final o in options) ...[
                SizedBox(height: _labelH, child: _RowLabel(option: o)),
                SizedBox(height: _rowH, child: _OptionRow(option: o)),
              ],
            ],
          ),
        ),
      ),
      size,
    ));
    await tester.pump(const Duration(milliseconds: 100));
    await shoot(tester, 'reports/img', '04_pilot_wizard');

    // 실루엣을 흑백으로 확인하려면 도트 자료가 필요하다 (2-C 규칙).
    // 시트에는 넣지 않고 파일로만 남긴다.
    final dump = StringBuffer();
    for (final o in options) {
      dump.writeln('# ${o.title}');
      for (final row in o.sprite.rows) {
        dump.writeln(row);
      }
    }
    Directory('reports/img/_shots').createSync(recursive: true);
    File('reports/img/_shots/pilot_rows.txt').writeAsStringSync('$dump');
  });
}

/// 열 제목 줄
class _Header extends StatelessWidget {
  const _Header();

  static const _style = TextStyle(
      fontFamily: kFont9, fontSize: 10, height: 1.4, color: kTextDim);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        SizedBox(
            width: _colGame,
            child: Center(child: Text('① 실제 게임 크기', style: _style))),
        SizedBox(width: _gap),
        SizedBox(
            width: _colZoom,
            child: Center(child: Text('② 4배 확대', style: _style))),
        SizedBox(width: _gap),
        SizedBox(
            width: _colStage,
            child: Center(child: Text('③ 전투 배경 위', style: _style))),
      ],
    );
  }
}

/// 안 이름 + 방식 한 줄
class _RowLabel extends StatelessWidget {
  const _RowLabel({required this.option});

  final _Option option;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBgPanel,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(option.title,
              style: const TextStyle(
                  fontFamily: kFont9,
                  fontSize: 10,
                  height: 1.4,
                  fontWeight: FontWeight.w900,
                  color: kGold)),
          const SizedBox(width: 8),
          Text(option.note,
              style: const TextStyle(
                  fontFamily: kFont9,
                  fontSize: 10,
                  height: 1.4,
                  color: kTextDim)),
        ],
      ),
    );
  }
}

/// 한 안의 3열
class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.option});

  final _Option option;

  PixelSpriteView _sprite(double size, {bool halo = false}) => PixelSpriteView(
        option.sprite,
        size: size,
        tint: kWizardTint,
        extraPalette: option.extra,
        halo: halo ? kSpriteHalo : null,
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ① 실제 게임 크기
        Container(
          width: _colGame,
          color: _stageBg,
          child: Center(child: _sprite(_gameSize)),
        ),
        const SizedBox(width: _gap),
        // ② 4배 확대 — 도트 품질을 여기서 판단한다
        Container(
          width: _colZoom,
          color: _stageBg,
          child: Center(child: _sprite(192)),
        ),
        const SizedBox(width: _gap),
        // ③ 전투 배경 위 — 복잡한 배경에서 실루엣이 뜨는지
        SizedBox(
          width: _colStage,
          child: ClipRect(
            child: Stack(
              children: [
                const Positioned.fill(
                  child: StageBackdrop(
                      palette: BackdropPalette.frost, time: 0.3),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 4,
                  child: Center(child: _sprite(_gameSize, halo: true)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
