# Surge Wizard v4 — Current Authority / Agent Handoff (2026-10-03)

## Status

**Fresh-clone handoff: GO for implementation bootstrap.**  
**Flutter/Dart runtime validation: still pending and must be the first local implementation gate.**

The repeated-retry handoff was independently rechecked and repaired in:

```text
docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.1.md
docs/v4/preimplementation/validate_repo_handoff_v8_1.py
```

## Authority order

1. Newest explicit user instruction.
2. This document + `FINAL_HANDOFF_RECHECK_v8.1.md`.
3. v8 correction/normalization files in `docs/v4/preimplementation/`.
4. v7 Full Narrative package in `docs/v4/narrative/v7/`.
5. v6 Remaining Design Complete package in `docs/v4/design/v6/`.
6. reconciled ACT I–II v4.0 values.
7. v5.0–v5.9 runtime architecture/schema/loader/interpreter/work-package contracts, with v8 extensions.
8. v3.9 / v3.8 / v3.7 / v3.6.
9. v3.5 and older historical sources.

### Persisted-state exception

Persist story flags using:
`docs/v4/preimplementation/CANONICAL_FLAG_MAP_v8.0.json`.

v6/v7 renamed tokens are authoring/migration aliases, not parallel durable keys.
Party active/bench state is PartyState, not StoryFlag.

## Explicit superseded sources

These remain for provenance only:

```text
GAME_DESIGN.md
HANDOFF.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md
docs/v4/final/FINAL_AUDIT_2026-10-01.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-02.md
```

## Mandatory implementation corrections

- M08 West Anchor remains a Major Choice; do not auto-resolve it.
- Circle 5 story gate commits only after M04 is committed and D05 is resolved.
- Main-path cumulative XP minimums:
  - ACT II→III: 1640
  - ACT III→IV: 4130
  - ACT IV→V: 7030
- Preserve P01–P20 and E01–E24 canonical identities.
- v6/v7 JSON is authoring source; compile/normalize into runtime repositories.
- Encounter runtime must support scripted interactables and nonstandard victory/failure objectives.
- Freeze stable semantic narrative/localization IDs before production import.
- Do not restore rewarded ads, gems, deck-slot monetization, or the pre-v4 manual-reroll core.

## Complete committed authoring packages

```text
docs/v4/design/v6/
  Markdown specs
  structured JSON
  checkpoint audits
  manifest
  original validator + validation log

docs/v4/narrative/v7/
  full scripts
  structured JSON
  checkpoint audits
  dialogue catalog
  audit data
  manifest
  original validator + validation log
```

## First local gate

Run from a fresh clone:

```bash
python docs/v4/preimplementation/validate_repo_handoff_v8_1.py
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

The Python handoff validators verify specification/package integrity only.  
Do not claim Flutter/Dart validation passed until those commands actually execute locally.

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
then ACT III → IV → V
```
