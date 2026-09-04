# Claude Code 실행 프롬프트 모음

각 블록을 **순서대로** Claude Code에 그대로 붙여넣으세요.
`GAME_DESIGN.md`와 `CLAUDE.md`는 프로젝트 루트에 미리 넣어두셔야 합니다.

---

## 0. 사전 준비 (사용자가 직접 하는 일)

터미널에서 순서대로 실행하세요.

```bash
# 1. Flutter 설치 확인
flutter doctor

# 2. 프로젝트 생성
flutter create surge_wizard
cd surge_wizard

# 3. 기획서와 규칙 파일을 프로젝트 루트로 복사
#    (GAME_DESIGN.md, CLAUDE.md 두 파일)

# 4. Claude Code 실행
claude
```

`flutter doctor`에서 안드로이드 관련 항목에 ❌가 있으면, 그 화면을 그대로
Claude Code에 붙여넣고 "이거 해결해줘"라고 하시면 됩니다.

---

## ⚡ 병렬 실행 안내 (크레딧 소진 요령)

**터미널 창을 2개 띄우세요.**

- **창 A**: 아래 1단계 → 3단계 → 4단계 … 순서대로 (메인 개발)
- **창 B**: 2단계(데이터 생성)만 계속 반복 (독립 작업이라 병렬 가능)

창 B는 `surge_wizard/assets/data/` 폴더만 건드리므로 충돌하지 않습니다.
이렇게 해야 오늘 안에 크레딧을 제대로 씁니다.

---

## 1단계 · 판정 엔진 + 단위 테스트 (창 A)

```
GAME_DESIGN.md와 CLAUDE.md를 먼저 읽어줘.

1단계로 게임의 판정 엔진만 만들 거야. UI는 전혀 만들지 마.

만들 것:
1. lib/core/constants.dart — 모든 밸런싱 수치를 상수로 정의
   (DC 7/10/13, 위력 배율, 결과 4단계 경계값, 마력 축적 임계치 등)
2. lib/core/dice.dart — 주사위 3개 굴림, 개별 잠금, 잠기지 않은 것만 재굴림
3. lib/core/combo.dart — 족보 판정 (페어/트리플/스트레이트/뱀눈, 우선순위 포함)
4. lib/core/check.dart — 판정 엔진.
   입력: 주사위 눈 3개, DC, 보정치, 마력 축적 게이지
   출력: 결과 등급(대성공/성공/아슬아슬/실패), 적용된 족보, 최종 판정값
5. test/check_test.dart — CLAUDE.md의 "테스트 규칙" 항목을 전부 커버하는 단위 테스트

작업 순서:
- 먼저 계획을 한국어로 정리해서 보여줘. 내가 확인한 뒤에 코드를 짜.
- 코드를 다 짠 뒤 `flutter test`를 실행해서 전부 통과하는지 확인해.
- 3.4절 확률표와 실제 시뮬레이션 결과를 표로 비교해서 보여줘.

테스트가 통과할 때까지 다음 단계로 넘어가지 마.
```

---

## 2단계 · 게임 데이터 생성 (창 B — 병렬)

이 프롬프트는 **네 번에 나눠서** 실행하세요. 한 번에 다 시키면 품질이 떨어집니다.

### 2-1. 주문 70종

```
GAME_DESIGN.md의 5.1절 스키마를 읽고, assets/data/spells.json 을 만들어줘.

- 총 70종 (common 30 / rare 25 / epic 15)
- 마법사 판타지 컨셉. 속성은 fire, frost, arcane, shadow, nature 다섯 가지
- base_damage는 rarity에 따라: common 5~9, rare 8~14, epic 12~22
- dc_modifier는 강력할수록 높게: common 0, rare 0~1, epic 1~3
- effect가 있는 주문을 30% 정도 섞어줘 (방어막, 회복, 적 행동 지연, 마나 회복,
  다음 판정 보정, 주사위 1개 추가 등)
- 이름은 한국어. 설명은 한 문장, 20자 이내
- icon 값은 game-icons.net에 실제로 존재하는 아이콘 이름을 써줘
- surge_tags를 반드시 넣어줘 (폭주 필터링에 쓰임)

만든 뒤 JSON이 문법적으로 유효한지 검증하고, rarity별 개수와
평균 base_damage를 표로 보여줘.
```

### 2-2. 폭주 80종 (가장 중요)

