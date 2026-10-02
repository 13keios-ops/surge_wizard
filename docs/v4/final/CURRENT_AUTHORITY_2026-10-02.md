# Surge Wizard v4 — Current Authority / Agent Handoff (2026-10-02)

## Priority

1. Newest explicit user instruction.
2. v8 pre-implementation audit/corrections.
3. v7 Full Narrative Script.
4. v6 Remaining Design Complete.
5. This authority document.
6. reconciled ACT I–II v4.0 numbers.
7. v5.0–v5.9 architecture/schema/loader/interpreter/work-package contracts, as extended by v8.
8. v3.9 / v3.8 / v3.7 / v3.6.
9. v3.5 and older historical sources.

**Exception:** persisted story-flag names use the original v1.5 vocabulary normalized by
`docs/v4/preimplementation/CANONICAL_FLAG_MAP_v8.0.json`.

## Mandatory corrections

- Restore M08 West Anchor; it must not auto-resolve.
- Circle 5 story gate commits only after M04 is committed and D05 is resolved.
- Main-path transition XP minimums: ACT II→III 1640, ACT III→IV 4130, ACT IV→V 7030.
- v6/v7 are authoring sources; normalize/compile into v5-style runtime repositories.
- Root `GAME_DESIGN.md` and `HANDOFF.md` are legacy pre-v4 history.

## Validation truth

Verified: v6 campaign structural validator, v7 narrative continuity validator, v8 preimplementation correction validator, prior UTF-8/JSON/handoff integrity checks.

Still required locally:
```bash
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

## Implementation order

```text
WP00 baseline + real SDK validation
WP01 canonical schema/validator/content foundation
WP02 character/equipment/derived stats
WP03 spellbook/prepared/mastery
WP04 encounter/reward migration
WP05 save/durable flow + canonical flags
WP06 world/quest/narrative interpreter
WP07 ACT I
WP08 Ruin Vertical Slice
WP09 Mine
WP10 Swamp
WP11 ACT II resolver/Arken gate
WP12 verification
then ACT III -> IV -> V
```
