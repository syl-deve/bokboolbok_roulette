# 🎯 복불복룰렛 (Lucky Roulette)

[![Get it on Google Play](https://play.google.com/intl/en_us/badges/static/images/badges/ko_badge_web_generic.png)](https://play.google.com/store/apps/details?id=com.malee.bokboolbok_roulette)

친구, 동료들과 함께 즐기는 간단하고 직관적인 룰렛 추첨 앱입니다.
Flutter로 개발되었으며, Google Play Store에서 누구나 무료로 다운로드할 수 있습니다.

<br>

## ✨ 주요 기능

### 🎡 룰렛 추첨
- 부드러운 애니메이션의 컬러풀한 룰렛 휠
- 당첨자 수 조절 (1명 ~ 전체 인원 -1명)
- 다회 뽑기 시 중복 당첨 없이 순차 선정
- 최종 당첨자 발표 시 폭죽 이펙트 + 당첨자 다이얼로그

### 👥 참가자 관리
- 참가자 추가 / 개별 삭제 / 전체 삭제
- 앱 재시작 후에도 목록 유지 (로컬 저장)

### 📂 프리셋
- 현재 참가자 목록을 이름을 붙여 프리셋으로 저장
- 저장된 프리셋 원터치 불러오기 (현재 목록 교체)
- 프리셋 미리보기: 참가자 최대 3명 이름 + 총 인원 수
- 프리셋 삭제
- 앱 재시작 후에도 프리셋 유지

### 📜 당첨 기록
- 당첨자 자동 기록 (이름 + 누적 횟수)
- 당첨 횟수 순위 정렬
- 기록 전체 초기화

### 🌐 다국어 지원
한국어 · English · 日本語 · 中文

### 💰 광고
- 하단 배너 광고 (AdMob)
- 스핀 후 전면 광고 (AdMob)

<br>

## 🛠️ 기술 스택

| 구분 | 기술 | 설명 |
|:---|:---|:---|
| **Framework** | `Flutter` / `Dart` | 크로스플랫폼 앱 개발 |
| **State Management** | `Provider` | 단일 `ChangeNotifier` 기반 상태 관리 |
| **UI / Animation** | `flutter_fortune_wheel`, `confetti` | 룰렛 휠, 폭죽 애니메이션 |
| **Sound / Haptic** | `audioplayers` | 스핀·당첨 효과음, 햅틱 피드백 |
| **Local Storage** | `shared_preferences` | 참가자 목록 · 프리셋 · 당첨 기록 영속성 |
| **Monetization** | `google_mobile_ads` | 배너 · 전면 광고 |
| **Localization** | `flutter_localizations` | ko / en / ja / zh |

<br>

## 🚀 실행 방법

```bash
# 1. 패키지 설치
flutter pub get

# 2. 앱 실행
flutter run

# 3. 빌드 (Android 릴리즈)
flutter build apk --release

# l10n 재생성 (arb 파일 수정 후)
flutter gen-l10n
```

<br>

## 📁 프로젝트 구조

```
lib/
└── main.dart          # 앱 전체 로직 (단일 파일 구조, ~1,500 lines)
    ├── AdHelper        # AdMob 전면광고 라이프사이클
    ├── MyBannerAd      # 배너광고 위젯
    ├── Player          # 참가자 데이터 모델
    ├── Preset          # 프리셋 데이터 모델
    ├── PlayerProvider  # 상태 관리 (참가자·프리셋·기록)
    ├── HomeScreen      # 메인 UI (룰렛·참가자 목록·스핀 버튼)
    ├── _PresetSheet    # 프리셋 BottomSheet
    ├── _HistorySheet   # 당첨 기록 BottomSheet
    └── _WinnerDialog   # 당첨자 다이얼로그
lib/l10n/
    ├── app_ko.arb
    ├── app_en.arb
    ├── app_ja.arb
    └── app_zh.arb
```

<br>

## 🗺️ 로드맵 (미구현 기능)

| 기능 | 설명 |
|:---|:---|
| 📅 기록 타임스탬프 | 당첨 기록에 날짜/시간 추가 |
| 📆 세션 단위 기록 | 날짜별로 기록 구분하여 조회 |
| ✏️ 참가자 이름 편집 | 삭제 없이 인라인 수정 |

<br>

## 📦 버전

**v1.0.2** (build 8) · 2026-03-06 기준
