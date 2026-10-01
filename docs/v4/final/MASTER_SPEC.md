# Surge Wizard v4 — Authoritative Master Index (2026-10-01)

The current specification is layered because later work refines different subsystems without rewriting the complete historical record.

## Single complete handoff entry

Start here:

```text
artifacts/v4/FINAL_COMPLETE_HANDOFF/00_START_HERE.md
```

To reconstruct the complete design/specification history from the v4 direction change through v5.9 as one workspace/package:

```bash
bash artifacts/v4/FINAL_COMPLETE_HANDOFF/build_final_complete_handoff.sh
```

The two older archive files are now provenance components of that one handoff, not separate authorities an implementation agent must reason about manually.

## First authority documents

Read:

```text
docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md
docs/v4/final/FINAL_AUDIT_2026-10-01.md
```

They resolve known version collisions and validation status.

## Base specification

Integrated v3.5 master:

```text
docs/v4/final/MASTER_SPEC_v3.5.md.xz
```

v3.6 full implementation supplement:

```text
docs/v4/final/IMPLEMENTATION_SPEC_v3.6_FULL.md.xz
```

## Later refinement layers

```text
v3.6  Path/Combat Preview, Combat Log, Safe Point persistence
v3.7  equipment/stat/spellbook/enemy-AI/reward/game-flow architecture
v3.8  T0–T2 equipment, C0–C3 spells, Hub/Shop/Party UX, slice noncombat
v3.9  XP/world/quest/quick-item/companion/tutorial/journal
v4.0  reconciled ACT I–II content numbers and flow
v4.x staged batch  detailed historical content/UX drafts where non-conflicting
v5.0–v5.9  schema, validator target, loader, interpreter, navigation, verification, work packages, milestones
```

All exact generated source artifacts for these layers are reachable from the single FINAL_COMPLETE_HANDOFF entry.

## Historical provenance components

The builder verifies and merges:

```text
artifacts/v4/complete_handoff/Surge_Wizard_v4_COMPLETE_HANDOFF_CONTENT_2026-10-01.tar.xz
SHA-256 1e3a7b89640377869b9598a92970bfd884a22aa08980d07067a9a76703101792

artifacts/v4/complete_handoff/Surge_Wizard_v4_POST_V3_6_COMPLETE_HANDOFF_2026-10-01.tar.xz
SHA-256 c518cb389d95d0111cbb1d1c4520aed5d6665f4de19b6c5d21b06670c55b5601
```

The first component begins at the 2026-09-29 v4 Planning Baseline / landscape party-RPG direction change, rather than beginning at v3.7.

## Current implementation status

The live repository contains the landscape v4 prototype source plus the specification handoff.

Later v3.6–v5.9 documents are specifications and planning outputs; they are not proof that all of those features are already implemented.

Real Flutter/Dart build/test remains an implementation gate.
