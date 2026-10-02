# Surge Wizard v4 — Current Authority / Agent Handoff (2026-10-02)

## Current status

The fresh-clone handoff repair is documented by:

```text
docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.1.md
docs/v4/preimplementation/validate_repo_handoff_v8_1.py
```

## Authority order

1. Newest explicit user instruction.
2. This current authority + `FINAL_HANDOFF_RECHECK_v8.1.md`.
3. v8 pre-implementation correction files.
4. v7 Full Narrative package.
5. v6 Remaining Design Complete package.
6. reconciled ACT I–II v4.0 numbers.
7. v5.0–v5.9 runtime architecture/schema/loader/interpreter/work-package contracts, with v8 extensions.
8. v3.9 / v3.8 / v3.7 / v3.6.
9. v3.5 and older historical sources.

**Exception:** persisted story-flag names use the stable vocabulary normalized by
`docs/v4/preimplementation/CANONICAL_FLAG_MAP_v8.0.json`.

## Historical documents

The following are preserved for provenance only and are not current authority:

```text
HANDOFF.md
GAME_DESIGN.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md
docs/v4/final/FINAL_AUDIT_2026-10-01.md
```

## Mandatory v8 corrections

- Restore M08 West Anchor; it must not auto-resolve.
- Circle 5 gate commits only after M04 is committed and D05 is resolved.
- Transition minimum cumulative XP: II→III 1640, III→IV 4130, IV→V 7030.
- Preserve P01–P20 / E01–E24.
- Use canonical story flags; party active/bench is PartyState, not StoryFlag.
- Extend encounter runtime for scripted interactables and nonstandard objectives.
- Freeze stable semantic narrative/localization IDs before production import.

## Package locations

```text
docs/v4/design/v6/       validated v6 authoring package + JSON + validator
docs/v4/narrative/v7/    validated v7 narrative package + JSON + validator
docs/v4/preimplementation/ current correction overlays + handoff validator
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

## Validation truth

Package/static validators can verify handoff integrity.
They do **not** prove Flutter/Dart compilation or gameplay balance.

Run locally:

```bash
python docs/v4/preimplementation/validate_repo_handoff_v8_1.py
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```
