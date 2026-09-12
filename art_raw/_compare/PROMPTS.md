# 비교 실험 — sprite-gen 대 GPT 수동 (2026-09-12)

> ## 🔴 이 파일은 **GPT 결과물 38종을 보기 전에** 작성됐다
> 사용자가 GPT로 38종을 이미 만들었지만 **일부러 주지 않았다.** 먼저 보면 그것이
> 가이드가 되어 비교가 무의미해진다. **아래 프롬프트는 그 전에 고정된 것이고,
> 결과물을 본 뒤에 고치지 않는다.**
>
> 작성 시각: 2026-09-12 23:34 (codex 한도로 생성 실패한 직후)
> 재시도 가능 시각: **2026-09-13 01:47** (OpenAI 한도 해제)

## 조건

| | |
|---|---|
| 제공자 | `codex` (ChatGPT image_gen) — grok 은 미구독 |
| 참조 그림 | `art_raw/wizard/v4/wizard_back.png` (승인된 화풍 기준) |
| 투명 | `--alpha-mode chroma --chroma-key magenta` |
| 왜 크로마인가 | **참조를 붙이면 `auto` 가 크로마로 내려간다** (`docs/gen.md`).<br>codex 는 참조가 붙으면 6번 중 5번 체커보드를 그린다고 측정돼 있다.<br>그래서 프롬프트가 키 색을 직접 들고 있어야 한다 |
| 키를 마젠타로 고른 이유 | 대상 셋 중 둘이 초록·청록이다. 초록 키를 쓰면 몸이 지워진다 |

## 공통 문장 (세 프롬프트가 공유한다)

```
Single game monster sprite for a vertical mobile RPG. Match the art style of the
attached reference character exactly: clean flat cel shading, bold readable
silhouette, chunky simple forms, limited palette, soft dark outline, light from
the upper left. SUBJECT: <대상>. <특징 과장 지시>. Use one strong color only.
Full body, centered, nothing cropped. DO NOT draw a ground shadow. No text, no
labels, no border, no extra objects. Background must be a completely flat solid
pure magenta #FF00FF filling the entire canvas. Square 1:1 composition.
```

## 대상 3종 — 왜 이 셋인가

성질이 서로 다른 것을 고른다. 하나만 보면 우연인지 실력인지 모른다.

| 파일 | 왜 고르나 |
|---|---|
| `enemy_green_slime` | **가장 쉬운 것.** 단순한 덩어리 + 눈 하나. 이게 안 되면 나머지는 볼 것도 없다 |
| `enemy_skeleton_apprentice` | **실루엣이 까다로운 것.** 자기 몸보다 큰 지팡이를 든 가는 뼈. 팔다리가 엉키기 쉽다 |
| `boss_elder_slime` | **보스.** 반투명 몸 안에 삼킨 뼈가 비쳐야 한다. 그리고 **이미 구워진 것이 있어** 직접 대조가 된다 |

### 1. `enemy_green_slime`

> a small green slime monster - a translucent lime-green jelly blob with ONE
> oversized round eye that dominates its whole body, squat and wide, cute but
> simple. Exaggerate the single huge eye so the silhouette alone reads as this
> monster.

### 2. `enemy_skeleton_apprentice`

> a small skeleton apprentice mage - a skinny skeleton straining to hold up a
> bone staff TALLER than its own body, blue flame flickering inside its empty
> eye sockets. Exaggerate how oversized the staff is compared to the frail
> skeleton so the silhouette alone reads as this monster.

### 3. `boss_elder_slime`

> a huge ancient slime BOSS - a massive dark teal translucent jelly mass with
> THREE eyes, with swallowed bones and a broken sword suspended and visible
> inside its see-through body. Wide, heavy and imposing, clearly larger and more
> threatening than an ordinary slime. Make the three eyes crisp and a different
> color from the body so the shape still reads when the whole body is filled
> black as a silhouette.

## 실행 명령 (그대로 다시 돌린다)

