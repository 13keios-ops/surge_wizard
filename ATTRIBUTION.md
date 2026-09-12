# ATTRIBUTION — 외부 에셋 출처

> **현재 상태 (2026-09-05):** 게임 화면의 그림은 대부분 `lib/art/` 의
> **자체 제작 픽셀아트**이고, 2026-09-05부터 **원화 1장(마법사 뒷모습)**이
> `assets/art/` 에 함께 들어간다. 외부에서 온 것은 **한글 픽셀 폰트**와
> **그 원화**이며 아래에 기록한다.

---

# 폰트 — Galmuri (갈무리)

| 항목 | 내용 |
|---|---|
| 이름 | Galmuri (갈무리) — 사용 파일: `Galmuri11`, `Galmuri11 Bold`, `Galmuri9` |
| 작가 | Lee Minseo (quiple) — quiple@quiple.dev |
| 저작권 | Copyright © 2019–2025 Lee Minseo |
| 라이선스 | **SIL Open Font License 1.1 (OFL 1.1)** — 상업적 사용·번들·재배포 허용 |
| 출처 | https://github.com/quiple/galmuri (릴리스 `v2.40.4`) |
| 라이선스 원문 | https://github.com/quiple/galmuri/blob/main/ofl.md — 사본을 `assets/fonts/OFL.md` 에 함께 넣었다 |
| 받은 날짜 | 2026-09-01 |
| 확인한 것 | 위 라이선스 페이지를 직접 열어 OFL 1.1 임을 확인했다 |

**변경 사항**: 앱 용량을 줄이려고 `fontTools.subset` 으로 **한글·라틴·기호 영역만
남기고 가나·한자를 덜어냈다** (12.6MB → 7.5MB). OFL은 변경·재배포를 허용하며,
파생본에 예약 이름(Reserved Font Name)을 쓰지 못하게 할 뿐인데 Galmuri는 예약
이름을 지정하지 않았다. 원본 파일은 위 릴리스에서 언제든 다시 받을 수 있다.

기준 픽셀 크기: Galmuri11 = 12px, Galmuri9 = 10px.
**정수 배율에서만 또렷하므로** 화면에서 쓰는 글자 크기를 12·24·36·48·84 와
10·20·30 으로 제한했다 (`lib/widgets/pixel_ui.dart` 의 `kFont11` / `kFont9`).

---

# (대체됨) 원화 — 마법사 뒷모습 v1 (Phase 1)

> ⛔ **2026-09-07, Phase 1.5 가 같은 경로를 덮어썼다.** 아래 「원화 — Phase 1.5 3장」이
> 지금 게임에 들어 있는 것이다. 이 절은 기록으로만 남긴다.

| 항목 | 내용 |
|---|---|
| 게임용 파일 | `assets/art/wizard/body_back.webp` (512×512) |
| 원본 | `art_raw/wizard/_turn_back.png` (316×618) — 4방향 시트에서 잘라 낸 뒷모습 |
| 만든 방법 | **사용자가 ChatGPT 이미지 생성(DALL·E)으로 직접 뽑았다.** 시트 메타데이터 `art_raw/wizard/라벤더_머리_마법사_스프라이트_시트.metadata.json` 의 `dalle_metadata.gen_id` = `fb934984-9ff4-4db9-98b0-05af693c0f1b` |
| 권리 | 사용자 본인이 생성한 이미지. **상업 이용 가능 여부는 사용자가 2026-09-01에 확인했다** (`HANDOFF.md` 7-6절 · `UI_DESIGN.md` 3-3절) |
| 후처리 | `tool/bake_art.py` — 알파 경계 크롭 · 512×512 정규화 · 알파 250↑ 스냅 · 무손실 WebP. **색을 줄이거나 외곽선을 더하지 않는다** |
| 들인 날짜 | 2026-09-05 (그래픽 Phase 1) |

> ⚠ **아직 안 정해진 것** — 앞으로 **ComfyUI**로 뽑을 에셋은 얹는
> 체크포인트·LoRA·IPAdapter마다 라이선스가 따로다. 위 확인은 **여기에 적용되지
> 않는다.** 뽑기 전에 정해서 이 문서에 적어야 한다 (`HANDOFF.md` 7-6절).

---

# 원화 — Phase 1.5 3장 (마법사 · 고블린 정찰병 · 숲 배경)

전투 화면 한 장을 통째로 원화로 세운 세 장이다 (`WORK_ORDER_ART_PHASE1_5.md`).

