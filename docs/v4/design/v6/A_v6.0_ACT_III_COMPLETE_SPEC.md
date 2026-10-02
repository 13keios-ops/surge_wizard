# Surge Wizard v4 — 묶음 A / ACT III 완전 상세화 v6.0

**범위:** Quest · Encounter · Hub · Companion · Reward · Major Choice · Spell Gate  
**기존 기준:** Story Bible v1.2, Progression v1.3, Companion/Choice v1.4, C4–C6 v2.4  
**원칙:** 기존 확정 규칙을 바꾸지 않고 ACT III를 실제 구현 가능한 순서로 닫는다.

---

# 1. ACT III의 역할

ACT III의 핵심은 **“몬스터가 이상하다”에서 “사람이 의도적으로 폭주를 만들고 있다”로 질문이 바뀌는 것**이다.

플레이어가 확인해야 하는 사실은 세 단계다.

```text
1. R07 — 자연변이처럼 보인 현상에 인공 증폭 흔적이 있다.
2. T07/T08 — 왕립 마도원 밖에서도 같은 현상을 추적하고 있으며 인간 조직이 개입한다.
3. D05 — 해방파가 실제로 장치·생물·사람을 대상으로 실험했다.
```

ACT 종료 시 알아야 하는 것:

```text
해방파의 존재와 강제적 방법
왕립 마도원이 일부 과거 자료를 통제했다는 의혹
고대 마력맥 관측 기록
북부에 더 큰 마력 지점이 있다는 사실
주인공 폭주가 단순 우연이 아닐 가능성
```

해방파의 주장 자체를 개발자의 정답으로 만들지 않는다.

---

# 2. 전체 흐름

```text
T06 Arken 진입
→ 왕립 마도원 합동보고
→ 세온 영입
→ [R07 불탄 숲 / T07 Freehold / T08 Redgate] 중 조사
→ 조사증거 2개 이상
→ D05 해방파 연구시설
→ 연구자 CAPTURED
→ M04 처리 선택
→ T09 Sunmarket
→ D06 매몰 천문관
→ Sun Sphinx
→ 북부 마력 지점 확인
→ ACT IV
```

R07/T07/T08의 순서는 부분적으로 자유다. D05는 증거 2개 이상 이후 열린다.

T08에서 루카는 **정식 Roster에 반드시 합류 가능**하며, 대화 선택으로 영입 자체를 영구 Miss시키지 않는다.

---

# 3. Arken / 세온

왕립 마도원 첫 보고는 장문의 정치 설명이 아니라 ACT II 증거를 테이블 위에 놓는 장면으로 한다.

마도원 조사관:
> “세 지역의 현상이 같은 근원이라면, 우연이라고 부를 단계는 지났습니다.”

세온은 여러 신전 기록에서 동일한 맥동 주기를 확인한 인물로 합류한다.

세온:
> “신전 기록은 ‘재앙’이라고 부르지 않습니다. 반복된다는 기록만 있습니다. 그게 더 불편합니다.”

**Circle 4 Story Gate**는 이 합동보고가 끝날 때 열린다. Lv9가 안 됐으면 Knowledge만 보여주고 학습은 잠근다.

---

# 4. 세 조사축

## 4.1 R07 불탄 숲

핵심 발견:
- 불타는 수목이 단순 산불 변이가 아님.
- 뿌리 아래 초기형 증폭기가 있음.
- 카일 개인퀘스트의 과거 상단 습격 흔적과 기술 계통이 닮음.

Burning Treant는 인위적으로 만든 꼭두각시가 아니라 **증폭에 의해 원래 생태적 반응이 폭주한 존재**다.

보스 후:
- `act3_burnt_forest_evidence=true`
- Inferno Orb의 Primary Knowledge Source 확보
- Kael PQ의 과거 장치 비교대사 활성화

## 4.2 T07 Freehold

전투 필수 없음.

