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
}
