# 작업 지시서 D — 진행 구조 교체 · 엔진층 (구현 창용)

발행: 2026-09-02, 기획 창. **사용자 승인 완료된 작업이다** (`GAME_DESIGN.md` v2 6절).

근거 문서: **`STAGES.md`** (지역·스테이지·층수) · **`ENEMIES.md`** (변종·tier 풀·지역 배율)

> ### 🪟 창 운영
> **새 창(`/clear` 후)에서 시작한다.** 이 지시서는 **엔진·데이터만** 다룬다.
> 화면 재설계는 **다음 지시서(G)** 다. 스크린샷은 **마지막에 1장**(가로 480px)만
> 찍어 앱이 죽지 않는지 확인하면 된다.

---

## 0. 이 작업의 목적 (한 줄)

**데이터에는 지역 12 · 스테이지 100 · 변종 6종이 들어가 있는데, 코드는 아직
「1층~10층 단선」이라 그 데이터를 하나도 읽지 못한다.** 그 다리를 놓는다.

## 0-1. ⚠ 범위 — 「엔진층까지」다

| 이번에 한다 | 다음 지시서(G) |
|---|---|
| 모델 3종 · 로더 확장 | **지역/스테이지/난이도 선택 화면** |
| 변종·지역 배율 런타임 적용 | 지도 화면 재설계 |
| `RunState`·`RunController` 스테이지 기반 재작성 | 철수 · 중간 저장 UI |
| 보상 층 배치 규칙 (층수 가변) | 소탕 · 방치 보상 |
| 화면은 **깨지지 않을 만큼만** 고친다 | |

> **임시 진입 규칙**: 선택 화면이 없으므로 판을 시작하면
> **「지역 1 · 스테이지 1 · 보통」으로 고정 진입**한다. 상수 하나로 두어
> 다음 지시서가 갈아끼우기 쉽게 할 것.

## 0-2. 절대 지킬 것

- **`core/check.dart` · `core/combo.dart` · `core/surge.dart`를 고치지 마라.**
  판정도 폭주도 이 작업과 무관하다
- **밸런스 수치를 임의로 바꾸지 마라.** 이 지시서가 주는 값(2-C 난이도 배율)만 쓴다
- 매직 넘버 금지 · 파일 300줄 · 함수 40줄 · 주석 한국어
- `flutter analyze` 경고 0, `flutter test` 전부 통과

---

# 작업 1 — 모델과 로더

## 1-A. 모델 3종 신규

`lib/models/`에 만든다. **전부 `fromJson`/`toJson`을 갖춘다** (`CLAUDE.md` 코딩 규칙).

| 클래스 | 파일 | 필드 |
|---|---|---|
| `Region` | `region.dart` | `id` `name` `theme` `bossId` `stageCount` `scale` `tierPool` `variantWeights` |
| `Stage` | `stage.dart` | `id` `regionId` `index` `subtitle?` `floors` `recommendedLevel` `isBossStage` |
| `EnemyVariant` | `enemy_variant.dart` | `id` `namePrefix` `tint?` `hpMul` `atkMul` |

- `tierPool`·`variantWeights`는 `Map<String, int>` 그대로 받는다
- `tint`는 JSON에 `"#C8503C"` 문자열이다. **모델은 문자열로 들고, 색 변환은 화면 쪽에서** 한다
  (`models/`가 Flutter에 의존하면 `tool/`이 죽는다 — `CLAUDE.md` LESSONS)

## 1-B. `Enemy`에 `region` 추가

```dart
final int? region;   // 지역 보스만 값이 있다. 일반 적과 미배정 보스는 null
```

`fromJson`/`toJson` 모두 반영. **null 허용이 중요하다** — 일반 적 26종과
`boss_dice_devourer`는 값이 없다.

## 1-C. 로더·파서 확장

- `lib/data/parser.dart`에 `parseRegions` · `parseStages` · `parseVariants` 추가
  (⚠ **Flutter import 금지.** `tool/`이 이 파일을 쓴다)
