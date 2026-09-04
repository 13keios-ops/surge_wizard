# 밤샘 무인 작업 프롬프트

> ## ⚠️ 오늘 밤 (Flutter·git 미설치) → **A안**을 쓰세요
> ## 내일 이후 (환경 준비 완료) → **B안**을 쓰세요

---

# A안 · Flutter 없이 데이터 생성만 (오늘 밤 이걸 쓰세요)

폴더에 **`GAME_DESIGN.md` 하나만** 넣고 실행하세요.

```powershell
mkdir D:\Projects\surge_wizard
cd D:\Projects\surge_wizard
claude --dangerously-skip-permissions
```

아래 블록 전체를 붙여넣고 주무세요.

```
GAME_DESIGN.md를 전부 읽어라. 나는 자고 있으니 질문하지 마라.
막히면 BLOCKERS.md에 적고 다음 작업으로 넘어가라.
D:\Projects\surge_wizard 폴더 밖은 절대 건드리지 마라.

이 PC에는 git과 Flutter가 설정되어 있지 않다.
Dart나 Flutter 코드를 작성하지 마라. git 명령도 쓰지 마라.
검증은 Python으로만 해라.

assets/data/ 폴더에 아래 JSON 4개를 순서대로 만들어라.
하나를 완성하고 검증한 뒤 다음으로 넘어가라.

1) spells.json — 주문 70종 (GAME_DESIGN.md 5.1절 스키마)
   common 30 / rare 25 / epic 15, 속성 5종
   base_damage: common 5~9, rare 8~14, epic 12~22
   dc_modifier: common 0, rare 0~1, epic 1~3
   30%는 effect 보유. 이름과 설명은 한국어, 설명은 20자 이내

2) surges.json — 폭주 80종 (5.2절) ★ 가장 공들여라
   자해형 30% / 반전형 20% / 소환형 20% / 도박형 15% / 순수이득형 15%
   설명은 구체적인 사고가 눈에 그려지게 써라.
   "마법이 실패했다" 같은 밋밋한 문장은 전부 다시 써라.
   effect type은 5.2절에 명시된 것만 사용

3) enemies.json — 적 30종 (일반 26 + 보스 4)
   4.4절 층별 HP/대미지 곡선에 맞춰 tier 1~5 배치
   pattern은 3~4개 행동의 고정 순환, 랜덤 없음
   보스는 HP 90 내외 2페이즈

4) relics.json — 유물 40종 (common 18 / rare 14 / epic 8)
   70%는 판정 확률 관련. 판정 보정은 epic이라도 최대 +3

각 파일마다 Python으로 JSON 파싱 검증과 id 중복 확인을 실제로 실행해라.
통계(등급별 개수, 평균값)를 PROGRESS.md에 표로 기록해라.

4개가 다 끝나고 시간이 남으면, GAME_DESIGN.md 3.4절 확률표를
Python으로 검증하는 스크립트를 tool/verify_probability.py 로 만들고 실행해서
결과를 BALANCE.md에 기록해라. 수치를 고치지는 말고 기록만 해라.

전부 끝나면 MORNING_REPORT.md를 쓰고 멈춰라.
전문 용어는 괄호로 한 줄 설명을 붙여라. 나는 비전공자다.
```

---
---

# B안 · Flutter 포함 전체 작업 (내일 이후)

이미 만들어진 파일이 있으면 확인하고 이어서 작업해라. 처음부터 다시 만들지 마라.

`GAME_DESIGN.md`와 `CLAUDE.md`를 폴더에 넣고 실행하세요.

아래 블록 **전체**를 Claude Code에 한 번에 붙여넣고 주무세요.

---

