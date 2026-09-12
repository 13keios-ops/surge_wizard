# 몬스터 발주 — **계열 단위** (2026-09-13)

> 요청서 본문은 `art_raw/_compare/v3/PROMPT.md` 다. 여기는 **계열마다 무엇을 넣고
> 무엇을 첨부하는지**만 적는다.

## 🔴 첨부 규칙 — 계열마다 다르다

| 언제 | 무엇을 첨부하나 |
|---|---|
| **그 계열의 첫 장** | `art_raw/_ref/style_goblin_400.png` **한 장만** |
| **둘째 장부터** | `style_goblin_400.png` **＋ 그 계열에서 방금 만든 첫 장** |

**첫 장이 그 계열의 기준이 된다.** 둘째부터 그것을 같이 붙여야 계열 안이 모인다.
화풍 기준은 계속 붙인다 — 빼면 장을 거듭할수록 세밀해진다.

⚠ 🔴 **`art_raw/wizard/_turn_*.png` 를 붙이지 마라.** 그것이 지난번 실패의 원인이다
(고블린보다 3배 세밀하다 — `v3/PROMPT.md`).

---

## 거구 — 색 **#9B5B3C** (적갈)

**4장.** 아래 순서대로. **첫 장은 `enemy_hobgoblin`** 이다.

| 순서 | 파일명 | 이름 | SUBJECT 에 넣을 말 | 첨부 |
|---|---|---|---|---|
| 1 | `enemy_hobgoblin` | 홉고블린 | **배가 앞으로 나온 거구.** 통나무 곤봉. 적갈색 피부 | 화풍 기준만 |
| 2 | `enemy_troll_bruiser` | 트롤 싸움꾼 | **팔이 다리보다 굵고 길어** 땅에 끌린다. 청회색 피부 | 화풍 기준 ＋ `enemy_hobgoblin` |
| 3 | `enemy_ogre_champion` | 오우거 투사 | **배가 앞으로 크게 나왔다.** 쇠몽둥이를 어깨에 걸침. 흙빛 | 화풍 기준 ＋ `enemy_hobgoblin` |
| 4 | `boss_iron_troll` | 무쇠 트롤 (보스) | **몸에 광산 철판을 못으로 박아** 뒀다. 한쪽 팔이 곡괭이와 붙었다 | 화풍 기준 ＋ `enemy_hobgoblin` |

**COLOR 문장**: `the dominant colour is #9B5B3C` + 그 몬스터의 고유 악센트 색
(눈·불씨 등)은 따로 적는다 — 실루엣 연출이 거기에 기댄다.

---

## 로브 — 색 **#8E4FA8** (자주)

**4장.** 아래 순서대로. **첫 장은 `enemy_dark_cultist`** 이다.

| 순서 | 파일명 | 이름 | SUBJECT 에 넣을 말 | 첨부 |
|---|---|---|---|---|
| 1 | `enemy_dark_cultist` | 어둠의 신도 | **후드 안이 어둡고 빛 두 점만.** 제물용 단검. 자주색 로브 | 화풍 기준만 |
| 2 | `enemy_ice_witch` | 얼음 마녀 | **머리에 뾰족한 얼음 왕관.** 창백한 얼굴. 청백 | 화풍 기준 ＋ `enemy_dark_cultist` |
| 3 | `enemy_plague_shaman` | 역병 주술사 | **새부리 가면.** 발밑에 탁한 녹색 안개가 깔린다 | 화풍 기준 ＋ `enemy_dark_cultist` |
| 4 | `boss_archlich` | 대마도사 리치 (보스) | **왕관을 쓴 해골.** 로브가 바닥에 길게 끌린다. 보라 | 화풍 기준 ＋ `enemy_dark_cultist` |

**COLOR 문장**: `the dominant colour is #8E4FA8` + 그 몬스터의 고유 악센트 색
(눈·불씨 등)은 따로 적는다 — 실루엣 연출이 거기에 기댄다.

