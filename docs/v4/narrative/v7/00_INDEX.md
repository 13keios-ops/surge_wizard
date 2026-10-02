# Surge Wizard v4 — Full Narrative Script Complete v7.0~v7.8

이 패키지는 기존 ACT I~V 게임 설계를 바꾸는 새 기획이 아니라,
**이미 확정된 스토리를 실제 게임 대사/시나리오로 내린 최종 Narrative Pass**다.

## 순서

1. `N1_v7.0_CHARACTER_NPC_VOICE_BIBLE.md`
   - 주인공 선택문 원칙
   - 동료 5명 Voice Lock
   - 세력 Voice
   - Named NPC 45명
   - 정보공개 안전선

2. `N2_v7.1_ACT_I_II_MAIN_SCRIPT.md`
   - New Game → ACT III 초청
   - Kael / Erin / Nera 영입
   - M01/M02/M03

3. `N3_v7.2_ACT_III_MAIN_SCRIPT.md`
   - Arken / Seon / Luka
   - Freehold / R07
   - D05 Karden / M04
   - D06

4. `N4_v7.3_ACT_IV_MAIN_SCRIPT.md`
   - M05 White Wolf
   - D07 resonance reveal
   - T11/D08
   - M06/M07

5. `N5_v7.4_ACT_V_ENDING_EPILOGUE_SCRIPT.md`
   - 3 Anchor
   - Serkan
   - Void Titan
   - C01 Restore/Change
   - 11 Hub + 5 Companion Epilogue

6. `N6_v7.5_COMPANION_PERSONAL_QUEST_FULL_SCRIPT.md`
   - 5 companions × 6 nodes = 30 PQ scenes

7. `N7_v7.6_HUB_NPC_RUMOR_AMBIENT_SCRIPT.md`
   - 38 Hub core NPC
   - 33 Rumor
   - 33 Ambient
   - Hub companion comments

8. `N8_v7.7_COMPANION_REACTIONS_BANTER_BARKS.md`
   - Major Choice reaction 100
   - Companion pair 10쌍 / Banter 20
   - Combat Bark 75

9. `N9_v7.8_FINAL_NARRATIVE_CONTINUITY_AUDIT.md`
   - 원 Quest Beat 전체 crosswalk
   - Knowledge reveal audit
   - Voice/Choice/PQ/Ending/Save audit

## 구조화 데이터

모든 단계에는 JSON이 같이 있다.
특히:

- `N9_v7.8_FULL_DIALOGUE_CATALOG.json`
  - canonical 한국어 dialogue catalog **1152 entries**
- `N9_v7.8_NARRATIVE_AUDIT_DATA.json`
- `validate_v7_narrative.py`

## 검증 결과

```text
V7_FULL_NARRATIVE_VALIDATION_OK
main_scenes 65
personal_quest_scenes 30
dialogue_entries 1152
named_npcs 45
major_choice_reactions 100
travel_banter_variants 20
combat_barks 75
```

이 검증은 **Narrative 명세 내부의 구조/누락/선행스포일러/Choice coverage** 검증이다.

Flutter 구현 완료나 실제 플레이 QA를 의미하지 않는다.

## 현재 판단

이 패키지 이후에는
**본편 스토리 라인, 주요 NPC 대화, 동료 대화, 개인퀘스트, Major Choice 반응,
Hub 대화, Travel Banter, Combat Bark, Ending/Epilogue의 설계는 완료**로 본다.

다음은 Narrative 설계가 아니라:

```text
JSON → Flutter Narrative Interpreter 이식
실제 UI 텍스트 길이 조정
플레이테스트
문장 Copy Edit
Localization
Voice recording (선택)
```

단계다.