자유연구회는 마도원이 숨긴다는 주장과 해방파 주장을 둘 다 검증 대상으로 본다.

연구자:
> “변화가 자연스럽다는 말과, 사람을 밀어 넣어도 된다는 말은 전혀 다르죠.”

보상:
- Crystal Barricade/중력·수정 연구 Knowledge 접근
- `act3_freehold_evidence=true`
- M04 C 선택의 정보량 증가

## 4.3 T08 Redgate

해방파·용병·변이 몬스터가 섞인 첫 본격 인간 혼성전.

루카는 외부 조사대를 감시하다가 방어전을 함께 치른다.

루카:
> “조사 결과는 나중입니다. 지금 저 문이 무너지면 안쪽 사람들이 먼저 죽습니다.”

전투 후 정식 Roster 해금:
- 영입 Miss 불가
- Active 3인에 넣을지는 플레이어 선택

---

# 5. D05 해방파 연구시설

던전 감정선:

```text
외곽의 군사시설
→ 격리실
→ 공명장치
→ 조사대/피실험 기록
→ 연구자와 직접 대면
```

연구자는 단순 악당이 아니다. 그러나 **사람을 위험에 노출한 책임은 실제로 존재**한다.

최종 전투 HP 0:
```text
DEAD가 아니라 CAPTURED
```

전투 결과 직후 자동 보상 지급 후 M04로 넘어가지 않는다. 먼저 기록을 읽고 책임 사실을 명확히 한 뒤 선택한다.

D05 완료:
- Circle 5 Story Gate
- `d05_researcher_captured=true`
- 연구자 처리 M04
- Suppression Field / 일부 Countermagic Knowledge

---

# 6. M04 연구자 처리

선택은 반드시:

```text
PRESENTED
→ PROVISIONAL
→ 관련 동료 개입
→ [고수] / [다시 생각]
→ COMMITTED
```

A. 왕립 마도원 인계  
B. 자료 압수 후 추방  
C. 감시 조건 비밀 협력

세 선택 모두 D06와 ACT IV로 진행한다.

중요:
- A = 정답 아님.
- B = 중립 정답 아님.
- C = 자유주의 정답 아님.
- 세온/루카의 C 반대는 연구 지식 자체가 아니라 책임 면제 문제.
- 네라의 A 반대는 범죄자 보호가 아니라 정보가 다시 묻힐 위험.

---

# 7. T09 / D06

Sunmarket은 대도시 설명 장면이 아니라 **고대 관측 기록을 해석하기 위한 문화·기록 거점**이다.

D06에서는 전투 외에 반사판/천문 장치가 실제 경로를 바꾼다.

Sun Sphinx의 역할:
- 침입자를 벌하는 괴물이라기보다 관측시설 수호자.
- 반사판을 이용해 플레이어가 안전지대를 만든다.
- 후반 MR이 내려가 마무리가 빨라진다.

획득:
- Thunder Lance
- Temporal Anchor
- 북부 마력 지점 좌표
- `north_ley_point_identified=true`

---

# 8. Encounter / Reward 표