---

## 뼈 — 색 **#E8E2CF** (뼈흰)

**3장.** 아래 순서대로. **첫 장은 `enemy_skeleton_apprentice`** 이다.

| 순서 | 파일명 | 이름 | SUBJECT 에 넣을 말 | 첨부 |
|---|---|---|---|---|
| 1 | `enemy_skeleton_apprentice` | 견습 해골 | **자기 몸보다 큰 뼈 지팡이**를 힘겹게 든다. 눈구멍 속 파란 불씨 | 화풍 기준만 |
| 2 | `enemy_bone_dragon_whelp` | 새끼 뼈 용 | **살 없는 날개뼈만 남았다.** 뼈 흰색 + 눈구멍에 초록 불 | 화풍 기준 ＋ `enemy_skeleton_apprentice` |
| 3 | `boss_bone_heap` | 뼈무더기 거인 (보스) | **여러 시체의 뼈가 뭉쳐 만들어진 거구.** 갈비뼈 안이 텅 비었다. 이끼 낀 회녹 | 화풍 기준 ＋ `enemy_skeleton_apprentice` |

**COLOR 문장**: `the dominant colour is #E8E2CF` + 그 몬스터의 고유 악센트 색
(눈·불씨 등)은 따로 적는다 — 실루엣 연출이 거기에 기댄다.

---

## 큰 야수 — 색 **#6FA8D6** (백청)

**3장.** 아래 순서대로. **첫 장은 `enemy_wolf_pack`** 이다.

| 순서 | 파일명 | 이름 | SUBJECT 에 넣을 말 | 첨부 |
|---|---|---|---|---|
| 1 | `enemy_wolf_pack` | 늑대 무리 | **두 마리가 앞뒤로 겹쳐** 선다. 곤두선 목덜미 갈기, 노란 눈 | 화풍 기준만 |
| 2 | `boss_sun_sphinx` | 태양의 스핑크스 (보스) | **사자 몸에 석상 얼굴.** 한쪽 날개만 펼쳤다. 금빛 | 화풍 기준 ＋ `enemy_wolf_pack` |
| 3 | `boss_white_wolf` | 눈보라의 흰 늑대 (보스) | **말만큼 크다.** 숨결이 서리로 뿜어진다. 백청 + 붉은 눈 | 화풍 기준 ＋ `enemy_wolf_pack` |

**COLOR 문장**: `the dominant colour is #6FA8D6` + 그 몬스터의 고유 악센트 색
(눈·불씨 등)은 따로 적는다 — 실루엣 연출이 거기에 기댄다.

---

## 석상 — 색 **#C9A96B** (모래황)

**3장.** 아래 순서대로. **첫 장은 `enemy_stone_gargoyle`** 이다.

| 순서 | 파일명 | 이름 | SUBJECT 에 넣을 말 | 첨부 |
|---|---|---|---|---|
| 1 | `enemy_stone_gargoyle` | 석상 가고일 | **한쪽 돌 날개만 펼치고** 한쪽은 접혀 있다. 이끼 낀 회색 | 화풍 기준만 |
| 2 | `enemy_crystal_colossus` | 수정 거상 | **몸 전체가 각진 수정 덩어리.** 안에서 청보라 빛 | 화풍 기준 ＋ `enemy_stone_gargoyle` |
| 3 | `boss_awakened_idol` | 눈을 뜬 거대 석상 (보스) | **사암 신상인데 눈에만 금빛이 들어왔다.** 한쪽 팔이 부서져 있다 | 화풍 기준 ＋ `enemy_stone_gargoyle` |

**COLOR 문장**: `the dominant colour is #C9A96B` + 그 몬스터의 고유 악센트 색
(눈·불씨 등)은 따로 적는다 — 실루엣 연출이 거기에 기댄다.

---

## 갑옷 — 색 **#3FA9A0** (청록)

