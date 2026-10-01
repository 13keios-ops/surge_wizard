# Surge Wizard v4 — Flutter Vertical Slice + CombatEngineV4

버전: v3.3  
목적: 기존 Portrait 전투를 보존하면서 **가로형 v4 Hex 전투의 UI + 순수 전투엔진**을 별도 실행한다.

## 실행

```bash
flutter run -t lib/main_v4_preview.dart
```

기존 `lib/main.dart`는 수정하지 않는다.

## 이번 버전에 실제 연결된 것

- Seeded deterministic RNG.
- Timeline `nextActionTime`.
- Speed → effective delay.
- 3d6 attack check.
- natural 3 miss / natural 18 hit+crit.
- 90–110% damage variance.
- Armor/MR / elemental weakness-resist.
- Status application.
- Burn/Bleed/Poison stack basis.
- Slow/Haste delay modifier.
- Root.
- Stun → Boss Stagger conversion hook.
- Exposed.
- Weakened.
- Disrupted.
- Guarded.
- Barrier instances / 50% maxHP cap.
- Poison healing reduction.
- KO clear.
- 9×7 movement reachability.
- Water cost / Block terrain basis.
- Opportunity attack.
- forced move bypass hook.
- Minimal deterministic AUTO.
- v2.9 Landscape UI reads real engine HP/timeline.
- UI `실행` button commits preview action.

## Preview action mapping

```text
Attack  -> real 3d6 damage action
Control -> Root effect check
Defense -> Barrier
Tool    -> HP potion
```

Enemy turns use minimal AUTO.

This is still a **Vertical Slice engine fixture**, not the final spell catalog implementation.

## Tests

```bash
flutter test \
  test/battle_layout_v4_test.dart \
  test/seeded_rng_v4_test.dart \
  test/timeline_v4_test.dart \
  test/status_system_v4_test.dart \
  test/combat_engine_v4_test.dart
```

## 다음 단계

1. Spell/Skill data-driven action definitions.
2. Line/Burst/Cone/Chain target resolver.
3. real Fireball/Burn/Surge.
4. full status activation timing QA.
5. AI scoring from design spec.
6. enemy/boss JSON loader.
7. Vertical Slice B01~B05 encounter loader.
8. headless thousands-run simulation with this exact resolver.

## 주의

현재 실행 환경에서는 Flutter SDK를 사용할 수 없어 실제 `flutter analyze/test`를 여기서 실행하지 못했다.
코드는 저장소의 Dart 3.12 / Flutter 구조에 맞춰 작성했으며 정적 괄호·파일구조 검사를 거쳤다.


# v3.1 추가

실제 주문 레이어:

```text
spell_action_v4.dart
spell_catalog_v4.dart
target_resolver_v4.dart
surge_cast_resolver_v4.dart
```

연결된 Preview 주문:

```text
Attack  -> Fireball / Burst7
Control -> Arcane Bind
Defense -> Arcane Shield
Tool    -> HP Potion
```

Cast Stability:

```text
3d6 + MND mod + mastery + cast modifiers
>= 9 + circle + difficulty + condition penalty
```

결과:
- Stable
- Unstable
- Surge
- Perfect Cast

Perfect:
- 자연 18 + 성공
- MP 20% refund

Unstable:
- 주문별 Penalty

Surge:
- 주문별 SurgeEffect
- Fireball은 중심 Hex 1칸 Shift

추가 테스트:

```bash
flutter test test/target_resolver_v4_test.dart
flutter test test/surge_cast_resolver_v4_test.dart
flutter test test/spell_cast_engine_v4_test.dart
```


# v3.2 추가

Vertical Slice B01~B05가 JSON Encounter로 고정됐다.

```text
assets/data/v4_vertical_slice_encounters.json
```

추가 구현:

```text
encounter_data_v4.dart
vertical_slice_catalog_v4.dart
encounter_loader_v4.dart
headless_policy_v4.dart
headless_runner_v4.dart
tool/v4_headless_sim.dart
```

중요 규칙 수정:

```text
이동 → 행동 가능
한 Activation에 자발 이동은 1회
Ranged attack은 Range 검사
직접 Ranged는 Cover +2 EVA
공격 Spell도 실제 3d6 vs EVASION
Wizard Staff Accuracy +1
```

실제 Dart Headless 실행:

```bash
dart run tool/v4_headless_sim.dart 5000
```

또는 Flutter SDK만 있는 환경이면:

```bash
flutter pub get
dart run tool/v4_headless_sim.dart 5000
```

이 환경에서는 Dart SDK가 없어 위 명령을 직접 실행하지 못했다.
동봉된 simulation CSV는 Python behavioral mirror 결과이며
Dart runner 결과와 구분해서 사용해야 한다.


# v3.3 추가

Bone Heap 실제 Boss fixture:

```text
Bone Throw       +4 / raw 13 / Range 5 / Delay 90
Bone Sweep       +5 / raw 16 / Cone3 / Delay 105
Bone Cage        Fortitude / Root 1 / Delay 120
Reassemble       HP <=60% 1회 / Barrier25 / Skeleton1 / next +20
Fractured Core   HP <=30% / incoming Accuracy +1 / Sweep damage +15%
```

추가:

```text
combat_engine_v4_npc_actions.dart
boss_bone_heap_v4.dart
dungeon_run_state_v4.dart
headless_dungeon_runner_v4.dart
tool/v4_dungeon_run_sim.dart
```

