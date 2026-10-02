# Surge Wizard v4 — Pre-Implementation Handoff v8.1

This directory contains the correction overlay and final fresh-clone handoff checks.

## Read order

1. `FINAL_HANDOFF_RECHECK_v8.1.md`
2. `../final/CURRENT_AUTHORITY_2026-10-03.md`
3. `LOCAL_AGENT_BOOTSTRAP_v8.0.md` (compatibility filename; content is v8.1)
4. `CANONICAL_FLAG_MAP_v8.0.json`
5. `M08_WEST_ANCHOR_RESTORATION_v8.0.md`
6. `XP_TRANSITION_FLOOR_v8.0.json`
7. `ENCOUNTER_RUNTIME_EXTENSION_v8.0.json`
8. `NARRATIVE_RUNTIME_NORMALIZATION_v8.0.json`
9. `RESOURCE_ID_NORMALIZATION_v8.0.json`
10. `POI_EVENT_AUTHORITY_v8.0.json`
11. `LATE_GEAR_ACQUISITION_GAPS_v8.0.json`
12. `ACTII_BOSS_NARRATIVE_PATCH_v8.0.md`
13. `validate_repo_handoff_v8_1.py`

## Status

The earlier v8.0 audit was a pre-repair snapshot. Its discovered issues are retained for provenance.
The current status is determined by `FINAL_HANDOFF_RECHECK_v8.1.md` and the fresh-clone validator.

The validated v6/v7 structured packages and their original validators are committed in the repository.
No external local-only package is required to discover the current design.

Flutter/Dart build/test is still a separate implementation-environment gate.
