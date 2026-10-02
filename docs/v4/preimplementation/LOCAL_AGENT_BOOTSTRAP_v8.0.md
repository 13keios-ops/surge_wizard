# Surge Wizard v4 — LOCAL AGENT BOOTSTRAP v8.0

> Updated by v8.2 handoff recheck. This file keeps the v8.0 name because it defines implementation bootstrap rules, not an authority version.

## Read first

1. `docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.2.md`
2. `docs/v4/final/CURRENT_AUTHORITY_2026-10-03.md`
3. `docs/v4/preimplementation/00_INDEX.md`
4. `docs/v4/design/v6/00_INDEX.md`
5. `docs/v4/narrative/v7/00_INDEX.md`

## Current product

Landscape mobile RPG with Wizard + up to 2 companions, authored hex tactical combat, 11 hubs, 14 regions, 9 dungeons, ACT I–V.

## Mandatory current rules

- canonical persisted story flags: `docs/v4/preimplementation/CANONICAL_FLAG_MAP_v8.0.json`
- M08: `docs/v4/preimplementation/M08_WEST_ANCHOR_RESTORATION_v8.0.md`
- Circle 5 gate after M04/D05 resolution
- XP floor II→III 1640 / III→IV 4130 / IV→V 7030
- P01–P20 / E01–E24 preserved
- v6/v7 JSON is authoring source, not ad-hoc UI state
- stable semantic dialogue IDs before localization/runtime import
- no rewarded ads/gems/deck-slot/manual-reroll resurrection

## Historical / legacy only

```text
HANDOFF.md
GAME_DESIGN.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md
docs/v4/final/FINAL_AUDIT_2026-10-01.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-02.md
artifacts/v4/complete_handoff/*.tar.xz
```

The old binary provenance archives are preserved but are **not required** by the implementation handoff builder.

## First commands

```bash
python docs/v4/preimplementation/validate_repo_handoff_v8_2.py
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

Do not rewrite game rules merely to satisfy legacy tests; record real failures and reconcile against current authority.
