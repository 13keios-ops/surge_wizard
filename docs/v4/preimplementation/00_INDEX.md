# Surge Wizard v4 — Pre-Implementation Audit v8.0

이 패키지는 로컬 코딩 에이전트를 시작하기 직전의 **최종 오염/충돌/누락 교정 오버레이**다.

먼저 읽기:

1. `PREIMPLEMENTATION_FULL_AUDIT_v8.0.md`
2. `LOCAL_AGENT_BOOTSTRAP_v8.0.md`
3. `CANONICAL_FLAG_MAP_v8.0.json`
4. `M08_WEST_ANCHOR_RESTORATION_v8.0.md`
5. `XP_TRANSITION_FLOOR_v8.0.json`
6. `ENCOUNTER_RUNTIME_EXTENSION_v8.0.json`
7. 나머지 normalization/gap 파일

핵심 결론:

- 원본 repo 그대로는 **NO-GO** (root CLAUDE/HANDOFF/GAME_DESIGN 오염).
- v8 오버레이를 로컬 repo에 두고 bootstrap을 최우선으로 읽히면 **GO**.
- 광범위한 게임 재설계는 더 필요하지 않다.
- 구현 중 가장 먼저 해결할 것은 문서 권위, flag migration, runtime schema extension, 실제 Flutter validation이다.

이 패키지는 GitHub에 자동 커밋하지 않았다.