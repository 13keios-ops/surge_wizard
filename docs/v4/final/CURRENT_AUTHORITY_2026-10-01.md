# Surge Wizard v4 — Current Authority / Agent Handoff (2026-10-01)

This file is the first authority index for the current handoff.

## Priority

1. Newest explicit user instruction.
2. This authority/resolution document and `FINAL_AUDIT_2026-10-01.md`.
3. The reconciled ACT I–II v4.0 content spec/data inside the post-v3.6 handoff archive for ACT I–II encounter/reward numbers.
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

## Post-v3.6 complete source

Exact archive:

```text
artifacts/v4/complete_handoff/Surge_Wizard_v4_POST_V3_6_COMPLETE_HANDOFF_2026-10-01.tar.xz
```

SHA-256:

```text
c518cb389d95d0111cbb1d1c4520aed5d6665f4de19b6c5d21b06670c55b5601
```

After extraction, use:

```text
Surge_Wizard_v4_FINAL_HANDOFF_2026-10-01/current/
Surge_Wizard_v4_FINAL_HANDOFF_2026-10-01/validation/
```

The archive also preserves all staged v4.0–v4.9 and generated v5.0–v5.9 source artifacts.

## Implementation contracts

Use the v5 documents for architecture:

```text
v5.0 schemas/stable IDs
v5.1 validator/CI target
v5.2 migration dependency order
v5.3 content loader/repositories
v5.4 quest/event interpreter
v5.5 Flutter state/navigation
v5.6 encounter/map contract
v5.7 verification pipeline
v5.8 work packages
v5.9 milestones
```

Use the archive's `current/contract_examples_reconciled/` rather than historical v5 ACT I example values when seeding current content.

## Validation status

Actually checked at handoff:

```text
UTF-8 / JSON integrity
content counts / ID uniqueness
reconciled encounter XP/count invariants
historical v5 example validator
current handoff validator
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
