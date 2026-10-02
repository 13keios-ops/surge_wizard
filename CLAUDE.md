# CLAUDE.md — Surge Wizard v4

> **Current implementation bootstrap.**
> This file is authoritative only as an entry point; detailed authority is defined below.

## Read first

1. `docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.1.md`
2. `docs/v4/preimplementation/LOCAL_AGENT_BOOTSTRAP_v8.0.md`
3. `docs/v4/final/CURRENT_AUTHORITY_2026-10-03.md`
4. `docs/v4/preimplementation/00_INDEX.md`
5. `docs/v4/narrative/v7/00_INDEX.md`
6. `docs/v4/design/v6/00_INDEX.md`
7. `AGENT_START_HERE.md`

## Current product

- landscape mobile RPG
- Wizard + up to 2 companions
- authored hex tactical combat with absolute timeline
- 11 hubs / 14 regions / 9 dungeons
- Acts I–V + two final world outcomes
- no rewarded-ad core loop
- legacy portrait entry `lib/main.dart` remains protected
- use `lib/main_v4_preview.dart` until explicit entry-point migration

## Legacy warning

These are preserved historical pre-v4 sources and **must not be used as current implementation authority**:

```text
HANDOFF.md
GAME_DESIGN.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md
docs/v4/final/FINAL_AUDIT_2026-10-01.md
```

The validated v6/v7 structured packages are committed under `docs/v4/design/v6/` and
`docs/v4/narrative/v7/`. v8 corrections are overlays; do not silently rewrite their historical authoring data.

## Critical implementation corrections

- Persist story flags using `docs/v4/preimplementation/CANONICAL_FLAG_MAP_v8.0.json`.
- Restore M08 West Anchor using `M08_WEST_ANCHOR_RESTORATION_v8.0.md`.
- Circle 5 story gate commits after M04/D05 resolution.
- Main-path XP floors: II→III 1640, III→IV 4130, IV→V 7030.
- Preserve P01–P20 / E01–E24 identities.
- Compile v6/v7 authoring data into runtime repositories; do not invent parallel UI-local schemas.

## First real local validation

```bash
flutter pub get
flutter analyze
flutter test
python docs/v4/preimplementation/validate_repo_handoff_v8_1.py
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

Planning/static validators are not a substitute for the Flutter/Dart commands above.
