# RUNTIME_ASSET_SPEC.md

## 원본
- 큰 무손실 PNG
- 실제 alpha
- `art_raw/`

## 게임용
- 캐릭터/장비 canonical canvas: 512×512
- WebP 사용 가능
- `assets/art/`

## 정규화
- 캐릭터 중심/발 기준을 기존 `UI_DESIGN.md`와 맞춘다
- auto-crop 후 canonical canvas 배치
- alpha 250 이상은 필요 시 255로 snap
- 개별 장비 `dx/dy/scale` 보정 허용

## Flutter
- 기존 PixelSprite는 완전 전환 전까지 fallback 유지
- 기존 BattleStage Transform 애니메이션 재사용
