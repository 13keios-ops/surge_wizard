# AGENT_START_HERE — Surge Wizard v4

> **Purpose:** this repository is the complete implementation handoff for the current Surge Wizard v4 design work.
> Preserve first, prune later. Historical material is intentional.

## Authority order

When records conflict:

1. The user's newest explicit instruction.
2. `docs/v4/final/MASTER_SPEC.md` and the exact compressed master it points to.
3. `docs/v4/decisions/COMPLETE_DECISION_LOG.md`.
4. Current v4 source and tests.
5. Latest implementation/validation notes.
6. Historical artifacts in `artifacts/v4/complete_handoff/`.
7. Older repository documents.

## Read first

```text
AGENT_START_HERE.md
docs/v4/final/MASTER_SPEC.md
docs/v4/decisions/COMPLETE_DECISION_LOG.md
docs/v4/final/IMPLEMENTATION_VALIDATION.md
docs/v4/VERTICAL_SLICE_V3_5.md
validation/v4/README.md
```

Then inspect:

```text
lib/main_v4_preview.dart
lib/core/*_v4.dart
lib/screens/*_v4.dart
lib/widgets/*_v4.dart
test/*_v4_test.dart
assets/data/v4_vertical_slice_encounters.json
tool/v4_headless_sim.dart
tool/v4_dungeon_run_sim.dart
```

## Complete generated-artifact handoff

The repository contains:

```text
artifacts/v4/complete_handoff/Surge_Wizard_v4_COMPLETE_HANDOFF_CONTENT_2026-10-01.tar.xz
```

Archive SHA-256:

```text
1e3a7b89640377869b9598a92970bfd884a22aa08980d07067a9a76703101792
```

It contains the logical contents of **all 128 top-level Surge Wizard v4 generated artifacts still present in the generation workspace at handoff time**, plus latest extracted v3.5 working directories.

This includes historical master specs, detailed-spec package contents, code-package contents, design reports, camera/layout proof PNGs, CSV/JSON simulation outputs, static-check outputs, and the latest working snapshots.

Generated ZIP containers are recorded by original name/size/SHA-256 and their logical contents are extracted in the handoff archive. The goal is complete implementation-context preservation without storing many redundant nested compressed containers.

## Validation status

Three different things must not be confused:

- **Dart/Flutter source generated:** yes.
- **Python behavioral mirror actually executed:** yes.
- **Dart/Flutter analyze/test/build actually executed in the generation environment:** no; that environment did not contain Dart/Flutter SDKs.

Before accepting the code as build-clean, run locally:

```bash
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

Do not call Python mirror results “Dart engine test results.”

## Conversation coverage

This handoff preserves the **generated artifacts and consolidated decisions available at handoff time**. It is not a byte-for-byte export of every ChatGPT message.

If a verbatim chat transcript is later desired, export it separately and store it under:

```text
artifacts/v4/raw_chat_export/
```

## Legacy protection

Legacy portrait entry point:

```text
lib/main.dart
```

v4 landscape entry point:

```text
lib/main_v4_preview.dart
```

Do not replace the legacy entry point until an explicit migration decision is made.

## Next direction

After this preservation commit, continue concretizing the implementation specification. The most recent next-work direction was:

```text
Path Preview
pre-commit Hit / Effect / Friendly-Fire preview
detailed Combat Log
Safe Point save/restore serialization
then real Flutter analyze/test/device validation
```