**3장.** 아래 순서대로. **첫 장은 `enemy_cursed_armor`** 이다.

| 순서 | 파일명 | 이름 | SUBJECT 에 넣을 말 | 첨부 |
|---|---|---|---|---|
| 1 | `enemy_cursed_armor` | 저주받은 갑옷 | **속이 비어 있다.** 투구 틈으로 어둠만 보인다. 창백한 청록 빛 | 화풍 기준만 |
| 2 | `enemy_vampire_knight` | 흡혈 기사 | **깃을 높이 세운 망토.** 안감만 진홍 | 화풍 기준 ＋ `enemy_cursed_armor` |
| 3 | `boss_headless_knight` | 목 없는 검은 기사 (보스) | **머리 자리가 비었고 그 틈이 어둡다.** 대검. 흑철 | 화풍 기준 ＋ `enemy_cursed_armor` |

**COLOR 문장**: `the dominant colour is #3FA9A0` + 그 몬스터의 고유 악센트 색
(눈·불씨 등)은 따로 적는다 — 실루엣 연출이 거기에 기댄다.

---

## 그림자 — 색 **#4A3670** (짙은 보라)

**3장.** 아래 순서대로. **첫 장은 `enemy_wraith`** 이다.

| 순서 | 파일명 | 이름 | SUBJECT 에 넣을 말 | 첨부 |
|---|---|---|---|---|
| 1 | `enemy_wraith` | 원혼 | **하반신이 안개로 흩어져** 다리가 없다. 창백한 청록 | 화풍 기준만 |
| 2 | `enemy_shadow_assassin` | 그림자 암살자 | **얼굴이 없고 눈 자리만 빛난다.** 짙은 보라 | 화풍 기준 ＋ `enemy_wraith` |
| 3 | `boss_void_titan` | 공허의 거인 (보스) | **윤곽만 있고 속이 별 없는 밤하늘이다.** 무채 보라 | 화풍 기준 ＋ `enemy_wraith` |

**COLOR 문장**: `the dominant colour is #4A3670` + 그 몬스터의 고유 악센트 색
(눈·불씨 등)은 따로 적는다 — 실루엣 연출이 거기에 기댄다.

---

## 용·마족 — 색 **#C0342B** (진홍)

**3장.** 아래 순서대로. **첫 장은 `enemy_storm_harpy`** 이다.

| 순서 | 파일명 | 이름 | SUBJECT 에 넣을 말 | 첨부 |
|---|---|---|---|---|
| 1 | `enemy_storm_harpy` | 폭풍 하피 | **팔이 그대로 날개다.** 발톱이 크다. 짙은 남색 깃 | 화풍 기준만 |
| 2 | `enemy_demon_gatekeeper` | 마계 문지기 | **뿔이 좌우 다르게** 났다. 삼지창. 검붉은 피부 | 화풍 기준 ＋ `enemy_storm_harpy` |
| 3 | `boss_inferno_dragon` | 겁화의 화염룡 (보스) | **가장 크게.** 긴 목과 펼친 날개의 실루엣. 적 | 화풍 기준 ＋ `enemy_storm_harpy` |

**COLOR 문장**: `the dominant colour is #C0342B` + 그 몬스터의 고유 악센트 색
(눈·불씨 등)은 따로 적는다 — 실루엣 연출이 거기에 기댄다.

---

## 젤리 — 색 **#8FD94A** (연두)

**2장.** 아래 순서대로. **첫 장은 `enemy_green_slime`** 이다.

| 순서 | 파일명 | 이름 | SUBJECT 에 넣을 말 | 첨부 |
|---|---|---|---|---|
| 1 | `enemy_green_slime` | 초록 슬라임 | **몸에 비해 지나치게 큰 눈 하나.** 반투명 젤리 덩어리. 연두 | 화풍 기준만 |
| 2 | `boss_elder_slime` | 태고의 슬라임 (보스) | 슬라임인데 **몸 안에 삼킨 뼈와 부러진 검이 비쳐 보인다.** 눈이 셋. 짙은 청록 | 화풍 기준 ＋ `enemy_green_slime` |

