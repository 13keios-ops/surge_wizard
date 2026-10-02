# Surge Wizard v4 — 로컬 구현 직전 전수검수 v8.0 (2026-10-02)

## 최종 판정

**현재 원본 그대로 로컬 에이전트를 시작하는 것은 NO-GO.**

이유는 게임 설계가 비어서가 아니라 **인수인계 오염과 데이터 계약 불일치가 구현 에이전트를 잘못된 방향으로 보낼 수 있기 때문**이다.

다만 아래 v8 교정 오버레이를 함께 적용하면 **GO**로 전환할 수 있다. 스토리/전투/성장/콘텐츠의 큰 설계를 다시 만들 필요는 없다.

이번 검수는 기존 v1.x~v5.9, 새 v6.0~v6.3, v7.0~v7.8, 현재 GitHub main 진입문서/README/CLAUDE/HANDOFF/pubspec을 교차대조했다.

## 자동 재검증

```text
V6_CAMPAIGN_VALIDATION_OK
V7_FULL_NARRATIVE_VALIDATION_OK
```

이는 v6/v7 내부 구조검사 통과를 의미한다. 이번 v8 검수에서는 그보다 상위인 **버전 간 의미 충돌**을 별도로 검사했다.

## 발견 사항

| 심각도 | ID | 문제 | 구현 전 처리 |
|---|---|---|---|
| BLOCKER | `AUTH-001` | Root CLAUDE.md auto-loads the obsolete pre-pivot game and can steer a local Claude agent into implementing the wrong product. | Replace/redirect CLAUDE.md locally before starting the agent. |
| BLOCKER | `AUTH-002` | GitHub AGENT_START_HERE/CURRENT_AUTHORITY stop at v5.9. v6 campaign completion and v7 full narrative are local-only, so a fresh clone cannot know the newest design. | Give the local agent this v8 package + v6/v7 packages, or copy them into the local repo before implementation. |
| BLOCKER | `STORY-001` | M08 West Anchor Major Choice exists from v1.4 through v3.5 and v1.5 Quest/Flag docs but vanished in v6/v7 without a deletion decision. | Restore M08 using M08_WEST_ANCHOR_RESTORATION_v8.0. |
| BLOCKER | `STATE-001` | Persistent story flag names drifted in v6/v7 (mine, swamp, researcher, wolf, trait, temple, crisis, anchors). Without normalization save/load and consequence resolvers can silently diverge. | Persist only CANONICAL_FLAG_MAP_v8.0 names; accept newer names as migration aliases. |
| BLOCKER | `SPELL-001` | Circle 5 story gate is set at D05 capture in v6 A3_060, before the M04 disposition. The earlier C4-C6 spec requires 'D05 research facility resolved'. | Move circle5_story_gate commit to after M04 COMMITTED / D05 resolution. |
| BLOCKER | `XP-001` | v6.3 ACT II progression math assumes an undefined 120 common XP and 270 synthesis. Actual authored common node before arcs is 40; two 430-XP arcs from ACT I 390 need up to 350 to hit Lv9. | Use transition minimum-XP catch-up rule in XP_TRANSITION_FLOOR_v8.0. |
| HIGH | `XP-002` | v6.0 ACT III main baseline ends 3935, 195 short of Lv15; its audit incorrectly says one optional encounter is enough, but the optional convoy is only 100 XP. | Use ACT III→IV minimum 4130 catch-up or explicitly add 195 authored story XP. |
| HIGH | `POI-001` | v4.3 invented replacement POIs even though v1.8 already fixed P01-P20; v6/v7 never re-linked the canonical 20 POIs and 24 side-event archetypes. | Use POI_EVENT_AUTHORITY_v8.0; v6 98 entries are additive regional pool entries, not replacements. |
| HIGH | `SCHEMA-001` | v6 structured JSON is authoring format and does not conform to v5 runtime schemas; v7 narrative JSON has no canonical runtime schema at all. | Add a content compiler/adapter; do not load v6/v7 authoring JSON directly at runtime. |
| HIGH | `SCHEMA-002` | v5 encounter schema lacks explicit victory/failure objectives and scripted interactables needed by M05 subdue/repel, civilians, capture, Anchor devices, and boss channels. | Extend encounter contract per ENCOUNTER_RUNTIME_EXTENSION_v8.0 before ACT IV/V implementation. |
| HIGH | `NARR-001` | N9 dialogue catalog uses positional array-path IDs; inserting/reordering lines changes localization keys. | Freeze explicit scene-based stable text keys before localization/runtime import. |
| HIGH | `ITEM-001` | Late T3-T5 gear includes milestone/reward items whose actual RewardDefinition transactions are not wired; Hub stock also contains placeholder group tokens instead of item IDs. | Resolve LATE_GEAR_ACQUISITION_GAPS_v8.0 before equipment content migration. |
| HIGH | `EVENT-001` | v6 regional events use shorthand or undefined resource IDs (basic_supplies, ore_supplies, battle_supplies, scroll_material, essence_cache). | Normalize existing materials and define reward bundles per RESOURCE_ID_NORMALIZATION_v8.0. |
| HIGH | `REPO-001` | README/HANDOFF/GAME_DESIGN still advertise the obsolete game; plain flutter run uses legacy main.dart. | Treat them as legacy and use v4 preview target until entry migration. |
| HIGH | `MONET-001` | pubspec still carries google_mobile_ads and obsolete gem/deck-slot monetization comments. | Remove ads dependency in current v4 migration; retain IAP only for current paid expansion/respec purposes if needed. |
| MEDIUM | `NARR-002` | ACT I-II 'full' script omitted explicit Iron Troll and Bog Toad boss pre/post scenes, unlike other bosses. | Apply ACTII_BOSS_NARRATIVE_PATCH_v8.0. |
| MEDIUM | `PARTY-001` | v7 uses nera_active/nera_bench as effects/conditions even though party composition belongs to companion/party state, not durable story flags. | Map to party assignment actions/predicates, never persistent story flags. |
| MEDIUM | `COND-001` | v7 condition token freehold_evidence drifts from act3_freehold_evidence; other condition strings mix local choice IDs, party predicates, and world flags in one namespace. | Normalize condition expression types before interpreter import. |
| MEDIUM | `ART-001` | Five human combat archetypes and Serkan story-boss combat require visual representation but are outside the approved 26 monster + 12 monster-boss art list. | Use explicit human-character combat placeholders/rigs and create a separate human-combat art order later; do not silently add them to monster count. |
| MEDIUM | `WORLD-001` | Exact ~90-cell world mask remains intentionally unfrozen; only anchors/topology/routes are authoritative. | Not a WP00-06 blocker; make the visual map mask during world-map proof before final ACT map production. |
| MEDIUM | `QA-001` | Flutter/Dart analyze/test/5k headless runs were never executed in a real Flutter SDK environment after these later specs. | First local-agent milestone must run real SDK validation before broad migration. |
| LOW | `TIME-001` | Old per-Act 3-4/5-6/6-7/6-7/7-8 sums to 27-32h while latest master calls 20-25h main-centered and 25-35h typical. | Interpret old Act times as typical/explorer pacing; target critical main route at 20-25h and measure in playtest. |

