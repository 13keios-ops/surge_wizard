# Surge Wizard v4 — FINAL COMPLETE HANDOFF

This directory is the single full-history handoff entry point for the **v4 landscape party RPG**.

## Current authority

Read first:

```text
CLAUDE.md
docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.1.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-03.md
docs/v4/final/MASTER_SPEC.md
```

The 2026-10-01 / 2026-10-02 authority documents and the root pre-v4 `GAME_DESIGN.md` / `HANDOFF.md`
are preserved history, not current implementation authority.

## Full history layout

Two immutable provenance archives preserve the v4 direction-change history through v5.9:

```text
artifacts/v4/complete_handoff/Surge_Wizard_v4_COMPLETE_HANDOFF_CONTENT_2026-10-01.tar.xz
artifacts/v4/complete_handoff/Surge_Wizard_v4_POST_V3_6_COMPLETE_HANDOFF_2026-10-01.tar.xz
```

Current authoring and correction layers are committed live:

```text
docs/v4/design/v6/
docs/v4/narrative/v7/
docs/v4/preimplementation/
```

`build_final_complete_handoff.sh` verifies the provenance archives, runs the fresh-clone handoff validator,
extracts the historical layers, and copies the live v6/v7/v8.1 layers into one merged workspace.

## Authority order

1. newest explicit user instruction
2. `docs/v4/final/CURRENT_AUTHORITY_2026-10-03.md`
3. `docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.1.md` and v8 corrections
4. v7 narrative package
5. v6 campaign package
6. reconciled ACT I–II v4.0 values
7. v5 runtime architecture/contracts with v8 extensions
8. v3.9 / v3.8 / v3.7 / v3.6
9. v3.5 and older historical material

## Validation truth

The handoff/package validators verify specification integrity, file presence, JSON parsing and key invariants.
They do **not** prove Flutter/Dart runtime correctness.

Still required locally:

```bash
python docs/v4/preimplementation/validate_repo_handoff_v8_1.py
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```
