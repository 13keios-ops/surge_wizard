# Surge Wizard (폭주 마법사) — v4

가로형 모바일 RPG. 플레이어는 마법사와 최대 2명의 동료로 파티를 구성하고,
월드 탐험·짧은 선택 이벤트·헥스 전술전투를 거쳐 ACT I~V를 진행한다.

## 현재 구현 기준

로컬 구현 에이전트는 다음 순서로 읽는다.

```text
CLAUDE.md
docs/v4/preimplementation/LOCAL_AGENT_BOOTSTRAP_v8.0.md
docs/v4/preimplementation/PREIMPLEMENTATION_FULL_AUDIT_v8.0.md
docs/v4/final/CURRENT_AUTHORITY_2026-10-02.md
AGENT_START_HERE.md
```

최신 본편 설계:
- `docs/v4/design/v6/`
- `docs/v4/narrative/v7/`
- `docs/v4/preimplementation/`

## Legacy 보호

`GAME_DESIGN.md`, `HANDOFF.md`, 그리고 `lib/main.dart`는 방향전환 전 세로형 로그라이트의
역사/레거시 구현을 보존한다. 현재 v4의 기준으로 사용하지 않는다.

Landscape v4 preview:

```bash
flutter run -t lib/main_v4_preview.dart
```

실제 로컬 구현 시작 전에는 반드시:

```bash
flutter pub get
flutter analyze
flutter test
dart run tool/v4_headless_sim.dart 5000
dart run tool/v4_dungeon_run_sim.dart 5000
```

을 실행하고 결과를 기록한다.