## 단계별 판정

### 1. 프로젝트 진입점 / 문서 권위 — FAIL → v8로 교정 필요

- `AGENT_START_HERE.md` 자체는 v4를 가리키지만, **Claude Code가 자동으로 읽는 `CLAUDE.md`가 더 오래된 게임을 지시**한다.
- 루트 `HANDOFF.md`, `GAME_DESIGN.md`, `README.md`도 방향전환 전 세로형 주사위 로그라이트를 현재 기준처럼 설명한다.
- 따라서 로컬 에이전트에게는 `LOCAL_AGENT_BOOTSTRAP_v8.0.md`를 최상위 지침으로 주고 옛 문서를 legacy로 격리해야 한다.

### 2. 전투 규칙 / Timeline / 상태이상 — PASS (구현 실측만 남음)

- 3d6 판정, ability modifier, 방어값, Delay/Speed, 상태 지속, Boss control 변환의 큰 충돌은 발견하지 못했다.
- v3.7 modifier와 기존 Combat Formula Sheet가 동일하다.
- 단, v6 후반 콘텐츠가 요구하는 **비표준 승리조건**은 v5 encounter schema에 빠져 있다.

### 3. ACT I–II — PASS WITH FIXES

- reconciled v4.0 전투 수치가 staged v4.0-v4.9보다 우선하는 기존 결론 유지.
- M01~M03의 서사/동료 반응은 유지 가능.
- Iron Troll/Bog Toad boss 대사 공백 보강 필요.
- ACT II→III XP 수학은 v6.3의 `120 common + 270`이 실제 authoring graph와 맞지 않는다. v8 transition floor로 수정.

### 4. ACT III — PASS WITH FIXES

- Arken→Seon→R07/T07/T08→D05→M04→D06 구조는 기존 Story Bible과 일치.
- 가장 중요한 오류는 **Circle 5 gate가 M04보다 먼저 set되는 것**이다. M04 commit 이후로 이동.
- ACT III main-only XP는 Lv15에 195 부족하므로 transition floor를 둔다.

### 5. ACT IV — PASS WITH FLAG NORMALIZATION

