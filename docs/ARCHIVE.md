# 문서 보관소 — 읽지 않아도 되는 것들

> **2026-09-07 신설.** `CLAUDE.md` 문서 지도에 있던 **⛔폐기 6건 + ✅완료 지시서 20건 = 26행**을
> 여기로 옮겼다. 그 26행은 매 창에 자동으로 실리면서 **다시 읽힐 일이 없었다.**
>
> **파일은 옮기지 않았다.** 전부 저장소 루트에 그대로 있다 —
> `reports/`의 검토서들이 지시서 이름을 **64곳**에서 가리키고 있어서,
> 옮기면 그 링크가 전부 끊긴다. **여기는 「목록」이지 「폴더」가 아니다.**
>
> 필요할 때(옛 결정의 배경이 궁금할 때)만 이름을 찾아 루트에서 열면 된다.
>
> ## 🔴 2026-09-11 — **파일 자체에 배너를 박았다**
> 목록이 여기 있어도 **파일을 직접 연 사람은 그 목록을 안 본다.** 실제로
> ChatGPT가 저장소를 읽고 `ART_REQUEST_V3.md`의 폐기된 「N칸」 표를 집었다.
> 그 파일의 ⛔ 상자는 **25줄 아래**에 있어서 눈에 안 띄었다.
>
> **그래서 폐기·완료 문서 30건 전부의 머리말 두 번째 줄에 배너를 넣었다.**
> - `> ⛔` — 끝났거나 폐기됐다. **기준으로 삼지 마라**
> - `> 📄` — 특정 시점의 기록이다. 현재 상태가 아니다
>
> 🔴 **앞으로 문서를 폐기·완료 처리할 때는 이 목록에 줄을 넣는 것으로 끝내지 말고,
> 그 파일 머리말에도 배너를 넣어라.** 목록만으로는 막지 못한다는 것이 확인됐다.

---

## ⛔ 폐기 — 읽지 마라

| 문서 | 왜 폐기됐나 | 대체 문서 |
|---|---|---|
| `GRAPHICS_PLAN.md` | v1 픽셀아트 전제 | `UI_DESIGN.md` |
| `ART_PIPELINE.md` | v1 픽셀아트 전제 | `UI_DESIGN.md` |
| `WORK_ORDER_ART_PIPELINE.md` | 96×96 · 강제 양자화 · 알파 이진화 (2026-09-05 폐기) | `GAME_ART_ROADMAP.md` |
| `DICE_DESIGN.md` | v1 기준 + 옛 확률표 | `GAME_DESIGN.md` 3절 |
| `WORK_ORDER_BALANCE.md` | v1 기준 밸런스 개정 5개 작업 | — (⛔ 보류) |
| `WORK_ORDER_GRAPHICS.md` | v1 기준 그래픽 4개 작업 | `GAME_ART_ROADMAP.md` |

## ✅ 완료된 구현 창 지시서

**전부 검토 승인이 끝났다.** 무엇을 했는지는 `reports/INDEX.md`와 각 검토서에 있다.