```bash
~/.claude/skills/sprite-gen/.venv/bin/sprite-gen gen \
  --provider codex \
  --ref "D:/Projects/surge_wizard/art_raw/wizard/v4/wizard_back.png" \
  --transparent --alpha-mode chroma --chroma-key magenta \
  --out "D:/Projects/surge_wizard/art_raw/_compare/spritegen/<파일>.png" \
  --report "D:/Projects/surge_wizard/art_raw/_compare/spritegen/<파일>.report.json" \
  --prompt "<위 문장>"
```

## 비교할 때 볼 것 — **숫자 먼저, 그림은 나중**

| 항목 | 재는 법 | 기준 |
|---|---|---|
| 격자 | `tool/measure_grid.py` | **없어야 한다** (부드럽게 그린 그림) |
| 세부 밀도 | 키를 1000으로 정규화한 뒤 인접 차이 | 마법사 v4 가 **5.0~5.3** |
| 알파 | 투명 픽셀 비율 · 알파 0 자리의 RGB | 진짜 알파여야 한다 |
| 실루엣 | 몸을 검게 칠해도 무엇인지 읽히나 | 보스는 **눈이 남아야** 한다 |
| 화풍 거리 | 마법사 v4 와 색·명암 성격 비교 | 같은 게임으로 보이나 |

🔴 **판정은 「어느 쪽이 예쁜가」가 아니다.** 38종을 한 대화에서 이어 뽑은 GPT 쪽이
화풍 일관성에서 유리할 수 있고, sprite-gen 은 **왕복이 없는 것**이 이점이다.
**둘 다 쓸 수 있으면 물량은 sprite-gen, 기준 한 장은 손으로** 가 답일 수 있다.

---

# 결과 (2026-09-13 01:50, codex 한도 해제 직후)

세 장 모두 한 번에 성공. 장당 **53~63초**. 재시도 없음.

## 숫자

| | 투명 | 발바닥 | 중심 | 밀도 | **잔여 RGB** |
|---|---|---|---|---|---|
| 도구 · 초록 슬라임 | 75.9% | **0.754** | 0.497 | 1.62 | **0** |
| 도구 · 견습 해골 | 85.2% | 0.951 | 0.492 | 3.65 | **20** |
| 도구 · 태고의 슬라임 | 36.9% | 0.953 | 0.500 | 2.42 | **0** |
| — 기준: 마법사 v4 | 76.3% | 0.938 | 0.500 | 5.31 | 6278 |
| — 손 · 고블린(기존) | 76.7% | 0.953 | 0.500 | 1.80 | 5098 |
| — 손 · 태고의 슬라임(기존) | 61.3% | 0.903 | 0.499 | 2.32 | 6135 |

### 🔴 같은 대상으로 직접 비교 — 태고의 슬라임

**밀도 2.42(도구) 대 2.32(손).** 도구가 근소하게 더 곱다.

### 알파가 훨씬 깨끗하다

**잔여 RGB**(투명한데 색이 남은 픽셀)가 도구는 **0~20**, 손 작업물은 **5000~6300**이다.
후처리가 지우므로 최종 결과는 같지만, **도구 쪽이 처음부터 규격을 지킨다.**

### 발바닥은 볼 필요가 없었다

초록 슬라임이 0.754로 크게 벗어났지만 **문제가 아니다.** `tool/gridize.py` 가 실루엣을
잘라내 출력 캔버스에 다시 앉힌다 — 마법사 v4에서 이미 확인한 것과 같다.

## 그림 (`reports/img/compare/spritegen_vs_hand.png`)

| | 판정 |
|---|---|
| 초록 슬라임 | 요구대로 **눈 하나가 몸을 지배**한다. 실루엣만으로 읽힌다 |
| 견습 해골 | **자기 몸보다 큰 지팡이**, 눈구멍의 파란 불씨. 셋 중 가장 어려운 실루엣인데 성공 |
| 태고의 슬라임 | **눈 셋이 노랗게 또렷**하고 삼킨 뼈와 부러진 검이 비친다 |
| 손 · 태고의 슬라임(기존) | 🔴 **눈이 또렷하지 않다.** 이끼 낀 돌무더기로 읽힌다 |

🔴 **기존 손 작업물은 보스 실루엣 연출에 부적합하다.** 몸을 검게 칠했을 때 눈이
읽혀야 하는데(6.7절 ②) 그 그림은 눈이 흐리다. **도구 쪽은 바로 쓸 수 있다.**

