# 몬스터 요청서 v3 — 화풍 기준을 **고블린**으로 바꿨다 (2026-09-13)

> ## 🔴 무엇이 문제였나 — **참조 그림이 원인이었다**
>
> 사용자가 GPT에 준 참조는 `art_raw/wizard/_turn_*.png` **4장**이었다.
> 그것들을 재 보니 **원하는 것보다 3배 세밀했다.** GPT는 충실히 따랐을 뿐이다.
>
> | | 실효 해상도 | 밀도 |
> |---|---|---|
> | **고블린** (사용자가 「이것처럼」이라고 한 것) | 200px | **2.08** |
> | 참조 `_turn_back` | 340px 초과 | **5.80** |
> | 참조 `_turn_front` | 340px 초과 | **6.78** |
> | 그 결과 나온 갑옷 | 340px 초과 | **7.28** |
>
> **말로 「단순하게」라고 적는 것보다 참조를 바꾸는 것이 확실하다.**

## 참조 파일 — **이것 한 장만 첨부한다**

```
art_raw/_ref/style_goblin_400.png
```

`enemy_goblin_scout.png` 를 400px로 줄인 것이다. 실효 해상도가 200px이라
**줄여도 잃는 것이 없고**, 크게 주면 모델이 또 세밀하게 그린다.

🔴 **`_turn_*.png` 4장을 주지 마라.** 그것이 이번 문제의 원인이다.

## 결과 (2026-09-13 시험)

가장 크게 실패했던 둘로 돌렸다 → `reports/img/compare/prompt_v3.png`

| | 전 | 후 | 목표 |
|---|---|---|---|
| 갑옷 밀도 | 7.28 | **3.50** | 2.08 |
| 늑대 밀도 | 5.46 | **3.74** | 2.08 |

- ✅ **정면 지시가 먹혔다** — 늑대가 옆모습에서 정면으로 바뀌었다
- ✅ **색 지정이 먹혔다** — 청록·백청으로 나왔다
- ⚠ 밀도는 절반쯤 내려왔고 **아직 고블린보다 높다**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Game monster sprite for a vertical mobile RPG, in the EXACT style of the attached reference goblin.

🔴 STUDY THE REFERENCE FIRST. It defines three things you must match:
- the LEVEL OF DETAIL — it is simple. Large flat shapes, few small marks. DO NOT draw with more detail than the reference. No rivets, no fine trim, no texture, no engraved patterns.
- the OUTLINE — one clean dark outline around the whole body.
- the PROPORTIONS — big head, short body, chunky limbs.

🔴 POSE: standing upright, FACING THE VIEWER STRAIGHT ON, both feet planted on the ground, body symmetric. Exactly like the reference goblin. Not in profile, not turned away, not flying, not crouching.

SUBJECT: <여기에 그 몬스터의 설명 — `ASSET_LIST.md`>

COLOR: <여기에 그 계열의 색 — `art_raw/_compare/family_colors.json`>. Not grey, not brown unless that IS the family colour.

Full body, centered, nothing cropped. DO NOT draw a ground shadow. No text, no labels, no border, no extra objects. Background must be a completely flat solid pure magenta #FF00FF filling the entire canvas. Square 1:1 composition.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 여기까지 ━━━

## 아직 남은 것

- **밀도 3.5를 2.1까지 더 내릴 것인가.** 사용자가 그림을 보고 정한다
- **38종의 색**은 `family_colors.json` 에 계열별로 있다. 몬스터마다 그 계열 색을 넣는다
- 🔴 **재도색(`tool/retint.py`)은 폐기됐다** — 「색 하나로 모두 칠하는 것은 별로다」
  (2026-09-13 사용자). 색은 **그릴 때** 정해져야 한다
