# surge_wizard 게임 아트 파이프라인 — 최종 로드맵

> ## 🔴 2026-09-05 개정 — Phase 1 결과로 **순서가 바뀌었다**
> **Phase 1은 코드는 통과, 화면은 반려됐다** (`reports/27_*` 9절).
> **반려된 것은 화면이지 원화 화풍이 아니다** — 사용자 말은
> 「마법사 원화 퀄에 비해 나머지가 다 떨어져서 별로다」였다.
> **원화 화풍은 좋고, 그것이 이후 모든 에셋의 기준이다.**
>
> 원인은 **칸 밀도가 7.7배 다른 것**이다 (칸 대 칸) —
> 코드 도트는 한 칸 **2.96dp**(48칸), 원화는 한 칸 **0.383dp**(**308칸**).
> **적과 배경이 코드 도트로 남아 있는 한 어떤 원화를 넣어도 화면이 통일되지 않는다.**
>
> → **Phase 1.5(Scene Proof)를 신설**해 **적 1종 + 배경 1장**을 앞으로 당겼다.
> **지팡이(Phase 2)는 그 뒤다.** 13-5절 · 24절.
>
> **번호는 다시 매기지 않았다** — 기존 문서·보고서의 참조가 깨지지 않게 하려는 것이다.
> 이 개정판은 **기획 창이 사용자 지시로 고친 것**이며, 원본은 `Z:` 패키지에 있다.

## 0. 목적
이 문서는 `surge_wizard` 저장소의 현재 구조를 기준으로 그래픽 에셋을 단계적으로 교체·확장하는 실행 로드맵이다.

핵심 원칙:
1. 지금 필요한 것만 만든다.
2. 현재 Flutter 구조와 이미 검증된 방식은 최대한 재사용한다.
3. 캐릭터/장비/배경/UI를 한 번에 자동화하지 않는다.
4. 각 Phase에서 실제 화면에 넣어 확인한 뒤 다음 단계로 간다.
5. 사용자는 시각적 품질만 판단하고, 규격·파일·코드·테스트 검증은 Claude가 맡는다.
6. 신규 카테고리의 첫 기준 에셋은 반드시 사용자 승인 후 `approved` 기준으로 삼는다.

## 1. Source of Truth
그래픽 관련 판단 우선순위:
1. `GAME_DESIGN.md`
2. `UI_DESIGN.md`
3. `ASSET_LIST.md`
4. `ASSET_LIST_EQUIP.md`
5. `ASSET_LIST_BG.md`
6. 이 패키지의 신규 아트 문서
7. `art_raw/README.md`

현재 그래픽 구현 기준으로 사용하지 않을 것:
- `ART_PIPELINE.md`
- `GRAPHICS_PLAN.md`
- `WORK_ORDER_ART_PIPELINE.md`의 96×96 / 강제 양자화 / alpha 이진화 규칙

## 2. 현재 게임 아트 방향
- 캐릭터 / 적 / 보스 / 배경: 외부 원화 기반
- 버튼 / 패널 / 텍스트 / 기본 UI: Flutter 기반
- 폰트: Galmuri
- 전투 이펙트: 원화 + Flutter 코드 혼합
- UI 전체를 이미지로 교체하지 않는다.

## 3. 원본과 게임용 결과물 분리
### 원본
- 큰 무손실 PNG
- 실제 알파 채널
- 크기 유동적
- `art_raw/` 보관

### 게임용
- 캐릭터/장비 canonical canvas: **512×512**
- 후처리 후 WebP 사용 가능
- `assets/art/`에 배치

흐름:
`큰 원본 PNG → 정규화/후처리 → 512×512 게임용 에셋`

## 4. 캐릭터 구조
복잡한 skeleton 시스템을 만들지 않는다.

`Character Identity + View/Pose + Equipment Layer + Runtime Correction`

초기 View/Pose:
- `wizard_front_idle`
- `wizard_back_idle`
- `wizard_back_staff_idle`

`wizard_back_staff_idle`에는 실제 지팡이를 그리지 않는다. 손과 팔만 grip 자세로 만든다.

아직 만들지 않는다:
- Pose Family framework
- onehand / twohand / spear / ranged
- 복잡한 skeleton
- 다수의 anchor

## 5. 장비 정렬
기본 보정:
- `dx`
- `dy`
- `scale`

복잡한 anchor 시스템은 만들지 않는다.
향후 자동 정렬이 정말 필요해질 때 최소 landmark(`root`, `right_hand_grip`)만 추가 검토한다.

## 6. Layer 정책
처음에는 `body → equipment`.

