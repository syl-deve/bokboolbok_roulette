// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get participants => '참가자';

  @override
  String get roulette => '룰렛';

  @override
  String get history => '히스토리';

  @override
  String get enterParticipantName => '참가자 이름 입력';

  @override
  String get exampleName => '예: 홍길동';

  @override
  String get noParticipants => '🙋‍♀️ 참가자를 추가해주세요!';

  @override
  String get winner => '당첨자 수';

  @override
  String get spinRoulette => '돌리기';

  @override
  String get finalWinner => '최종 당첨자';

  @override
  String get noHistory => '📭 아직 당첨 기록이 없습니다.';

  @override
  String get times => '회';

  @override
  String get resetHistory => '히스토리 초기화';

  @override
  String get confirmResetHistory => '정말로 모든 당첨 기록을 삭제하시겠습니까?';

  @override
  String get cancel => '취소';

  @override
  String get reset => '초기화';

  @override
  String get personUnit => '명';

  @override
  String get clearAll => '전체 삭제';

  @override
  String findingWinner(int current, int total) {
    return '$total명 중 $current번째 당첨자 선정 중...';
  }

  @override
  String selectingWinners(int count) {
    return '순차적으로 $count명을 선정합니다';
  }

  @override
  String get winnerTitle => '당첨!';

  @override
  String get winnersTitle => '당첨자 발표!';

  @override
  String get close => '닫기';

  @override
  String get spinAgain => '다시 돌리기';
}
