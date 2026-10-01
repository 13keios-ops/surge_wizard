# AGENT_START_HERE — Surge Wizard v4

> **Single handoff entry point:** `artifacts/v4/FINAL_COMPLETE_HANDOFF/00_START_HERE.md`

The project handoff is now organized so an implementation agent does **not** need to understand the old pre/post-v3.6 archive split.

## Read first

```text
artifacts/v4/FINAL_COMPLETE_HANDOFF/00_START_HERE.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md
docs/v4/final/FINAL_AUDIT_2026-10-01.md
docs/v4/final/MASTER_SPEC.md
```

For the complete historical/specification workspace from the v4 direction change through v5.9:

```bash
bash artifacts/v4/FINAL_COMPLETE_HANDOFF/build_final_complete_handoff.sh
```

This verifies both archived components by SHA-256, extracts them into one merged workspace, checks the expected source file counts, writes a manifest, and by default produces one `FINAL_COMPLETE_HANDOFF.tar.xz`.

## Current v4 code

Then inspect:

```text
lib/main_v4_preview.dart
lib/core/*_v4.dart
lib/screens/*_v4.dart
lib/widgets/*_v4.dart
test/*_v4_test.dart
tool/v4_headless_sim.dart
tool/v4_dungeon_run_sim.dart
assets/data/v4_vertical_slice_encounters.json
```

The live repository is authoritative for current code state. Historical generated source snapshots are context/regression material, not an instruction to overwrite newer code.

## Critical content authority resolution

For ACT I–II encounter/reward numbers, the later reconciled ACT I–II v4.0 data wins over the staged v4.0–v4.9 batch.

```text
Encounter counts
ACT I 9
Mine  5
Swamp 5
Ruin  5

Core combat XP
ACT I 355
Mine  295
Swamp 285
Ruin  303
```

See the final audit for all known collisions and resolutions.

## Validation truth

Planning-time Python/static/balance outputs and handoff integrity checks are preserved.

Still **not verified in the generation environment**:

```bash
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

Do not claim those passed until actually executed.

## Legacy protection

Legacy portrait entry remains `lib/main.dart`.

Landscape v4 preview remains `lib/main_v4_preview.dart`.

Do not replace the legacy entry point without an explicit migration decision.

## Next implementation

Use v5.8 work packages / v5.9 milestone order from the complete handoff.

Start with real Flutter/Dart validation and content-foundation migration, not another broad architecture redesign.