실제 문제가 생길 때만 확장:
- 손 가림: `body → staff → hand_front`
- 무기 앞뒤 교차: `staff_rear → body → staff_front → hand_front`
- 로브 앞뒤 교차: `robe_back → body → robe_front`
- 모자/머리 충돌: 필요 시 `hat_back / hat_front / mask`

## 7. 기존 Flutter 애니메이션 재사용
현재 BattleStage의:
- 숨쉬기
- 시전 기울기
- 피격 flash
- 피격 squash
- knockback
- ambient movement

을 최대한 재사용한다.
Phase 0~7에서는 별도 idle/walk/cast 프레임 애니메이션을 만들지 않는다.

## 8. 생성 파이프라인
사용자 요청
→ Claude가 최신 프로젝트 규칙 확인
→ 승인 레퍼런스 확인
→ 에셋 prompt 작성
→ ComfyUI 생성
→ 후보 1~4개
→ 기본 규격 검사
→ 실제 게임 합성 preview
→ Claude 기술 검수
→ 사용자 비교 sheet 승인
→ approved asset
→ compact metadata + generation recipe + checksum

### IPAdapter
스타일 유지용. `wizard_body`와 같은 카테고리의 승인 에셋을 우선 참조한다.

### ControlNet
기본 필수가 아니다. 자세/길이/실루엣이 반복적으로 흔들릴 때만 사용한다.

## 9. 후보 개수
- 쉬운 에셋: 1~2개
- 선택이 필요한 에셋: 3~4개

사용자에게는 가능하면 한 장의 contact sheet로 보여준다.

## 10. 사용자 역할
사용자는 다음 네 가지만 판단한다.
1. 같은 캐릭터/같은 게임처럼 보이는가
2. 장비가 자연스럽게 붙어 있는가
3. 얼굴/몸을 가리는 어색함이 있는가
4. 전체적으로 마음에 드는가

규격·alpha·파일·코드·테스트 검증은 Claude가 맡는다.

## 11. 메타데이터
기존 장문의 metadata를 모든 파일마다 반복하지 않는다.
스타일 설명은 공통 문서에 한 번만 둔다.

승인 에셋에는 최소 recipe만 저장한다.

예:
```json
{
  "id": "staff_c_knotted",
  "type": "staff",
  "view": "back",
  "pose": "staff_idle",
  "workflow": "staff_v1",
  "seed": 123456,
  "dx": 2,
  "dy": -3,
  "scale": 1.04,
  "approved": true,
  "sha256": "..."
}
```

## 12. Phase 0 — 문서/규격 정리
목표: 신구 그래픽 문서 충돌 제거.

해야 할 일:
- `UI_DESIGN.md`를 현재 runtime 기준으로 유지
- 배경 개수 등 최신 정보가 `ASSET_LIST_BG.md`와 맞는지 확인
- 96×96 / 강제 palette / alpha 이진화 규칙을 구형으로 명확히 표기
- 신규 로드맵을 Source of Truth 목록에 추가

완료 조건:
새 그래픽 작업 창이 최신 문서만 읽고 같은 결론을 낼 수 있다.

## 13. Phase 1 — Runtime Proof  ⚠ **코드 통과 / 그림 반려** (2026-09-05)
목표: 외부 원화 마법사 1장을 실제 전투 화면에 넣는다.

작업:
- `wizard_back` 원화 준비
- Flutter assets 등록
- BattleStage에서 기존 `kSpriteWizardBack` 대신 원화 표시
- 기존 PixelSprite는 fallback 유지
- 현재 Transform 효과 그대로 적용

사용자 확인:
기존 전투 화면 vs 새 원화 전투 화면 비교.

완료 조건:
외부 원화가 실제 게임에서 자연스럽게 표시된다.

### 13-5. 🔴 결과와 배운 것 (2026-09-05)

| | |
|---|---|
| **코드** | ✅ 통과. 원화가 뜨고, 기존 Transform 연출이 그대로 돈다. fallback도 산다 |
| **그림** | ⛔ **반려.** 마법사 몸은 **`approved` 가 아니다** |

**이 완료 조건이 잘못 끊겨 있었다.**
「마법사 1장을 세운다」로 증명되는 것은 **「코드가 원화를 띄우는가」**뿐이다.
**「화면이 하나로 보이는가」는 이 구성으로 애초에 판정할 수 없다** —
옆에 선 적과 배경이 아직 코드 도트이기 때문이다.

**실측 (기획 창 재현 완료)**

| | 화면에서 한 칸 |
|---|---|
| 적·배경 (코드 도트, 48칸 격자 → 상자 142dp) | **2.96 dp** (48칸) |
| 마법사 원화 (블록 2px → 512 캔버스 → 상자 142dp) | **0.383 dp** (**308칸**) |
| | **7.7배** |