Dungeon Carry:
- B02 → B03 → B05
- Optional route: B02 → B03 → B04 → B05
- HP/MP carry
- 전투 승리 시 KO 동료 1 HP 복귀
- 전투 사이 HP Potion 자동 정책은 QA runner 전용
- 시작 HP Potion 2개
- Status/Barrier는 전투 사이 유지하지 않음

실제 Dart sequential simulation:

```bash
dart run tool/v4_dungeon_run_sim.dart 5000
```

# v3.4 추가

## 실제 Encounter BattleScreen 연결

Preview 시작점은 더 이상 고정 Fixture가 아니다.

```text
main_v4_preview.dart
→ VerticalSliceBattleHostV4
→ assets/data/v4_vertical_slice_encounters.json
→ EncounterLoaderV4
→ BattlePreviewControllerV4
→ BattleScreenV4
```

화면 왼쪽 위 `B01~B05` 선택기로 각 Encounter를 즉시 재현할 수 있다.
승리/패배 후 `RETRY / NEXT`가 표시된다.

실행:

```bash
flutter run -t lib/main_v4_preview.dart
```

저장소의 현재 `pubspec.yaml`은 이미 아래를 등록하고 있어 JSON 추가 선언은 필요 없다.

```yaml
assets:
  - assets/data/
```

## 동적 Hex Board

기존 Preview의 9×7 고정 Geometry를 제거했다.

```text
B01 9×7
B02 9×7
B03 9×7
B04 8×6
B05 10×7
```

각 Encounter의 실제 `columns / rows`가 Hit Test와 Board rendering에 사용된다.
Cover / Forest / Water / Fire / Block terrain도 Board layer에 전달된다.

Bone Heap의 Pending Sweep Hex는 별도 Telegraph layer로 표시된다.

## 동료 최소 Skill

Kael:

```text
Quick Slash    Accuracy +1 / Delay 90
Heavy Strike   Power +5 / Accuracy -1 / Delay 130
Guard Stance   Guarded 20% / 2 Activations / Delay 95
Hook Pull      Range 3 / vs BRACE / Pull 1 / Delay 110
```

Nera:

```text
Vital Strike     Power +6, Exposed면 +10 / Delay 110
Expose Weakness  Range 3 / vs EVASION / Exposed 2 / Delay 90
Smoke Step       Range 3 / Opportunity bypass / Guarded 15% / Delay 85
```

현재 1차 Radial은 카테고리당 대표 Skill 하나를 직접 실행한다.
2차 Skill picker는 다음 UI 단계에서 연결한다.

## Balanced AUTO

Party AUTO는 이제 단순 최근접 공격이 아니라 후보 행동을 평가한다.

개념 Score:

```text
Expected Damage
+ Kill Value
+ Multi-target Value
+ Control Value
+ Survival Value
+ Position Value
- Mana Cost
- Delay Cost
- Surge Risk
```

Wizard:
- Fireball / Fire Bolt / Arcane Dart / Arcane Bind / Arcane Shield

Kael:
- Quick Slash / Heavy Strike / Hook Pull / Guard Stance

Nera:
- Vital Strike / Expose Weakness / Smoke Step

`auto_choice` CombatEvent에 선택한 Intent와 Score를 남긴다.

## v3.4 Balance fixture 보정

Boss Antechamber:

```text
Party HP Full
Wizard MP minimum 100
Start Ward Barrier 10
Potion 복원 없음
```

B04 Ancient Focus:

```text
Wizard MP +40
B05 Start Barrier 25
```

Bone Sweep Telegraph wind-up fixture:

```text
Base Delay 55
```

Bone Throw는 Range 안에서 현재 HP 비율이 가장 낮은 파티를 우선한다.

## Reference simulation

동봉 Python behavioral mirror:

```bash
python tool/reference_mirror_v3_4.py \
  assets/data/v4_vertical_slice_encounters.json \
  /tmp/individual.csv \
  /tmp/dungeon.csv \
  5000
```

최종 밸런스 승인에는 반드시 Dart SDK가 있는 환경에서 아래를 다시 실행한다.

```bash
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter test
flutter analyze
```


# v3.5 추가

수동 전투 UI가 실제 플레이 흐름으로 확장됐다.

- 1차 Radial: Attack / Control / Defense / Tool.
- 2차 Radial: 실제 Skill 선택, 중앙 Back orb.
- MOVE 버튼: 실제 Reachable Hex 표시.
- Opportunity Attack 예상 Hex는 `!` 마커로 표시.
- 이동은 즉시 수행되지만 Activation은 유지되어 Move → Act 가능.
- Status/Barrier 아이콘을 전장 Unit과 Party HUD에 표시.
- HP Potion은 Preview에서도 실제 수량을 소모.
- B01 → B02 → B03 → [B04 Optional] → B05를 같은 Run 상태로 진행.
- Gold / Essence / Potion / HP / MP Carry.
- B03 뒤 Boss Safe Point 적용.
- B04 Ancient Focus reward 적용.
- Wipe Retry는 HP/MP Safe State를 복원하지만 전투 중 사용한 Potion은 유지해서 감소.

기존 Encounter Picker는 제거하고 기본 진입점을 **실제 Vertical Slice Run**으로 바꿨다.
