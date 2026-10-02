# Surge Wizard v4 — 묶음 D / 전체 통합 검수 v6.3

**범위:** C4~C7 · T3~T5 장비 · 11 Hub · 14 Region Event · D01~D09 Tactical Map · 5 Companion Quest · XP/Gold/Essence · Flag · New Game→Ending  
**목표:** “각 문서가 따로 맞는 것”이 아니라 **전체 캠페인이 연결됐을 때 모순 없이 작동하는가**를 확인한다.

---

# 1. 최종 설계 범위 상태

| 영역 | 현재 상태 |
|---|---|
| 전투 공식/Timeline/Hex/Status | 기존 v3.x 기준 유지 |
| ACT I | reconciled v4.0 기준 |
| ACT II Mine/Swamp/Ruin | reconciled v4.0 + v4.9 detail |
| ACT III | v6.0에서 완성 |
| ACT IV | v6.1에서 완성 |
| ACT V / Ending | v6.2에서 완성 |
| C0~C3 | v3.8 |
| C4~C6 | 기존 v2.4 상세 Catalog |
| C7 | v6.2 3종(Branch 2 + Optional 1) |
| Equipment T0~T2 | v3.8 |
| Equipment T3~T5 | v6.3 curated roster 40종 |
| Companion Quest | 기존 v1.7 + v6.1/v6.3 integration |
| 11 Hub | 기존 v4.4 + v6.3 late stock |
| 14 Region Event | v6.3 실제 Event 98개 |
| Tactical Map | D01~D09 + S01/S02 총 38개 |
| Endings | A/B 2개 |
| Easter Egg | 5개 / Ending과 독립 |

---

# 2. Spell progression 최종 연결

기존 57개 C0~C6는 다시 설계하지 않는다.

```text
C0~C3 = 30
C4~C6 = 27
C7     = 3 definitions
```

Base campaign 일반 플레이:
```text
실제 보유 C7 = 1~2
```

Gate:

```text
C4 — ACT III Arken report + Lv9
C5 — D05 + Lv13
C6 — D07 + resonance identified + Lv17
C7 — ACT V 3 Anchor + M06 Branch
```

Optional C7:
- Inferno Dragon + Anchor records
- Essence 120
- Ending 필수 아님

Mastery로 Area를 키우지 않는 규칙 유지.

---

# 3. T3~T5 장비

추가 late gear: **40종**.

철학:
- Random affix 없음.
- 내구도 없음.
- 같은 Tier 안에서 공격/안정/기동/방어 sidegrade.
- 주요 Build item은 고정 Hub/Quest/Boss source.
- Relic은 기본 Shop rotation에 넣지 않음.

가격은 기존 base price를 유지한다.

```text
T3 Head 520 / Shoes 560 / Body 760 / Weapon 980
T4 1100 / 1200 / 1600 / 2100
T5 2200 / 2400 / 3200 / 4200
```

v3.8 rarity enum:
```text
COMMON / FINE / RARE / RELIC
```
을 사용한다.

---

# 4. 11 Hub late-game stock

- T06 Arken: Caster/Priest T3 → selected T4 → ACT V T5/최고급 소비품.
- T07 Freehold: Control/Crystal/optional C7 연구.
- T08 Redgate: Heavy/Rogue/전투 소비품.
- T09 Sunmarket: Ranger/희귀 촉매/동부 Anchor.
- T10 Frosthold: T4 Frost/North gear.
- T11 Saint's Reach: T4 defensive/support → ACT V T5/Final Prep.

초기 5개 Hub의 정체성을 후반에도 유지하며 모든 도시가 같은 종합마트가 되지 않는다.

---

# 5. 14 Region actual Event Pool

총 **98개**.

각 Region 정확히:
```text
Combat 2
Discovery 2
Resource 2
Rare 1
= 7
```

Random Event는:
- Main Key
- 필수 NPC
- ACT progression
을 주지 않는다.

R14 Rare는 Final Route 중 disabled.

최근 8개 같은 Event ID 금지, 최근 4개 같은 family ×0.5 기존 규칙을 유지한다.

---

# 6. Tactical Map

총 **38개** layout.

포함:
```text
D01~D09
S01 Headless Knight
S02 Inferno Dragon
```

각 map:
- board columns/rows.
- 3인 party spawn.
- enemy spawn slot.
- terrain coordinate.
- boss anchor.
- special mechanic.
를 가진다.

42° Orthographic 카메라 기준과 충돌하지 않는다.

Boss map은 중앙 이동공간을 비우고 Cover를 외곽으로 보내 Huge footprint가 막히지 않게 구성한다.

---

# 7. Companion Personal Quest 전역 검수

5개 모두:
- Main Gate 아님.
- Owner가 Bench면 Party Prompt.
- Temporary Leave → PAUSED.
- Permanent Leave → CLOSED_BY_DEPARTURE.
- 완료 Trait은 해당 동료 전용.
- Ending A/B 잠금 없음.
- ACT V에서 작은 but meaningful option을 제공.

ACT V Bonus가 “전투 통째 제거” 수준이 되지 않도록 제한했다.

---

# 8. XP Cross-check

Curve:

```text
Lv4  = 390
Lv9  = 1,640
Lv15 = 4,130
Lv20 = 7,030
Lv25 = 10,680
```

## ACT I

reconciled:
```text
Combat 355
Noncombat 35
= 390 → Lv4
```

## ACT II

두 Arc로 ACT III에 갈 수 있으므로 공통 XP를 명시한다.

```text
ACT II start          390
Common early          120
Arc 1                 430
Arc 2                 430
Invitation synthesis  270
-------------------------
Total                1,640 → Lv9
```

세 번째 Arc:
```text
+430
→ Lv9 후반~Lv10
```