## 판정

**도구로 38종을 뽑아도 된다. 이 세 장에서는 오히려 손보다 낫다.**

### 화풍 일관성 — 걱정의 방향이 달랐다

「한 대화에서 이어 뽑아야 화풍이 유지된다」고 봤는데, 도구는 다르게 푼다 —
**매 장을 같은 참조 그림(마법사 v4)에 고정한다.** 앞 그림을 따라가지 않으므로
**표류(drift)가 구조적으로 없다.** 긴 대화에서 조금씩 어긋나는 것보다 안정적이다.

### 그래도 남는 것

- **밀도가 마법사 v4(5.31)보다 낮다** (1.6~3.6). 다만 대상 성질 차이가 크다 —
  슬라임은 매끈한 젤리라 세부가 적은 것이 맞다. **같은 대상 비교가 유일하게 공정하고,
  거기서는 도구가 이겼다**
- 승인된 몬스터가 쌓이면 `--ref` 에 **함께 넣어** 더 조일 수 있다

---

# 2차 (2026-09-13) — **어려운 성질 셋**

1차에서 안 건드린 것을 골랐다. 조건은 1차와 **완전히 동일**(참조도 마법사 v4 하나).

| 대상 | 무엇을 시험하나 | 밀도 | 잔여 RGB | 판정 |
|---|---|---|---|---|
| `enemy_bat_swarm` | **세 마리가 한 덩어리** — 「한 파일에 하나」와 부딪힌다 | 1.12 | 0 | ✅ 하나의 실루엣으로 뭉쳤다 |
| `enemy_fire_elemental` | **형태가 없는 것** — 실루엣·알파 시험 | 1.19 | 0 | ✅ 몸이 없고 불꽃 자체다 |
| `enemy_cursed_armor` | **속이 비어 있다** — 모델이 흔히 채운다 | **4.69** | 0 | ⚠ 아래 |

## 🔴 갑옷이 드러낸 것 둘 — **프롬프트의 구멍이다**

### 1. 강한 색이 없다
은·회색으로 나왔다. 요청서는 **「강한 색 하나만」**을 요구한다 —
**코드가 변종 6종의 색조를 입히기 때문**이다 (`ASSET_LIST.md` 1-2절).
회색에 색조를 입히면 흐려진다. 「창백한 청록 빛」은 이음새에 거의 안 보인다.

### 2. 밀도가 4배 튄다
**갑옷 4.69 대 박쥐 1.12.** 판금과 리벳이 많아서다.
이대로 38종을 뽑으면 **한 화면에 같이 섰을 때 따로 논다** — 격자화가 같은 칸 수로
맞춰도 하나는 빽빽하고 하나는 휑하다.

### 고칠 것 (38종 발주 전에)

프롬프트에 **화풍 기준은 있는데 「세부의 양」 기준이 없다.** 둘을 넣는다.

1. **세부의 양**을 참조 그림에 맞추라고 명시 — 「참조 캐릭터보다 더 잘게 그리지 마라」
2. **강한 색 하나**를 강제 — 「회색·은색·갈색만으로 칠하지 마라. 한눈에 보이는
   채도 높은 색이 하나 있어야 한다. 코드가 그 색을 바꿔 변종을 만든다」

## 1·2차 합계 판정

**6장 중 5장이 요구대로 나왔다.** 알파는 6장 모두 잔여 RGB 0~20으로 깨끗하다.
어려운 성질(한 덩어리·형태 없음·큰 소품·삼킨 것이 비침)을 전부 소화했다.
**남은 문제는 그림 실력이 아니라 프롬프트가 안 적은 것**이다.

---

# 🔴 3차 검토 (2026-09-13) — **GPT 38종을 게임 크기로 봤다**

사용자가 `art_raw/_compare/chatgpt/` 에 38종을 넣고 두 가지를 물었다.

> 1. 같은 프롬프트면 **거의 같은 그림**이 나오는 것 같다. 학습된 기본값 같다
> 2. 게임에 넣었을 때 **지나치게 자세한 부분이 표현될까**

