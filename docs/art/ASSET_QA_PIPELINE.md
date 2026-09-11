# ASSET_QA_PIPELINE.md

## Claude가 먼저 검사
- 파일명
- alpha
- dimensions
- crop
- canonical 512 canvas
- runtime position
- layer order
- 장착 composite
- game-size readability
- style mismatch
- build/test impact

## 사용자에게 보여줄 것
가능하면 한 장의 contact sheet:
- 기존
- 신규
- 장착 preview
- 후보 비교

사용자 질문:
1. 같은 캐릭터/같은 게임처럼 보이나?
2. 장비가 자연스럽게 붙나?
3. 얼굴/몸을 가리나?
4. 전체적으로 마음에 드나?

## 첫 기준 에셋
새 카테고리 최초 에셋은 사용자 승인 필수.

## 자동화
초기:
- dimensions
- alpha
- transparent background

반복 문제가 생기면:
- bbox
- scale
- position
- contact sheet
- checksum
순으로 추가한다.