따라서 “두 Arc 후 ACT III인데 Lv9 gate를 못 넘는 문제”를 제거한다.

이 270은 단순 초청 대화 한 줄 XP가 아니라:
- 세 이상현상 비교보고
- 왕도 이동/연결 Quest 완료
- 공식 조사 의뢰 인계
를 합친 **cross-act resolution reward**다.

## ACT III

```text
Start reference 1,640
Mandatory combat 1795
Story            500
End              3935
```

Lv15 threshold 4,130보다 약간 아래.
Optional encounter/POI/PQ 하나만 해도 Lv15에 도달.

## ACT IV

```text
Lv15 start      4,130
Mandatory       2030
Story             840
End              7000
```

Lv20 7,030에 30 XP 부족.
정상 플레이의 Discovery/PQ 1개로 넘는다.

Main-only player에게도 ACT V 진입 시 **30 XP transition award**를 허용해 grind를 막는다.
이 award는 Lv20 미만일 때만 적용하며 XP threshold까지만 채운다.

## ACT V

```text
Lv20 7,030
Combat 2,965
Story    685
= 10,680 → Lv25
```

Final Boss 전에 Lv25가 필요한 경우 D09 final-prep story award의 시점을 앞당기되 총합은 바꾸지 않는다.

---

# 9. Economy Cross-check

기존 Economy Reference 목표를 변경하지 않는다.

| ACT | Main Gold | Typical Gold | Main Essence | Typical Essence |
|---|---:|---:|---:|---:|
| I | 599 | 730 | 46 | 52 |
| II | 2,005 | 2,570 | 122 | 145 |
| III | 4,184 | 5,230 | 189 | 225 |
| IV | 7,495 | 9,140 | 310 | 360 |
| V | 12,886 | 15,160 | 458 | 520 |

Typical spending:
```text
I   440
II  1,650
III 3,550
IV  6,300
V   10,100
```

검수 결과:
- Main Gold가 해당 ACT typical spend보다 항상 많음.
- 하지만 여러 캐릭터 장비를 모두 최상 Tier로 즉시 교체할 만큼 넉넉하지는 않음.
- 첫 C7 무료이므로 Ending 직전 Essence 강제저축이 필요 없음.
- optional C7 120은 ACT V Typical Essence 520 범위에서 의미 있는 선택.
- 모든 C6를 Lv5까지 만드는 것은 여전히 불가능.

---

# 10. Choice / Flag exclusivity

Exactly-one group:

```text
M01 2
M02 2
M03 3
M04 3
M05 3
M06 2
M07 3
C01 2
```

Anchor:
```text
west=true
central=true
east=true
```
가 전부 필요하지만 **해결 방식 Flag를 하나의 정답으로 요구하지 않는다.**

Easter Flag는 Ending Resolver 입력에서 제외.

---

# 11. 모든 과거 Choice 조합의 진행성

M01~M07 조합 수:

```text
2 × 2 × 3 × 3 × 3 × 2 × 3 = 648
```

모든 조합에서:
- West Anchor fallback.
- Central Anchor fallback.
- East Anchor fallback.
- D09 접근.
- Ending A/B 둘 다.
가 존재해야 한다.

동료 개인퀘스트 완료/미완료 32조합까지 포함해도 Main Gate는 달라지지 않는다.

---

# 12. New Game → Ending state walkthrough

총 {len(trace)}개 핵심 Commit checkpoint를 구조화 데이터로 작성했다.

핵심 Crash boundary:

```text
Recruit
Major Choice Commit
Spell Learn/Mastery
Equipment Purchase
Consumable Use
Encounter Victory
Anchor Resolution
Story C7 Grant
Final Boss
Ending Commit
```

Presentation 화면은 durable state의 source of truth가 아니다.

---

# 13. Boss HP-sponging 검수

기존 보스:
- Elder Slime — 단계 변화.
- Iron Troll — Plate Break.
- Bog Toad — 이동/독/재생 없음.
- Bone Heap — Reassemble/Fractured Core.
- Burning Treant — Branch channel/Core exposed.
- Sun Sphinx — Reflector/MR down.
- White Wolf — summon stop/EVA down.
- Archlich — Focus 제거.
- Awakened Idol — Arm→Core.
- Void Titan — Arm→Core.
- Headless Knight — Phantom Mount + Armor down.
- Inferno Dragon — Wing stagger/Grounded.

Final human leader:
- Pylon 제거 → MR/Barrier down.

**단순 HP 증가만으로 Phase를 만든 보스 없음.**

---

# 14. 남은 의도적 미확정

완전히 끝내지 않은 것은 콘텐츠가 아니라 **구현/실측 단계**다.

```text
Flutter compile/analyze
Flutter unit/widget tests
Dart headless 5,000-run regeneration
실기기 터치/가독성
각 Tactical Map 실제 화면 Proof
각 Encounter 최종 수치 balance
전체 Dialogue 최종 문장 polishing/localization
ACT III~V NPC Portrait/Art production
```

또한:
- C7 기원 서사의 더 깊은 미스터리
- 주인공 공명체질의 “왜 태어났는가”
는 본편에서 일부 남겨두는 것이 기존 Story Bible 방향이다.

---

# 15. 설계 완료 판단

이 시점부터 **본편의 주요 시스템/퀘스트/진행/성장/결말을 새로 설계할 필요는 없다.**

다음 단계는:

```text
1. 실제 Flutter/Dart 환경 검증
2. v5 WP00~WP12 구현
3. ACT I부터 데이터 이식
4. 실제 플레이테스트
5. 수치 조정
```

으로 넘어가는 것이 맞다.

새로운 광범위 설계가 필요한 경우는 구현 중 명백한 모순이 발견됐을 때뿐이다.