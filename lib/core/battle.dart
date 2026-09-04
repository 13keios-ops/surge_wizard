import 'dart:math';

import '../models/enemy.dart';
import '../models/spell.dart';
import '../models/surge_event.dart';
import 'cast_intensity.dart';
import 'check.dart';
import 'constants.dart';
import 'enemy_turn.dart';
import 'hand_deck.dart';
import 'relic_powers.dart';
import 'spell_effects.dart';
import 'surge.dart';

export 'cast_intensity.dart';

/// 한 전투의 진행 로직 (UI 없음, GAME_DESIGN 4.1절 턴 흐름).
/// 사용 순서: startTurn() → castSpell(...) → enemyTurn() → 반복.
/// isOver 가 true 면 종료 (playerWon 으로 승패 확인).
/// 폭주는 SurgeSystem(surge.dart), 적 턴은 EnemyTurnRunner(enemy_turn.dart) 담당.
class Battle {
  Battle({
    required this.enemy,
    required this.hand,
    required this.surgePool,
    this.deck,
    int? playerHp,
    int? playerMaxHp,
    int? maxMana,
    this.checkModifier = 0,
    this.relics = const RelicPowers(),
    Random? random,
  })  : _random = random ?? Random(),
        playerHp = playerHp ?? kPlayerStartHp,
        playerMaxHp = playerMaxHp ?? playerHp ?? kPlayerStartHp,
        maxMana = maxMana ?? kPlayerStartMaxMana,
        mana = maxMana ?? kPlayerStartMaxMana,
        enemyHp = enemy.hp {
    shield = relics.startShield;
    freeRerollsLeft = relics.freeRerolls;
  }

  final Random _random;
  final Enemy enemy;

  /// 이번 턴의 손패. [deck]이 있으면 턴마다 새로 뽑혀 갈린다.
  List<Spell> hand;

  /// 덱 (GAME_DESIGN 4.2절). null 이면 손패를 고정으로 쓴다 — 기존 동작.
  final List<Spell>? deck;
  final List<SurgeEvent> surgePool;
  final int checkModifier; // 유물 외 고정 판정 보정치 (버프 등)
  final RelicPowers relics; // 보유 유물 효과 합산

  /// 폭주·적 턴 담당 (지연 초기화라 this 참조 가능)
  late final SurgeSystem surge = SurgeSystem(this, _random);
  late final EnemyTurnRunner enemyRunner = EnemyTurnRunner(this);

  /// 덱을 받았을 때만 만들어지는 손패 추첨기
  late final HandDeck? handDeck =
      deck == null ? null : HandDeck(deck!, _random);

  // ── 플레이어 상태 ──
  final int playerMaxHp;
  int playerHp;
  int maxMana;
  int mana;
  int shield = 0;
  int charge = 0; // 마력 축적 게이지
  int freeRerollsLeft = 0; // 유물: 마나 없이 쓰는 리롤 (전투당)
  final Set<String> sealedSpellIds = {}; // 이번 전투 동안 봉인된 주문
  int pendingCheckBonus = 0; // 다음 판정 1회 한정 보너스 (주문 효과)
  bool pendingExtraDie = false; // 다음 굴림에 주사위 +1 (4개 중 상위 3개)

  // ── 적 상태 ──
  int enemyHp;
  int enemyShield = 0;
  int enemyDelayTurns = 0; // 대성공 등으로 적 행동이 밀린 턴 수
  bool enemyActsAgain = false; // 아슬아슬 반동: 적 행동 앞당김

  // ── 통계·기록 (시뮬레이터·디버깅용) ──
  int castCount = 0; // 시전 성공 횟수
  int surgeCount = 0; // 폭주 발생 횟수 (SurgeSystem이 올린다)
  final Map<CheckGrade, int> gradeCounts = {}; // 판정 결과별 (재굴림 포함)
  CheckResult? lastResult; // 마지막으로 적용된 판정 (판정값·족보 표시용)

  /// 실제로 전투에 적용된 등급 (UI·통계가 쓴다).
  /// 현재는 항상 `lastResult.grade`와 같다. 강등·승격 규칙(확정 굴림 등)이
  /// 생기면 여기서 갈린다.
  CheckGrade? lastAppliedGrade;
  final List<String> log = [];
  int turnCount = 0;

