/// 소환수를 화면에 그린다.
///
/// **이게 없어서 맞는 이유가 화면에 안 보였다** — 폭주로 아군이 나와도 아무 일도
/// 안 일어나고, 하드의 호위가 매 턴 때리는데 원인이 화면에 없었다
/// (`reports/36_길옆물체.md` 화면 확인에서 발견).
///
/// 위력이 **양수면 아군**(적을 때린다), **음수면 적대**(나를 때린다) —
/// `lib/core/surge.dart` 의 규약을 그대로 따른다.
library;

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/surge.dart';
import 'pixel_palette.dart';

/// 소환수 한 체의 크기 (dp). 마법사(112)보다 확실히 작아야 딸린 것으로 읽힌다.
const double kSummonSize = 34.0;

/// 소환수끼리 좌우로 어긋나는 간격
const double kSummonGap = 8.0;

/// 소환수 줄이 주인에게서 옆으로 떨어진 거리
const double kSummonSideOffset = 74.0;

/// 남은 턴을 숨기는 문턱. 호위는 사실상 무한이라(999) 숫자를 띄우면 어지럽다.
const int kSummonTurnsHideAbove = kSummonDuration * 3;

/// 전투 무대의 **소환수 겹**. 배경·길 옆 물체 **위**, 몬스터·캐릭터 **아래**에 깐다.
class SummonRow extends StatelessWidget {
  const SummonRow({super.key, required this.summons});

  final List<SummonUnit> summons;

  @override
  Widget build(BuildContext context) {
    if (summons.isEmpty) return const SizedBox.shrink();
    final allies = summons.where((s) => s.power > 0).toList();
    final foes = summons.where((s) => s.power < 0).toList();
    return Stack(
      children: [
        // 아군은 마법사 옆(오른쪽), 적대는 적 옆(왼쪽)에 선다
        if (allies.isNotEmpty) _side(allies, kHeroFoot, toRight: true),
        if (foes.isNotEmpty) _side(foes, kFoeFrontFoot, toRight: false),
      ],
    );
  }

  /// [toRight]면 화면 오른쪽 가장자리에서, 아니면 왼쪽 가장자리에서 띄운다.
  Widget _side(List<SummonUnit> units, double foot, {required bool toRight}) =>
      Positioned(
        bottom: foot - 4,
        left: toRight ? null : kSummonSideOffset,
        right: toRight ? kSummonSideOffset : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final u in units) ...[
              _SummonChip(unit: u),
              const SizedBox(width: kSummonGap),
            ],
          ],
        ),
      );
}

/// 소환수 한 체. 원화가 없어 **단색 실루엣**이다 — 그림이 들어오면 여기만 바뀐다.
class _SummonChip extends StatelessWidget {
  const _SummonChip({required this.unit});

  final SummonUnit unit;

  bool get _hostile => unit.power < 0;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (unit.turnsLeft <= kSummonTurnsHideAbove)
            Text('${unit.turnsLeft}',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.1,
                  color: _hostile ? kHpRed : Colors.white70,
                )),
          Container(
            width: kSummonSize,
            height: kSummonSize,
            decoration: BoxDecoration(
              color: _hostile
                  ? kHpRed.withValues(alpha: 0.85)
                  : const Color(0xFF7FD1E8).withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(color: kBgDeep, width: 2),
            ),
            child: Center(
              child: Text(
                '${unit.power.abs()}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
}
