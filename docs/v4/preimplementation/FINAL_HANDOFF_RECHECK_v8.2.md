# Surge Wizard v4 — Final Handoff Recheck v8.2 (2026-10-03)

## Why this second recheck exists

The first v8.1 repair restored the missing v6/v7 structured packages and quarantined legacy authorities.
A second independent pass against the actual current GitHub tree found two remaining reference defects and one handoff-builder risk:

1. `CLAUDE.md` referenced `M08_WEST_ANCHOR_RESTORATION_v8.0.md` as a bare root-relative filename.
2. `docs/v4/final/MASTER_SPEC.md` referenced `validate_repo_handoff_v8_1.py` as if it lived in the final directory.
3. The unified builder still depended on two old binary provenance archives. Their Git-tree sizes are 7,527 bytes and 15,008 bytes; historical generation records for at least the post-v3.6 archive reported a different local size. Because the binary bytes cannot be revalidated through the text-only connector used for this audit, they are no longer an implementation prerequisite.

v8.2 fixes all three: current entry references are explicit repository paths, and the unified builder packages the validated live repository layers instead of extracting the old binary archives.

## Independent checks performed against current main

### v6 structured campaign data

Re-evaluated the original validator invariants directly from the committed JSON:

```text
ACT III encounters 14
ACT IV encounters 12
ACT V encounters 16
ACT V mandatory combat XP 2965
ACT V story XP 685
ACT III baseline end 3935
ACT IV baseline end 7000
late gear 40
regional events 98
tactical maps 38
choice combinations 648
errors 0
```

### v7 narrative data

Re-evaluated the original validator invariants directly from committed JSON:

```text
main scenes 65
companion PQ scenes 30
dialogue entries 1152
named NPCs 45
major-choice reactions 100
travel banter variants 20
combat barks 75
rumors 33
duplicate scene/dialogue IDs 0
audit/crosswalk errors 0
```

### v8 correction data

Confirmed:
- choice groups M01–M08 + C01
- M08 has 3 methods
- XP floors 1640 / 4130 / 7030
- canonical POIs 20
- side-event archetypes 24
- encounter runtime extension includes nonstandard victory conditions
- `google_mobile_ads` absent from `pubspec.yaml`

## Current handoff rule

The implementation handoff must be reproducible from a fresh clone using committed live files.
Historical binary archives remain provenance-only; they are not required to validate or build the current implementation handoff.

## Final spec verdict

**GO for local implementation bootstrap after `validate_repo_handoff_v8_2.py` passes.**

This verdict means the specification/handoff is internally consistent enough to start implementation.
It does **not** mean Flutter/Dart compile, tests, headless simulations, or device QA have passed.

## First local runtime gate

```bash
python docs/v4/preimplementation/validate_repo_handoff_v8_2.py
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
flutter run -t lib/main_v4_preview.dart
```