  /// 폭주 자해 상한 적용 「전」 합계 누적 (시뮬레이터 측정용).
  /// 상한은 SurgeSystem 안에서 잘리므로 도구 쪽에서는 볼 수 없어 여기 둔다.
  int surgeSelfDamageRaw = 0;

  /// 폭주 자해 상한 적용 「후」, 실제로 들어간 합계 누적 (시뮬레이터 측정용)
  int surgeSelfDamageApplied = 0;

  /// 방어막이 막아 낸 피해 총량 (시뮬레이터 측정용 — 회복 수정 측정)
  int shieldAbsorbed = 0;

  /// 방어막을 뚫고 **실제로 체력을 깎은** 피해 총량 (시뮬레이터 측정용)
  int hpDamageTaken = 0;

  /// 실제로 회복된 체력 총량 — 최대 체력에 막혀 버려진 분은 빼고 센다
  int healedTotal = 0;

  bool get isOver => playerHp <= 0 || enemyHp <= 0;
  bool get playerWon => enemyHp <= 0;

  /// 다음 적 행동 예고 (화면 표시용)
  EnemyAction get telegraph => enemyRunner.telegraph;

  /// 시전 가능한(봉인되지 않은) 손패 인덱스 목록
  List<int> get castableIndexes => [
        for (var i = 0; i < hand.length; i++)
          if (!sealedSpellIds.contains(hand[i].id)) i,
      ];

  /// 턴 시작: 마나 회복 + 덱이 있으면 손패를 새로 뽑는다 (GAME_DESIGN 4.2절)
  void startTurn() {
    turnCount++;
    mana = min(maxMana, mana + kManaRegenPerTurn);
    final d = handDeck;
    if (d != null) hand = d.draw(sealedSpellIds);
  }

  /// 주사위를 굴린다. pendingExtraDie 면 4개 굴려 상위 3개를 쓴다.
  /// 유물 reroll_ones가 있으면 1이 나온 눈을 바꾼다.
  List<int> rollDice() {
    final count = pendingExtraDie ? kDiceCount + 1 : kDiceCount;
    pendingExtraDie = false;
    final rolled = List.generate(count, (_) {
      final face = _random.nextInt(kDiceSides) + 1;
      return face == 1 && relics.rerollOnesTo > 0 ? relics.rerollOnesTo : face;
    })
      ..sort((a, b) => b.compareTo(a));
    return rolled.take(kDiceCount).toList();
  }

  /// 강도 조건부 유물 판정 보정 (전력 전용 보너스)
  int _intensityBonus(CastIntensity it) => switch (it) {
        CastIntensity.full => relics.checkBonusFull,
        CastIntensity.normal => 0,
      };

  /// 주문의 실효 대미지 (유물 damage_up 포함, 보조 주문은 그대로 0)
  int spellPower(Spell spell) =>
      spell.baseDamage > 0 ? spell.baseDamage + relics.damageUp : 0;

  /// 주문 시전 전체 파이프라인. 마나가 모자라면 false.
  /// [dice] 를 주면 그 눈을 쓰고(리롤 후 확정 눈), 없으면 새로 굴린다.
  bool castSpell(int handIndex, CastIntensity intensity, {List<int>? dice}) {
    final spell = hand[handIndex];
    if (sealedSpellIds.contains(spell.id)) return false;
    if (mana < intensity.manaCost) return false;
    mana -= intensity.manaCost;
    castCount++;
    handDeck?.markCast(spell.id); // 이 주문은 다음 턴을 쉰다
    surge.clearLast(); // 이번 시전의 폭주 표시를 위해 초기화

    final result = resolveCheck(
      dice: dice ?? rollDice(),
      dc: intensity.dc + spell.dcModifier,
      modifier: checkModifier +
          pendingCheckBonus +
          relics.checkBonus +
          _intensityBonus(intensity),
      charge: charge,
      pairBonus: kPairBonus + relics.pairBonusUp,
    );
    pendingCheckBonus = 0;
    final gained = result.chargeGained +
        (result.chargeGained > 0 ? relics.chargeGainUp : 0);
    // 강등이 없어졌으므로(v2 3.3절) 확정 대성공은 항상 게이지를 소모한다.
    final consumed = result.chargeConsumed;
    charge = consumed ? 0 : charge + gained;

    applyGrade(spell, intensity, result);
    return true;
  }