**COLOR 문장**: `the dominant colour is #8FD94A` + 그 몬스터의 고유 악센트 색
(눈·불씨 등)은 따로 적는다 — 실루엣 연출이 거기에 기댄다.

---

## 양서류 — 색 **#7A8C3A** (황록)

**2장.** 아래 순서대로. **첫 장은 `enemy_swamp_toad`** 이다.

| 순서 | 파일명 | 이름 | SUBJECT 에 넣을 말 | 첨부 |
|---|---|---|---|---|
| 1 | `enemy_swamp_toad` | 늪 두꺼비 | **몸통이 거의 전부 입이다.** 혀가 밖으로 늘어져 있다. 젖은 광택 | 화풍 기준만 |
| 2 | `boss_bog_toad` | 독안개 두꺼비 (보스) | **등에 독주머니 혹**이 여럿. 입에서 녹색 안개가 샌다. 탁한 황록 | 화풍 기준 ＋ `enemy_swamp_toad` |

**COLOR 문장**: `the dominant colour is #7A8C3A` + 그 몬스터의 고유 악센트 색
(눈·불씨 등)은 따로 적는다 — 실루엣 연출이 거기에 기댄다.

---

## 식물 — 색 **#2E6B34** (진초록)

**2장.** 아래 순서대로. **첫 장은 `enemy_mushroom_sprite`** 이다.

| 순서 | 파일명 | 이름 | SUBJECT 에 넣을 말 | 첨부 |
|---|---|---|---|---|
| 1 | `enemy_mushroom_sprite` | 버섯 정령 | **갓이 몸통보다 크다.** 갓 그늘 아래 눈 두 점. 붉은 갓에 흰 반점 | 화풍 기준만 |
| 2 | `boss_burning_treant` | 불타는 나무 거인 (보스) | **몸이 숯이고 갈라진 틈마다 잉걸불.** 한쪽 팔만 가지처럼 길게 뻗었다 | 화풍 기준 ＋ `enemy_mushroom_sprite` |

**COLOR 문장**: `the dominant colour is #2E6B34` + 그 몬스터의 고유 악센트 색
(눈·불씨 등)은 따로 적는다 — 실루엣 연출이 거기에 기댄다.

---

## 소형 야수 — 색 **#C08A8A** (회분홍)

**2장.** 아래 순서대로. **첫 장은 `enemy_cave_rat`** 이다.

| 순서 | 파일명 | 이름 | SUBJECT 에 넣을 말 | 첨부 |
|---|---|---|---|---|
| 1 | `enemy_cave_rat` | 동굴 쥐 | **앞니가 얼굴의 절반.** 회갈색 털, 분홍 꼬리 | 화풍 기준만 |
| 2 | `enemy_bat_swarm` | 박쥐 떼 | **세 마리가 한 덩어리로 뭉쳐** 있다. 어둠 속에 눈만 빛난다 | 화풍 기준 ＋ `enemy_cave_rat` |

**COLOR 문장**: `the dominant colour is #C08A8A` + 그 몬스터의 고유 악센트 색
(눈·불씨 등)은 따로 적는다 — 실루엣 연출이 거기에 기댄다.

---

## 소형 인간형 — 색 **#D4A017** (겨자)

**2장.** 아래 순서대로. **첫 장은 `enemy_goblin_scout`** 이다.

| 순서 | 파일명 | 이름 | SUBJECT 에 넣을 말 | 첨부 |
|---|---|---|---|---|
| 1 | `enemy_goblin_scout` | 고블린 정찰병 | **귀가 얼굴보다 크다.** 작은 단검, 겨자색 두건 | 화풍 기준만 |
| 2 | `enemy_orc_warrior` | 오크 전사 | **아래턱 송곳니가 코까지 올라온다.** 어깨가 머리 두 배. 녹슨 도끼 | 화풍 기준 ＋ `enemy_goblin_scout` |

