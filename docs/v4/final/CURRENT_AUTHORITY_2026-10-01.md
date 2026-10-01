# Surge Wizard v4 — Current Authority / Agent Handoff (2026-10-01)

## Single handoff entry point

The complete design/specification history from the v4 direction change onward is now exposed through:

```text
artifacts/v4/FINAL_COMPLETE_HANDOFF/00_START_HERE.md
artifacts/v4/FINAL_COMPLETE_HANDOFF/build_final_complete_handoff.sh
```

The build script merges the two provenance archives into one workspace/package. The old archive split is no longer something an implementation agent needs to reason about manually.

## Priority

1. Newest explicit user instruction.
2. This authority document and `FINAL_AUDIT_2026-10-01.md`.
3. The reconciled ACT I–II v4.0 content for ACT I–II encounter/reward numbers.
4. v5.0–v5.9 architecture contracts for schema/loader/repository/interpreter/navigation/testing/work-package structure.
5. v3.9 for level/XP framework, world topology, quick items, companion progression, tutorial, journal.
6. v3.8 for early equipment, C0–C3 spell catalog, Hub/Shop/Party UX and Vertical Slice noncombat flow.
7. v3.7 for equipment/stat/spellbook/enemy-AI/reward/game-flow architecture not superseded above.
8. v3.6 for Path Preview / Combat Preview / Combat Log / Safe Point persistence.
9. v3.5 integrated master for areas not superseded by later documents.
10. staged/historical artifacts.

## Important version-name collision

The staged `v4.0-v4.9` bundle and the later integrated `ACT1_ACT2_CONTENT_SPEC_v4.0` overlap.

For ACT I–II encounter count / XP / reward numbers, **the integrated reconciled v4.0 wins** because it explicitly resolves XP double-counting and matches the intended ACT progression budgets.

The staged ten-file batch remains valuable for detailed prose and decision history when it does not conflict.

## Provenance components

The unified handoff builder verifies these existing repository archives:

```text
Surge_Wizard_v4_COMPLETE_HANDOFF_CONTENT_2026-10-01.tar.xz
SHA-256 1e3a7b89640377869b9598a92970bfd884a22aa08980d07067a9a76703101792
extracted files 1681

Surge_Wizard_v4_POST_V3_6_COMPLETE_HANDOFF_2026-10-01.tar.xz
SHA-256 c518cb389d95d0111cbb1d1c4520aed5d6665f4de19b6c5d21b06670c55b5601
extracted files 85
```

Together they preserve the v4 direction-change baseline through v5.9.

## Validation status

Actually checked at handoff:

```text
UTF-8 / JSON integrity
content counts / ID uniqueness
reconciled encounter XP/count invariants
historical v5 example validator
current handoff validator
archive SHA/component inclusion checks
```

Still required in a real Flutter/Dart environment:

```bash
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

## Implementation start

Preferred next work:

```text
WP00 baseline preservation
WP01 schema/validator/content foundation
WP02 character/equipment/derived stats
WP03 spellbook/prepared/mastery
WP04 encounter/reward migration
WP05 save/durable flow
WP06 world/quest interpreter
WP07 ACT I
WP08 Ruin Vertical Slice on final architecture
WP09 Mine
WP10 Swamp
WP11 ACT II resolver/Arken gate
WP12 verification
```

Do not start broad ACT III–V content implementation before the core migration and real Flutter validation gates are stable.