```
GAME_DESIGN.md의 5.2절을 읽고, assets/data/surges.json 을 만들어줘.

이게 이 게임의 유일한 차별점이야. 절대 대충 만들지 마.

- 총 80종
- 유형별 비율: 자해형 30% / 반전형 20% / 소환형 20% / 도박형 15% / 순수이득형 15%
- 각 항목은 이름과 한 문장 설명(text)을 가져야 하고, 설명이 재미있어야 해.
  "마법이 실패했다" 같은 밋밋한 문장은 금지. 구체적인 사고가 눈에 그려져야 해.
- effects는 실제로 구현 가능한 타입만 써: self_damage, heal, mana_change,
  seal_spell, swap_hp, summon_ally, damage_multiplier, skip_enemy_turn,
  extra_die, force_reroll
- tags로 속성 제한을 걸어줘. 60%는 ["any"], 40%는 특정 속성
- weight는 1~10. 강력하거나 웃긴 사고일수록 낮게

다 만든 뒤, 특히 잘 나왔다고 생각하는 10개를 골라서 보여줘.
```

### 2-3. 적 30종

```
GAME_DESIGN.md의 4.3절과 4.4절을 읽고, assets/data/enemies.json 을 만들어줘.

- 총 30종 (일반 26 + 보스 4)
- tier 1~5로 나누고, 4.4절 층별 HP/대미지 곡선에 맞춰 배치
- pattern은 3~4개 행동의 순환. 반드시 예고 가능해야 함
- action 타입: attack, charge(다음 턴 강타 예고), defend, heal, debuff
- 보스는 HP 90 내외에 2페이즈 (HP 50% 이하에서 패턴 변경)
- 이름은 한국어, icon은 game-icons.net 실제 아이콘 이름

만든 뒤 tier별로 HP와 턴당 평균 대미지를 표로 정리해서,
4.4절 곡선과 맞는지 확인해줘.
```

### 2-4. 유물 40종

```
GAME_DESIGN.md의 5.4절을 읽고, assets/data/relics.json 을 만들어줘.

- 총 40종 (common 18 / rare 14 / epic 8)
- 효과의 70%는 판정 확률을 건드리는 것으로:
  판정 +1~+3, 리롤 횟수 추가, 특정 눈 재굴림, 족보 조건 완화,
  아슬아슬을 성공으로 승격, 마력 축적 속도 증가, 주사위 1개 추가 등
- 나머지 30%는 자원 관련: 최대 체력, 마나 회복, 폭주 시 이득 등
- effect type은 코드에서 구현 가능하도록 명확한 열거형으로 정의해줘.
  사용한 type 목록을 마지막에 정리해서 보여줘.

주의: 판정 보정이 너무 세면 3.4절 확률 설계가 무너져.
epic이라도 판정 보정은 최대 +3까지만.
```

---

## 3단계 · 전투 화면 (창 A)

```
2단계 데이터가 준비됐어. 이제 전투 화면을 만들자.

만들 것:
1. lib/data/loader.dart — assets/data/*.json 로드 및 모델 파싱
2. lib/models/ — spell, enemy, relic, surge_event, run_state 모델
3. lib/screens/battle_screen.dart — 전투 화면
4. lib/widgets/dice_widget.dart — 주사위 3개. 탭하면 잠금/해제
5. lib/widgets/spell_card.dart — 주문 카드. 시전 강도 3개 버튼과 각각의 성공 확률 표시
6. lib/widgets/enemy_panel.dart — 적 HP바 + 다음 행동 예고
7. lib/widgets/surge_popup.dart — 폭주 발생 시 뜨는 팝업

화면 요구사항:
- GAME_DESIGN.md 4.1절 턴 흐름을 정확히 따를 것
- 시전 강도 버튼에 성공 확률을 % 로 표시할 것 (DC와 현재 보정치로 실시간 계산)
- 확률에 따라 색을 다르게 (70% 이상 초록 / 40~70% 노랑 / 40% 미만 빨강)
- 마력 축적 게이지를 항상 화면에 보이게
- 세로 화면 고정, 한 손 조작 가능하도록 주요 버튼은 화면 아래쪽에 배치

디자인은 어둡고 차분한 톤에 마법 느낌. 아이콘 중심으로 단순하게.
UI 이미지는 만들지 말고 Flutter 도형과 아이콘만으로 처리해.

먼저 화면 레이아웃을 글로 설명해서 보여준 뒤 코드를 짜줘.
```

---

## 4단계 · 지도, 런 진행, 메타 성장 (창 A)

```
전투가 동작하니 이제 한 판 전체를 이어붙이자.

만들 것:
1. lib/screens/map_screen.dart — 1~10층 진행 지도. 갈림길 2~3개
2. lib/screens/reward_screen.dart — 3/6/9층 보상 선택 (주문 3장 중 1택 등)
3. lib/screens/result_screen.dart — 승리/사망 결과 + 마력 결정 획득
4. lib/screens/meta_screen.dart — 영구 강화 화면 (5.5절 표대로)
5. lib/screens/title_screen.dart — 타이틀
6. lib/services/save_service.dart — shared_preferences로 저장
   (영구 강화 상태, 해금 주문, 최고 기록, 진행 중인 런)

중요:
- 앱을 껐다 켜도 진행 중이던 런이 이어져야 해 (모바일에서 필수)
- 인터넷 연결을 요구하는 코드는 절대 넣지 마

다 만든 뒤 1층부터 10층까지 한 판이 끝까지 돌아가는지 직접 실행해서 확인해줘.
```

