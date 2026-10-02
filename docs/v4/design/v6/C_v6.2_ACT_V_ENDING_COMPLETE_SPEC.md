# Surge Wizard v4 — 묶음 C / ACT V + 최종던전 + Ending v6.2

**범위:** 3 Anchor · 과거 선택 회수 · C7 · D09 · 해방파 수장 · Void Titan · Ending A/B · Epilogue  
**원칙:** 중간 선택은 결말을 자동 결정하지 않는다. 마지막 선택은 플레이어가 직접 한다.

---

# 1. ACT V 구조

```text
대륙 동시 위기
→ West / Central / East Anchor 세 곳을 자유순서 해결
→ T06 또는 T11 최종 준비
→ 첫 Circle 7 무료 획득
→ R14 마력맥 왕관
→ D09
→ 해방파 수장
→ Void Titan
→ C01 최종 마력맥 선택
→ Ending A 또는 B
→ World-state Epilogue
```

세 Anchor의 순서는 자유다.

Enemy level은 전면 동기화하지 않는다. 권장 Lv21~23 범위에서 authored 상태를 유지한다.

---

# 2. 이전 선택이 실제로 돌아오는 방식

## West — Ironvale / R03

읽는 Flag:
```text
M01 광산 봉쇄/안정화
Kael Personal Quest
```

봉쇄:
- 지하 유지보수길은 없음.
- 대피가 단순해 표면 민간인 위험이 낮음.

안정화:
- 유지보수 지하길이 살아 있어 Anchor 접근이 짧아짐.
- 대신 내부 전투/Hazard를 직접 통과.

Kael PQ 완료:
- 민간인 방어선 지원.
- 증원 1개가 늦어짐.

어느 과거 선택도 Anchor 자체를 실패시키지 않는다.

## Central — Arken

읽는 Flag:
```text
M03 고대기록
M04 연구자
M07 성맥 진실
Nera/Seon PQ
```

여기서 가장 많은 과거 정보가 합쳐진다.

- 기록을 마도원에 넘겼으면 공식 열쇠.
- 공유했으면 Freehold 사본.
- 재봉인했으면 물리 봉인경로.
- 연구자 협력 시 실시간 보정코드.
- Nera Trait이면 봉인장치 1개 사전해제.
- Seon Trait이면 Ley hazard 1개 사전 억제.

모든 조합에 기본 Fallback이 존재한다.

## East — Redgate / Sunscar

읽는 Flag:
```text
Luka/Erin PQ
D06 기록
일부 M04 후속
북부 수송상태
```

Erin:
첫 Hazard 예고 + 유리한 시작배치.

Luka:
적 Reinforcement Timeline +25.

---

# 3. ACT II M02의 후반 회수

Swamp 선택도 잊히지 않는다.

정화:
```text
T04 약초 공급 유지
Final Prep에서 Greater Cleanse 재료 지원
```

소각:
```text
질병/독 확산은 낮음
약초 공급 감소
Final Prep 무료 정화 보급이 적음
```

둘 다 메인 전투력 격차는 작은 범위로 제한한다.

---

# 4. 세 Anchor Encounter

| ID | Anchor | Lv | XP | Gold | Essence | 역할 |
|---|---|---:|---:|---:|---:|---|
| `A5_W_E01_IRONVALE_EVAC` | WEST | 21 | 140 | 520 | 16 | M01 결과 회수 / 민간인·광산 접근 |
| `A5_W_E02_DEEP_FAULT` | WEST | 21 | 150 | 560 | 18 | 광산 구조 선택의 실제 지형 차이 |
| `A5_W_E03_ANCHOR_CORE` | WEST | 22 | 180 | 700 | 26 | 서부 Anchor 안정화/차단 |
| `A5_C_E01_ARKEN_UNDERWAY` | CENTRAL | 21 | 145 | 540 | 17 | M03/M04/M07 정보상태 회수 |
| `A5_C_E02_ARCHIVE_LOCK` | CENTRAL | 22 | 155 | 590 | 19 | Nera/Seon 우회 Option |
| `A5_C_E03_ANCHOR_CHAMBER` | CENTRAL | 22 | 185 | 720 | 27 | 중앙 Anchor / 공공질서 상태 반영 |
| `A5_E_E01_REDGATE_LINE` | EAST | 22 | 150 | 570 | 18 | Luka 방어선 / Erin 사전경고 |
| `A5_E_E02_SUNSCAR_RELAY` | EAST | 23 | 160 | 620 | 20 | D06 기록 기반 장치 역산 |
| `A5_E_E03_ANCHOR_MIRROR` | EAST | 23 | 190 | 760 | 28 | 동부 Anchor / 반사경+장치 |

