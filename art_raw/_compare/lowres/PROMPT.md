# 저해상도 시험 프롬프트 (2026-09-13)

> **왜**: 38종을 게임 크기(37칸)로 줄이니 자세한 것이 전부 사라졌다.
> **그러면 애초에 그 해상도로 그리게 하면 어떤가** — 사용자 제안.
>
> 🔴 **「N칸으로 그려라」는 쓰지 않는다.** 세 번 시도해 세 번 실패했다
> (`UI_DESIGN.md` 3-0절). 대신 **「가장 작은 요소의 크기 하한」**으로 바꾼다.
> 모델이 세지 않아도 지킬 수 있는 형태다.

**같은 문장을 GPT 창과 sprite-gen 양쪽에 넣는다.** 대상은 1차에서 가장 크게
실패한 **저주받은 갑옷**이다 (게임 크기에서 회색 덩어리가 됐다).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Game monster sprite for a vertical mobile RPG, drawn as TRUE CHUNKY PIXEL ART.

CRITICAL - this sprite will be shown very small, about 40 pixels tall. Design it
for that size from the start:
- NO feature may be smaller than 1/20 of the sprite's height. If a detail would
  be thinner than that, LEAVE IT OUT instead of shrinking it.
- Use at most 8 flat colors total. No gradients, no texture, no noise, no rivets,
  no small trim, no patterns.
- The whole sprite must still read when shrunk to a thumbnail. Shape first.
- Bold dark outline around the whole silhouette.

SUBJECT: a cursed suit of armor that is COMPLETELY EMPTY INSIDE - standing
upright and animated with nobody wearing it, and through the gap of the visor
there is only darkness, never a face. Exaggerate the hollow emptiness and the
wide shoulders so the silhouette alone reads as this monster.

COLOR: one strong colour dominates - a pale glowing TEAL. Do not make it grey,
silver or brown. The teal must be obvious from across the room.

Full body, centered, nothing cropped. DO NOT draw a ground shadow. No text, no
labels, no border, no extra objects. Background must be a completely flat solid
pure magenta #FF00FF filling the entire canvas. Square 1:1 composition.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 여기까지 ━━━

## 비교할 것

1차 결과 두 장이 이미 있다 — `_compare/chatgpt/저주받은 갑옷.png`(손) ·
`_compare/spritegen/enemy_cursed_armor.png`(도구). **네 장을 게임 크기로 나란히 본다.**

---

# 결과 (2026-09-13) — **된다. 단 조건이 있다**

`reports/img/compare/lowres_armor.png` — 네 장을 게임 크기(37칸)로 나란히 놨다.

| | 게임 크기에서 |
|---|---|
| 1차 GPT | 회색 덩어리. 갑옷인지 알 수 없다 |
| 1차 도구 | 회색 덩어리 |
| **저해상도 v1** | 청록 파편. 색은 살았는데 **실루엣을 잃었다** |
| **저해상도 v2** | ✅ **또렷한 청록 기사.** 투구·어깨·바이저가 다 읽힌다 |

## v1 이 실패한 이유 — 「속이 비었다」를 문자 그대로 그렸다

투명 비율이 **87%** 였다. 몸통을 실제로 투명하게 그려 조각만 남았다.
**설명의 은유를 그림 지시로 읽는다.** 「속이 비어 있다」는 설정이지 그리는 법이 아니다.

## v2 에서 효과가 있었던 네 문장

1. **`NO feature smaller than 1/20 of the sprite height — LEAVE IT OUT instead of shrinking`**
   🔴 **칸 수를 세라고 하지 않는 것이 핵심이다.** 크기 하한은 모델이 지킬 수 있다
2. **`at most 8 flat colors total`** — 색이 뭉개지는 것을 막는다
3. **`ONE SOLID OPAQUE SHAPE with a thick black outline`** — v1 의 실패를 정확히 막는다
4. **`one strong colour dominates … obvious from across the room`** — 회색으로 돌아가는 것을 막는다

## 다음

**같은 프롬프트(`prompt_v2.txt`)를 GPT 창에도 넣어 비교한다.** 사용자가 한다.
