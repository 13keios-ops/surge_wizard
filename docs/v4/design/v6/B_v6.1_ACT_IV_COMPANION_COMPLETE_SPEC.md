# Surge Wizard v4 — 묶음 B / ACT IV + 동료 개인퀘스트 통합 v6.1

**범위:** 북부·D07·D08·M05/M06/M07 + 동료 5명 개인퀘스트 전체 연결  
**원칙:** ACT III 결과를 회수하되 어느 M04 선택도 메인 진행을 막지 않는다.

---

# 1. ACT IV의 질문

ACT III가 “누가 폭주를 만들고 있는가”였다면 ACT IV는:

> **왜 주인공만 불안정 마력을 받아들이는가?**
> **오래된 신전과 마도탑은 실제로 무엇을 하고 있었는가?**

를 다룬다.

플레이어는 ACT 종료 시 다음을 알고 있어야 한다.

```text
주인공 = 불안정 마력을 흡수·변환 가능한 공명체
고대 마도탑과 성맥신전은 마력맥 조절망 일부
현재 질서는 자연 그대로라기보다 오래된 안정화의 결과
해방파의 문제는 ‘변화’라는 질문이 아니라 강제·실험 방식
```

---

# 2. 전체 흐름

```text
북부 통로
→ R11 White Wolf 사건 / M05
→ T10 Frosthold
→ R12 / D07 최초 마도탑
→ Archlich
→ protagonist_resonance_identified
→ Circle 6 Gate
→ T11 Saint's Reach
→ 세온 개인퀘스트 해금
→ R13 / D08
→ Awakened Idol
→ M06 마력핵: 흡수 vs 안정화
→ M07 성맥성지 진실 공개정책
→ ACT V
```

D07과 T11의 부가 조사는 일부 교환 가능하나 **M06는 D07+D08 핵심 증거 이후**에만 일어난다.

---

# 3. M04 결과의 ACT IV 회수

M04 A — 마도원 인계:
- D07 관련 공식 기록 접근이 가장 빠름.
- Nera는 기록 누락 여부를 확인하는 추가 Scene.

M04 B — 추방:
- Freehold/현장 증거로 동일 핵심정보 확보.
- 공식 지원은 적지만 진행 손실 없음.

M04 C — 비밀협력:
- 연구자가 D07 장치의 초기 보정값을 보냄.
- D07 첫 장치 interaction이 짧아짐.
- Seon/Luka와 책임처리 후속 대화가 존재.

**세 경로 모두 D07 핵심진실에 도달한다.**

---

# 4. M05 White Wolf

White Wolf는 단순 야생 보스가 아니다.

플레이어가 먼저 확인하는 사실:

```text
늑대 이동로가 인간 정착지를 향한 이유 = 북부 마력선 이동
모든 개체가 먼저 사람을 공격한 것은 아님
Alpha는 불안정 맥동에 과민반응
```

선택:
A. 전체 토벌  
B. Alpha 제압 후 이동로 변경  
C. 마을 방어선 강화 후 이동을 기다림

모든 선택에서 Alpha와의 짧은 보스 교전은 존재해 기존 보스 콘텐츠를 버리지 않는다.

```text
A → 0 HP Kill
B → 10% HP Subdue
C → 25% HP Repel
```

에린의 Red Line은 **대체수단과 비적대 개체를 확인한 상태에서 단순 편의로 A를 고수**하는 경우에만 검토한다.

---

# 5. D07 최초 마도탑

D07은 설명문으로 진실을 읽는 장소가 아니다.

전투/장치 순서:

```text
얼어붙은 전실
→ 파손 서고
→ 초점실
→ Focus 시스템 사전학습
→ Archlich
→ 생체/마력 반응 기록
```

Archlich 사후 기록:

일반 마법사:
```text
불안정 마력 → 회로 손상
```

주인공:
```text
불안정 마력 → 흡수 → 내부 공명 → 재방출
```

Set:
```text
protagonist_resonance_identified = true
circle6_story_gate = true
```

Circle 6는 여기에 **Lv17** 조건이 추가된다.

---

# 6. T11 / 세온

Saint's Reach에서는 “신앙이 거짓이었다”는 반전으로 처리하지 않는다.

핵심:

```text
후대의 의식
= 의미를 잊은 부분도 있지만
= 실제 장치 운용절차를 보존해 온 문화적 기억
```

세온 개인퀘스트 「빈 기도문」은 여기서 자연스럽게 열리며,
M07 세계 공개정책과 개인퀘스트의 교육 방식 선택을 분리한다.

---

# 7. D08 / Awakened Idol

D08는:
- 신전 지하 구조
- 안정화 맥
- 거대한 Core
를 실제 Tactical 공간으로 보여준다.

Awakened Idol:
- 양팔 Channel
- 팔 파괴 → Core Barrier 제거
- 35% 이하 Core exposed

즉 보스가 단순 390 HP 덩어리가 아니다.

승리 후 주인공만 Core에 안정적으로 접근.

---

# 8. M06 성장 선택

## A. 공명체 / Resonant Core

```text
Max MP +10
C5+ Cast DC +1
Surge의 긍정적 추가효과 ×1.20
Surge의 기존 부정효과는 제거하지 않음
```

공격/폭주 리스크를 받아들이는 방향.

## B. 조율자 / Harmonizer

```text
RESOLVE +1
C4+ Stability +1
전투당 첫 Surge 1회 → Unstable로 downgrade
```

안정/제어 방향.

이 선택:
- Ending A/B 잠금 X
- 동료 이탈 X
- 첫 C7 종류와 일부 ACT V 대사에 영향 O

---