- `GameData`에 `regions` · `stages` · `variants` 필드 추가
- `lib/data/loader.dart`가 **7개 파일**을 읽도록 확장
- `pubspec.yaml`의 assets 목록에 **새 JSON 3개가 포함되는지 확인**하라.
  `assets/data/`를 통째로 잡고 있으면 그대로 두면 된다
- `tool/sim_core.dart`의 `loadGameData()`도 3파일을 읽도록 함께 고친다

---

# 작업 2 — 적 구성 (`lib/core/`)

## 2-A. 변종·배율 적용 — 신규 `lib/core/enemy_builder.dart`

**원본 `Enemy`를 바꾸지 말고 새 인스턴스를 만들어 돌려준다.**

```
Enemy build(Enemy base, EnemyVariant v, double regionScale, Difficulty d)
```

| 대상 | 곱하는 것 |
|---|---|
| `hp` | `regionScale × v.hpMul × d.hpMul` |
| `pattern`·`phase2Pattern`의 `attack`·`charge` value | `regionScale × v.atkMul × d.atkMul` |
| `pattern`·`phase2Pattern`의 `defend`·`heal` value | `regionScale × v.hpMul × d.hpMul` |
| `phase2HpThreshold` | 새 `hp ~/ 2` 로 **다시 계산** |
| `name` | `"${v.namePrefix} ${base.name}"` (기본 변종은 접두어 없음) |

- ⚠ **보스는 `regionScale`을 곱하지 않는다** (`ENEMIES.md` 3절 — 표가 최종값).
  변종 배율과 난이도 배율은 보스에도 적용한다
- 반올림은 **`.round()`**, 최소 1 보장 (0이 되면 안 되는 값들이다)

## 2-B. 적 뽑기 — 신규 `lib/core/stage_runner.dart` (또는 적절한 이름)

```
Enemy pickEnemy(GameData data, Region region, Stage stage, int floor, Difficulty d, Random r)
```

1. **마지막 층이면** `region.bossId`로 보스를 찾는다
2. 아니면 `region.tierPool` 가중 추첨으로 tier를 뽑고, **그 tier의 일반 적** 중 하나
3. `region.variantWeights` 가중 추첨으로 변종을 뽑는다
4. 2-A로 조립해 돌려준다

**보스 변종은 난이도로 고정한다** (`ENEMIES.md` 4절):

| 난이도 | 보스 변종 |
|---|---|
| 보통 | `normal` |
| 하드 | `shadow` |
| 데스 | `ancient` |

> ⚠ **「호위」(소환수 동반)와 「연전」(2체째)은 이번에 만들지 않는다.**
> 변종만 적용한다. 나중에 별도 지시서로 낸다

## 2-C. ✅ 난이도 3단계 배율 (기획 창 지정 — 출발점 〔시뮬〕)

`Difficulty` enum과 배율표를 `core/constants.dart`에 상수로 둔다.

| 난이도 | 적 HP | 적 공격 | 보상 | 경험치 |
|---|---|---|---|---|
| **보통** `normal` | ×1.0 | ×1.0 | ×1.0 | ×1.0 |
| **하드** `hard` | ×1.5 | ×1.25 | ×1.8 | ×1.6 |
| **데스** `death` | ×2.2 | ×1.5 | ×3.0 | ×2.5 |

- **HP를 공격보다 크게 올린다.** 공격을 많이 올리면 즉사가 늘어 좌절이 커지고,
  HP를 올리면 「오래 걸린다」가 된다. 6.2절의 「불가능이 아니라 오래 걸림」 원칙이다
- **보상 배율이 HP 배율보다 크다.** 그래야 어려운 난이도를 도는 이유가 생긴다
- 경험치·보상 배율은 **값만 정의해 두고** 실제 지급은 이번 범위가 아니다

---

# 작업 3 — 판 진행

## 3-A. `RunState` 확장

```dart
int regionId;      // 1~12
int stageIndex;    // 1~(지역의 stage_count)
Difficulty difficulty;
int floor;         // 1~stage.floors
```

