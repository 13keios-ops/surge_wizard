/// 배경 위에 얹히는 전투 UI — 상단 띠 · 보스 체력바 · 캐릭터 밑 표시.
/// (주문 슬롯 5칸은 `spell_slots.dart` 로 갈라 냈다 — 300줄 규칙)
///
/// v3에서 **어두운 트레이 상자를 없앴다.** 배경이 화면 전체를 덮고 이 조각들이
/// 그 위에 뜬다 (보고서 31 · 4-7절). 그래서 바탕은 전부 반투명이고,
/// 글자에는 그림자를 넣어 밝은 배경 위에서도 읽히게 한다.
library;

import 'package:flutter/material.dart';

import '../core/battle.dart';
import '../core/constants.dart';
import 'pixel_ui.dart';

/// 밝은 배경 위에서도 글자가 읽히게 하는 그림자
const List<Shadow> kOnArtShadow = [
  Shadow(color: Colors.black, blurRadius: 3),
  Shadow(color: Colors.black, offset: Offset(0, 1)),
];

/// 화면 맨 위 — 던전 이름 + 층, 우측에 설정.
/// 배경 위에 뜨므로 바탕은 위에서 아래로 사라지는 그늘만 깐다.
///
/// **일시정지 버튼은 없다** (검토 31 · 2-1절). 일시정지는 독립된 기능이 아니라
/// **설정 화면을 열면 전투가 멈추는 부수 효과**다. 그래서 우상단은 톱니 하나이고,
/// 설정 화면이 생기기 전까지는 **비활성**이다 — 자리(44dp)만 잡아 둔다.
class BattleTopBar extends StatelessWidget {
  const BattleTopBar({
    super.key,
    required this.title,
    this.floor,
    this.floors,
  });

  final String title;
  final int? floor;
  final int? floors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kTopBarHeight,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x8C100E1A), Color(0x00100E1A)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1,
                        color: kTextMain,
                        shadows: kOnArtShadow,
                      ),
                    ),
                    if (floor != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        '$floor층 / ${floors ?? floor}',
                        style: const TextStyle(
                          fontFamily: kFont9,
                          fontSize: 10,
                          height: 1,
                          color: kTextDim,
                          shadows: kOnArtShadow,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 터치 대상 44dp (접근성 하한). 설정 화면이 생기면 onPressed 를 연결한다
              SizedBox(
                width: kTopBarHeight,
                height: kTopBarHeight,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: null,
                  icon: const Icon(Icons.settings, size: 22, color: kTextDim,
                      shadows: kOnArtShadow),
                  tooltip: '설정',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 보스 체력 — 화면 맨 위 가로 전체 한 줄.
/// **보스는 발밑에 체력바를 두지 않는다** (2026-09-08 사용자 지시).
class BossHpBar extends StatelessWidget {
  const BossHpBar({super.key, required this.battle});

  final Battle battle;

  @override
  Widget build(BuildContext context) {
    final enemy = battle.enemy;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: kBossBarHeight,
          child: PixelBar(
            value: battle.enemyHp / enemy.hp,
            color: kHpRed,
            height: kBossBarHeight,
            label: '${battle.enemyHp} / ${enemy.hp}',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '★ ${enemy.name}'
          '${battle.enemyShield > 0 ? '  ◈${battle.enemyShield}' : ''}',
          style: const TextStyle(
            fontFamily: kFont9,
            fontSize: 10,
            color: kGold,
            shadows: kOnArtShadow,
          ),
        ),
      ],
    );
  }
}

/// 캐릭터 발밑에 붙는 체력바 + 이름/레벨 한 줄.
class UnitPlate extends StatelessWidget {
  const UnitPlate({
    super.key,
    required this.width,
    required this.ratio,
    required this.color,
    required this.label,
  });

  final double width;
  final double ratio;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: kUnitPlateHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xE60E0B1A),
              border: Border.all(color: const Color(0xB3000000)),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio.clamp(0.0, 1.0),
              child: ColoredBox(color: color),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: kFont11,
              fontSize: 12,
              height: 1.2,
              color: kTextMain,
              shadows: kOnArtShadow,
            ),
          ),
        ],
      ),
    );
  }
}
