/// ★ 「손패에 무엇이 잡혔나」 표 (WORK_ORDER_DECK_SIM 작업 3).
///
/// 측정 15는 손패를 「그 지역 최고 서클 3장」으로 고정했고, 그 결과
/// **완주율이 손패 위력이 아니라 「유틸이 들어 있느냐」와 상관**했다.
/// 덱에서 뽑게 바꾼 뒤 유틸이 실제로 손에 잡히는지를 여기서 확인한다.
library;

import 'package:surge_wizard/core/constants.dart';
import 'package:surge_wizard/models/spell.dart';

import 'measure_profile.dart';
import 'measure_stage_report.dart';
import 'measure_stage_run.dart';
import 'measure_stats.dart';

/// 한 지역의 시전 집계 (난이도 3개를 합산한 값).
/// 정책 비교표(measure_policy_report.dart)도 같은 셈법을 써야 하므로 공개다.
class CastMix {
  int total = 0;
  int utility = 0;
  int heal = 0;
  int powerSum = 0;

  double get utilityRate => total == 0 ? 0 : utility / total;
  double get healRate => total == 0 ? 0 : heal / total;
  double get avgPower => total == 0 ? 0 : powerSum / total;
}

/// 지역 하나의 시전 집계 — 난이도 3개의 castSpellCounts 를 합친다
CastMix castMixOf(Map<Difficulty, ComboResult> row) {
  final mix = CastMix();
  final byId = {for (final s in row.values.first.deck) s.id: s};
  for (final combo in row.values) {
    combo.tally.castSpellCounts.forEach((id, n) {
      final spell = byId[id];
      if (spell == null) return; // 덱 밖의 주문은 나올 수 없다
      mix.total += n;
      mix.powerSum += spell.baseDamage * n;
      if (isUtilitySpell(spell)) mix.utility += n;
      if (spell.effect?.type == 'heal') mix.heal += n;
    });
  }
  return mix;
}

/// 3-F. 덱 구성과 실제 시전 — 유틸이 손에 잡히는가
List<String> sectionDeck(ComboTable t) {
  final lines = <String>[
    '',
    '── 3-F. ★ 손패에 무엇이 잡혔나 (덱 기반) ─────────',
    '  유틸 = heal · shield · delay_enemy · mana_restore · check_bonus · extra_die',
    '  「시전 유틸%」는 난이도 3개를 합산한 값이다 (본 측정 + 보스만 측정 제외).',
    '  ${pad('지역', 20)}${pad('덱크기', 8)}${pad('유틸장수', 10)}'
        '${pad('덱유틸%', 10)}${pad('시전유틸%', 12)}${pad('회복시전%', 12)}'
        '${pad('평균시전위력', 14)}${pad('시전수', 10)}',
  ];
  for (final id in kRegionIds) {
    final row = t[id]!;
    final combo = row[Difficulty.normal]!;
    final deck = combo.deck;
    final deckUtil = deck.where(isUtilitySpell).length;
    final mix = castMixOf(row);
    lines.add('  ${pad('$id ${combo.region.name}', 20)}'
        '${pad('${deck.length}', 8)}${pad('$deckUtil', 10)}'
        '${pad('${pct(deckUtil / deck.length)}%', 10)}'
        '${pad('${pct(mix.utilityRate)}%', 12)}'
        '${pad('${pct(mix.healRate)}%', 12)}'
        '${pad(fix(mix.avgPower), 14)}${pad('${mix.total}', 10)}');
  }
  return lines;
}

/// 3-F2. 지역별 덱 목록 — 무엇이 들어 있는지 눈으로 확인한다
List<String> sectionDeckList(ComboTable t) {
  final lines = <String>[
    '',
    '── 3-F2. 지역별 덱 (서클 슬롯표대로) ─────────────',
    '  괄호는 위력. ⓤ 는 유틸 효과가 붙은 주문이다.',
  ];
  for (final id in kRegionIds) {
    final combo = t[id]![Difficulty.normal]!;
    lines
      ..add('')
      ..add('  [$id ${combo.region.name}] ${combo.deck.length}장')
      ..add('    ${combo.deck.map(_label).join(' · ')}');
  }
  return lines;
}

String _label(Spell s) =>
    '${s.name}(${s.baseDamage})${isUtilitySpell(s) ? 'ⓤ' : ''}';
