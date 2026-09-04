import 'package:flutter/material.dart';

import '../art/pixel_sprite.dart';
import '../art/sprites_items.dart';
import '../models/surge_event.dart';
import 'pixel_ui.dart';

/// 폭주 발생 팝업.
/// 읽히는 순서는 SURGE_DESIGN 1절이 정한 대로 **갈래 → 숫자 → 한 줄 → 사건 이름**이다.
/// 유저가 알아야 할 것은 "이번 시전이 어떻게 됐나" 하나이므로 갈래가 가장 크다.
class SurgePopup extends StatelessWidget {
  const SurgePopup({super.key, required this.surge, this.summary});

  final SurgeEvent surge;

  /// 실제로 무슨 일이 일어났는지 (SurgeSystem.lastSurgeSummary).
  /// 불발이면 빈 문자열이고, 그때는 숫자 칸을 비운다.
  final String? summary;

  /// 6갈래 → 화면에 쓰는 한글 이름
  static const Map<String, String> _categoryNames = {
    'backlash': '역류',
    'misfire': '오발',
    'fizzle': '불발',
    'amplify': '증폭',
    'summon': '소환',
    'chain': '연쇄',
  };

  /// 6갈래 → 색. 불발이 무채색인 것이 중요하다.
  static const Map<String, Color> _categoryColors = {
    'backlash': kHpRed,
    'misfire': kSurgePurple,
    'fizzle': kSurgeGray,
    'amplify': kGold,
    'summon': kHpGreen,
    'chain': kManaBlue,
  };

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[surge.category] ?? kCharge;
    final label = _categoryNames[surge.category] ?? '폭주';
    final number = summary ?? '';
    return Dialog(
      backgroundColor: Colors.transparent,
      child: PixelPanel(
        color: kBgPanel,
        borderColor: color,
        glow: color,
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PixelSpriteView(kIconSkull, size: 32, tint: color),
            const SizedBox(height: 8),
            // 갈래 — 이것만 봐도 무슨 일이 났는지 안다
            Text(
              '$label!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFont9,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            // 숫자 — 불발은 비는 것이 정상이다
            if (number.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: kFont9,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kTextMain,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              surge.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, height: 1.5, color: kTextMain),
            ),
            const SizedBox(height: 4),
            Text(
              surge.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: kFont9, fontSize: 10, color: kTextDim),
            ),
            const SizedBox(height: 14),
            PixelButton(
              label: '이런...',
              height: 40,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
