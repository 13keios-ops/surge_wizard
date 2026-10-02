# Surge Wizard v4 — Final Handoff Recheck v8.1 (2026-10-03)

## 목적

반복 재시도와 부분 커밋 이후에도 fresh clone 기준으로 구현 에이전트가 잘못된 권위를 읽거나, 인덱스가 존재하지 않는 파일을 가리키는 문제가 없는지 다시 검증한다.

## v8.1에서 바로잡는 실제 문제

1. `LOCAL_AGENT_BOOTSTRAP_v8.0.md`가 수정된 `CLAUDE.md`/`README.md`까지 legacy로 부르던 자기모순.
2. bootstrap이 최신 `CURRENT_AUTHORITY_2026-10-02.md`가 아니라 10월 1일 권위를 다시 가리키던 역류.
3. `HANDOFF.md` / `GAME_DESIGN.md` legacy 배너 반영이 실제 커밋되지 않았는데 완료로 기록된 문제.
4. v6 인덱스가 15개 구조화 데이터/validator 파일을 가리키지만 저장소에는 없던 문제.
5. v7 인덱스가 구조화 Narrative JSON/validator를 가리키지만 저장소에는 없던 문제.
6. `FINAL_COMPLETE_HANDOFF` builder가 v5.9까지만 묶고 최신 v6/v7/v8을 포함하지 않던 문제.
7. 구 `CURRENT_AUTHORITY_2026-10-01.md`와 `FINAL_AUDIT_2026-10-01.md`가 superseded 표시 없이 살아 있던 문제.
8. v8 audit/index의 “아직 GitHub에 커밋되지 않았다” 같은 시점성 문구가 현재 저장소와 어긋난 문제.

## 보존 원칙

- 옛 문서는 삭제하지 않는다.
- 다만 current entrypoint에서 절대로 권위로 선택되지 않도록 명시적으로 격리한다.
- v6/v7 ZIP에서 검증된 원본 파일을 그대로 복원한다.
- v8 교정은 v6/v7 authoring 원본을 덮어쓰지 않고 overlay로 적용한다.
- `lib/main.dart` legacy entry는 삭제하지 않는다.

## 독립 재검증 결과

로컬 보존 ZIP을 새 디렉터리에 다시 추출하여 원래 validator를 직접 실행했다.

```text
V6_CAMPAIGN_VALIDATION_OK
encounters_act3 14
encounters_act4 12
encounters_act5 16
late_gear 40
events 98
maps 38
choice_combinations_checked 648
xp_act3_end 3935 xp_act4_end 7000 xp_act5_end 10680

V7_FULL_NARRATIVE_VALIDATION_OK
main_scenes 65
personal_quest_scenes 30
dialogue_entries 1152
named_npcs 45
major_choice_reactions 100
travel_banter_variants 20
combat_barks 75
```

v6/v7 ZIP 내부 JSON은 각각 11개, 총 22개이며 JSON parse failure는 0이었다.

## 현재 구현 전 필수 overlay

- M08 West Anchor 복원.
- canonical persisted story flags.
- Circle 5 gate는 M04/D05 resolution 이후.
- ACT II→III XP floor 1640.
- ACT III→IV XP floor 4130.
- ACT IV→V XP floor 7030.
- P01–P20 / E01–E24 identity 보존.
- v6/v7은 authoring source이며 runtime import 전 schema compiler/adapter 사용.
- 후반 encounter는 nonstandard victory/failure/interactable contract 확장.
- Narrative localization key는 array position이 아니라 stable semantic key로 동결.

## 최종 판정 규칙

GitHub 반영 후 `validate_repo_handoff_v8_1.py`와 원래 v6/v7 validator가 모두 통과하고,
current entry docs의 참조 경로 검사에서 broken reference가 0이면 **fresh-clone handoff GO**로 판정한다.

Flutter/Dart SDK 실제 실행은 별도 구현환경 gate다. 이 문서의 PASS는 Flutter compile/test PASS를 뜻하지 않는다.