# 9. M07 성맥성지 진실

A. 즉시 공개  
B. 공동검증 후 공개  
C. 봉인

B를 자동 정답으로 만들지 않는다.

B의 비용:
- 공개 지연.
- ACT V 위기 직전 일부 지역이 충분히 준비하지 못할 수 있음.

A의 비용:
- 혼란/오해/선동 위험.

C의 비용:
- 기존 기관의 정보독점이 유지될 가능성.

네라/세온/루카의 기존 반응 Matrix를 그대로 적용한다.

---

# 10. Encounter 표

| ID | Lv | XP | Gold | Essence | 역할 |
|---|---:|---:|---:|---:|---|
| `A4_R11_E01_SNOW_PASS` | 15 | 130 | 330 | 12 | 기상/긴 이동 / White Wolf 단서 |
| `A4_R11_E02_PACK_LINE` | 16 | 140 | 350 | 14 | Pack Mark / 비적대 개체 구분 |
| `A4_R11_B01_WHITE_WOLF` | 17 | 220 | 520 | 24 | M05 분기형 제압/토벌 보스 |
| `D07_E01_FROZEN_VESTIBULE` | 17 | 150 | 390 | 15 | 언데드/해제 / 고위 주문 압박 |
| `D07_E02_BROKEN_LIBRARY` | 18 | 160 | 420 | 16 | 기록 접근 / LOS |
| `D07_E03_FOCUS_CHAMBER` | 18 | 170 | 450 | 18 | Focus 개념 사전학습 |
| `D07_B01_ARCHLICH` | 18 | 260 | 720 | 34 | Focus 2개 / 공명체질 진실 / C6 Gate |
| `A4_R13_E01_PILGRIM_BREAK` | 18 | 150 | 410 | 16 | 성지 접근 / M07 공개갈등 준비 |
| `D08_E01_UNDERCROFT_SEAL` | 19 | 170 | 460 | 20 | 장치와 종교기록의 기능 연결 |
| `D08_E02_CORE_APPROACH` | 19 | 180 | 500 | 22 | 마력핵 전초 / Huge footprint 공간 |
| `D08_B01_AWAKENED_IDOL` | 20 | 300 | 850 | 42 | 팔 채널 파괴 / M06 직전 최종 증거 |
| `S01_B01_HEADLESS_KNIGHT` | 15 | 210 | 650 | 26 | ACT III~IV 선택 보스 / Holy 대응 |

Mandatory combat XP: **2030**  
Story XP: **840**  
Mandatory Gold subtotal: **5400**  
Mandatory Essence subtotal: **233**

기존 ACT IV 경제 목표:

```text
Gold Main-focused 7,495 / Typical 9,140 / Explorer 11,608
Essence Main-focused 310 / Typical 360 / Explorer 446
```

나머지는 Personal Quest, Hub 지원, Discovery, optional S01, 지역보상으로 채운다.

---

# 11. 동료 개인퀘스트 전체 연결

| 동료 | Quest | 최초 자연 해금 | Trait | ACT V 회수 |
|---|---|---|---|---|
| Kael | 남겨진 명단 | ACT III T08 | 끝까지 선다 | 구조선/민간인 배치 |
| Erin | 두 번째 계절 | ACT III T02 재방문 | 길을 읽는 눈 | 안전 우회·Encounter 사전정보 |
| Nera | 봉인된 이름 | ACT III T05/T06 | 틈을 보는 자 | 봉인자료/장치 우회 |
| Seon | 빈 기도문 | ACT IV T11 | 두 손의 기도 | Anchor Hazard 감소 |
| Luka | 명령의 무게 | ACT III 후반 T08 | 수호의 맹세 | 방어선/증원 지연 |

공통:
- Owner Companion이 벤치면 시작 시 편성 Prompt.
- Main Quest는 막지 않음.
- ACT V에서도 미완료라면 Crisis Variant로 진행 가능.
- Temporary Leave면 PAUSED.
- Permanent Leave면 CLOSED_BY_DEPARTURE.
- Personal Quest 선택으로 Ending A/B를 잠그지 않음.

---

# 12. 동료 Quest를 ACT IV에 몰아넣지 않는 이유

ACT IV 메인만 6~7시간이다.

따라서 개인퀘스트는:
```text
ACT III 후반부터 4개가 열리고
Seon만 ACT IV에서 새로 열림
ACT IV/V에서 자유롭게 회수
```

하도록 유지한다.

플레이어가 모든 Quest를 ACT IV 진입 직후 몰아서 해야 하는 체크리스트 구조를 만들지 않는다.

---

# 13. ACT IV Save Flags

```text
white_wolf_pack_killed | white_wolf_redirected | white_wolf_repelled
d07_complete
protagonist_resonance_identified
circle6_story_gate
saints_reach_open
d08_idol_defeated
protagonist_trait_resonant_core | protagonist_trait_harmonizer
temple_truth_public_immediate | temple_truth_joint_verify | temple_truth_sealed
act4_complete
act5_unlocked
```

각 Choice group은 exactly-one.

---

# 14. ACT IV 완료 기준

- M05 세 경로 모두 T10/D07로 연결.
- D07 이전에는 주인공 공명 정체를 확정적으로 설명하지 않음.
- D07+Lv17 이전 C6 학습 불가.
- M06는 Ending을 잠그지 않음.
- M07은 세계상태/후일담에 반영되나 Ending 선택 자체를 대신하지 않음.
- 5 Personal Quest 모두 Main Ending 비필수.
- 보스 White Wolf / Archlich / Awakened Idol이 각각 기믹으로 방어가 풀리며 HP 스펀지가 아님.