---

## 5단계 · 손맛 (창 A) — 절대 생략 금지

```
GAME_DESIGN.md 6절 표대로 손맛을 넣어줘.

- lib/services/sfx_service.dart 를 만들어 진동과 효과음을 한 곳에서 관리
- 진동은 Flutter 내장 HapticFeedback 사용
- 효과음 파일은 아직 없으니, 파일이 없어도 앱이 죽지 않게 안전하게 처리하고
  필요한 효과음 목록을 파일명과 함께 정리해줘 (내가 나중에 넣을게)
- 주사위 굴림 애니메이션: 회전하다가 마지막 400ms에 ease-out으로 감속
- 대성공 시 화면 플래시, 폭주 시 화면 흔들림
- 대미지 숫자가 위로 튀어오르며 사라지는 연출

이 단계는 코드량 대비 체감 품질이 가장 크게 오르는 부분이야.
대충 하지 말고 실제로 실행해서 느낌을 확인한 뒤 조정해줘.
```

---

## 6단계 · 광고 + 결제 (창 A)

**먼저 사용자가 직접 할 일이 있습니다:**

1. [AdMob](https://admob.google.com) 가입 → 앱 등록 → 광고 단위 3개 생성
   (전면광고 1개, 보상형 광고 2개) → 각 단위 ID 복사
2. Play Console에서 앱 만들기 → 인앱 상품 2개 등록
   (`remove_ads` ₩5,500, `spellbook_pack` ₩3,300)

그 다음 아래를 붙여넣으세요.

```
GAME_DESIGN.md 7절대로 광고와 결제를 붙여줘.

내 AdMob 광고 단위 ID:
- 전면광고: (여기에 붙여넣기)
- 보상형 광고 1 (부활): (여기에 붙여넣기)
- 보상형 광고 2 (재굴림): (여기에 붙여넣기)

인앱 상품 ID: remove_ads, spellbook_pack

만들 것:
1. lib/services/ad_service.dart — google_mobile_ads
2. lib/services/iap_service.dart — in_app_purchase

필수 요구사항:
- 인터넷이 없으면 광고를 조용히 건너뛰어야 해. 에러 메시지를 절대 띄우지 마
- 광고 제거를 구매했으면 광고 관련 코드를 전부 우회
- 구매 상태는 shared_preferences에 저장해서 오프라인에서도 유지
- 개발 중에는 AdMob 테스트 광고 ID를 쓰고, 실제 ID로 바꾸는 방법을 알려줘
- 앱 시작 시 이전 구매 복원(restore) 처리

그리고 개인정보처리방침이 스토어 심사에 필요하니, 이 앱에 맞는
한국어 개인정보처리방침 초안을 PRIVACY.md로 만들어줘.
```

---

## 7단계 · 안드로이드 빌드 (창 A)

```
안드로이드 출시 빌드를 준비해줘.

1. android/app/build.gradle 설정 (applicationId, versionCode, minSdkVersion)
2. 서명 키(keystore) 생성 방법을 단계별로 알려줘. 명령어를 그대로 알려줘야 해
3. key.properties 설정 및 .gitignore 처리
4. 앱 아이콘 설정 방법
5. `flutter build appbundle` 실행

각 단계에서 내가 터미널에 직접 입력해야 하는 명령은
번호를 매겨서 하나씩 알려줘. 한 번에 여러 개 주지 마.

주의: 서명 키를 잃어버리면 앱 업데이트가 영영 불가능하다는 점을
어디에 백업해야 하는지 포함해서 알려줘.
```

---

## 크레딧이 남으면

```
지금까지 만든 코드를 재사용 가능한 템플릿으로 정리해줘.

1. CLAUDE.md의 LESSONS 항목을 이번 작업에서 배운 내용으로 채워줘.
   특히 내가 정정했던 부분, 네가 잘못 짰던 부분을 구체적으로.
2. 다음에 비슷한 Flutter 캐주얼 게임을 만들 때 그대로 복사해 쓸 수 있도록,
   게임 로직과 무관한 공통 부분(저장, 광고, 결제, 사운드, 화면 전환)을
   template/ 폴더로 분리해줘.
3. 이번 프로젝트를 처음부터 다시 만든다면 어떤 순서로 하는 게 나았을지
   회고를 NEXT_TIME.md로 남겨줘.
```

이 마지막 단계가 오늘 크레딧에서 **가장 오래 남는 자산**입니다.
크레딧은 사라져도 템플릿과 LESSONS는 남습니다.
