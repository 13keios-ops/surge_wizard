# Surge Wizard v4 — Implementation / Validation Handoff

## Implemented source

The repository contains a separate v4 landscape prototype including:

- B01–B05 encounter loading.
- dynamic 8×6 / 9×7 / 10×7 Hex boards.
- seeded `nextActionTime` combat engine.
- Move → Act and opportunity attacks.
- Cover, activation statuses and barriers.
- direct spell-hit EVASION checks.
- Stability / Unstable / Surge / Perfect Cast.
- Kael / Nera actions.
- Bone Heap phases/Telegraphs.
- Balanced AUTO.
- radial/second-level skill UI.
- MOVE mode + opportunity-warning Hexes.
- sequential carry state, Boss Antechamber Safe Point and Ancient Focus.
- Dart headless runners and regression-test source.

## Actually executed during generation

- Python behavioral-mirror simulations.
- static source checks used during generation:
  - delimiter/brace balance.
  - file-size/split checks.
  - selected relative dependency/import checks in later stages.
- artifact packaging and SHA-256 manifest generation.

## Not executed in the generation environment

No Dart/Flutter SDK was installed there. Therefore the following were **not** actually run:

```bash
flutter analyze
flutter test
flutter run
dart run tool/v4_headless_sim.dart
dart run tool/v4_dungeon_run_sim.dart
```

Do not interpret the existence of test source as a passing test run.

## Required local validation

```bash
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

The Dart engine should become authoritative after local compilation/tests. Python mirror data remains useful as a reference/regression triangulation baseline.

## Known next QA risks

- compile/API mistakes invisible to text-only checks.
- UI overflow/touch ergonomics on real devices.
- final path preview.
- pre-commit Hit/Effect/Friendly-Fire prediction.
- detailed Combat Log.
- Safe Point serialization/persistence.
- companion defensive-AI balance.
- real human Bone Heap learning curve vs trained AUTO.

## Preservation

Full historical generated-artifact contents are under:

```text
artifacts/v4/complete_handoff/
```

Review the archive and authority rules before deleting anything.