- **`isCleared`는 `floor > stage.floors`** 로 바뀐다. `kFloorCount`를 쓰지 않는다
- `fromJson`/`toJson`에 새 필드 전부 반영 — **중간 저장(6.3절)이 이 위에 얹힌다**
- **옛 저장 데이터 호환은 신경 쓰지 마라.** 아직 출시 전이다.
  읽다가 필드가 없으면 새 판을 시작하면 된다

## 3-B. `RunController` 재작성

- 생성 시 `regionId` · `stageIndex` · `difficulty`를 받는다
  (**임시 진입 상수**: 1 · 1 · `normal`)
- `region` / `stage` 게터로 `GameData`에서 찾아 쓴다
- `_pickEnemyForFloor`를 **2-B의 `pickEnemy` 호출로** 교체
- `isBossFloor` → `state.floor == stage.floors`

## 3-C. ★ 보상 층 배치 — 층수가 3~10으로 가변이다

지금은 **3·9층 주문 / 6층 유물 / 4층 상점**으로 못 박혀 있다.
층수가 3층인 스테이지도 있으므로 **비율 규칙으로 바꾼다.**

`core/constants.dart`에 함수 하나로 둔다:

```
floorEvent(floor, floors):
  floor == floors            → 보스
  floor == floors - 1        → 상점
  floor == (floors/2).round() 이고 floor < floors-1 → 유물 보상
  floor % 3 == 0 이고 floor < floors-1              → 주문 보상
  그 밖                       → 일반 전투
```

- **보스 층을 깬 뒤에도 주문 보상을 1회** 준다 (스테이지 완주 보상)
- 겹치면 위에서부터 우선한다
- ⚠ **3층 스테이지에서는 유물 보상이 없다.** 정상이다 (도입 지역은 짧다)
- 기존 상수 `kSpellRewardFloors` · `kRelicRewardFloor` · `kShopFloor` ·
  `kFloorCount` · `kFloorTier`는 **삭제한다**

---

# 작업 4 — 화면은 「깨지지 않을 만큼만」

**재설계하지 마라.** `kFloorCount`가 사라지면서 깨지는 곳만 고친다.

| 파일 | 무엇을 |
|---|---|
| `lib/screens/map_screen.dart` | `kFloorCount` → `run.stage.floors`, 층 라벨은 `floorEvent`로 |
| `lib/screens/result_screen.dart` | `/ $kFloorCount` → 스테이지 층수 |
| `lib/widgets/battle_stage.dart` | 층 표식 계산을 `floors` 기반으로 |
| 진입점 | 임시 상수로 「지역 1 · 스테이지 1 · 보통」 시작 |

**화면 위에 지역·스테이지 이름을 한 줄로 띄우는 정도**는 해도 좋다
(「마나의 숲 I」). 그 이상은 하지 마라.

> ⚠ **`UI_DESIGN.md`(2026-09-02 신설)에 화면 6종의 구도가 이미 있다.**
> 하지만 **이번에 그대로 만들지 마라.** 그건 지시서 G의 일이고,
> **원화(캐릭터·배경)가 들어오는 것을 전제로 짜인 구도**라 지금 만들면
> 도트 자산 위에 절반만 얹혀 두 번 일하게 된다.
> 이번에는 **「기존 화면이 스테이지 층수대로 동작하게」**만 하면 된다.

---

# 작업 5 — 테스트

## 5-A. `test/progression_test.dart` (신규)

