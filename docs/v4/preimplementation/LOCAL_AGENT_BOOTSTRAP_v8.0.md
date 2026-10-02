# Surge Wizard v4 — LOCAL AGENT BOOTSTRAP v8.0

## STOP: do not trust the repo root legacy entry docs

Before implementing, treat these as **legacy pre-pivot historical files** unless v8 explicitly cites them:

```text
CLAUDE.md
HANDOFF.md
GAME_DESIGN.md
README.md (product description / entry instructions)
```

The current game is the **landscape 3-character tactical RPG**, not the old portrait manual-reroll/deck roguelite.

## Authority order for local implementation

1. New explicit user instruction.
2. `PREIMPLEMENTATION_FULL_AUDIT_v8.0.md` and all v8 correction files.
3. v7.0–v7.8 Full Narrative package.
4. v6.0–v6.3 Remaining Design Complete package.
5. repo `docs/v4/final/CURRENT_AUTHORITY_2026-10-01.md`.
6. reconciled ACT I–II v4.0 content for ACT I–II numbers.
7. v5 schema/loader/interpreter/work-package contracts, with the v8 schema extensions.
8. v3.9 / v3.8 / v3.7 / v3.6.
9. v3.5 and older historical sources.

Exception: persistent Story Flag names are stabilized by `STORY_FLAG_STATE_SPEC_v1.5` and `CANONICAL_FLAG_MAP_v8.0.json`.

## Mandatory corrections before content migration

```text
M08 West Anchor restored.
Circle5 gate commits after M04/D05 resolution.
Act transition XP floor:
  II→III min cumulative XP 1640
  III→IV min cumulative XP 4130
  IV→V min cumulative XP 7030
Canonical persistent flags only.
P01-P20 / E01-E24 preserved.
```

## Runtime data rule

v6/v7 JSON = AUTHORING SOURCE.

Do not deserialize those files directly as shipping runtime data.

Compile/migrate them into the v5 repositories after extending the encounter/narrative contracts described by v8.

## First commands in a real local repo

```bash
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```

Record actual failures; do not alter rules simply to make old tests pass.

## Legacy entry point

`lib/main.dart` remains legacy portrait mode.
Use `lib/main_v4_preview.dart` until a deliberate entry-point migration work package.

## Do not do

- do not implement rewarded ads from old pubspec comments.
- do not resurrect gems/deck-slot monetization from old docs.
- do not persist v6/v7 renamed flag aliases as new parallel flags.
- do not delete historical docs; quarantine them by authority.
- do not replace P01-P20 with v4.3 `poi.side.*`.
- do not drop M08.