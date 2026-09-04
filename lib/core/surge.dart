import 'dart:math';

import '../models/effect.dart';
import '../models/spell.dart';
import '../models/surge_event.dart';
import 'battle.dart';
import 'check.dart';
import 'constants.dart';
import 'surge_summary.dart';

/// 폭주로 소환된 존재. power 양수 = 아군(적 공격), 음수 = 적대(나를 공격).
class SummonUnit {
  SummonUnit({required this.power, this.turnsLeft = kSummonDuration});

  final int power;
  int turnsLeft;
}

/// 한 번의 폭주를 적용하는 동안 쌓이는 것들.
/// 자해 피해는 효과마다 바로 입히지 않고 여기 모았다가 상한을 걸어 한 번에 입힌다
/// (SURGE_DESIGN 4절 2번).
class SurgeOutcome {
  /// 이번 폭주에서 발생한 자해 피해의 합계 (상한 적용 전)
  int selfDamage = 0;

  /// 화면에 보여줄 결과 조각들 (공백으로 이어 붙인다)
  final List<String> parts = [];
}

/// 폭주 추첨과 효과 적용을 담당한다. Battle이 생성해 들고 쓴다.
/// 효과 값의 의미 규약은 BLOCKERS.md 판단 6, SURGE_DESIGN 4절 참조.
class SurgeSystem {
  SurgeSystem(this._battle, this._random);

  final Battle _battle;
  final Random _random;

  /// 현재 전장에 나와 있는 소환수들
  final List<SummonUnit> summons = [];

  /// 마지막으로 발동한 폭주 (UI 표시용, 시전 시작 시 Battle이 초기화)
  SurgeEvent? lastSurge;

  /// 마지막 폭주의 결과 요약 문자열 (팝업의 「숫자」 칸).
  /// 불발처럼 아무 일도 없었으면 빈 문자열이다.
  String? lastSurgeSummary;

  /// 새 시전이 시작될 때 이전 폭주 표시를 지운다.
  void clearLast() {
    lastSurge = null;
    lastSurgeSummary = null;
  }

  /// 폭주 추첨(가중치) 후 효과 적용
  void applySurge(Spell spell, CastIntensity it) {
    final candidates = _battle.surgePool
        .where((s) => s.matchesTags(spell.surgeTags))
        .toList();
    if (candidates.isEmpty) return;
    final total = candidates.fold(0, (a, s) => a + s.weight);
    var pick = _random.nextInt(total);
    final surge = candidates.firstWhere((s) => (pick -= s.weight) < 0);
    lastSurge = surge;
    _battle.surgeCount++;
    _battle.log.add('폭주: ${surge.name}');

    final out = SurgeOutcome();
    for (final e in surge.effects) {
      _applyEffect(e, spell, it, out);
      final part = summarizeEffect(e);
      if (part != null) out.parts.add(part);
    }
    _applySelfDamage(out);
    lastSurgeSummary = out.parts.join('  ');
  }

  /// 폭주 효과 1개 적용
  void _applyEffect(GameEffect e, Spell spell, CastIntensity it,
      SurgeOutcome out) {
    final b = _battle;
    switch (e.type) {
      case 'self_damage':
        out.selfDamage += e.value;
      case 'self_damage_spell':
        out.selfDamage += _backlashDamage(spell, e.value);
      case 'chain_cast':
        _chainCast(spell, e.value, out);
      case 'heal':
        b.healPlayer(e.value);
      case 'shield':
        b.shield += e.value;
      case 'enemy_heal':
        b.enemyHp = min(b.enemy.hp, b.enemyHp + e.value);
      case 'mana_change':
        b.mana = max(0, min(b.maxMana, b.mana + e.value));
      case 'seal_spell':
        b.sealedSpellIds.add(spell.id);
      case 'swap_hp':
        _swapHp();
      case 'summon_ally':
        summons.add(SummonUnit(power: e.value));
      case 'damage_multiplier':
        b.dealToEnemy((b.spellPower(spell) * it.power * e.value).round());
      case 'skip_enemy_turn':
        b.addEnemyDelay(e.value);
      case 'extra_die':
        b.pendingExtraDie = true;
      case 'force_reroll':
        _forceReroll(spell, it);
    }
  }

