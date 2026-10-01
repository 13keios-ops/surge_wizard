# AGENT_START_HERE — Surge Wizard v4

> **Purpose:** complete implementation handoff. Preserve first, prune later.

## Authority order

1. newest explicit user instruction
2. `docs/v4/final/MASTER_SPEC.md`
3. `docs/v4/final/IMPLEMENTATION_SPEC_v3.6.md` for v3.6 topics
4. `docs/v4/decisions/COMPLETE_DECISION_LOG.md` + `docs/v4/decisions/V3_6_DECISIONS.md`
5. current v4 source/tests
6. latest implementation/validation notes
7. historical archive

## Read first

```text
AGENT_START_HERE.md
docs/v4/final/MASTER_SPEC.md
docs/v4/final/IMPLEMENTATION_SPEC_v3.6.md
docs/v4/decisions/V3_6_DECISIONS.md
docs/v4/decisions/COMPLETE_DECISION_LOG.md
docs/v4/final/IMPLEMENTATION_VALIDATION.md
docs/v4/VERTICAL_SLICE_V3_5.md
validation/v4/README.md
```

## Current implementation status

v3.5 source exists for the landscape Vertical Slice. v3.6 is the next implementation specification and has **not** yet been implemented.

Generation-environment validation distinction remains:

- Dart/Flutter source generated: yes
- Python behavioral mirror executed: yes
- Flutter analyze/test/build in generation environment: no SDK, therefore no

Before calling the source build-clean, run:

```bash
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

## Complete historical handoff

```text
artifacts/v4/complete_handoff/Surge_Wizard_v4_COMPLETE_HANDOFF_CONTENT_2026-10-01.tar.xz
```

Historical material is intentionally retained. Do not use age alone as authority.

## Legacy protection

Legacy portrait entry:

```text
lib/main.dart
```

v4 landscape entry:

```text
lib/main_v4_preview.dart
```

Do not replace the legacy entry point without an explicit migration decision.

## Current next implementation

Implement v3.6 in the order defined by `IMPLEMENTATION_SPEC_v3.6.md`:

```text
deterministic pathfinder
shared 3d6 probability helper
pure combat preview
Path Preview UI
Hit/Effect/Friendly-Fire prediction UI
structured Combat Log
Safe Point save/restore
then real Flutter/Dart validation
```
