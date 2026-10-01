# Surge Wizard v4 — Vertical Slice v3.5

This snapshot adds the landscape v4 combat prototype alongside the legacy portrait app.

## Included

- Independent landscape entry point: `lib/main_v4_preview.dart`
- B01–B05 encounter data and sequential run host
- Dynamic 8×6 / 9×7 / 10×7 hex boards
- Seeded CombatEngineV4, timeline, movement, opportunity attacks
- Spell targeting, stability, Unstable / Surge / Perfect Cast
- Status effects and barriers
- Kael / Nera companion actions
- Bone Heap boss behavior and telegraphs
- Balanced AUTO planner
- Manual radial skill UI, MOVE mode and opportunity warnings
- Headless Dart runner entry points and regression tests

## Run

```bash
flutter run -t lib/main_v4_preview.dart
```

Headless runners:

```bash
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
```

## Validation status

The source bundle was structurally checked during generation, but the generation
environment did not have a Dart/Flutter SDK. Therefore this commit does **not**
claim a successful `flutter analyze`, `flutter test`, or device build yet.

The earlier 5,000-run balance numbers were produced by a Python behavioral mirror,
not by the Dart runner. The Dart runners in this commit should be executed in a
Flutter/Dart development environment before treating those numbers as final.

## Legacy protection

The existing `lib/main.dart` portrait entry point is intentionally unchanged.
v4 is entered through `lib/main_v4_preview.dart`.
