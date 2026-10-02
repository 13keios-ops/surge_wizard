# Surge Wizard (폭주 마법사) — v4

가로형 모바일 RPG. 플레이어는 마법사와 최대 2명의 동료로 파티를 구성하고,
월드 탐험·선택 이벤트·헥스 전술전투를 거쳐 ACT I~V를 진행한다.

## 구현 문서 시작점

```text
CLAUDE.md
docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.2.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-03.md
docs/v4/preimplementation/LOCAL_AGENT_BOOTSTRAP_v8.0.md
AGENT_START_HERE.md
```

현재 authoring package:

```text
docs/v4/design/v6/          ACT III–V / late progression / maps-events-state
docs/v4/narrative/v7/       full narrative / dialogue / structured data
docs/v4/preimplementation/  implementation corrections / validators
```

## Legacy

`GAME_DESIGN.md`, `HANDOFF.md`, 2026-10-01/10-02 authority snapshots, and `lib/main.dart`
are historical/protected legacy material, not current v4 authority.

## Fresh-clone gate

```bash
python docs/v4/preimplementation/validate_repo_handoff_v8_2.py
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

For a portable implementation handoff, use:
`artifacts/v4/FINAL_COMPLETE_HANDOFF/build_final_complete_handoff.sh`.
The current builder uses validated live repository layers and does not depend on old binary provenance archives.
