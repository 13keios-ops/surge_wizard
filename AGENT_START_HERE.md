# AGENT_START_HERE — Surge Wizard v4

## Current single implementation entry

Read in this order:

```text
docs/v4/preimplementation/LOCAL_AGENT_BOOTSTRAP_v8.0.md
docs/v4/preimplementation/PREIMPLEMENTATION_FULL_AUDIT_v8.0.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-02.md
docs/v4/design/v6/00_INDEX.md
docs/v4/narrative/v7/00_INDEX.md
docs/v4/final/MASTER_SPEC.md
```

The old root `GAME_DESIGN.md` / `HANDOFF.md` are legacy pre-pivot history, not current v4 authority.

## Critical v8 corrections

- M08 West Anchor Major Choice is restored.
- Persistent story flags use the v8 canonical map; v6/v7 renamed tokens are migration aliases only.
- Circle 5 story gate commits after M04/D05 resolution, not at researcher capture.
- Act transition XP floor prevents mandatory grind: II→III 1640, III→IV 4130, IV→V 7030.
- P01–P20 and E01–E24 remain canonical authored POI/side-event identities.
- v6/v7 are authoring sources; compile/migrate to v5 runtime repositories.
- Encounter runtime needs nonstandard victory/failure conditions and scripted interactables for later Acts.

Legacy `lib/main.dart` remains protected until an explicit migration.

## Real local validation still required

```bash
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```