| 항목 | 내용 |
|---|---|
| 게임용 파일 | `assets/art/wizard/body_back.webp` (512×512)<br>`assets/art/enemy/goblin_scout.webp` (512×512)<br>`assets/art/bg/forest.webp` (1024×1536) |
| 원본 | `art_raw/phase1_5_assets/wizard_back.png`<br>`art_raw/phase1_5_assets/enemy_goblin_scout.png`<br>`art_raw/phase1_5_assets/bg_forest.png` (전부 원본 크기 그대로) |
| 만든 방법 | **사용자가 ChatGPT 이미지 생성으로 직접 뽑았다** (2026-09-07 사용자 확인). 요청서는 `ART_REQUEST_PHASE1_5.md`, 생성기가 남긴 규격 메타데이터는 각 파일 옆 `*.metadata.json` |
| 권리 | 사용자 본인이 생성한 이미지. **상업 이용 가능 여부는 사용자가 2026-09-01에 확인했다** — 위 「마법사 뒷모습 v1」 절과 **같은 권리 근거**다 (`HANDOFF.md` 7-6절 · `UI_DESIGN.md` 3-3절) |
| 후처리 | `tool/bake_art.py` — **알파 250↑ 스냅 + 무손실 WebP, 그 둘뿐이다.** 🔴 **크기를 건드리지 않는다** (원화가 7px·2px 정사각 블록으로 그려져 있어 정수배 아닌 리샘플은 격자를 깬다). 색 줄이기·외곽선 추가·알파 이진화도 하지 않는다 |
| 들인 날짜 | 2026-09-07 (그래픽 Phase 1.5) |

> ⚠ 위 ComfyUI 경고문은 **여전히 유효하다.** Phase 2(지팡이)부터 ComfyUI를 쓴다면
> 뽑기 전에 체크포인트·LoRA 라이선스를 정해 이 문서에 적어야 한다.

---

# 생성 도구 — sprite-gen + codex (2026-09-12 설치)

> 절대 규칙 6이 요구하는 확인이다. **도구의 라이선스와 산출물의 라이선스는 별개다.**

## 도구

| 이름 | 라이선스 | 확인 | 비고 |
|---|---|---|---|
| **sprite-gen** v2.2.0 | **Apache-2.0** | 2026-09-12, 저장소 `LICENSE` 원문 | `github.com/aldegad/sprite-gen`. 설치 위치 `~/.claude/skills/sprite-gen`.<br>**그림을 만들지 않는다** — 프롬프트를 제공자에게 넘기고 잘라내기·격자·아틀라스만 한다 |
| ffmpeg | (시스템 설치) | — | 영상 → 프레임. 산출물에 코드가 안 들어간다 |

`NOTICE`에 적힌 이식 출처 셋은 전부 허용 라이선스다 — perfectpixel-studio(**MIT**)의
정렬·분할·크로마 매팅 이식, hatch-pet(**Apache-2.0**) 워크플로 영감.

## 🔴 산출물을 만드는 쪽 — 여기가 진짜 판단 지점

| 제공자 | 무엇 | 지금 상태 | 산출물 권리 |
|---|---|---|---|
| **`codex`** | ChatGPT 이미지 생성 (OAuth) | **ready** | 🔴 **OpenAI 이용약관을 따른다.** 사용자가 지금 ChatGPT 창에서 직접 받는 것과 **같은 계정·같은 모델**이다 |
| `grok` | xAI Imagine | unavailable (계정 미연결) | 쓰게 되면 그때 xAI 약관을 확인해 여기 적는다 |

**Claude는 제공자가 될 수 없다** — 이미지 생성 모델이 없다. 도구를 부리는 것만 한다.

> ### 이 도구가 라이선스 상황을 바꾸지 않는다
> 지금도 사용자가 ChatGPT에서 손으로 받고 있다. sprite-gen은 **그 왕복을 자동화할 뿐**
> 그림의 출처가 바뀌지 않는다. 따라서 **새로 생기는 라이선스 위험이 없다.**
> 바뀌는 순간은 `grok`이나 다른 제공자를 켤 때다. **그때 이 표를 갱신한다.**

---

# 생성 파이프라인 — ComfyUI + 모델 가중치 (2026-09-07 확인)

`GAME_DESIGN.md` 14절 18번 · 절대 규칙 6이 요구하는 확인이다.
**ComfyUI는 껍데기일 뿐이고, 상업 이용 가부는 얹는 가중치마다 따로 정해진다.**
아래는 **에셋을 뽑기 전에** 원문을 직접 열어 확인한 결과다.

## 도구

| 이름 | 라이선스 | 확인 | 비고 |
|---|---|---|---|
| **ComfyUI** | **GPL-3.0** | 2026-09-07, GitHub 저장소 원문 | 무료 오픈소스. **도구라 산출물에 라이선스가 옮겨붙지 않는다.**<br>유료는 선택 사항(Comfy Cloud · 외부 API 노드)이며 **`--disable-api-nodes`로 오프라인 강제 가능** |
| ComfyUI-Manager | GPL-3.0 | 2026-09-07 | 플러그인 관리 |
| ComfyUI_IPAdapter_plus | GPL-3.0 | 2026-09-07 | 스타일 유지 (로드맵 8절) |
| comfyui_controlnet_aux | Apache-2.0 | 2026-09-07 | 전처리기. 로드맵상 **필요할 때만** |