세 Anchor mandatory combat XP: **1455**

세 곳 완료:
```text
anchor_west_resolved
anchor_central_resolved
anchor_east_resolved
```
모두 true → Final Prep.

---

# 5. 첫 Circle 7

C7은 일반 성장표의 단순 다음 단계가 아니다.

기본편:
```text
첫 C7 = Story Free
선택 C7 = 최대 1개 추가
C7 Mastery 2~5 없음
```

## 공명 폭주 / Resonance Overdrive

M06 흡수 계열.

```text
C7 Attack
MP 52
Delay 185
Burst7
Power 42 Arcane
Very Hard
```

Huge Core/Channel에 Stable +15%.

Surge는 강하지만:
- 같은 Burst7을 유지한다.
- Area를 넓히지 않는다.
- Stagger/추가 MP 손실 리스크가 남는다.

## 세계의 닻 / World Anchor

M06 안정화 계열.

```text
C7 Defense
MP 48
Delay 175
All Allies
```

- Barrier `28 + MNDmod`
- Stability +2 / 2 activations
- Forced Move Resist +2
- 활성 Ley Rift 1개를 1 activation 억제

Void Titan을 자동으로 무력화하지 않는다.

## Optional — 마력맥 지배 / Leyline Dominion

조건:
```text
S02 Inferno Dragon
+ 3 Anchor 기록
+ Essence 120
```

Boss에게:
```text
Slow15% / 1
Stagger25
```

정도로 변환.

Hidden boss를 잡아야 Ending을 볼 수 있는 구조는 아니다.

---

# 6. S02 Inferno Dragon

Lv24 optional.

- Main Ending 영향 없음.
- 7서클 optional Knowledge의 가장 이른/강한 source.
- Frost와 Wing stagger 취약창 활용.
- 보상은 강하지만 필수 build power가 아님.

---

# 7. D09 최종던전

순서:

```text
Outer Fissure
→ Liberation Line
→ Ley Scar
→ Core Gate
→ Liberation Leader
→ Void Titan
```

Combat XP + Story XP 합계는 ACT V 시작 Lv20 기준으로 **Lv25 도달 목표 3,650 XP를 정확히 채우도록 구성**했다.

```text
Mandatory Combat XP = 2,965
Story XP            =   685
Total               = 3,650
```

Side/PQ를 많이 한 플레이어는 더 일찍 Lv25가 될 수 있으나 Lv25가 본편 cap이므로 추가 XP는 저장하지 않거나 cap 처리한다.

---

# 8. 해방파 수장

`story_boss_liberation_leader`는 **12종 몬스터 보스 아트 목록을 늘리지 않는다.**

- 인간 Story Character 전투표현 사용.
- 3개 Pylon이 독립 Channel.
- 60% 이하 남은 Pylon Overload.
- Pylon을 끄면 MR/Barrier가 내려감.
- 25% 이하 Pylon 종료 + 빠른 마무리.

전투 후 추가 “처형/용서” Moral Choice를 넣지 않는다.

수장은 패배한 상태로 마지막 주장을 남긴다.

> “우리가 만든 게 아니야. 멈춰 있던 걸 다시 움직였을 뿐이지.”

주인공은 그 주장과 강제적 방법을 분리해 마지막 결정을 한다.

---

# 9. Void Titan

기존 Boss Data 유지:

```text
HP 620
Huge7
Core + Left Arm + Right Arm
```

구조:
- 팔 → Core Barrier
- Ley Rift
- 35% 이하 Core exposed
- Armor/MR -2
- 팔 Action 중단