**둘 다 사실이다.** 그리고 **둘은 같은 문제의 앞뒷면이다.**

## 방법 — 실제 게임 해상도로 줄였다

일반 적은 화면에서 **76dp 상자 · 논리 37칸**이다 (`docs/HANDOFF_ART.md`).
38종 전부를 그 해상도로 다시 찍었다 → `reports/img/compare/gpt38_ingame.png`.
같은 대상을 GPT와 도구가 각각 그린 것도 나란히 → `detail_survival.png`.

## 답 2 — **자세한 부분은 사라진다. 확인됐다**

37칸에서 살아남는 것은 **실루엣과 강한 색 하나뿐**이다.
저주받은 갑옷은 GPT·도구 **양쪽 다 회색 덩어리**가 됐다. 판금·리벳·망토 무늬가
전부 뭉개진다. 반대로 **버섯 정령·초록 슬라임·화염 정령·동굴 쥐는 또렷하다** —
실루엣이 독특하고 색이 하나로 강해서다.

🔴 **이건 생성기 문제가 아니다.** `ASSET_LIST.md` 1-3절이 이미 정해 둔 것이다 —
「작은 화면에서 실루엣만 보고 구분되어야 한다」, 「각 적은 색을 하나만 강하게」.
**38종이 그 규칙을 안 지켰다.**

### 칸을 늘리면 되지 않나 — 안 된다

37칸에 76dp 상자면 한 칸이 약 1.76dp다. 밴드가 **1.55~1.75dp**이므로 이미 하한이다
(`docs/HANDOFF_ART.md`). 칸을 늘리면 밴드를 벗어난다.
**해상도로 풀 문제가 아니라 그림을 단순하게 그려야 하는 문제다.**

## 답 1 — **기본값이 실제로 있다. 숫자로 보인다**

### 색이 몰렸다

| 대표 색 | 종수 |
|---|---|
| 빨강 | **10** |
| 파랑 | 6 |
| 주황 · 보라 · **무채(회색)** | 각 5 |
| 노랑 | 4 |
| 청록 | 2 |
| **초록** | **1** |

🔴 **초록이 1종뿐인데 도입 지역이 숲이다.** 그리고 **빨강에 10종이 몰렸다.**
37칸에서 색은 실루엣과 함께 단 두 개뿐인 단서인데, 그 하나가 겹친다.

**채도가 약한 것이 8종**이고 그중 5종은 사실상 무채색이다
(늑대 무리 1.1% · 뼈무더기 거인 4.5% · 새끼 뼈 용 5.6% · 트롤 싸움꾼 8.4% · 석상 가고일 12.0%).

### 자세도 몰렸다

38종 중 약 20종이 **정면 직립 · 어깨 넓은 인간형**이다. 서로 다른 설명을 넣어도
같은 틀로 돌아온다. **틀을 벗어난 것은 설명이 인간형을 불가능하게 만든 것들**뿐이다
— 슬라임·버섯·불꽃·쥐·두꺼비·박쥐.

## 그래서 프롬프트를 이렇게 고친다 (38종 발주 전)

| 넣을 것 | 왜 |
|---|---|
| **각 적에게 서로 다른 강한 색을 지정한다** | 색이 두 단서 중 하나다. 빨강 10종은 안 된다 |
| **「회색·갈색·은색만으로 칠하지 마라」** | 무채 5종이 나왔다 |
| **「정면 직립 인간형을 피하라」를 필요한 종에 명시** | 20종이 같은 자세다 |
| **세부 상한** — 「37칸으로 줄여도 남을 것만 그려라」 | 판금·리벳은 무조건 사라진다 |

🔴 **색 배정은 사람이 해야 한다.** 12지역 × tier 를 보고 겹치지 않게 짜야 하므로
`ASSET_LIST.md` 에 **적마다 대표 색을 한 칸 추가**하는 것이 맞다.

## 도구냐 손이냐 — **이 질문은 이제 중요하지 않다**

6장 비교에서 도구가 손보다 못하지 않았다. 그런데 **38종을 게임 크기로 보니
양쪽 다 같은 문제를 갖는다.** 생성 경로를 바꿔도 안 풀린다.
**고쳐야 하는 것은 요청서다.**
