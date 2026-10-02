# M08 서부 Anchor 복원 패치 v8.0

v1.4 Choice Matrix와 v1.5 Quest/Flag 문서에는 **M08이 명시적으로 존재**했지만,
v6.2/v7.4에서 서부 Anchor가 자동 해결 장면으로 바뀌면서 선택이 사라졌다.
삭제 결정을 한 기록이 없으므로 이는 **의도된 개편이 아니라 누락**으로 판정한다.

## 복원

A. 광산 구조 폭파 → 빠른 차단 / 광산 영구 상실  
B. 내부 수동 안정화 → 추가 고위험 전투 / 성공 시 광산 보존  
C. 마도원 원격장치 → 과거 정보·관계에 따른 조건부 Option

완료 시 공통 canonical flag:

```text
west_anchor_stable = true
```

해결방식은 별도 exactly-one:

```text
west_anchor_method_blast
west_anchor_method_manual
west_anchor_method_remote
```

v6/v7의 `anchor_west_resolved`는 저장하지 않고 `west_anchor_stable` alias로만 읽는다.

Remote 초기 조건은 구현용으로 다음을 사용한다.

```text
act2_ruin_resolved
&& (ancient_records_academy || ancient_records_shared)
```

향후 실제 플레이에서 너무 쉽게/어렵게 열리면 조건만 튜닝하고 M08 자체는 삭제하지 않는다.