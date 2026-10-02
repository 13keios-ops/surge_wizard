# Surge Wizard v4 — LOCAL AGENT BOOTSTRAP v8.1

> Filename retained as `LOCAL_AGENT_BOOTSTRAP_v8.0.md` for compatibility with earlier links.
> Content reflects the final fresh-clone recheck.

## Trusted current entry documents

```text
CLAUDE.md
README.md
AGENT_START_HERE.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-02.md
docs/v4/final/MASTER_SPEC.md
docs/v4/preimplementation/FINAL_HANDOFF_RECHECK_v8.1.md
```

## Historical / legacy only

```text
HANDOFF.md
GAME_DESIGN.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md
docs/v4/final/FINAL_AUDIT_2026-10-01.md
```

The current game is the **landscape 3-character tactical RPG**, not the old portrait manual-reroll/deck roguelite.

## Authority order

1. New explicit user instruction.
2. `CURRENT_AUTHORITY_2026-10-02.md` + `FINAL_HANDOFF_RECHECK_v8.1.md`.
3. All v8 correction files in this directory.
4. v7.0–v7.8 Full Narrative package.
5. v6.0–v6.3 Remaining Design Complete package.
6. reconciled ACT I–II v4.0 numbers.
7. v5 runtime architecture/schema/loader/interpreter contracts, with v8 extensions.
8. v3.9 / v3.8 / v3.7 / v3.6.
9. v3.5 and older historical sources.

Persisted story flags are normalized by `CANONICAL_FLAG_MAP_v8.0.json`.

## Mandatory corrections before content migration

```text
M08 West Anchor restored.
Circle5 gate commits after M04/D05 resolution.
II→III min cumulative XP 1640.
III→IV min cumulative XP 4130.
IV→V min cumulative XP 7030.
Canonical persistent flags only.
P01-P20 / E01-E24 preserved.
```

## Authoring vs runtime

The complete validated v6/v7 JSON packages are now committed in the repository.
They remain **AUTHORING SOURCE**, not ad-hoc runtime models.

Normalize/compile them into the canonical repositories after extending encounter/narrative contracts.
Do not create parallel rules inside widgets/screens.

## First commands in a fresh clone

```bash
python docs/v4/preimplementation/validate_repo_handoff_v8_1.py
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

Record actual SDK failures. Do not change game rules merely to satisfy legacy tests.

## Do not do

- do not implement rewarded ads or old gem/deck-slot monetization.
- do not persist v6/v7 flag aliases as parallel story flags.
- do not use `HANDOFF.md` or `GAME_DESIGN.md` as current authority.
- do not replace P01-P20 with v4.3 `poi.side.*`.
- do not drop M08.
- do not claim Flutter/Dart validation passed until it actually runs locally.
