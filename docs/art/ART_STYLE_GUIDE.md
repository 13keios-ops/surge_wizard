# ART_STYLE_GUIDE.md

- 기준: `wizard_body.png` + 사용자 승인 에셋
- 방향: 고밀도 픽셀아트풍 모바일 RPG
- strict retro pixel art 아님
- colored outline
- 좌상단/좌전방 광원
- 재질별 명암
- 제한적 AA 허용
- 반투명 alpha / glow 허용
- 출력 색 수를 기계적으로 제한하지 않음

금지:
- 24~64색 강제 quantization
- alpha 0/255 이진화
- 큰 retro pixel block 강제
- 사진풍
- 3D render풍
- 과도한 vector gradient
- 다른 상용 게임의 구체 디자인 복제

배경:
- 캐릭터보다 지나치게 강한 대비 금지
- 캐릭터 주변 시각적 노이즈 억제
- gameplay focal point가 묻히지 않게 조정

UI:
- Flutter 픽셀 UI 유지
- Galmuri 유지
- SaaS dashboard처럼 만들지 않음