  /// 판정 결과를 전투에 반영한다 (GAME_DESIGN 3.2절).
  /// 폭주의 force_reroll(재굴림)에서도 재사용되므로 공개 메서드다.
  void applyGrade(Spell spell, CastIntensity it, CheckResult result) {
    final grade = result.grade;
    lastResult = result;
    lastAppliedGrade = grade;
    gradeCounts.update(grade, (v) => v + 1, ifAbsent: () => 1);
    final base = (spellPower(spell) * it.power);
    switch (grade) {
      case CheckGrade.critSuccess:
        dealToEnemy((base * kCritDamageMultiplier).round());
        mana = min(maxMana, mana + it.critManaRefund);
        addEnemyDelay(kCritEnemyDelay);
        healPlayer(relics.healOnCrit);
        applySpellEffect(spell);
        log.add('대성공! ${spell.name}');
      case CheckGrade.success:
        dealToEnemy(base.round());
        applySpellEffect(spell);
        log.add('성공: ${spell.name}');
      case CheckGrade.graze:
        dealToEnemy((base * kGrazePowerMultiplier).round());
        applySpellEffect(spell);
        applyGrazeBacklash(this, spell, _random);
        log.add('아슬아슬: ${spell.name}');
      case CheckGrade.failure:
        log.add('실패! 폭주 발생');
        surge.applySurge(spell, it);
        mana = min(maxMana, mana + relics.manaOnSurge);
    }
    // 스트레이트: 동시 시전 (실패 시 주문 불발이라 없음 — BLOCKERS 판단 7)
    if (result.extraCastTriggered && result.grade != CheckGrade.failure) {
      _autoCastOther(spell, it);
    }
  }

  /// 적 행동 지연을 누적하되 kMaxEnemyDelayStack 을 넘지 않게 자른다.
  /// 대성공·주문 효과·폭주 등 모든 경로가 이 메서드를 통과해야 한다.
  void addEnemyDelay(int turns) {
    if (turns <= 0) return;
    enemyDelayTurns = min(kMaxEnemyDelayStack, enemyDelayTurns + turns);
  }

  /// 자기 자신과 봉인된 주문을 뺀, 서로 다른 손패 주문 [count]개.
  /// 손패가 모자라면 있는 만큼만 돌려준다.
  /// 스트레이트(동시 시전)와 폭주 연쇄(chain_cast)가 함께 쓴다.
  List<Spell> otherCastableSpells(Spell current, int count) {
    final picked = <Spell>[];
    for (final i in castableIndexes) {
      final other = hand[i];
      if (other.id == current.id) continue;
      if (picked.any((s) => s.id == other.id)) continue;
      picked.add(other);
      if (picked.length >= count) break;
    }
    return picked;
  }

  /// 스트레이트 효과: 손패의 다른 주문 1개가 같은 강도로 공짜 발동한다.
  /// 추가 판정 없이 "성공" 취급 (재귀 방지).
  void _autoCastOther(Spell current, CastIntensity it) {
    for (final other in otherCastableSpells(current, 1)) {
      dealToEnemy((spellPower(other) * it.power).round());
      applySpellEffect(other);
      log.add('스트레이트! ${other.name} 동시 시전');
    }
  }

  /// 주문의 부가 효과 적용 (발동 성공 시). 본체는 spell_effects.dart 에 있다.
  /// 폭주 연쇄(chain_cast)도 같은 규약을 쓰므로 공개 메서드다.
  void applySpellEffect(Spell spell) => applyEffectTo(this, spell);

  /// 적 턴 실행: 소환수 행동 → 적 행동 (상세는 EnemyTurnRunner)
  void enemyTurn() {
    if (isOver) return;
    surge.tickSummons();
    if (isOver) return;
    enemyRunner.run();
  }

  /// 적에게 대미지 (방어막 먼저 깎임)
  void dealToEnemy(int dmg) {
    final absorbed = min(enemyShield, dmg);
    enemyShield -= absorbed;
    enemyHp -= dmg - absorbed;
  }

  /// 플레이어에게 대미지 (방어막 먼저 깎임)
  void dealToPlayer(int dmg) {
    final absorbed = min(shield, dmg);
    shield -= absorbed;
    playerHp -= dmg - absorbed;
    shieldAbsorbed += absorbed;
    hpDamageTaken += dmg - absorbed;
  }

  /// 플레이어 회복 (최대 체력까지)
  void healPlayer(int amount) {
    if (amount <= 0) return;
    final before = playerHp;
    playerHp = min(playerMaxHp, playerHp + amount);
    healedTotal += playerHp - before;
  }
}