## 🔴 모델 가중치 — 여기가 진짜 판단 지점

| 가중치 | 출처 | 라이선스 | 상업 이용 |
|---|---|---|---|
| **SDXL Base 1.0** | `stabilityai/stable-diffusion-xl-base-1.0` | **CreativeML Open RAIL++-M** | ✅ **가능** |
| **IP-Adapter SDXL** (`ip-adapter_sdxl` · `ip-adapter-plus_sdxl_vit-h`) | `h94/IP-Adapter` | **Apache-2.0** | ✅ 가능 |
| **CLIP-ViT-H-14 / bigG-14 image encoder** | `h94/IP-Adapter` | **Apache-2.0** | ✅ 가능 |
| **ControlNet Canny SDXL** | `xinsir/controlnet-canny-sdxl-1.0` | **Apache-2.0** | ✅ 가능 |

### CreativeML Open RAIL++-M 의 핵심 두 줄 (원문 확인)

- **산출물 소유권**: *"Except as set forth herein, Licensor claims no rights in the
  Output You generate using the Model."* → **우리가 뽑은 그림에 대해 권리를 주장하지 않는다**
- **상업 이용**: 로열티 없는 영구·전세계·비독점 라이선스를 부여하며 SaaS 형태의
  호스팅까지 허용한다. **금지 목록(Attachment A)은 전부 「해로운 용도」**(허위정보로
  타인을 해치기, 미성년자 착취, 차별적 활용 등)이며 **게임 원화 제작과 무관하다**

### 🔴 이 표에 없는 것을 얹지 마라

**체크포인트·LoRA·머지 모델을 새로 추가하면 그때 라이선스를 다시 확인하고
이 표에 줄을 추가한다.** 커뮤니티 머지 모델과 LoRA 중에 **비상업 한정**이 섞여 있다.
다 뽑고 나서 알면 **전부 다시 뽑아야 한다.**

---

# (보관) game-icons.net 아이콘 출처

이 게임의 모든 아이콘은 [game-icons.net](https://game-icons.net)의
작품이며 [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/)
라이선스를 따른다. 작가별 사용 아이콘 목록:

## badges (1개)

sun

## carl-olsen (1개)

flame

## cathelineau (1개)

witch-face

## darkzaitzev (2개)

cauldron, hooded-assassin

## delapouite (41개)

bat, black-knight-helm, bracer, cape, chalk-outline-murder, column-vase, dice-shield, dice-six-faces-six, dice-six-faces-three, dice-twenty-faces-one, dice-twenty-faces-twenty, dragon-shield, frozen-body, gargoyle, gauntlet, giant, gloves, goblin-head, gold-nuggets, heart-wings, herbs-bundle, horseshoe, night-sleep, notebook, ogre, orc-head, plague-doctor-profile, prism, prisoner, rabbit, rat, ring, rock-golem, rolling-dices, slime, spear-feather, stone-pile, two-coins, vampire-cape, winter-hat, wizard-face

## faithtoken (1개)

dragon-head

## lorc (84개)

anvil-impact, beam-wake, beams-aura, beanstalk, bee, belt-buckles, bookmarklet, burning-dot, cat, clover, cold-heart, compass, crowned-skull, crystal-ball, crystal-cluster, cultist, curled-leaf, cursed-star, daemon-skull, dark-squad, dragon-breath, droplet-splash, duality, earth-spit, eclipse, feather, fire-dash, fire-ring, fire-shield, fire-silhouette, fireball, flaming-arrow, frog, frozen-arrow, frozen-block, frozen-orb, ghost, glowing-hands, gluttonous-smile, grab, grim-reaper, hand, harpy, heat-haze, hourglass, ice-bolt, ice-spear, icicles-aura, icicles-fence, incense, insect-jaws, laser-blast, life-tap, lightning-storm, meteor-impact, mirror-mirror, missile-swarm, mushroom, oak, perfume-bottle, quake-stomp, root-tip, rune-stone, sands-of-time, serrated-slash, shield-echoes, snowing, sparky-bomb, spectre, spiked-tentacle, star-swirl, stone-throne, teapot, tentacle-strike, third-eye, thorny-vine, time-trap, tornado, unstable-orb, vine-whip, vortex, walking-boot, whip, wolf-head

## lucasms (1개)

belt

## sbed (1개)

lava

## skoll (3개)

fangs, skeleton, troll

