// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '복불복룰렛';

  @override
  String get participants => '참가자';

  @override
  String get roulette => '룰렛';

  @override
  String get history => '히스토리';

  @override
  String get enterParticipantName => '이름 입력 (쉼표로 여러 명 추가)';

  @override
  String get exampleName => '예: 홍길동';

  @override
  String get noParticipants => '참가자를 추가해주세요!';

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

  @override
  String get presets => '프리셋';

  @override
  String get savePreset => '현재 목록 저장';

  @override
  String get noPresets => '저장된 프리셋이 없습니다.';

  @override
  String get presetNameHint => '프리셋 이름 입력';

  @override
  String get save => '저장';

  @override
  String get loadPreset => '불러오기';

  @override
  String get deletePreset => '삭제';

  @override
  String get confirmDeletePreset => '프리셋을 삭제하시겠습니까?';

  @override
  String get presetLoaded => '프리셋을 불러왔습니다.';

  @override
  String get presetSaved => '프리셋이 저장되었습니다.';

  @override
  String get presetNameEmpty => '이름을 입력해주세요.';

  @override
  String presetPersonCount(int count) {
    return '$count명';
  }

  @override
  String get removeAds => '광고 제거';

  @override
  String get restorePurchase => '구매 복원';

  @override
  String get proVersion => 'PRO 버전';

  @override
  String get shareResult => '결과 공유';

  @override
  String shareMessage(int total) {
    return '복불복룰렛 추첨 결과 ($total명 중)';
  }

  @override
  String get shareInvite => '직접 돌려보기:';

  @override
  String get shareFailed => '공유하지 못했어요. 잠시 후 다시 시도해 주세요.';

  @override
  String get modeRoulette => '룰렛';

  @override
  String get modeLadder => '사다리';

  @override
  String get modeTeams => '팀 나누기';

  @override
  String get ladderStart => '사다리 타기';

  @override
  String get ladderWin => '당첨';

  @override
  String get ladderLose => '꽝';

  @override
  String get ladderEditHint => '아래 결과 칸을 누르면 내용을 바꿀 수 있어요';

  @override
  String get ladderEditTitle => '결과 입력';

  @override
  String get ladderResetResults => '결과 초기화';

  @override
  String get ladderResultTitle => '사다리 결과';

  @override
  String get ladderAgain => '다시 타기';

  @override
  String get teamCount => '팀 수';

  @override
  String get teamSplitButton => '팀 나누기';

  @override
  String teamName(int n) {
    return '$n팀';
  }

  @override
  String get teamResultTitle => '팀 나누기 결과';

  @override
  String get teamAgain => '다시 나누기';

  @override
  String shareLadderMessage(int total) {
    return '복불복룰렛 사다리 결과 ($total명)';
  }

  @override
  String shareTeamMessage(int total, int teams) {
    return '복불복룰렛 팀 나누기 결과 ($total명, $teams팀)';
  }

  @override
  String get editName => '이름 수정';

  @override
  String get nameTaken => '이미 목록에 있는 이름이에요.';

  @override
  String get proActivated => 'PRO가 적용됐어요. 이제 광고가 보이지 않아요.';

  @override
  String get purchaseFailed => '구매를 완료하지 못했어요. 잠시 후 다시 시도해 주세요.';

  @override
  String get storeUnavailable => 'Google Play에 연결할 수 없어요. 인터넷 연결을 확인해 주세요.';

  @override
  String get restoreChecking => '구매 내역을 확인하고 있어요.';

  @override
  String get addParticipant => '참가자 추가';

  @override
  String get removeParticipant => '참가자 삭제';

  @override
  String get decrease => '줄이기';

  @override
  String get increase => '늘리기';

  @override
  String confirmClearAll(int count) {
    return '참가자 $count명을 모두 지울까요?';
  }
}
