# Surge Wizard v4 — Authoritative Master Spec v3.6

The current authority is the combination of:

1. the integrated v3.5 master snapshot, and
2. the v3.6 implementation-spec supplement.

## Integrated v3.5 base

Exact file:

```text
docs/v4/final/MASTER_SPEC_v3.5.md.xz
```

SHA-256:

```text
231682a2788a2fe6f1336b1316d16bbdd2a6c036433008ee1f3de53ce4b28a85
```

Extract:

```bash
xz -dc docs/v4/final/MASTER_SPEC_v3.5.md.xz > /tmp/Surge_Wizard_v4_MASTER_v3.5.md
```

## v3.6 implementation supplement

```text
docs/v4/final/IMPLEMENTATION_SPEC_v3.6.md
```

Source artifact SHA-256:

```text
198d4dc4ed59afe6fe5521b7ea6f506405b99c9529533591122312987c735e22
```

v3.6 defines implementation-ready behavior for:

- deterministic Path Preview and move confirmation
- per-edge Opportunity risk preview
- exact 216-outcome Hit / Effect / Stability probability preview
- damage / Barrier / Cover / boss-control preview
- harmful Friendly-Fire warning and second confirmation
- deterministic timeline ghost preview
- structured Detailed Combat Log
- Safe Point save/restore schema
- consumable persistence across wipe/force-close
- idempotent reward commits
- primary/backup save recovery and schema migration

## Authority

When records conflict:

1. newest explicit user instruction
2. this v3.6 authority index
3. `IMPLEMENTATION_SPEC_v3.6.md` for its covered topics
4. integrated v3.5 master for all other topics
5. consolidated decision log
6. current code/tests
7. historical artifacts

The v3.6 document is a **specification**. It does not claim these features have already been implemented or Flutter/Dart-tested.