> ⚠ 보고서의 「10배」는 코드의 한 *칸*과 원화의 원본 *1픽셀*을 견준 값이다.
> **원화의 한 칸은 원본 2px**이므로 같은 단위로는 **7.7배**다.

**교훈**: **한 요소만 바꿔서는 「화면이 통일됐는가」를 판정할 수 없다.**
판정하려면 **그 화면을 이루는 요소를 한꺼번에** 바꿔야 한다.

> **반대 방향(원화를 굵은 픽셀로 뭉개 코드 도트에 맞추기)은 하지 않는다.**
> 「원화를 그대로 크게 쓴다」는 v2 결정을 되돌리는 것이고,
> **지팡이 v2·v3를 죽인 바로 그 처리**다 (`CLAUDE.md` LESSONS 2026-09-04).

## 13.5. ★ Phase 1.5 — Scene Proof (한 화면을 통째로 원화로)  🔴 신설

**목표: 전투 화면 한 장이 「하나의 게임」으로 보이는가를 처음으로 판정한다.**

이것이 **원화 방향 전체의 관문**이다. 여기서 막히면 지팡이를 15종 뽑은 뒤에
아는 것보다 싸게 끝난다.

### ★ 밀도 기준 — **화면 한 칸 = 2.0 px** (2026-09-05 사용자 확정)

| 자산 | 캔버스 | 화면 | **논리 칸** | 캔버스 안 한 칸 |
|---|---|---|---|---|
| 마법사 | 512² | 118px | **59칸** | 7.2px |
| 일반 적 | 512² | 118px | **59칸** | 7.2px |
| 배경 | 1080×1920 | 채움 | **540×960칸** | 2.0px |

**상세는 `UI_DESIGN.md` 1-2-b절.** 지금 마법사 원화는 **한 칸 0.383dp**로
자기 격자가 뭉개져 있다 — **마법사도 이 기준으로 다시 뽑는다.**

작업:
- **마법사 뒷모습 재생성** — 59칸 기준 (지금 것은 **308칸**이라 뭉개진다).
  ⚠ **화풍은 그대로.** 바꾸는 것은 칸 밀도뿐이다
- **일반 적 1종** 원화 — 같은 기준
- **배경 1장** 원화 — 같은 기준
- 셋을 한 전투 화면에 올린다 (**띄우는 코드는 Phase 1에서 이미 됐다**)
- 기존 화면 vs 새 화면 비교 시트

**⚠ 이 셋은 같은 밀도 기준으로 동시에 뽑는다.** 하나씩 뽑아 붙이면
Phase 1과 똑같이 「하나만 매끈한 화면」이 또 나온다.

완료 조건:
**전투 화면 한 장이 하나의 게임처럼 보인다.**

승인 대상 (23절):
- 마법사 몸 (Phase 1에서 반려됐으므로 **여기서 다시 판정**)
- **일반 적 첫 1종**
- **배경 첫 1장**

**여기서 막히면**: 지팡이·모자·로브·나머지 적·보스를 **한 장도 뽑지 않는다.**
밀도 기준을 고쳐 다시 이 세 장만 뽑는다.

## 14. Phase 2 — Staff Proof  *(Phase 1.5 승인 뒤에 시작한다)*
목표: 장비 교체 구조를 지팡이 1종으로 증명.

작업:
- 지팡이가 없는 `wizard_back_staff_idle`
- 지팡이 1종 독립 에셋
- body + staff 합성
- `dx/dy/scale` 조정
- 실제 전투 화면 확인

처음 layer:
`body → staff`

문제가 있을 때만:
- `hand_front`
- `staff_rear`
- `staff_front`

완료 조건:
지팡이 1종이 안정적으로 장착된다.

## 15. Phase 3 — Repeatability
목표: 같은 방식이 다른 지팡이에도 재사용 가능한지 확인.

작업:
- 지팡이 2~3종 추가
- 같은 ComfyUI workflow
- IPAdapter 기준 고정
- 필요 시에만 ControlNet
- compact recipe 저장
- contact sheet 생성

완료 조건:
지팡이 3종 이상이 같은 캐릭터에 자연스럽게 장착되고 스타일 drift가 크지 않다.

## 16. Phase 4 — Equipment Expansion
순서:
1. 지팡이 batch
2. 모자 1종
3. 로브 1종
4. 각각 장착 검수
5. 문제 없으면 batch 확장

로브는 실제 문제가 있을 때만 `robe_back / robe_front`로 분리한다.
모자도 실제 hair occlusion 문제가 있을 때만 mask를 만든다.

## 17. Phase 5 — World Art  *(1~4번은 Phase 1.5로 앞당겨졌다)*
순서:
1. ~~배경 1종~~ → **Phase 1.5**
2. ~~일반 적 1종~~ → **Phase 1.5**
3. ~~실제 BattleStage 적용~~ → **Phase 1.5**
4. ~~전체 톤 확인~~ → **Phase 1.5**
5. 배경 전체 (8종 — `ASSET_LIST_BG.md`)
6. 일반 적 전체 (26종)
7. 보스 (13종)

