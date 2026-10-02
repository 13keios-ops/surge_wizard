# Surge Wizard (폭주 마법사) — v4

가로형 모바일 RPG. 플레이어는 마법사와 최대 2명의 동료로 파티를 구성하고,
월드 탐험·선택 이벤트·헥스 전술전투를 거쳐 ACT I~V를 진행한다.

## 구현 문서 시작점

```text
CLAUDE.md
docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.1.md
docs/v4/preimplementation/LOCAL_AGENT_BOOTSTRAP_v8.0.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-02.md
AGENT_START_HERE.md
```

현재 본편 authoring package:

```text
docs/v4/design/v6/       ACT III–V / late progression / integration data
docs/v4/narrative/v7/    full narrative / dialogue / structured data
docs/v4/preimplementation/ v8 implementation corrections and validators
```

## Legacy 보호

`GAME_DESIGN.md`, `HANDOFF.md`, `docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md`,
`docs/v4/final/FINAL_AUDIT_2026-10-01.md`, 그리고 `lib/main.dart`는 역사/레거시 보존물이다.
현재 v4 구현 기준으로 사용하지 않는다.

Landscape v4 preview:

```bash
flutter run -t lib/main_v4_preview.dart
```

Fresh clone에서 구현 전에:

```bash
python docs/v4/preimplementation/validate_repo_handoff_v8_1.py
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
```

실제 Flutter/Dart 실행 결과를 기록한 뒤 broad migration을 시작한다.
