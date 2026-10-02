# Surge Wizard v4 — FINAL COMPLETE HANDOFF

This is the portable **implementation handoff** for the current v4 landscape party RPG.

## Current authority

```text
CLAUDE.md
docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.2.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-03.md
docs/v4/final/MASTER_SPEC.md
```

## Build model

The handoff is built from the **validated live repository tree**:

```text
docs/v4/final/
docs/v4/design/v6/
docs/v4/narrative/v7/
docs/v4/preimplementation/
lib/
test/
tool/
assets/data/
```

Historical binary archives under `artifacts/v4/complete_handoff/` remain provenance-only.
They are not required to validate or build the current implementation handoff.

## First local gate

```bash
python docs/v4/preimplementation/validate_repo_handoff_v8_2.py
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

The Python handoff validator verifies specification/package integrity, not Flutter runtime correctness.
