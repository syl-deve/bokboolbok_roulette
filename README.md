# 🎯 복불복룰렛 (Lucky Roulette)

[![Get it on Google Play](https://play.google.com/intl/en_us/badges/static/images/badges/ko_badge_web_generic.png)](https://play.google.com/store/apps/details?id=com.malee.bokboolbok_roulette)

친구, 가족, 동료와 함께 쓰는 랜덤 추첨 앱입니다. 참가자 이름만 넣으면 룰렛, 사다리타기, 팀 나누기를 바로 할 수 있어요.
Flutter로 개발했고, Google Play에서 무료로 받을 수 있습니다(Android 전용).

<br>

## ✨ 주요 기능

화면 상단의 **[룰렛 | 사다리 | 팀 나누기]** 탭으로 모드를 바꾸고, 참가자 목록은 세 모드가 함께 씁니다. 각 모드의 실행 버튼은 화면 아래(배너 위)에 고정돼 있어 스크롤 없이 누를 수 있습니다.

### 🎡 룰렛
- 당첨자 수 조절 (1명 ~ 전체 인원 -1명), 여러 명이면 중복 없이 한 명씩 차례로 선정
- 효과음·진동·폭죽 효과, 당첨자 창

### 🪜 사다리타기
- 결과 칸을 직접 입력 (기본값: 당첨 1칸 + 나머지 꽝), 입력한 결과는 저장
- "사다리 타기"를 누르는 순간 가로줄이 생기고, 참가자별 색 선이 내려가며 결과 공개
- 결과를 먼저 완전히 무작위로 정한 뒤 그 결과가 나오는 사다리를 그려서, 누구나 모든 칸에 같은 확률로 도착

### 👥 팀 나누기
- 팀 수 선택 (2팀 ~ 참가자 수), 인원 차이가 최대 1명이 되도록 무작위로 나눔

### 📤 결과 공유
- 모든 모드의 결과 창에서 "결과 공유" → 결과 글 + Play 스토어 링크 (카카오톡에서는 스토어 미리보기 카드로 보임)

### 👤 참가자 · 📂 프리셋 · 📜 히스토리
- 참가자 추가(쉼표·줄바꿈으로 여러 명 한 번에)/이름 수정/삭제/전체 삭제(확인 후), 앱을 다시 열어도 유지
- 자주 쓰는 목록을 프리셋으로 저장하고 한 번에 불러오기
- 룰렛 당첨 기록과 횟수 순위 (이름에 특수문자가 있어도 저장)

### 🌐 다국어
한국어 · English · 日本語 · 中文

### 💰 광고 · PRO
- 하단 배너 광고, 각 모드 결과 창을 닫을 때 전면 광고 (AdMob)
- **PRO (1회 구매, `remove_ads_pro`)**: 모든 광고 제거, 앱바 ⋮ 메뉴에서 구매 복원 가능

### ⭐ 기타
- 결과 3회·10회째에 Play 인앱 리뷰 요청
- Firebase Analytics로 기능 사용 통계 수집 (참가자 이름 등 입력한 글자는 수집하지 않음)

<br>

## 🛠️ 기술 스택

| 구분 | 기술 | 설명 |
|:---|:---|:---|
| **Framework** | Flutter / Dart | Android 전용 |
| **상태 관리** | Provider | `PlayerProvider` 하나로 참가자·프리셋·기록 관리 |
| **UI / 애니메이션** | `flutter_fortune_wheel`, `confetti`, CustomPainter | 룰렛 휠, 폭죽, 사다리 그리기 |
| **소리 / 진동** | `audioplayers`, `HapticFeedback` | |
| **저장** | `shared_preferences` | 참가자·프리셋·기록·사다리 결과 |
| **수익화** | `google_mobile_ads`, `in_app_purchase` | 광고, 광고 제거 PRO |
| **분석 · 리뷰 · 공유** | `firebase_analytics`, `in_app_review`, `share_plus` | |
| **다국어** | `flutter_localizations` (ARB) | ko / en / ja / zh |

<br>

## 🚀 실행 방법

```bash
flutter pub get                    # 패키지 설치
flutter run                        # Android 기기에서 실행
flutter test                       # 테스트
flutter analyze --no-fatal-infos   # 정적 분석
flutter gen-l10n                   # ARB 수정 후 다국어 파일 재생성
flutter build appbundle --release  # Play Console 업로드용 AAB
```

릴리스 서명에는 `android/key.properties`와 `my-release-key.jks`가 필요합니다(둘 다 git 제외).

<br>

## 📁 프로젝트 구조

```
lib/
├── main.dart                    # 앱 설정, 룰렛, 공용 화면 (탭·참가자·프리셋·히스토리)
├── modes/
│   ├── ladder.dart              # 사다리타기 (로직 + 화면)
│   ├── team_split.dart          # 팀 나누기 (로직 + 화면)
│   └── mode_result_dialog.dart  # 사다리·팀 공용 결과 창
├── design_tokens.dart           # 디자인 색상 (DESIGN.md 기준)
├── app_analytics.dart           # Firebase Analytics
├── result_share.dart            # 결과 공유
├── review_prompter.dart         # 인앱 리뷰 요청
├── iap_service.dart             # 인앱 결제
├── firebase_options.dart        # Firebase 설정 (자동 생성)
└── l10n/                        # 다국어 (ko, en, ja, zh)
test/                            # 사다리 공정성·팀 균형·기록 저장 테스트
store-screenshots/               # Play 스토어 스크린샷 (폰·태블릿 × 4개 언어)
privacy-policy.html, terms.html  # GitHub Pages로 공개되는 개인정보처리방침·이용약관
```

개발 세부 규칙(저장 키, 분석 이벤트, 주의할 점)은 [AGENTS.md](AGENTS.md), 디자인 규칙은 [DESIGN.md](DESIGN.md)에 있습니다.

<br>

## 🗺️ 다음에 할 일

| 항목 | 설명 |
|:---|:---|
| 다크 모드 | DESIGN.md가 밝은 화면만 정의하고 있어 먼저 디자인 결정이 필요 |
| 글꼴 | DESIGN.md의 Geologica와 한국어·중국어 글꼴 결정 |
| "프리셋" 용어 | 가족 사용자에게 더 쉬운 말("저장한 명단" 등) 검토 |

<br>

## 📦 버전

**v1.1.1** (build 20) · 2026-11-21 심사 제출
