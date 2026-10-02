# 묶음 B 자체검수 — ACT IV + 동료 v6.1

## 결과: PASS

- ACT IV Story Bible의 White Wolf→D07→T11→D08→M06 흐름 유지.
- M05/M06/M07 Choice Matrix와 충돌 없음.
- M06는 Ending A/B와 독립.
- C6 Gate = D07 + resonance identified + Lv17 유지.
- 5개 Personal Quest의 기존 제목, 핵심 선택, Trait, ACT V callback 유지.
- Personal Quest는 호감도 수치/선물 Farming과 연결하지 않음.
- 동료가 벤치여도 Quest 시작 가능.
- Temporary/Permanent Leave 처리 기준 유지.
- White Wolf 비살상 분기를 기존 boss data의 10% Subdue를 활용하도록 연결.
- S01 Headless Knight는 optional이며 메인 레벨링 필수 아님.
- M04 어느 결과도 ACT IV 진입을 막지 않음.
- Flutter/Dart/밸런스 시뮬레이션은 아직 실행하지 않음.

## 다음 묶음 전달점

ACT V 시작 시:
`act4_complete=true`, protagonist Trait exactly-one, M07 truth policy exactly-one.
이전 ACT I–IV 주요 선택 Flag와 Personal Quest 상태를 모두 Epilogue/Anchor resolver가 읽는다.
