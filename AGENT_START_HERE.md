# AGENT_START_HERE — Surge Wizard v4

## Current implementation entry

Read in this order:

```text
docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.1.md
docs/v4/preimplementation/LOCAL_AGENT_BOOTSTRAP_v8.0.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-03.md
docs/v4/preimplementation/00_INDEX.md
docs/v4/narrative/v7/00_INDEX.md
docs/v4/design/v6/00_INDEX.md
docs/v4/final/MASTER_SPEC.md
```

Root `GAME_DESIGN.md` / `HANDOFF.md` and the 2026-10-01 authority/audit are historical only.

## Critical corrections

- M08 West Anchor Major Choice is restored.
- Persisted story flags use the v8 canonical map; v6/v7 renamed tokens are aliases only.
- Circle 5 gate commits after M04/D05 resolution.
- Main-path transition XP floor: II→III 1640, III→IV 4130, IV→V 7030.
- P01–P20 and E01–E24 remain canonical authored identities.
- v6/v7 JSON is authoring source; migrate through the runtime contracts instead of loading ad hoc.
- Late encounters need nonstandard victory/failure/interactable support.
- Narrative localization keys must be stable semantic IDs, not array positions.

## Package completeness

The validated v6 and v7 structured JSON, checkpoint audits, manifests, validation logs, and original
Python validators are committed in their package directories. Do not assume an index-only placeholder.

## Current code

```text
lib/main_v4_preview.dart
lib/core/*_v4.dart
lib/screens/*_v4.dart
lib/widgets/*_v4.dart
test/*_v4_test.dart
tool/v4_headless_sim.dart
tool/v4_dungeon_run_sim.dart
```

Legacy `lib/main.dart` remains protected until explicit migration.

## First local gate

```bash
python docs/v4/preimplementation/validate_repo_handoff_v8_1.py
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```
