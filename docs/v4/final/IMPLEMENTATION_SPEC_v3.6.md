# Surge Wizard v4 — Implementation Specification v3.6

The exact full v3.6 specification is preserved as:

```text
docs/v4/final/IMPLEMENTATION_SPEC_v3.6_FULL.md.xz
```

SHA-256 of the original uncompressed Markdown artifact:

```text
198d4dc4ed59afe6fe5521b7ea6f506405b99c9529533591122312987c735e22
```

Extract locally:

```bash
xz -dc docs/v4/final/IMPLEMENTATION_SPEC_v3.6_FULL.md.xz \
  > /tmp/Surge_Wizard_v4_IMPLEMENTATION_SPEC_v3.6.md
```

## Covered topics

The full specification fixes implementation-ready behavior for:

- two-stage MOVE destination preview/confirmation
- deterministic engine-authoritative shortest paths
- per-edge Opportunity risk preview
- terrain/path cost display
- pure pre-commit action prediction that consumes zero RNG/state
- exact 216-outcome 3d6 Hit / Effect / Stability probabilities
- damage, Cover, Barrier, boss-control and immunity preview
- AoE target enumeration
- harmful Friendly-Fire warning and second confirmation
- deterministic timeline ghost position
- structured Combat Event / Combat Log / Activation grouping
- Minimal / Normal / Detailed log presentation
- versioned Safe Point save/restore
- checkpoint state vs durable run state separation
- no consumable refund on wipe/force-close
- idempotent encounter rewards
- primary/backup save slots
- schema migration and corrupt-save recovery
- required acceptance tests and implementation order

## Authority

For the topics above, the full v3.6 document supersedes overlapping v3.5 wording.
For all other areas, the integrated v3.5 master remains authoritative unless a newer user instruction says otherwise.

**Note:** v3.6 is a specification pass. These features are not yet claimed as implemented or Flutter/Dart-tested.
