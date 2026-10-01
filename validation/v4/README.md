# validation/v4

Validation assets are engineering evidence.

## Current truth

- v4 source code exists.
- Python behavioral mirrors were actually executed.
- Dart/Flutter compilation/tests were not executed in the generation environment.
- Final acceptance requires local Dart/Flutter validation.

## Re-run

```bash
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
```

After the first real Dart baseline is established, add it here without deleting older Python reference outputs.

Older static-check and simulation history is retained in the complete handoff archive.
