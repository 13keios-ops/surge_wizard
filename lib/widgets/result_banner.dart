import 'package:flutter/material.dart';

import '../core/check.dart';
import '../core/combo.dart';
import 'pixel_ui.dart';

/// 판정 결과 배너: 등급·판정값·족보를 크게 보여준다.
/// [grade]는 실제로 전투에 적용된 등급이다.
class ResultBanner extends StatelessWidget {
  const ResultBanner({super.key, required this.result, required this.grade});

  final CheckResult result;
  final CheckGrade grade;

  static const Map<CheckGrade, (String, Color)> _gradeStyle = {
    CheckGrade.critSuccess: ('대성공!', kGold),
    CheckGrade.success: ('성공', kHpGreen),
    CheckGrade.graze: ('아슬아슬', kManaBlue),
    CheckGrade.failure: ('폭주!', kCharge),
  };

  static const Map<ComboType, String> _comboLabel = {
    ComboType.triple: '트리플',
    ComboType.straight: '스트레이트',
    ComboType.snakeEyes: '뱀눈',
    ComboType.pair: '페어 +3',
  };

  @override
  Widget build(BuildContext context) {
    final (label, color) = _gradeStyle[grade]!;
    final combo = _comboLabel[result.combo];
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: color,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.6), blurRadius: 12),
                const Shadow(color: Colors.black, blurRadius: 2),
              ],
            ),
          ),
          Text(
            '판정값 ${result.finalValue}${combo != null ? '   ·   $combo' : ''}',
            style: const TextStyle(fontSize: 12, color: kTextDim),
          ),
        ],
      ),
    );
  }
}
