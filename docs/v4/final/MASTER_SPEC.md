# Surge Wizard v4 — Authoritative Master Index (2026-10-03)

## Start here

```text
docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.2.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-03.md
docs/v4/preimplementation/LOCAL_AGENT_BOOTSTRAP_v8.0.md
docs/v4/design/v6/00_INDEX.md
docs/v4/narrative/v7/00_INDEX.md
```

## Layer order

```text
v8.2  fresh-clone authority/reference/builder recheck
v8.0  implementation correction/normalization overlay
v7.x  full narrative/NPC/companion/choice/epilogue
v6.x  ACT III–V completion + late progression + campaign audit
v5.x  runtime schema/validator/loader/interpreter/work packages
v4.0  reconciled ACT I–II numbers
v3.9  progression/world/quest/quick items/companion/tutorial/journal
v3.8  early equipment/C0–C3/hub/shop/party
v3.7  equipment/stat/spellbook/AI/reward/game-flow
v3.6  preview/log/safe-point
v3.5  integrated baseline where not superseded
```

Root `GAME_DESIGN.md` and `HANDOFF.md` are historical.

## v8/v8.2 implementation overrides

- Restore M08 West Anchor.
- Canonicalize persisted story flags.
- Circle 5 gate after M04/D05 resolution.
- Main-path transition XP floors.
- Preserve P01–P20 / E01–E24.
- Extend encounter/narrative runtime contracts before importing late content.
- Use `docs/v4/preimplementation/validate_repo_handoff_v8_2.py` for the fresh-clone spec gate.
- The unified handoff builder packages live validated repository layers; old binary provenance archives are not required.

Real Flutter/Dart build/test remains a separate implementation gate.
