# 폭주 재설계 — 6갈래 · 80종 (v2)

> 2026-09-01 기획 창 작성. `GAME_DESIGN.md` 7절의 구현 명세다.
> 이 문서가 `assets/data/surges.json` 재작성의 기준이 된다.
> **기획 창이 쓴 문서다. 구현 창은 이 문서를 고치지 말고 데이터로 옮기기만 한다.**

---

## 1. 원칙 — 폭주는 문장이 아니라 전투 결과다

v1은 재미있는 문장이 주인공이고 효과가 곁다리였다(「눈썹이 사라졌다」 — 체력 −2).
v2는 반대다. **유저가 알아야 할 것은 "이번 시전이 어떻게 됐나" 하나다.**

화면에 읽히는 순서:

```
[큰 글씨]   역류!
[숫자]      −14
[한 줄]     마력이 거슬러 오른다
```

- **큰 글씨 = 갈래 이름**(6종). 이것만 봐도 무슨 일이 났는지 안다
- **숫자 = 결과**. 피해·배율·마나 변화를 즉시 보여준다
- **한 줄 = `text`.** **8~12자 (공백 제외한 한글 글자 수).**
  이펙트 자막으로 쓸 수 있을 만큼 짧아야 한다
- `name`(사건 이름, 3~6자)은 전투 로그와 팝업 소자막용이다

문장 규칙: 코믹 금지. 건조하고 전투적으로.
**한 문장, 마침표 없음, 공백 제외 12자 이하.**

> ⚠ **글자 수는 공백을 빼고 센다.** (검토 08에서 기준이 모호해 혼선이 있었다)
> 「밀려난 마력이 나를 친다」는 공백 포함 13자지만 **글자로는 10자**라 규칙 안이다.

---

## 2. 6갈래

| 갈래 | `category` | 전투에서 무슨 일이 | 목표 비율 | 종수 |
|---|---|---|---|---|
| **역류** | `backlash` | 그 주문의 대미지를 내가 맞는다 | 25% | 20 |
| **오발** | `misfire` | 결과가 엉뚱한 곳으로 간다 | 20% | 18 |
| **불발** | `fizzle` | 아무 일도 일어나지 않는다 | 15% | 11 |
| **증폭** | `amplify` | 더 크게 터진다, 대신 대가 | 15% | 11 |
| **소환** | `summon` | 뭔가가 나타나 싸운다 | 15% | 11 |
| **연쇄** | `chain` | 손패의 다른 주문까지 터진다 | 10% | 9 |

- **「증폭」과 「오발」 일부가 순수 이득 역할**을 한다. 실패가 가끔 이득이어야 실패가 기대된다
- **「불발」이 15%인 이유**: 폭주가 매번 화려하면 무뎌진다. 아무 일 없는 경우가 있어야 사고가 터졌을 때 놀란다. 불발도 **마력 축적 게이지는 오르므로** 완전한 손해가 아니다

---

## 3. 비율을 정확히 맞추는 구조 ★ 중요

폭주는 주문의 `surge_tags`로 후보를 거른다. **갈래마다 태그 분포가 다르면 주문마다 실제 비율이 틀어진다.** 이걸 구조로 막는다.

**주문 70종은 전부 속성 태그를 정확히 하나씩 가진다** (화염14·냉기14·비전14·그림자14·자연14).
따라서 **폭주 쪽에서는 속성 5종만 태그로 쓴다.** 기존 부가 태그(`explosion` `life` `sky` `earth` `shield` `rune` `light` `void` `time` `mind` `curse` `swarm`)는 **폭주에서 쓰지 않는다.**

그러면 어떤 주문이든 후보 풀이 **`any` 40종 + 자기 속성 8종**으로 고정된다.

| 구분 | 종수 | 가중치 합 | 역류 | 오발 | 불발 | 증폭 | 소환 | 연쇄 |
|---|---|---|---|---|---|---|---|---|
| `any` | 40 | 1000 | 250 | 200 | 150 | 150 | 150 | 100 |
| 속성 1종당 | 8 | 120 | 30 | 24 | 18 | 18 | 18 | 12 |
| **한 주문의 실제 풀** | **48** | **1120** | **280** | **224** | **168** | **168** | **168** | **112** |
| **실제 비율** | | | **25.0%** | **20.0%** | **15.0%** | **15.0%** | **15.0%** | **10.0%** |

**어떤 주문을 써도 목표 비율과 오차 0이다.** 속성 8종의 갈래 구성(역류2·오발2·불발1·증폭1·소환1·연쇄1)과 가중치를 지키는 한 이 성질은 유지된다.

