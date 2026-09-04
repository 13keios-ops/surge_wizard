import '../models/effect.dart';

/// 폭주 결과를 팝업의 「숫자」 칸에 쓸 짧은 문자열로 옮긴다
/// (SURGE_DESIGN 1절: 갈래 → 숫자 → 한 줄).
///
/// 자해 계열(`self_damage`·`self_damage_spell`·음수 `chain_cast`)은 여기서
/// 다루지 않는다. 상한을 걸어 합산한 뒤 SurgeSystem이 「−N」 하나로 앞에 붙인다.
/// 보여줄 것이 없으면 null (불발은 그래서 빈 문자열이 된다).
String? summarizeEffect(GameEffect e) {
  final v = e.value;
  final signed = v >= 0 ? '+$v' : '−${-v}';
  return switch (e.type) {
    'heal' when v > 0 => '회복 +$v',
    'shield' when v > 0 => '방어막 $v',
    'enemy_heal' when v > 0 => '적 +$v',
    'mana_change' when v != 0 => '마나 $signed',
    'damage_multiplier' => '×$v',
    'chain_cast' when v != 0 => '연쇄 ${v.abs()}',
    'summon_ally' when v > 0 => '소환 $v',
    'summon_ally' when v < 0 => '적대 소환 ${-v}',
    'seal_spell' => '봉인',
    'swap_hp' => '체력 교환',
    'skip_enemy_turn' when v > 0 => '적 지연 $v',
    'extra_die' => '주사위 +1',
    'force_reroll' => '재굴림',
    _ => null,
  };
}
