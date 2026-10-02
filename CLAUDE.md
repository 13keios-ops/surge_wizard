# CLAUDE.md — Surge Wizard v4

> **Current implementation bootstrap.**
> The former root instructions described the pre-pivot portrait dice/deck roguelite and are obsolete for v4.

## Read first

1. `docs/v4/preimplementation/LOCAL_AGENT_BOOTSTRAP_v8.0.md`
2. `docs/v4/preimplementation/PREIMPLEMENTATION_FULL_AUDIT_v8.0.md`
3. `docs/v4/final/CURRENT_AUTHORITY_2026-10-02.md`
4. `docs/v4/design/v6/00_INDEX.md`
5. `docs/v4/narrative/v7/00_INDEX.md`
6. `AGENT_START_HERE.md`

## Current product

- landscape mobile RPG
- Wizard + up to 2 companions
- authored hex tactical combat with absolute timeline
- 11 hubs / 14 regions / 9 dungeons
- Acts I–V + two final world outcomes
- no rewarded-ad core loop
- legacy portrait entry `lib/main.dart` remains protected
- use `lib/main_v4_preview.dart` until explicit entry-point migration

## Authority warning

Root `GAME_DESIGN.md` and `HANDOFF.md` are **legacy pre-v4 historical documents**.
Do not use them as current game-design authority.

Persistent story flags use:
`docs/v4/preimplementation/CANONICAL_FLAG_MAP_v8.0.json`.

M08 West Anchor is restored by:
`docs/v4/preimplementation/M08_WEST_ANCHOR_RESTORATION_v8.0.md`.

## First real local validation

```bash
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

Do not claim these passed until they actually run in the local Flutter/Dart environment.
