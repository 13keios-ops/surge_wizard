# Surge Wizard v4 — Pre-Implementation Index

## Current gate

1. `FINAL_HANDOFF_RECHECK_v8.2.md`
2. `../final/CURRENT_AUTHORITY_2026-10-03.md`
3. `LOCAL_AGENT_BOOTSTRAP_v8.0.md`
4. `validate_repo_handoff_v8_2.py`

## v8 correction contracts

- `CANONICAL_FLAG_MAP_v8.0.json`
- `M08_WEST_ANCHOR_RESTORATION_v8.0.md`
- `XP_TRANSITION_FLOOR_v8.0.json`
- `ENCOUNTER_RUNTIME_EXTENSION_v8.0.json`
- `NARRATIVE_RUNTIME_NORMALIZATION_v8.0.json`
- `RESOURCE_ID_NORMALIZATION_v8.0.json`
- `POI_EVENT_AUTHORITY_v8.0.json`
- `LATE_GEAR_ACQUISITION_GAPS_v8.0.json`
- `ACTII_BOSS_NARRATIVE_PATCH_v8.0.md`

## Historical audit snapshots

- `PREIMPLEMENTATION_FULL_AUDIT_v8.0.md` — pre-repair snapshot.
- `FINAL_HANDOFF_RECHECK_v8.1.md` — first fresh-clone repair; superseded by v8.2 for current entry/reference/builder validation.
- `validate_repo_handoff_v8_1.py` — retained for provenance; use v8.2 now.
- `validate_v8_preimplementation.py` — v8 correction-contract validator, still called by v8.2.

## Current rule

Do not add another broad design layer before implementation.
Run `validate_repo_handoff_v8_2.py`, then real Flutter/Dart validation, then WP00→WP12.
