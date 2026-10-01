# Surge Wizard v4 — FINAL COMPLETE HANDOFF

This directory is the **single handoff entry point** for the project after the game-design direction changed to the v4 landscape party RPG.

A future implementation agent should not need to know that the historical material was originally archived in two different batches.

## One logical handoff, full history

The repository already contains every archived source component:

```text
artifacts/v4/complete_handoff/Surge_Wizard_v4_COMPLETE_HANDOFF_CONTENT_2026-10-01.tar.xz
  → v4 direction-change baseline (2026-09-29) through the v3.6-era handoff

artifacts/v4/complete_handoff/Surge_Wizard_v4_POST_V3_6_COMPLETE_HANDOFF_2026-10-01.tar.xz
  → v3.7 through v5.9, reconciled current content, schemas, validator scaffolds and final audit
```

Use `build_final_complete_handoff.sh` to extract both into **one merged workspace** and optionally produce one physical `FINAL_COMPLETE_HANDOFF.tar.xz`.

The split source archives are provenance/storage components only. They are **not separate implementation authorities**.

## Read first

After cloning the repository:

```text
AGENT_START_HERE.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md
docs/v4/final/FINAL_AUDIT_2026-10-01.md
docs/v4/final/MASTER_SPEC.md
```

Then use this directory as the full-history entry point.

## Authority

When historical files disagree:

1. newest explicit user instruction
2. `docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md`
3. `docs/v4/final/FINAL_AUDIT_2026-10-01.md`
4. reconciled current documents
5. v5 architecture contracts for the topics they cover
6. v3.9 / v3.8 / v3.7 / v3.6 refinements
7. integrated v3.5 master
8. historical staged artifacts

Preserved history is context, not automatic authority.

## Current known ACT I–II content resolution

```text
Encounter counts
ACT I 9
Mine  5
Swamp 5
Ruin  5
Total 24

Core combat XP
ACT I 355
Mine  295
Swamp 285
Ruin  303
```

The later reconciled ACT I–II v4.0 data wins over the staged v4.0–v4.9 batch for those numbers.

## Validation truth

The archive contains the actual planning-time Python/static/balance outputs that were run, plus final handoff integrity checks.

It does **not** establish that the current Flutter/Dart source has passed:

```bash
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

Those remain implementation-environment gates.

## Why this exists

The user's handoff requirement is:

> Preserve everything from the v4 direction change onward so the implementation agent receives the complete reasoning/specification history and decides what to retain or discard.

Accordingly, old versions are intentionally not deleted.
