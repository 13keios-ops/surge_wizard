> ⛔ **SUPERSEDED CURRENT-AUTHORITY SNAPSHOT (2026-10-01).**  
> Do not use this file as current implementation authority. Use `docs/v4/final/CURRENT_AUTHORITY_2026-10-03.md`.  
> Preserved for provenance only.

# Surge Wizard v4 — Final Consistency Audit (2026-10-01)

## Result

**Handoff status: PASS WITH EXPLICIT RESOLUTIONS.**

No post-v3.6 source file failed UTF-8 decoding. All JSON files in the reviewed v3.7–v5.9 artifact set parse successfully. The historical v5 example validator reports `VALIDATION OK`; the reconciled handoff validator reports `CURRENT_HANDOFF_VALIDATION_OK`.

This does **not** mean Flutter/Dart compilation has been executed. It has not been verified in the generation environment.

## Reviewed scope

- v3.7 implementation architecture.
- v3.8 equipment/spell/hub/noncombat content + JSON.
- v3.9 progression/world/quest + JSON.
- reconciled ACT I–II content v4.0 + JSON.
- staged v4.0–v4.9 ten-spec batch and structured data.
- v5.0–v5.9 schema/validator/loader/interpreter/navigation/map/test/work-package milestone batch.
- current GitHub v4 source/test handoff state.

Files reviewed: **49** post-v3.6 source files.
UTF-8 decode failures: **0**.
Replacement-character files: **0**.
JSON parse failures: **0**.

## Resolution 1 — ACT I/II content authority

There are two v4 content generations.

The staged `v4.0-v4.9` batch is preserved as design history, but its encounter XP/count data is **not current authority**.

Historical staged values:

```text
ACT I combat XP: 420
Mine combat XP: 400
Swamp combat XP: 415
Ruin combat XP: 340
Encounter counts: ACT I 9 / Mine 6 / Swamp 6 / Ruin 5
```

The separate integrated `Surge_Wizard_v4_ACT1_ACT2_CONTENT_SPEC_v4.0_2026-10-01.md` explicitly reconciles XP double-counting and therefore wins on ACT I–II encounter/reward numbers.

Current reconciled values:

```text
Encounter counts: ACT I 9 / Mine 5 / Swamp 5 / Ruin 5
Core combat XP:
  ACT I 355
  Mine 295
  Swamp 285
  Ruin 303
Optional combat XP:
  ACT I 35
  Mine 55
  Swamp 55
  Ruin 45
Target total after authored noncombat XP:
  ACT I 390
  Mine 430
  Swamp 430
  Ruin 430
```

Historical v4.0–v4.9 narrative/UX details remain usable when they do not conflict with the reconciled content document.

## Resolution 2 — v3.9 node XP

v3.9 quest-node XP is planning/budget information, not an instruction to double-pay combat nodes.

Current payout source of truth:

```text
Encounter combat XP → EncounterDefinition.xpReward
Quest/noncombat XP → explicitly authored quest/discovery resolution
```

A COMBAT quest node does not automatically add the old planning XP again.

## Resolution 3 — v5 examples vs schemas

The **v5 architecture contracts and schemas remain useful/current**, but the generated historical v5 `examples/encounters_act1.json` and `examples/rewards.json` were built from the superseded staged v4 content numbers.

Therefore:

```text
v5 schemas / loader / repository / interpreter / CI design = current contract
historical v5 example values = reference only
```

The post-v3.6 archive contains `current/contract_examples_reconciled/`, regenerated from the reconciled v4.0 content data. Use those for implementation seeding.

## Resolution 4 — historical v5 validator scope

The generated v5 validator is a **scaffold**, not the complete CI implementation promised by the v5.1 specification. It validates structure, uniqueness and selected references but does not yet implement every domain/reachability rule listed in the document.

The new `validation/v4/validate_current_handoff.py` adds checks for current counts, spawn bounds, encounter/reward linkage and reconciled core XP. Production CI still needs the full v5.1 validator implementation.

## Resolution 5 — R06 human enemy placeholder

`human_bandit_tbd` exists in the v3.9 world-region draft but is not one of the approved 26 normal-monster art IDs and is not used by the reconciled ACT I/II encounter pack.

Current handling:

```text
Preserve the placeholder in historical v3.9 source.
Do not treat it as production-ready enemy content.
In reconciled world example, move it to deferredEnemyPlaceholders.
```

A future human-enemy content/art decision must explicitly resolve it.

## Resolution 6 — equipment slot wording

v3.8 resolves the v3.7 ambiguity:

```text
Visible initial equipment slots = Head / Clothing / Shoes / Weapon
Accessory/Relic may exist in engine data but is hidden until authored unlock.
```

## Resolution 7 — current validation truth

Verified in this handoff:

- JSON parse integrity.
- UTF-8 integrity.
- ID uniqueness for v3.8 equipment/spells and reconciled encounters.
- v3.8 equipment count = 34.
- v3.8 spell count = 30.
- v3.9 topology = 11 hubs / 14 regions / 9 dungeons.
- reconciled encounter count = 24.
- reconciled encounter enemy IDs all belong to the established normal/boss rosters.
- historical v5 validator execution = PASS.
- current handoff validator execution = PASS.

Not yet verified:

```text
flutter analyze
flutter test
flutter run
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
real-device touch/layout QA
```

Do not convert those into “passed” claims until actually executed in a Flutter/Dart environment.

## Remaining intentionally unresolved items

- `human_bandit_tbd` / human enemy production roster and art.
- C7 story-breakthrough details remain provisional.
- exact 90-cell world-map mask remains a map-proof task; topology is fixed first.
- v5 production schemas/validator need stricter domain definitions before shipping.
- ACT III–V mass content should not be implemented before M1–M8 gates in v5.9.

## Final recommendation to implementation agent

Start implementation rather than broad new architecture design.

Read `CURRENT_AUTHORITY_2026-10-01.md`, then implement from v5.8 work packages and v5.9 milestones. On content-number conflicts, the reconciled ACT I–II v4.0 data wins over the staged v4.0–v4.9 batch.