> `spells.json`은 고치지 않는다. 주문에 `explosion` 같은 부가 태그가 남아 있어도 그 태그를 가진 폭주가 없으므로 아무 영향이 없다.

---

## 4. 효과 규약

### 그대로 쓰는 것 (이미 구현됨)

`self_damage` · `heal` · `mana_change` · `seal_spell` · `swap_hp` · `summon_ally`(양수=아군/음수=적대) · `damage_multiplier` · `skip_enemy_turn` · `extra_die` · `force_reroll`

### 새로 필요한 것 4개

| 타입 | `value` 의미 | 쓰는 갈래 | 비고 |
|---|---|---|---|
| `self_damage_spell` | **주문 위력의 N%** 를 내가 맞는다 | **역류 · 증폭** | 역류의 정체성. 고정 수치는 후반에 무의미해진다 |
| `enemy_heal` | 적을 N 회복시킨다 | 오발 | |
| `shield` | 피해 흡수막 N | 오발 | `effect.dart` 주석에 이미 언급돼 있다 |
| `chain_cast` | 손패의 다른 주문 N개를 추가 시전<br>**음수면 그 주문이 나에게 터진다** | 연쇄 | 스트레이트의 `_autoCastOther`를 재사용할 수 있다 |

### 역류·자해 계산 규칙 (반드시 지킬 것)

1. **기준은 주문 기본 위력(`spellPower`)이며, 시전 강도 배율을 곱하지 않는다.**
   곱하면 전력 시전(3배) 실패가 곧 자살이 되어 아무도 전력을 안 쓴다
2. **자해 피해 상한 = 최대 체력의 40%.** 체력 20 기준 8.
   한 번의 실패로 즉사하면 원칙 2(완전 실패는 드물게)가 무너진다 〔시뮬〕
   - ⚠ **상한은 개별 효과가 아니라 「한 번의 폭주 전체」에 건다.**
     `self_damage_spell` + `self_damage` + 음수 `chain_cast`를 **합산한 뒤** 자른다.
     따로 걸면 효과가 두세 개 붙은 폭주에서 상한이 무의미해진다
   - 방어막은 그 **뒤에** 흡수한다 (자른 값을 `dealToPlayer`에 넘긴다)
3. **역류 갈래에서는** 값을 60~120% 구간에 둔다. 120%는 속성 역류에만 쓴다
   - ⚠ **증폭 갈래도 `self_damage_spell`을 쓴다** (`blast_aftermath`·`overload`, 둘 다 **40%**).
     거기서는 자해가 정체성이 아니라 **큰 위력의 「대가」**이므로 구간이 다르다.
     **증폭의 대가는 30~50%** 로 둔다 (2026-09-02 보강)
4. ⚠ **위력 0인 주문의 최저 기준값 = 4** (2026-09-02 보강)
   - `mana_shield`·`healing_herb`처럼 `base_damage`가 0인 보조 주문이 있다.
     그대로 계산하면 **역류 피해가 0**이 되어, 보조 주문은 실패해도 안전한
     지배 전략이 된다. 폭주 25%가 통째로 무력해진다
   - 따라서 **기준 위력 = `max(spellPower, 4)`** 로 계산한다 〔시뮬〕
   - 나중에 `Spell`에 `circle`을 읽히면 「서클 × 3」 같은 식으로 정교화할 수 있다.
     지금은 상수 하나로 막는다

---

## 5. 80종 전문

`id` / `name`(3~6자) / `text`(8~12자) / `weight` / `effects` 순.
`tags`는 표 제목이 곧 값이다 (`["any"]` 또는 `["fire"]` 등).

### 5.1 `any` — 역류 10종 (합 250)

| id | name | text | w | effects |
|---|---|---|---|---|
| `staff_backflow` | 지팡이 역류 | 마력이 거슬러 오른다 | 35 | `self_damage_spell 100` |
| `grip_burst` | 손아귀 파열 | 손 안에서 먼저 터졌다 | 30 | `self_damage_spell 70`, `mana_change -1` |
| `returned_spell` | 되돌아온 주문 | 주문이 시전자를 골랐다 | 30 | `self_damage_spell 90` |
| `mana_recoil` | 마력 반동 | 밀려난 마력이 나를 친다 | 25 | `self_damage_spell 60`, `self_damage 2` |
| `catalyst_burst` | 터진 촉매 | 품 안의 촉매가 터졌다 | 25 | `self_damage_spell 80` |
| `reversed_circuit` | 역방향 회로 | 회로가 거꾸로 돌았다 | 25 | `self_damage_spell 75`, `mana_change -2` |
| `inverted_glyph` | 뒤집힌 각인 | 각인이 나를 향해 있다 | 20 | `self_damage_spell 110` |
| `swallowed_spell` | 삼켜진 주문 | 주문이 목으로 돌아왔다 | 20 | `self_damage_spell 85`, `seal_spell 1` |
| `cracked_staff` | 균열난 지팡이 | 지팡이가 갈라졌다 | 20 | `self_damage_spell 65`, `seal_spell 1` |
| `self_ward` | 자기 결계 | 결계가 나를 조인다 | 20 | `self_damage_spell 95` |

