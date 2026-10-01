# AGENT_START_HERE — Surge Wizard v4

> This repository is the implementation handoff. Preserve historical material; use the authority index to decide what is current.

## Read first

```text
docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md
docs/v4/final/FINAL_AUDIT_2026-10-01.md
docs/v4/final/MASTER_SPEC.md
docs/v4/decisions/COMPLETE_DECISION_LOG.md
docs/v4/final/IMPLEMENTATION_VALIDATION.md
```

Then inspect current v4 source:

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

## Full specification archives

Pre-v3.6 handoff:

```text
artifacts/v4/complete_handoff/Surge_Wizard_v4_COMPLETE_HANDOFF_CONTENT_2026-10-01.tar.xz
```

Post-v3.6 through v5.9 handoff:

```text
artifacts/v4/complete_handoff/Surge_Wizard_v4_POST_V3_6_COMPLETE_HANDOFF_2026-10-01.tar.xz
```

Extract the post-v3.6 archive:

```bash
mkdir -p /tmp/surge_v4_post36
tar -xJf artifacts/v4/complete_handoff/Surge_Wizard_v4_POST_V3_6_COMPLETE_HANDOFF_2026-10-01.tar.xz \
  -C /tmp/surge_v4_post36
```

Inside it, read:

```text
Surge_Wizard_v4_FINAL_HANDOFF_2026-10-01/CURRENT_AUTHORITY.md
Surge_Wizard_v4_FINAL_HANDOFF_2026-10-01/FINAL_AUDIT_2026-10-01.md
Surge_Wizard_v4_FINAL_HANDOFF_2026-10-01/current/
Surge_Wizard_v4_FINAL_HANDOFF_2026-10-01/validation/
```

## Critical authority resolution

The staged v4.0–v4.9 batch is historical where it conflicts with the later integrated ACT I–II v4.0 content reconciliation.

Current ACT I–II encounter/reward authority:

```text
ACT I 9 encounters
Mine 5
Swamp 5
Ruin 5

Core combat XP:
ACT I 355
Mine 295
Swamp 285
Ruin 303
```

See the final audit for details.

## Validation truth

Actually executed/checkable in the handoff:
- Python behavioral mirror runs from earlier stages.
- source/static checks recorded in validation artifacts.
- post-v3.6 UTF-8/JSON integrity audit.
- current handoff content validator.

Still **not** verified in the generation environment:

```bash
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

Do not claim Dart/Flutter build/test success until those actually run.

## Legacy protection

Legacy portrait entry remains `lib/main.dart`.
Landscape v4 preview remains `lib/main_v4_preview.dart`.

Do not replace the legacy entry point without an explicit migration decision.

## Next implementation

Use the v5.8 work packages / v5.9 milestone order from the post-v3.6 archive.

Start with real Flutter/Dart validation and content-foundation migration, not more broad architecture design.