| 지시서 | 무엇 | 검토 |
|---|---|---|
| `WORK_ORDER_DATA_A.md` | 폭주 80종 + 주문 서클 | 검토 08 승인 |
| `WORK_ORDER_DATA_B.md` | 보스·변종·지역·스테이지 | 검토 09 승인 |
| `WORK_ORDER_CODE_SURGE.md` | 폭주 효과 4종 + 팝업 6갈래 | 검토 10 승인 |
| `WORK_ORDER_INTENSITY.md` | 시전 강도 2단계 개정 | 검토 11 승인 |
| `WORK_ORDER_SIM.md` | 시뮬레이션 측정 | 검토 12 승인 |
| `WORK_ORDER_PROGRESSION.md` | 진행 구조 교체 (엔진층) | 검토 13 승인 |
| `WORK_ORDER_SIM2.md` | 시뮬 재측정 | 검토 14 승인 |
| `WORK_ORDER_SCALE_FIX.md` | 지역 배율 분리 + 재측정 | 검토 15 승인 |
| `WORK_ORDER_DECK_SIM.md` | 덱에서 손패 뽑기 | 검토 16 (구현만 승인) 승인 |
| `WORK_ORDER_DECK_FIX.md` | 덱·봇 수정 + 재측정 | 검토 17 승인 |
| `WORK_ORDER_GROWTH_SIM.md` | 성장 반영 측정 | 검토 18 승인 |
| `WORK_ORDER_HEAL_FIX.md` | 회복 수정 + 재측정 | 검토 19 승인 |
| `WORK_ORDER_ATTRITION.md` | 소모전 완화 | 검토 20 승인 |
| `WORK_ORDER_LATE_CURVE.md` | 후반 곡선 정렬 | 검토 21 승인 |
| `WORK_ORDER_FINAL_TUNE.md` | 12지역 층수 + 곡선 조건 판정 | 검토 22 승인 |
| `WORK_ORDER_FINAL_TUNE2.md` | 12지역 배율 3.35 + 최종 판정 | 검토 23 — **곡선 종료** 승인 |
| `WORK_ORDER_SCREENS.md` | 지역·스테이지·난이도 화면 · 지도 · 파일 분리 | 검토 24 승인 |
| `WORK_ORDER_SCREENS2.md` | 화면 잔손질 3건 | 검토 25 승인 |
| `WORK_ORDER_LEVEL.md` | 레벨·경험치·서클 슬롯표 | 검토 26 승인 |
| `WORK_ORDER_UI_6A.md` | 전투 화면 v3 재설계 | 검토 31 — **구조 승인 / 수정 3건.** 🔴 지시서의 「조작부를 화면 높이 비례로」는 **틀린 처방이었다** — 답은 「모든 좌표를 화면 아래에서 잰다」 |

## ⛔ 다 쓴 원화 요청서 (2026-09-11 추가)

| 문서 | 상태 | 지금 기준 |
|---|---|---|
| `ART_REQUEST_V3.md` | 다 썼다. 🔴 본문의 **「N칸」 표가 폐기됐는데 분량이 커서 위험하다** | 생김새 `ASSET_LIST.md` · 규격 `UI_DESIGN.md` 1-3·3-0절 |
| `ART_REQUEST_V3_추가.md` | 다 썼다. 칸 수 협상은 `tool/gridize.py`로 해결 | 같음 |
| `ART_REQUEST_PHASE1_5.md` | 옛 요청서 (59칸 기준) | 배경은 `ART_REQUEST_BG_V4.md` |
| `WORK_ORDER_ART_V3.md` | 끝났다 (검토 34) | `docs/HANDOFF_ART.md` |

## 📄 특정 시점의 기록 (현재 상태가 아니다)

| 문서 | 시점 |
|---|---|
| `MORNING_REPORT.md` | 2026-09-01 아침 작업 보고 |
| `REVIEW.md` | 2026-08-31 전체 검수 |
| `ART_PROMPT.md` | 2026-09-02 사용자가 GPT에 넣은 지침 원문. 현행은 `docs/GPT_PROJECT_INSTRUCTIONS.md` |
| `GAME_DESIGN_V3_DRAFT.md` | v3 결정이 나온 자리. 병합 끝 — 어긋나면 `GAME_DESIGN.md`가 맞다 |

## ⚠ 끝나지 않은 채 대체된 지시서

| 지시서 | 상태 |
|---|---|
| `WORK_ORDER_ART_PHASE1.md` | **코드는 승인, 화면은 반려** (검토 27). 칸 밀도 7.7배 차이 → `WORK_ORDER_ART_PHASE1_5.md`가 이어받았다. **코드 성과는 살아 있다** — `docs/HANDOFF_ART.md` 7-4절 |