### 5.2 `any` — 오발 8종 (합 200)

| id | name | text | w | effects |
|---|---|---|---|---|
| `misplaced_blessing` | 빗나간 축복 | 치유가 적에게 붙었다 | 30 | `enemy_heal 6` |
| `hardened_mana` | 굳은 마력 | 터지지 못하고 굳었다 | 30 | `shield 6` |
| `tangled_ward` | 엉킨 결계 | 적이 제 발에 걸렸다 | 25 | `skip_enemy_turn 1` |
| `leaked_mana` | 새어 든 마나 | 빗나간 마력이 돌아왔다 | 25 | `mana_change 2` |
| `misread_glyph` | 오작동 각인 | 각인이 다른 걸 읽었다 | 25 | `extra_die 1` |
| `drawn_vitality` | 흘러든 생기 | 적의 기운이 내게 왔다 | 25 | `heal 5` |
| `swapped_vessel` | 뒤바뀐 그릇 | 상처가 저쪽으로 갔다 | 20 | `swap_hp 1` |
| `wrong_spell` | 잘못 읽은 주문 | 다른 주문이 튀어나왔다 | 20 | `force_reroll 1` |

### 5.3 `any` — 불발 6종 (합 150)

**효과가 비어 있는 것이 정상이다.** `"effects": []`

| id | name | text | w |
|---|---|---|---|
| `dead_ember` | 꺼진 불씨 | 마력이 붙지 않았다 | 30 |
| `empty_swing` | 헛손질 | 허공에서 흩어졌다 | 30 |
| `silent_staff` | 먹통 | 지팡이가 조용하다 | 25 |
| `cut_chant` | 끊긴 주문 | 마지막 음절을 놓쳤다 | 25 |
| `limp_mana` | 늘어진 마력 | 마력이 축 늘어졌다 | 20 |
| `empty_hand` | 빈 손 | 아무것도 나오지 않았다 | 20 |

### 5.4 `any` — 증폭 6종 (합 150)

| id | name | text | w | effects |
|---|---|---|---|---|
| `runaway_power` | 폭주한 위력 | 커진 마력이 나도 밀었다 | 30 | `damage_multiplier 2`, `self_damage 4` |
| `mana_gluttony` | 마력 폭식 | 남은 마나를 전부 삼켰다 | 30 | `damage_multiplier 2`, `mana_change -3` |
| `one_time_flash` | 한 번뿐인 섬광 | 이 주문은 다 타버렸다 | 25 | `damage_multiplier 3`, `seal_spell 1` |
| `overheated_staff` | 과열된 지팡이 | 지팡이가 벌겋게 달았다 | 25 | `damage_multiplier 2`, `self_damage 3` |
| `loss_of_control` | 통제 이탈 | 손을 떠나 제멋대로 갔다 | 20 | `damage_multiplier 3`, `self_damage 6` |
| `blast_aftermath` | 터진 여파 | 여파가 나까지 삼켰다 | 20 | `damage_multiplier 3`, `self_damage_spell 40` |

### 5.5 `any` — 소환 6종 (합 150)

| id | name | text | w | effects |
|---|---|---|---|---|
| `wrong_name` | 잘못 부른 이름 | 부르지 않은 것이 왔다 | 30 | `summon_ally 4` |
| `hand_from_rift` | 틈새의 손 | 균열에서 팔이 나왔다 | 30 | `summon_ally -3` |
| `lingering_echo` | 남은 잔향 | 죽은 주문이 일어섰다 | 25 | `summon_ally 3` |
| `drifting_remnant` | 떠도는 잔재 | 누군가의 잔재가 붙었다 | 25 | `summon_ally -4` |
| `watcher` | 감시자 | 무언가가 나를 지켜본다 | 20 | `summon_ally 5` |
| `open_door` | 열린 문 | 닫히지 않은 문이 있다 | 20 | `summon_ally -5` |

### 5.6 `any` — 연쇄 4종 (합 100)