- White Wolf→D07→Resonance reveal→T11/D08→M06/M07 흐름 일치.
- M05/M06/M07의 뜻도 기존 Matrix와 일치.
- 다만 flag 이름이 v1.5에서 대량 변경됐으므로 저장키는 canonical map으로 복원.

### 6. ACT V — FAIL 한 건(M08) + 나머지 PASS

- 세 Anchor 자유순서, Serkan→Void Titan→C01 구조는 유효.
- **서부 Anchor의 M08이 통째로 빠졌다.** v1.4~v3.5에 반복해서 존재하므로 복원.
- Central/East는 이전 선택의 결과를 회수하는 구조 유지.
- C01은 Restore/Change 두 선택 모두 항상 열려 있어야 한다.

### 7. Story Flags / Save — FAIL → canonicalization 필요

Persisted key는 `CANONICAL_FLAG_MAP_v8.0.json` 하나만 기준으로 삼는다.

대표 예:

```text
ironvale_mine_sealed          -> mine_closed
swamp_purified               -> swamp_cleansed
researcher_secret_coop       -> researcher_secret_ally
white_wolf_redirected        -> white_wolf_relocated
protagonist_trait_harmonizer -> trait_harmonizer
anchor_west_resolved         -> west_anchor_stable
```

`*_active`, `*_bench`는 story flag가 아니라 PartyState다.

### 8. NPC / 동료 / Narrative — PASS WITH RUNTIME NORMALIZATION

- 45 named NPC, 65 main scenes, 30 companion-PQ scenes, 100 major-choice reactions, 20 travel banter, 75 combat bark의 내부검사는 통과.
- 정보 공개 순서도 큰 누출 없음.
- 다만 N9의 `dlg.n2.root.scenes.000...` 같은 **위치 기반 localization key는 production key로 부적합**하다.
- v7 JSON은 authoring source로 보존하고 runtime용 scene/text schema로 compile해야 한다.

### 9. POI / Random Event — INCOMPLETE

- v1.8의 P01~P20 / E01~E24가 먼저 확정되어 있었는데 v4.3이 다른 POI 이름을 새로 만들었다.
- 기존 작업지시 자체가 '기존 POI를 재사용'하라는 것이었으므로 v4.3 replacement set은 오류.
- v6의 98 regional entries는 버리지 않는다. **P01~P20/E01~E24 위에 추가되는 지역별 pool entry**로 취급한다.

### 10. 장비 / 보상 / 상점 — PARTIAL

- T3~T5 장비 40종 자체 ID 중복은 없지만, milestone/reward 획득 연결이 완전하지 않다.
- Hub stock에는 concrete item이 아닌 placeholder token이 23개 남아 있다.
- 따라서 장비 정의는 구현 가능하지만 Shop/Reward repository에 바로 넣으면 안 된다.

### 11. 주문 — PASS WITH ONE GATE FIX

- C0~C3 30종, C4~C6 27종, C7 3 definition의 큰 구조는 일관.
- C7 Story Free / optional 120 Essence도 기존 경제원칙과 일치.
- Circle5 gate 위치만 수정.

### 12. 월드 / Hub — PASS FOR IMPLEMENTATION FOUNDATION

- 11 Hub / 14 Region / 9 Dungeon topology 유지.
- 정확한 ~90-cell visual mask는 의도적으로 미확정이며 world-map proof 단계에서 결정.
- 이 미확정은 schema/repository/quest 구현을 막지 않는다.

### 13. 아트 의존성 — PARTIAL

- Monster 26 + Boss 12 기준은 유지.
- 인간 전투 archetype 5종과 Serkan은 별도 human combat art/placeholder가 필요하다. 몬스터 38종 목록을 임의로 늘리지 않는다.

### 14. 실제 코드/SDK 검증 — NOT RUN

- 최신 v6/v7은 설계 산출물이며 Dart/Flutter 구현물이 아니다.
- `flutter analyze`, `flutter test`, 실제 5,000-run Dart sim, 실기기 layout 검증은 로컬 에이전트의 **첫 Milestone**이어야 한다.

## 구현 에이전트 시작 조건

아래 7개를 만족하면 GO:

1. Root `CLAUDE.md`를 v4 bootstrap으로 교체/우회한다.
2. v6/v7/v8을 로컬 repo에서 읽을 수 있게 둔다.
3. Canonical flag map을 먼저 적용한다.
4. M08을 복원한다.
5. Circle5 gate와 Act transition XP floor를 적용한다.
6. v6/v7 authoring JSON을 직접 runtime load하지 않고 v5 schema로 compile/migrate한다.
7. 실제 Flutter SDK baseline 검증부터 실행한다.

이 조건 이후에는 광범위한 재설계가 아니라 **구현→실측→수치튜닝** 단계로 넘어가면 된다.