  /// 역류 피해량 = max(주문 위력, kBacklashMinPower) × value%.
  /// ⚠ 시전 강도 배율(it.power)을 곱하지 않는다 — SURGE_DESIGN 4절 1번.
  /// 곱하면 전력 시전 실패가 곧 자살이 되어 아무도 전력을 쓰지 않게 된다.
  int _backlashDamage(Spell spell, int percent) {
    final base = max(_battle.spellPower(spell), kBacklashMinPower);
    return (base * percent / kPercentBase).round();
  }

  /// 연쇄: 손패의 다른 주문 |count|개가 추가로 터진다.
  /// 양수면 적에게(부가 효과까지), 음수면 나에게(부가 효과 없음).
  /// 판정을 다시 하지 않으므로 연쇄가 또 폭주를 부르지 않는다.
  void _chainCast(Spell current, int count, SurgeOutcome out) {
    final b = _battle;
    for (final other in b.otherCastableSpells(current, count.abs())) {
      final dmg = b.spellPower(other);
      if (count > 0) {
        b.dealToEnemy(dmg);
        b.applySpellEffect(other);
        b.log.add('연쇄! ${other.name} 발동');
      } else {
        out.selfDamage += dmg;
        b.log.add('연쇄! ${other.name}이(가) 나에게 터졌다');
      }
    }
  }

  /// 자해 피해를 「합산한 뒤」 최대 체력의 40%로 자르고 한 번에 입힌다.
  /// 방어막 흡수는 그다음이다 (SURGE_DESIGN 4절 2번).
  void _applySelfDamage(SurgeOutcome out) {
    if (out.selfDamage <= 0) return;
    final cap = (_battle.playerMaxHp * kSurgeSelfDamageMaxRatio).floor();
    final dmg = min(out.selfDamage, cap);
    // 상한이 얼마나 자주 무는지 재기 위해 자르기 전후를 함께 누적한다.
    _battle.surgeSelfDamageRaw += out.selfDamage;
    _battle.surgeSelfDamageApplied += dmg;
    _battle.dealToPlayer(dmg);
    out.parts.insert(0, '−$dmg');
  }

  /// 체력 교환 (서로 최대치를 넘지 않는다)
  void _swapHp() {
    final b = _battle;
    final tmp = b.playerHp;
    b.playerHp = min(b.playerMaxHp, b.enemyHp);
    b.enemyHp = min(b.enemy.hp, tmp);
  }

  /// force_reroll: 주사위를 다시 굴려 판정을 1회 다시 한다.
  /// 재귀 폭주를 막기 위해 재굴림에서 또 실패해도 폭주는 다시 안 터진다.
  void _forceReroll(Spell spell, CastIntensity it) {
    final b = _battle;
    final result = resolveCheck(
      dice: b.rollDice(),
      dc: it.dc + spell.dcModifier,
      modifier: b.checkModifier,
      charge: 0,
    );
    if (result.grade != CheckGrade.failure) {
      b.applyGrade(spell, it, result);
    } else {
      b.log.add('재굴림도 실패. 이번엔 조용히 넘어간다.');
    }
  }

  /// 소환수 행동: 아군은 적을, 적대 소환은 나를 때린다.
  /// 적 턴이 시작될 때 호출된다 (소환수는 적 페이즈에 행동한다는 규칙).
  void tickSummons() {
    for (final s in summons) {
      if (s.power > 0) {
        _battle.dealToEnemy(s.power);
      } else {
        _battle.dealToPlayer(-s.power);
      }
      s.turnsLeft--;
    }
    summons.removeWhere((s) => s.turnsLeft <= 0);
  }
}