| id | name | text | w | effects |
|---|---|---|---|---|
| `spreading_fire` | 번진 불 | 옆의 주문에 옮겨붙었다 | 30 | `chain_cast 1` |
| `blast_in_pocket` | 품 안의 폭발 | 손패가 통째로 터졌다 | 25 | `chain_cast -1` |
| `chain_collapse` | 연쇄 붕괴 | 터지자 전부 따라 터졌다 | 25 | `chain_cast 2` |
| `locked_glyphs` | 맞물린 각인 | 각인끼리 서로를 끌었다 | 20 | `chain_cast -2` |

---

### 5.7 `fire` — 화염 8종 (합 120)

| id | name | text | 갈래 | w | effects |
|---|---|---|---|---|---|
| `fire_backfire` | 역화 | 불길이 나를 먼저 안다 | 역류 | 15 | `self_damage_spell 120` |
| `returning_flame` | 되돌아온 화염 | 불이 손목을 타고 왔다 | 역류 | 15 | `self_damage_spell 90`, `self_damage 2` |
| `misguided_flame` | 엉뚱한 불길 | 불이 적을 감싸 지켰다 | 오발 | 12 | `enemy_heal 7` |
| `ash_shell` | 재의 껍질 | 재가 나를 덮었다 | 오발 | 12 | `shield 7` |
| `wet_ember` | 젖은 불씨 | 불이 끝내 안 붙었다 | 불발 | 18 | — |
| `flame_burst` | 화염 폭발 | 불길이 제멋대로 커졌다 | 증폭 | 18 | `damage_multiplier 3`, `self_damage 5` |
| `flame_spirit` | 불꽃 정령 | 불덩이가 형태를 얻었다 | 소환 | 18 | `summon_ally 5` |
| `catching_fire` | 옮겨붙은 불 | 손패까지 불이 번졌다 | 연쇄 | 12 | `chain_cast 1` |

### 5.8 `frost` — 냉기 8종 (합 120)

| id | name | text | 갈래 | w | effects |
|---|---|---|---|---|---|
| `frozen_hands` | 얼어붙은 손 | 손가락이 얼어붙었다 | 역류 | 15 | `self_damage_spell 70`, `seal_spell 1` |
| `reflected_frost` | 되친 서리 | 서리가 나를 먼저 덮었다 | 역류 | 15 | `self_damage_spell 100` |
| `hardened_frost` | 굳은 냉기 | 냉기가 껍질로 굳었다 | 오발 | 12 | `shield 8` |
| `frozen_moment` | 얼어붙은 순간 | 적이 그대로 멈췄다 | 오발 | 12 | `skip_enemy_turn 1` |
| `cooled_mana` | 식은 마력 | 마력이 그대로 식었다 | 불발 | 18 | — |
| `cold_snap` | 한파 | 냉기가 전장을 삼켰다 | 증폭 | 18 | `damage_multiplier 3`, `mana_change -3` |
| `ice_statue` | 얼음 조각상 | 얼음이 일어나 움직인다 | 소환 | 18 | `summon_ally 4` |
| `spreading_frost` | 번진 서리 | 손패까지 얼어붙었다 | 연쇄 | 12 | `chain_cast -1` |

### 5.9 `arcane` — 비전 8종 (합 120)

| id | name | text | 갈래 | w | effects |
|---|---|---|---|---|---|
| `spinning_sigil` | 폭주한 문양 | 문양이 나를 향해 돈다 | 역류 | 15 | `self_damage_spell 95` |
| `leaking_arcana` | 새어 나온 비전 | 비전이 살을 파고든다 | 역류 | 15 | `self_damage_spell 80`, `mana_change -2` |
| `shifted_coords` | 뒤바뀐 좌표 | 주문이 엉뚱한 데 꽂혔다 | 오발 | 12 | `force_reroll 1` |
| `overflowing_mana` | 넘친 마나 | 넘친 마나가 돌아왔다 | 오발 | 12 | `mana_change 3` |
| `broken_circuit` | 끊긴 회로 | 회로가 중간에 끊겼다 | 불발 | 18 | — |
| `overload` | 과부하 | 회로가 한계를 넘었다 | 증폭 | 18 | `damage_multiplier 3`, `self_damage_spell 40` |
| `arcane_afterimage` | 비전 잔상 | 내 잔상이 걸어 나왔다 | 소환 | 18 | `summon_ally 5` |
| `resonance` | 공명 | 손패가 함께 울렸다 | 연쇄 | 12 | `chain_cast 2` |

### 5.10 `shadow` — 그림자 8종 (합 120)