따라서 최종전도 HP만 깎는 전투가 아니다.

C7은 도움을 주지만 없으면 이길 수 없는 키가 아니다.

---

# 10. 마지막 선택 C01

Void Titan 승리 후.

A. 기존 안정 상태에 가깝게 복원  
B. 새로운 흐름을 통제 가능한 상태로 안정화

**다른 Hidden Ending 없음.**

과거 Flag는:
- 최종 대사
- 접근 방식
- Epilogue
에 영향을 주지만 A/B 버튼을 잠그지 않는다.

## Ending A

의미:
- 변이 감소
- 주문 안정
- 기존 질서 유지 가능

의미하지 않는 것:
- 왕립 마도원이 항상 옳았음
- 변화가 악이었음

## Ending B

의미:
- 일부 변화 잔존
- 새 마법환경
- 기관/생태계 적응 필요

의미하지 않는 것:
- 해방파의 실험이 옳았음
- 무통제 폭주 허용

---

# 11. Epilogue Resolver

Ending 번호는 A/B 두 개뿐.

후일담은 11 Hub와 5 Companion을 Flag로 조합한다.

| Hub | 주요 입력 |
|---|---|
| T01 | ending, kael_state, act1_local_recovery |
| T02 | ending, erin_pq_complete, swamp_purified_or_burned |
| T03 | ending, ironvale_mine_sealed_or_stabilized, anchor_west_resolution |
| T04 | ending, swamp_burned_or_purified |
| T05 | ending, ancient_records_choice, nera_records_choice |
| T06 | ending, researcher_choice, temple_truth_choice, anchor_central_resolution |
| T07 | ending, researcher_choice, temple_truth_choice |
| T08 | ending, luka_pq_complete, anchor_east_resolution |
| T09 | ending, d06_complete, anchor_east_resolution |
| T10 | ending, white_wolf_choice |
| T11 | ending, temple_truth_choice, seon_pq_complete, protagonist_trait |

Companion:
- Kael: 구조/책임과 개인퀘스트 기록 선택.
- Erin: 복원된/변한 생태계의 새 지도.
- Nera: 기관감시/독립조사/정보책임.
- Seon: 신앙+기능을 함께 가르치는 역할.
- Luka: 방어체계와 책임의 재정립.

Permanent Leave인 동료는 최종파티 대사를 하지 않지만 Epilogue에서 마지막 알려진 상태를 안전하게 처리한다.

---

# 12. ACT V 경제

기존 목표:

```text
Gold Main-focused 12,886 / Typical 15,160 / Explorer 18,495
Essence Main-focused 458 / Typical 520 / Explorer 614
```

Mandatory Encounter subtotal:

```text
Gold {main_gold}
Essence {main_ess}
```

차액은:
- Anchor resolution.
- Final preparation support.
- Quest rewards.
- prior unresolved ACT II arc.
- optional exploration.
에서 분배한다.

C7 첫 주문 무료라서 ACT V Essence가 7서클 때문에 강제 소진되지 않는다.

---

# 13. Save / Crash

Anchor 하나 해결 즉시:
```text
anchor_*_resolved
reward committed
save
```

3개 완료 후 C7 지급:
```text
story_c7_granted
save
```

Void Titan 승리:
```text
final_boss_defeated=true
save
→ Ending Choice
```

Ending 선택:
```text
PROVISIONAL
→ 동료 마지막 의견
→ Confirm
→ exactly one ending flag
→ final save
→ Epilogue
```

앱 종료로 다른 Ending이 자동 선택되지 않는다.

---

# 14. ACT V 완료조건

- Anchor 순서 6가지 모두 메인 진행 가능.
- 과거 M01~M07 어떤 조합도 dead-end가 아님.
- 개인퀘스트 미완료/동료 이탈도 fallback 존재.
- 첫 C7은 Trait에 따라 무료.
- Optional C7/Inferno Dragon은 Ending 필수 아님.
- Liberation Leader는 새 13번째 몬스터 보스 아트 요구사항을 만들지 않음.
- Void Titan 이후 A/B를 플레이어가 직접 선택.
- Easter Egg Flag는 Ending Resolver가 읽지 않음.