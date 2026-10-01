# Surge Wizard v4 — Authoritative Master Index (2026-10-01)

The current specification is deliberately **layered**, because later work refines different subsystems without rewriting the entire historical master into one monolithic file.

## First authority

Read:

```text
docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md
docs/v4/final/FINAL_AUDIT_2026-10-01.md
```

Those documents resolve known version collisions and validation status.

## Base

Integrated v3.5 master:

```text
docs/v4/final/MASTER_SPEC_v3.5.md.xz
```

v3.6 full implementation supplement:

```text
docs/v4/final/IMPLEMENTATION_SPEC_v3.6_FULL.md.xz
```

## Later refinements

The exact v3.7→v5.9 generated sources, reconciled current content examples, and validation outputs are preserved in:

```text
artifacts/v4/complete_handoff/Surge_Wizard_v4_POST_V3_6_COMPLETE_HANDOFF_2026-10-01.tar.xz
```

SHA-256:

```text
c518cb389d95d0111cbb1d1c4520aed5d6665f4de19b6c5d21b06670c55b5601
```

Effective layering:

```text
v3.6  Path/Combat Preview, Combat Log, Safe Point persistence
v3.7  equipment/stat/spellbook/enemy-AI/reward/game-flow architecture
v3.8  T0–T2 equipment, C0–C3 spells, Hub/Shop/Party UX, slice noncombat
v3.9  XP/world/quest/quick-item/companion/tutorial/journal
v4.0  reconciled ACT I–II content numbers and flow
v4.x staged batch  detailed historical content/UX drafts where non-conflicting
v5.0–v5.9  schema, validator target, loader, interpreter, navigation, verification, work packages, milestones
```

## Current implementation status

The repository contains the v3.5-era landscape prototype source plus later specification work.

Later v3.6–v5.9 documents are not themselves proof that those features were implemented.

Real Flutter/Dart build/test remains an implementation gate.