| id | name | text | 갈래 | w | effects |
|---|---|---|---|---|---|
| `shadow_recoil` | 그림자 반동 | 그림자가 주문을 씹었다 | 역류 | 15 | `self_damage_spell 85`, `seal_spell 1` |
| `returning_curse` | 되돌아온 저주 | 저주가 주인을 찾았다 | 역류 | 15 | `self_damage_spell 110` |
| `absorbed_dark` | 빨아들인 어둠 | 어둠이 적을 감쌌다 | 오발 | 12 | `enemy_heal 7` |
| `swallowing_dark` | 삼킨 어둠 | 어둠이 상처를 삼켰다 | 오발 | 12 | `heal 6` |
| `faded_dark` | 꺼진 어둠 | 어둠이 그냥 흩어졌다 | 불발 | 18 | — |
| `deepening_dark` | 짙어진 어둠 | 어둠이 통제를 벗어났다 | 증폭 | 18 | `damage_multiplier 3`, `self_damage 5` |
| `shadow_double` | 그림자 분신 | 내 그림자가 일어섰다 | 소환 | 18 | `summon_ally -5` |
| `spreading_dark` | 번진 어둠 | 손패가 어둠에 잠겼다 | 연쇄 | 12 | `chain_cast -2` |

### 5.11 `nature` — 자연 8종 (합 120)

| id | name | text | 갈래 | w | effects |
|---|---|---|---|---|---|
| `tangling_vines` | 얽힌 덩굴 | 덩굴이 나를 조인다 | 역류 | 15 | `self_damage_spell 75`, `seal_spell 1` |
| `drained_life` | 되돌아온 생명 | 생기가 나를 빨아 갔다 | 역류 | 15 | `self_damage_spell 95` |
| `misgiven_vitality` | 잘못 준 생기 | 생기가 적에게 갔다 | 오발 | 12 | `enemy_heal 8` |
| `bark_growth` | 돋아난 껍질 | 나무껍질이 돋았다 | 오발 | 12 | `shield 7` |
| `withered_spell` | 시든 주문 | 주문이 그대로 시들었다 | 불발 | 18 | — |
| `runaway_growth` | 폭주한 성장 | 덩굴이 전장을 삼켰다 | 증폭 | 18 | `damage_multiplier 3`, `mana_change -3` |
| `awakened_tree` | 깨어난 나무 | 나무가 몸을 일으켰다 | 소환 | 18 | `summon_ally 4` |
| `reaching_roots` | 뻗어나간 뿌리 | 뿌리가 손패를 끌었다 | 연쇄 | 12 | `chain_cast 1` |

---

## 6. 검산

| 갈래 | any 합 | 속성 5종 합 | 총 가중치 | 비율 | 종수 |
|---|---|---|---|---|---|
| 역류 | 250 | 150 | 400 | **25.0%** | 20 |
| 오발 | 200 | 120 | 320 | **20.0%** | 18 |
| 불발 | 150 | 90 | 240 | **15.0%** | 11 |
| 증폭 | 150 | 90 | 240 | **15.0%** | 11 |
| 소환 | 150 | 90 | 240 | **15.0%** | 11 |
| 연쇄 | 100 | 60 | 160 | **10.0%** | 9 |
| **합** | **1000** | **600** | **1600** | **100%** | **80** |

**구현 창 인수 조건**: 데이터를 옮긴 뒤 주문 70종 각각에 대해 갈래별 추첨 비율을 뽑아
**목표와 정확히 일치**해야 한다(위 구조상 오차 0이 나온다). 어긋나면 가중치나 태그가 틀린 것이다.

---

## 7. 구현 창에 넘길 작업 목록

`WORK_ORDER_SURGE.md`로 따로 낸다. 요지만 적으면:

1. `assets/data/surges.json` 80종 전면 교체 (5절 그대로)
2. 새 효과 4종 구현 — `self_damage_spell` · `enemy_heal` · `shield` · `chain_cast`
3. 역류 계산 규칙 3가지 (4절) — 특히 **강도 배율 곱하지 않기**와 **최대 체력 40% 상한**
4. `category` 값 6종 변경에 맞춰 `widgets/surge_popup.dart` 색상표 재작성
5. 폭주 팝업 레이아웃을 **갈래(큰 글씨) → 숫자 → 한 줄**로 변경
6. 검산 테스트 추가 (6절 인수 조건)

---

## 8. 남은 숫자 〔시뮬〕

- 역류 % 값 구간(60~120)과 최대 체력 40% 상한
- 증폭 배율 2·3배와 대가의 균형
- 소환수 위력 3~5와 적대 소환 −3~−5
- `chain_cast` 2개 동시 시전이 너무 센지