| ID | Lv | 지역 | XP | Gold | Essence | 역할 |
|---|---:|---|---:|---:|---:|---|
| `A3_E01_RIVER_CHECKPOINT` | 9 | R06 | 90 | 150 | 6 | 인간형 적 첫 도입 / Cover / 비살상 분위기 |
| `A3_R07_E01_CHARRED_VERGE` | 10 | R07 | 110 | 170 | 8 | 인공 증폭 흔적 / Fire hazard |
| `A3_R07_E02_ROOT_RELAY` | 11 | R07 | 120 | 190 | 9 | 장치 상호작용 / 제어 우선순위 |
| `A3_R07_B01_BURNING_TREANT` | 12 | R07 | 180 | 310 | 16 | 채널형 보스 / 가지 파괴 / C5 Inferno Orb 지식원 |
| `A3_R08_E01_REDGATE_ASSAULT` | 11 | R08 | 110 | 185 | 7 | Luka 영입 전투 / 인간+몬스터 혼합 |
| `A3_R08_E02_RELAY_CONVOY` | 12 | R08 | 100 | 210 | 8 | Optional 정보/장치 회수 |
| `D05_E01_OUTER_FENCE` | 12 | R08 | 120 | 190 | 8 | 해방파 시설 침투 |
| `D05_E02_CONTAINMENT` | 12 | R08 | 125 | 180 | 10 | 실험체/인간 책임 테마 |
| `D05_E03_RESONANCE_HALL` | 13 | R08 | 135 | 205 | 11 | 장치 끄기 / Suppression Field 지식 |
| `D05_E04_TRANSFER_BRIDGE` | 13 | R08 | 140 | 225 | 10 | 좁은 통로 / 후열 보호 |
| `D05_B01_RESEARCHER_CAPTURE` | 14 | R08 | 200 | 360 | 20 | CAPTURED 결과 / M04 연구자 처리 |
| `A3_R09_E01_DESERT_APPROACH` | 14 | R09 | 115 | 210 | 8 | 사막/긴 사거리 |
| `D06_E01_REFLECTION_HALL` | 14 | R09 | 130 | 235 | 10 | 반사판/LOS 예고 |
| `D06_B01_SUN_SPHINX` | 15 | R09 | 220 | 420 | 24 | 반사판 조작 / 북부 관측 기록 확보 |

Mandatory combat XP: **1795**  
Optional combat XP: **100**  
Story/Investigation XP: **500**  
Mandatory encounter Gold subtotal: **3030**  
Mandatory encounter Essence subtotal: **147**

ACT III 전체 경제 목표는 기존 Economy Reference를 유지한다.

```text
Gold Main-focused 4,184 / Typical 5,230 / Explorer 6,694
Essence Main-focused 189 / Typical 225 / Explorer 281
```

Encounter 보상만으로 목표를 채우지 않는다. Quest resolution, Hub 지원, Discovery, Personal Quest가 나머지를 담당한다.

---

# 9. ACT III에서 열리는 Personal Quest

```text
Kael  — T08 첫 방문 후 「남겨진 명단」
Erin  — ACT III + T02 재방문 후 「두 번째 계절」
Nera  — T06 봉인서고 접근 가능 후 「봉인된 이름」
Luka  — D05 해결 또는 Redgate 안정화 후 「명령의 무게」
Seon  — 영입은 ACT III, 개인퀘스트는 ACT IV T11
```

Personal Quest는 Main Gate가 아니다.

---

# 10. Save Flag

필수:

```text
act3_started
circle4_story_gate
seon_recruited
act3_burnt_forest_evidence
act3_freehold_evidence
act3_redgate_evidence
luka_recruited
d05_researcher_captured
circle5_story_gate
researcher_handed_to_academy | researcher_exiled | researcher_secret_coop
d06_complete
north_ley_point_identified
act3_complete
act4_unlocked
```

M04 세 Flag는 정확히 하나만 true.

---

# 11. ACT III 체크포인트

```text
Arken 보고 Commit
Seon Recruit Commit
Luka Recruit Commit
D05 진입
Researcher Captured
M04 Commit
D06 진입
Sun Sphinx Victory
ACT III Complete
```

---

# 12. ACT III 완료 조건

- 세온/루카 Roster 상태가 Save/Load된다.
- 어떤 조사순서에서도 evidence_count>=2로 D05가 열린다.
- D05 연구자는 일반 사망하지 않는다.
- M04 provisional state에서는 Strike/Flag/Reward가 0이다.
- M04 세 선택 모두 D06로 수렴한다.
- Circle 5는 D05+Lv13 gate를 지킨다.
- D06 완료 전 ACT IV 북부 Gate는 열리지 않는다.
- ACT III Main 진행에 특정 Personal Quest가 필요하지 않다.