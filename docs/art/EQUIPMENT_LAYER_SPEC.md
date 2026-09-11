# EQUIPMENT_LAYER_SPEC.md

초기 구조:
`body + equipment`

실제 문제가 생길 때만 확장:
- 손 가림: `body → staff → hand_front`
- 무기 앞뒤 교차: `staff_rear → body → staff_front → hand_front`
- 로브 앞뒤 교차: `robe_back → body → robe_front`
- 모자/머리 충돌: 필요 시 `hat_back / hat_front / mask`

V1 pose/view:
- `wizard_front_idle`
- `wizard_back_idle`
- `wizard_back_staff_idle`

`wizard_back_staff_idle`에는 실제 지팡이를 포함하지 않는다.

위치 보정 기본:
- dx
- dy
- scale

anchor/skeleton은 실제 필요성이 확인될 때만 추가한다.