**COLOR 문장**: `the dominant colour is #D4A017` + 그 몬스터의 고유 악센트 색
(눈·불씨 등)은 따로 적는다 — 실루엣 연출이 거기에 기댄다.

---

## 불 — 색 **#F07020** (주황)

**2장.** 아래 순서대로. **첫 장은 `enemy_fire_elemental`** 이다.

| 순서 | 파일명 | 이름 | SUBJECT 에 넣을 말 | 첨부 |
|---|---|---|---|---|
| 1 | `enemy_fire_elemental` | 화염 정령 | **형태가 불꽃 그 자체.** 가운데 핵만 밝다. 주황 | 화풍 기준만 |
| 2 | `enemy_lava_golem` | 용암 골렘 | **돌 틈새마다 용암이 갈라져 빛난다.** 붉은 균열 | 화풍 기준 ＋ `enemy_fire_elemental` |

**COLOR 문장**: `the dominant colour is #F07020` + 그 몬스터의 고유 악센트 색
(눈·불씨 등)은 따로 적는다 — 실루엣 연출이 거기에 기댄다.

---

---

## ⚠ 설명의 색과 계열 색이 부딪히는 곳

`ASSET_LIST.md` 의 설명에는 **옛 색**이 적혀 있다. 계열 설계 전에 쓴 것이다.

🔴 **계열 색이 우선한다.** 아래 항목은 SUBJECT 에 넣을 때 **설명에서 색 낱말을 빼라.**
안 그러면 모델이 둘 사이에서 헤맨다.

| 계열 (색) | 몬스터 | 설명에 적힌 색 |
|---|---|---|
| 갑옷 (청록) | `boss_headless_knight` 목 없는 검은 기사 | 검 |
| 갑옷 (청록) | `enemy_vampire_knight` 흡혈 기사 | 진홍 |
| 거구 (적갈) | `enemy_ogre_champion` 오우거 투사 | 흙빛 |
| 거구 (적갈) | `enemy_troll_bruiser` 트롤 싸움꾼 | 청회 |
| 그림자 (짙은 보라) | `enemy_wraith` 원혼 | 백·청록 |
| 로브 (자주) | `boss_archlich` 대마도사 리치 | 보라 |
| 로브 (자주) | `enemy_ice_witch` 얼음 마녀 | 백·청백 |
| 로브 (자주) | `enemy_plague_shaman` 역병 주술사 | 녹색 |
| 불 (주황) | `enemy_lava_golem` 용암 골렘 | 붉 |
| 뼈 (뼈흰) | `enemy_skeleton_apprentice` 견습 해골 | 파란 |
| 석상 (모래황) | `boss_awakened_idol` 눈을 뜬 거대 석상 | 금빛 |
| 석상 (모래황) | `enemy_stone_gargoyle` 석상 가고일 | 회색 |
| 석상 (모래황) | `enemy_crystal_colossus` 수정 거상 | 보라 |
| 식물 (진초록) | `enemy_mushroom_sprite` 버섯 정령 | 붉·흰 |
| 용·마족 (진홍) | `enemy_demon_gatekeeper` 마계 문지기 | 검·붉 |
| 젤리 (연두) | `boss_elder_slime` 태고의 슬라임 | 검·청록 |
| 큰 야수 (백청) | `boss_sun_sphinx` 태양의 스핑크스 | 금빛 |

**17건.** 나머지는 설명과 계열 색이 어긋나지 않는다.

> **예외 하나**: 「눈·불씨·균열」처럼 **작은 악센트**의 색은 남긴다.
> 실루엣 연출이 거기에 기댄다 (`GAME_DESIGN.md` 6.7절 ②).