**Phase 5에 남은 것은 물량이다.** 기준은 Phase 1.5에서 이미 승인됐다.

배경/적은 장비의 pose/anchor 규칙을 공유하지 않는다.
공유하는 것은 스타일, 조명, 색감, 디테일 밀도, 모바일 가독성이다.

## 18. Phase 6 — UI Polish
흐름:
`frontend-design → 구현 → ui-refactor → 수정 → 비교`

유지:
- Flutter UI
- Galmuri
- 기존 화면 구조
- pixel panel/button 기반

검수 화면:
- 타이틀
- 지역 선택
- 지도
- 전투
- 보상/결과

## 19. Phase 7 — Minimal Automation
반복 작업이 확인된 것만 자동화한다.

초기 자동화 후보:
- alpha 확인
- bbox
- crop
- 512×512 정규화
- alpha 250+ → 255 보정
- WebP export
- 합성 preview
- contact sheet
- checksum

하지 않을 것:
- sprite-gen 전체 fork
- automatic style score
- 자동 무한 correction
- 대규모 agent orchestration

## 20. Phase 8 — Advanced Animation
현재 Transform 기반 연출이 부족하다고 사용자가 느낄 때만 시작한다.

그때 검토:
- idle frame
- cast frame
- attack frame
- equipment-compatible frame

## 21. 카테고리별 파이프라인 분리
공통:
- `ART_STYLE_GUIDE`

Character/Equipment:
- pose/view
- dx/dy/scale
- layer
- composite preview

Enemy/Boss:
- silhouette
- scale
- stage readability

Background:
- composition
- contrast
- character readability

UI:
- frontend-design
- ui-refactor
- Flutter implementation

## 22. 현재 만들지 않을 것
- Pose Family framework
- 전신 skeleton
- 10개 이상의 anchor
- 20~30개 layer map
- 공용 40~72색 강제 팔레트
- 96×96 강제 변환
- alpha 이진화
- automatic style similarity score
- sprite-gen fork
- automatic correction engine
- 모든 animation frame 사전 제작
- 모든 장비 방향 동시 제작

## 23. 승인 규칙
새 카테고리의 최초 기준 에셋은 반드시 사용자 승인 후 `approved`로 등록한다.

대상:
- **wizard body (마법사 몸)** — 🔴 **2026-09-05 반려. `approved` 아님.** Phase 1.5에서 다시 판정
- staff 첫 1종
- hat 첫 1종
- robe 첫 1종
- enemy 첫 1종  ← **Phase 1.5**
- boss 첫 1종
- background 첫 1장  ← **Phase 1.5**

### 23-1. 🔴 승인 대상은 **혼자 판정할 수 없을 때 함께 뽑는다** (2026-09-05)

Phase 1이 마법사 몸 하나만 놓고 「같은 게임처럼 보이나」를 물었다가 반려됐다.
**옆에 설 것이 아직 코드 도트라 애초에 답할 수 없는 물음이었다.**
→ **한 화면을 이루는 첫 에셋들은 같은 기준으로 동시에 뽑아 함께 판정한다.**

### 23-2. 🔴 눈에 보이는 불일치는 **묻기 전에 먼저 말한다** (2026-09-05)

사용자 지적: **「이건 니가 봐도 전혀 아니야? 이 정도를 스스로 판단 못 해?」**
10절의 「사용자가 판단하는 네 가지」는 **취향**을 묻는 것이지,
**규격 불일치를 대신 찾아 달라는 뜻이 아니다.**
**픽셀 밀도·크기·정렬처럼 재면 나오는 것은 Claude가 먼저 재고 먼저 말한다.**

## 24. 전체 흐름  (2026-09-05 개정)
Phase 0 문서 정리 ✅
→ Phase 1 wizard_back 실제 전투 적용 — **코드 ✅ / 그림 ⛔ 반려**
→ **★ Phase 1.5 Scene Proof — 마법사 + 적 1종 + 배경 1장으로 한 화면 통째로**
→ Phase 2 staff 1종 장착 증명
→ Phase 3 staff 2~3종 재현성 검증
→ Phase 4 hat/robe/staff 확장
→ Phase 5 background/enemy/boss **물량**
→ Phase 6 UI polish
→ Phase 7 반복 작업만 자동화
→ Phase 8 필요 시 실제 프레임 애니메이션

> **Phase 1.5가 이 로드맵의 진짜 관문이다.** 여기를 통과하지 못하면
> 그 뒤 Phase는 전부 헛일이 된다.
