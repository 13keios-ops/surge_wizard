# Surge Wizard v4 — 남은 본편 설계 일괄 완료 패키지 v6.0~v6.3

사용자 요청에 따라 중간 질문 없이 다음 순서로 진행했다.

```text
묶음 A — ACT III 완전 상세화 → 자체검수
묶음 B — ACT IV + 동료 개인퀘스트 → 자체검수
묶음 C — ACT V + 최종던전 + Ending → 자체검수
묶음 D — 주문/장비/Hub/Event/Map/경제/Flag/QA 전체 통합검수
```

## 현재 권위

이 패키지는 기존 확정 내용을 임의로 갈아엎지 않는다.

- 전투 공식: 기존 v3.x.
- ACT I–II 수치: reconciled v4.0.
- C0–C3: v3.8.
- C4–C6: v2.4 상세 Catalog.
- Companion personalities/PQ: v1.4/v1.7.
- Boss base data: v2.5.
- Economy target: v2.1.
- 본 패키지는 **남아 있던 ACT III–V와 전역 연결을 닫는 후속 권위**다.

## 파일

- `A_v6.0_ACT_III_COMPLETE_SPEC.md`
- `A_v6.0_ACT_III_DATA.json`
- `A_v6.0_CHECKPOINT_AUDIT.md`
- `B_v6.1_ACT_IV_COMPANION_COMPLETE_SPEC.md`
- `B_v6.1_ACT_IV_COMPANION_DATA.json`
- `B_v6.1_CHECKPOINT_AUDIT.md`
- `C_v6.2_ACT_V_ENDING_COMPLETE_SPEC.md`
- `C_v6.2_ACT_V_ENDING_DATA.json`
- `C_v6.2_CHECKPOINT_AUDIT.md`
- `D_v6.3_FULL_CAMPAIGN_INTEGRATION_AUDIT.md`
- `D_v6.3_LATE_GEAR_SPELL_HUB_DATA.json`
- `D_v6.3_WORLD_EVENT_POOL_98.json`
- `D_v6.3_TACTICAL_MAP_LAYOUTS.json`
- `D_v6.3_COMPANION_QUEST_INTEGRATION.json`
- `D_v6.3_STATE_FLAG_MATRIX.json`
- `D_v6.3_FULL_WALKTHROUGH_STATE_TRACE.json`
- `D_v6.3_XP_ECONOMY_AUDIT.json`
- `validate_v6_campaign.py`
- `VALIDATION_RUN.txt`

## 검증 의미

`V6_CAMPAIGN_VALIDATION_OK`는 이 명세 패키지 내부의 ID/count/XP/choice/map contract 검증이다.

Flutter/Dart 코드가 이 설계를 구현했다는 뜻이 아니며, 실제 빌드/밸런스 테스트도 아니다.

## 다음 작업

이제 광범위한 본편 설계를 계속 추가하지 말고 실제 구현으로 이동한다.

```text
Flutter/Dart 실제 검증
→ v5 WP00~WP12
→ ACT I 데이터 이식
→ ACT II
→ ACT III
→ ACT IV
→ ACT V
→ 실제 플레이 밸런스
```