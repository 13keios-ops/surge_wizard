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
