🎯 복불복룰렛 (Bokboolbok Roulette)
친구, 동료들과 함께 즐기는 간단하고 직관적인 룰렛 앱입니다. Flutter로 개발되었으며, Google Play Store를 통해 누구나 다운로드하여 사용할 수 있습니다.

Tip: 앱을 시연하는 GIF 파일을 만들어 위 이미지 링크를 교체하면 훨씬 멋진 README가 됩니다.

✨ 주요 기능 (Features)
✍️ 참가자 관리: 참가자를 자유롭게 추가/삭제할 수 있으며, 앱을 종료해도 목록이 유지됩니다.

🎯 상세한 룰렛 기능: 부드러운 UI의 룰렛을 제공하며, 1명부터 여러 명까지 원하는 당첨자 수를 선택하여 뽑을 수 있습니다.

📜 당첨 기록 & 통계: 누가 몇 번 당첨되었는지 자동으로 기록하고, 당첨 횟수 순으로 순위를 보여주는 통계 기능을 제공합니다.

🎉 결과 축하 효과: 최종 당첨자가 결정되면 화려한 폭죽 효과가 터져 재미를 더해줍니다.

🌐 다국어 지원 (Localization): 한국어와 영어를 모두 지원하여 글로벌 사용성을 확보했습니다.

💰 광고 수익화 (AdMob): 배너 광고와 전면 광고를 적용하여 실제 앱 운영에 필요한 수익화 모델을 구현했습니다.

🛠️ 기술 스택 (Tech Stack)
구분	기술	설명
Framework & Language	Flutter / Dart	크로스플랫폼 앱 개발
State Management	Provider	상태 관리 및 UI와 비즈니스 로직 분리
UI / Animation	flutter_fortune_wheel, confetti	룰렛 UI 및 당첨 축하 애니메이션
Local Storage	shared_preferences	참가자 목록, 당첨 기록 등 데이터 영속성 처리
Monetization	google_mobile_ads	배너 및 전면 광고를 통한 수익화
Localization	flutter_localizations	한국어, 영어 다국어 지원

Sheets로 내보내기
🚀 프로젝트 실행 방법 (Getting Started)
Bash

# 1. 저장소 복제
git clone https://github.com/syl-deve/bokboolbok_roulette.git

# 2. 프로젝트 폴더로 이동
cd bokboolbok_roulette

# 3. 패키지 설치
flutter pub get

# 4. 앱 실행
flutter run