```
너는 오늘 밤 혼자서 작업한다. 나는 자고 있어서 질문에 답할 수 없다.
아래 규칙을 반드시 지켜라.

## 무인 작업 규칙

1. 나에게 질문하지 마라. 확인이 필요하면 스스로 판단하고,
   판단 근거를 BLOCKERS.md에 기록한 뒤 계속 진행해라.
2. 어떤 작업에서 막히면 30분 이상 붙잡지 말고,
   BLOCKERS.md에 상황을 적고 다음 작업으로 넘어가라.
3. 아래 "금지 작업"은 절대 시도하지 마라. 계정이나 비밀번호가 필요해서
   내가 깨어 있어야만 가능한 일이다.
4. 각 작업이 끝날 때마다 진행 상황을 PROGRESS.md에 갱신해라.
5. 모든 작업이 끝나면 MORNING_REPORT.md를 작성하고 멈춰라.

## 금지 작업 (절대 하지 마라)

- AdMob, Google Play Console, Apple 관련 모든 작업
- 광고(google_mobile_ads), 인앱결제(in_app_purchase) 코드 작성
- 서명 키(keystore) 생성, 출시 빌드
- git push, 외부 서비스 가입, 결제
- 프로젝트 폴더 바깥의 파일을 건드리는 일

## 시작 전에 읽을 것

GAME_DESIGN.md 와 CLAUDE.md 를 먼저 전부 읽어라.
이 두 파일이 모든 판단의 기준이다. 여기 적힌 수치를 임의로 바꾸지 마라.

---

## 작업 1 — 판정 엔진 (최우선)

lib/core/ 에 아래를 만들어라. UI는 만들지 마라.

- constants.dart : 모든 밸런싱 수치를 상수로 (DC 7/10/13, 위력 배율,
  결과 4단계 경계, 마력 축적 임계치 등)
- dice.dart : 주사위 3개 굴림, 개별 잠금, 잠기지 않은 것만 재굴림
- combo.dart : 족보 판정 (트리플 > 스트레이트 > 뱀눈 > 페어 우선순위)
- check.dart : 판정 엔진
  입력 = 주사위 눈 3개, DC, 보정치, 마력 축적 게이지
  출력 = 결과 등급(대성공/성공/아슬아슬/실패), 적용 족보, 최종 판정값

## 작업 2 — 단위 테스트 (통과할 때까지 반복)

test/check_test.dart 를 만들고 CLAUDE.md "테스트 규칙"을 전부 커버해라.

핵심 검증:
- 몬테카를로 10만 회 시뮬레이션 결과가 GAME_DESIGN.md 3.4절 확률표와
  오차 1% 이내로 일치하는가
- 트리플은 항상 대성공인가
- 뱀눈은 항상 폭주인가
- 페어 +3 보정이 정확한가
- 족보 우선순위가 지켜지는가
- 마력 축적 3칸에서 다음 시전이 무조건 대성공인가

`flutter test` 를 실행해서 전부 통과할 때까지 스스로 고쳐라.
통과하기 전에는 작업 3으로 넘어가지 마라.
시뮬레이션 결과와 3.4절 표를 비교한 표를 PROGRESS.md에 기록해라.

## 작업 3 — 게임 데이터 생성 (가장 오래 걸림)

GAME_DESIGN.md 5절 스키마대로 assets/data/ 에 JSON 4개를 만들어라.
한 번에 다 만들지 말고 아래 순서로 하나씩, 각각 완성 후 검증해라.

3-1. spells.json — 주문 70종
     common 30 / rare 25 / epic 15
     속성 5종(fire, frost, arcane, shadow, nature)
     base_damage: common 5~9, rare 8~14, epic 12~22
     dc_modifier: common 0, rare 0~1, epic 1~3
     30%는 effect 보유 (방어막/회복/적 지연/마나회복/판정보정/주사위추가)
     이름과 설명은 한국어, 설명은 20자 이내

3-2. surges.json — 폭주 80종 ★ 이 게임의 유일한 차별점. 가장 공들여라
     자해형 30% / 반전형 20% / 소환형 20% / 도박형 15% / 순수이득형 15%
     설명은 구체적인 사고가 눈에 그려지게 써라.
     "마법이 실패했다" 같은 밋밋한 문장은 전부 다시 써라.
     effect type은 실제 구현 가능한 것만:
     self_damage, heal, mana_change, seal_spell, swap_hp, summon_ally,
     damage_multiplier, skip_enemy_turn, extra_die, force_reroll

3-3. enemies.json — 적 30종 (일반 26 + 보스 4)
     GAME_DESIGN.md 4.4절 층별 HP/대미지 곡선에 맞춰 tier 1~5 배치
     pattern은 3~4개 행동의 고정 순환. 랜덤 없음
     보스는 HP 90 내외 2페이즈

3-4. relics.json — 유물 40종 (common 18 / rare 14 / epic 8)
     70%는 판정 확률 관련 효과
     판정 보정은 epic이라도 최대 +3까지만 (확률 설계가 무너지지 않도록)

각 파일마다:
- JSON 문법 유효성을 실제로 파싱해서 검증해라
- id 중복이 없는지 확인해라
- 통계(등급별 개수, 평균값)를 PROGRESS.md에 표로 기록해라

## 작업 4 — 모델과 로더

lib/models/ 에 spell, enemy, relic, surge_event 모델을 만들고
lib/data/loader.dart 로 JSON을 로드/파싱해라.

test/loader_test.dart 를 만들어서 4개 JSON이 전부 오류 없이
파싱되는지 검증해라. 하나라도 실패하면 JSON을 고쳐라.

## 작업 5 — 전투 로직 (UI 없이)

lib/core/battle.dart 에 전투 진행 로직만 만들어라. 화면은 만들지 마라.
GAME_DESIGN.md 4.1절 턴 흐름 그대로.

test/battle_test.dart 에서 화면 없이 한 전투를 끝까지 시뮬레이션해서
정상 종료되는지 검증해라.

## 작업 6 — 밸런스 시뮬레이션 (남는 시간에)

UI 없이 1층~10층 한 판을 1000회 자동 플레이하는 시뮬레이터를 만들어
tool/simulate.dart 로 저장하고 실행해라.

측정할 것:
- 층별 사망률
- 평균 도달 층수
- 판정 결과 4단계의 실제 발생 비율
- 폭주 발생 빈도

결과를 BALANCE.md에 표로 정리하고, 수치가 이상한 부분을
"이유 + 제안하는 수정값" 형태로 적어라. 단, 수치를 직접 고치지는 마라.
내가 아침에 보고 판단하겠다.

---

## 마지막에 할 일

MORNING_REPORT.md 를 작성해라. 내용:

1. 완료한 작업과 완료하지 못한 작업
2. flutter test 최종 결과
3. 생성한 데이터 통계 요약
4. BLOCKERS.md에 쌓인 문제 목록
5. 밸런스 시뮬레이션 결과 요약과 우려되는 지점
6. 내가 아침에 가장 먼저 해야 할 일 3가지
7. CLAUDE.md의 LESSONS 항목에 이번 작업에서 배운 것을 추가

전문 용어는 괄호로 한 줄 설명을 붙여라. 나는 비전공자다.
보고서를 다 쓰면 멈춰라. 새 작업을 시작하지 마라.
```

---

## 아침에 확인할 파일

일어나서 이 순서로 보세요.

1. **`MORNING_REPORT.md`** — 밤새 뭘 했는지
2. **`BLOCKERS.md`** — 막힌 곳
3. **`BALANCE.md`** — 게임이 너무 어렵거나 쉬운지
4. `PROGRESS.md` — 상세 기록

그 다음 `PROMPTS.md`의 3단계(전투 화면)부터 이어가시면 됩니다.
