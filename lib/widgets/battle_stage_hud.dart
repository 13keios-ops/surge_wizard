/// 적 발밑에 붙는 다음 행동 예고 칩.
///
/// v3에서 화면 상단의 `EnemyHeader`(이름 + 체력 + 예고)와 좌측 `NodeTrack`,
/// 우하단 `PlayerStatus` 를 **전부 걷어냈다** — 체력은 캐릭터 발밑(`UnitPlate`)과
/// 보스 전용 상단 바로 옮겼고, 층 정보는 상단 띠가 보여준다 (보고서 31 · 4-8절).
/// 남은 것은 **예고**뿐이다. 예고는 적 AI를 안 만드는 대신 둔 장치라
/// 없애면 안 된다 (GAME_DESIGN 4.4절).
library;

import 'package:flutter/material.dart';

import '../core/battle.dart';
import 'battle_overlay.dart';
import 'pixel_ui.dart';

/// 「⚠ 강타 12」처럼 적이 다음에 무엇을 할지 한 줄로 보여준다
class TelegraphChip extends StatelessWidget {
  const TelegraphChip({super.key, required this.battle});

  final Battle battle;

  @override
  Widget build(BuildContext context) {
    final t = battle.telegraph;
    final showValue = t.action == 'attack' || t.action == 'charge';
    final icon = switch (t.action) {
      'attack' => '⚠',
      'charge' => '◎',
      'defend' => '◈',
      _ => '♥',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: kBgWell.withValues(alpha: 0.82),
        border: Border.all(color: kGold, width: 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        '$icon ${t.label}${showValue ? ' ${t.value}' : ''}'
        '${battle.enemyDelayTurns > 0 ? ' (지연)' : ''}'
        '${battle.enemyShield > 0 ? '  ◈${battle.enemyShield}' : ''}',
        style: const TextStyle(
          fontFamily: kFont11,
          fontSize: 12,
          height: 1.2,
          fontWeight: FontWeight.bold,
          color: kGold,
          shadows: kOnArtShadow,
        ),
      ),
    );
  }
}
