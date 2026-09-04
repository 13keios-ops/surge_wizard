import 'package:flutter/material.dart';

import 'pixel_ui.dart';

/// 선택 화면들의 공통 머리 — 「← 제목 ... Lv.n」 한 줄.
/// 뒤로 가기는 **한 단계씩** 올라간다 (WORK_ORDER_SCREENS 2-D).
///
/// 오른쪽 레벨은 **[level]을 넘긴 화면에서만** 뜬다. 지역·스테이지 선택 화면이
/// 「권장 레벨」을 이미 보여주고 있어, 그 옆에 「내 레벨」이 서야 뜻이 생긴다
/// (WORK_ORDER_LEVEL 3절).
class ScreenHeader extends StatelessWidget {
  const ScreenHeader(
      {super.key, required this.title, this.subtitle, this.level});

  final String title;
  final String? subtitle;

  /// 지금 캐릭터 레벨. null이면 자리를 비운다
  final int? level;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _BackButton(onTap: () => Navigator.of(context).maybePop()),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    height: 1.1,
                    color: kTextMain),
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(subtitle!,
                    style: const TextStyle(
                        fontFamily: kFont9, fontSize: 10, color: kTextDim)),
            ],
          ),
        ),
        if (level != null)
          Text('Lv.$level',
              style: const TextStyle(
                  fontFamily: kFont9,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: kGold)),
      ],
    );
  }
}

/// 왼쪽 위 「←」 단추
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kBgPanel,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: kBorderDim, width: 2),
        ),
        child: const Text('←',
            style: TextStyle(
                fontSize: 20,
                height: 1,
                fontWeight: FontWeight.w900,
                color: kTextMain)),
      ),
    );
  }
}

/// ★ 3개 (보통·하드·데스 클리어 표시).
/// 채워진 별은 ★, 안 깬 것은 ☆ — **둘 다 갈무리 폰트에 있는 글자다.**
class ClearStars extends StatelessWidget {
  const ClearStars({super.key, required this.stars, this.size = 12});

  /// 난이도 3개의 클리어 여부 (보통·하드·데스 순)
  final List<bool> stars;
  final double size;

  /// 난이도가 올라갈수록 별이 뜨거워진다 — 색만 봐도 어디까지 깼는지 읽힌다
  static const _colors = [kGold, kManaBlue, kHpRed];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < stars.length; i++)
          Text(stars[i] ? '★' : '☆',
              style: TextStyle(
                  fontSize: size,
                  height: 1,
                  color: stars[i] ? _colors[i] : kBorderDim)),
      ],
    );
  }
}
