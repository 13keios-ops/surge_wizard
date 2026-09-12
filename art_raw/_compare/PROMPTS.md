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
