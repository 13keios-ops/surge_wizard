# v3.6 Decision Supplement

This file records the decisions added after the v3.5 handoff. Full detail is in:

```text
docs/v4/final/IMPLEMENTATION_SPEC_v3.6.md
```

## Path Preview

- MOVE becomes two-stage: first tap previews; second tap or confirm commits.
- Engine pathfinder is authoritative.
- Path tie-break is deterministic.
- Opportunity risk is evaluated per movement edge.
- Telegraph has higher visual priority than path preview.
- Preview never mutates position/RNG/reaction/timeline.
- Nera Smoke Step / teleport / disengage preview has no opportunity edge.

## Combat Prediction

- Preview is pure and consumes zero RNG.
- UI and Balanced AUTO must share one exact 3d6 / 216-outcome probability helper.
- Direct ranged attacks expose Cover +2 EVA in the reason line.
- Spell preview separates Stability, direct Hit, and Effect probability.
- Boss control conversion and immunity are shown before commit.
- Harmful ally impact receives an explicit friendly-fire warning and second confirmation.
- Timeline shows a deterministic ghost position using the same delay function as the engine.

## Combat Log

- Keep low-level engine events structured.
- Group human-readable logs by activation.
- Presentation levels: Minimal / Normal / Detailed.
- Detailed data can include dice, bonuses, mitigation, Barrier absorption, HP/MP before-after and timeline changes.
- Internal RNG state is development/export only and not shown in normal player UI.

## Save / Restore

- v4 first release saves between encounters / at Safe Points, not arbitrary mid-action combat.
- Checkpoint HP/MP/buffs are rollback state.
- Potions, committed rewards, route/story flags and attempt counter are durable state and do not roll back.
- Potion consumption is saved immediately to prevent force-close refund exploits.
- Encounter rewards are idempotent through completed/claimed ID sets.
- Initial storage uses existing shared_preferences dependency with versioned JSON.
- Primary + backup slots are required.
- Corrupt primary falls back to backup; two corrupt copies must not silently overwrite themselves with a New Run.
- Save schema is versioned and migratable.
- Retry encounter seed is derived from run seed + encounter ID + attempt.

## Implementation order

1. pathfinder/tests
2. shared probability helper
3. pure combat-preview model
4. path UI
5. combat-prediction UI
6. structured combat log
7. log UI
8. save schema/codec
9. save repository/backup
10. Vertical Slice host integration
11. real local Flutter analyze/test
12. Dart headless baseline
13. real-device QA