| # | 검사 |
|---|---|
| 1 | `Region`·`Stage`·`EnemyVariant`가 JSON에서 전부 파싱된다 (12 / 100 / 6) |
| 2 | `Enemy.region`이 보스 12종에만 있고 일반 적엔 없다 |
| 3 | ★ **변종 배율**: `hungry`(HP×0.8·공격×1.3)를 적용하면 HP·`attack`·`charge`가 기대값이 된다 |
| 4 | ★ **지역 배율이 보스에는 안 붙는다** — 지역 12(×5.0)의 보스 HP가 **480 그대로** |
| 5 | ★ **일반 적에는 붙는다** — 지역 12의 tier5 적 HP가 base × 5.0 |
| 6 | 변종 적용 후 `phase2HpThreshold == hp ~/ 2` |
| 7 | 변종 이름에 접두어가 붙는다 (`굶주린 오크 전사`), 기본 변종은 안 붙는다 |
| 8 | ★ **`floorEvent`를 스테이지 100개 전부에 돌려** 보스 층이 정확히 1개이고, 상점이 보스 앞 층이며, 이벤트가 층 범위를 벗어나지 않는다 |
| 9 | 난이도 3단계 배율이 HP·공격에 정확히 곱해진다 |
| 10 | 보스 변종이 난이도별로 `normal`/`shadow`/`ancient`다 |
| 11 | ★ **한 스테이지를 끝까지 도는 통합 테스트** — 1층부터 마지막 층까지 진행해 `isCleared`가 참이 되고, 마지막 층 적이 보스다 |
| 12 | `RunState`의 `toJson` → `fromJson` 왕복이 값을 보존한다 (중간 저장 대비) |

## 5-B. ⚠ 기존 테스트 — 미리 조사했다

**기획 창이 `kFloorCount` 계열을 쓰는 곳을 전수 조사했다.**

| 위치 | 조치 |
|---|---|
| `test/meta_test.dart` 116~117행 | `kFloorCount`를 쓴다. **상수가 사라지므로 리터럴 10 또는 새 값으로 바꾼다.** 검사 의도(층당 결정 + 보스 보너스)는 그대로 둘 것 |
| `test/widget_test.dart` 스모크 | 타이틀 → 지도 → 전투가 여전히 돌아가야 한다. **깨지면 화면 수정이 덜 된 것이다** |
| `test/run_test.dart` | `RunController`를 직접 쓰는 곳이 있으면 새 생성자에 맞춘다 |
| `tool/sim_core.dart` | `kFloorCount`·`kFloorTier`에 의존한다. **이번엔 최소 수정으로 「지역 1 스테이지 1」을 돌게만** 해 둘 것. 시뮬 재측정은 다음 지시서다 |

**그 밖의 테스트가 깨지면 구현이 틀린 것이다.** 특히
`check_test`·`combo_test`·`surge_effect_test`가 깨지면 **건드리면 안 될 곳을 건드린 것이다.**

---

# 마무리

1. `flutter analyze` 경고 0 / `flutter test` 전부 통과
2. `dart run tool/simulate.dart`가 **죽지 않고 돌아가는지** 확인
   (⚠ **수치를 해석하지 마라.** 재측정은 다음 지시서다)
3. **화면 확인 1장**(가로 480px) — 지도 화면이 스테이지 층수대로 뜨는지
4. **`reports/13_진행구조.md`를 새로 만든다** (양식 `reports/_TEMPLATE.md`)
   - 5-A의 **3·4·5번(배율) 결과를 수치 표로**
   - **8번(스테이지 100개 이벤트 배치)** 을 층수별로 요약해 표로
     (3층·5층·8층·10층 스테이지가 각각 어떤 배치가 되는지)
   - 근거 문서 오류를 발견하면 **고치지 말고 적어라**
5. 사용자에게는 **「보고서 <경로> 작성 완료」 한 줄만** 말한다

## 하지 않을 것

- ❌ **지역/스테이지/난이도 선택 화면** (지시서 G)
- ❌ 지도 화면 재설계 · 철수 · 중간 저장 UI
- ❌ 보스 「호위」·「연전」 등장 방식
- ❌ 소탕 · 방치 보상 · 미션 · 부활
- ❌ 레벨 · 경험치 · 패시브 트리 · 각인 · 장비
- ❌ 덱에서 손패 3장 뽑기 (v2 4.2절 — 서클·덱 편성과 함께 할 일)
- ❌ 시뮬레이션 재측정 · 밸런스 조정
