# CLAUDE.md — Surge Wizard v4

> **Current implementation bootstrap.**
> This file is only the entry point; detailed authority is defined below.

## Read first

1. `docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.2.md`
2. `docs/v4/final/CURRENT_AUTHORITY_2026-10-03.md`
3. `docs/v4/preimplementation/LOCAL_AGENT_BOOTSTRAP_v8.0.md`
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

These are provenance only and **must not be used as current implementation authority**:

```text
HANDOFF.md
GAME_DESIGN.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md
docs/v4/final/FINAL_AUDIT_2026-10-01.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-02.md
```

## Critical implementation corrections

- Persist story flags using `docs/v4/preimplementation/CANONICAL_FLAG_MAP_v8.0.json`.
- Restore M08 West Anchor using `docs/v4/preimplementation/M08_WEST_ANCHOR_RESTORATION_v8.0.md`.
- Circle 5 story gate commits after M04/D05 resolution.
- Main-path XP floors: II→III 1640, III→IV 4130, IV→V 7030.
- Preserve P01–P20 / E01–E24 identities.
- Compile v6/v7 authoring data into runtime repositories; do not invent parallel UI-local schemas.
- Do not use the old binary provenance archives as an implementation prerequisite; the v8.2 handoff builder packages the live validated repository layers.

## First real local validation

```bash
python docs/v4/preimplementation/validate_repo_handoff_v8_2.py
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

The Python handoff checks do not prove Flutter/Dart runtime correctness.
