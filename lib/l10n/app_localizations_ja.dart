// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ラッキールーレット';

  @override
  String get participants => '参加者';

  @override
  String get roulette => 'ルーレット';

  @override
  String get history => '履歴';

  @override
  String get enterParticipantName => '参加者名を入力';

  @override
  String get exampleName => '例：田中太郎';

  @override
  String get noParticipants => '🙋‍♀️ 参加者を追加してください！';

  @override
  String get winner => '当選者数';

  @override
  String get spinRoulette => '回す';

  @override
  String get finalWinner => '最終当選者';

  @override
  String get noHistory => '📭 まだ当選履歴がありません。';

  @override
  String get times => '回';

  @override
  String get resetHistory => '履歴をリセット';

  @override
  String get confirmResetHistory => '本当にすべての履歴を削除しますか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get reset => 'リセット';

  @override
  String get personUnit => '人';

  @override
  String get clearAll => 'すべて削除';

  @override
  String findingWinner(int current, int total) {
    return '$total人の中から$current番目の当選者を選んでいます...';
  }

  @override
  String selectingWinners(int count) {
    return '順次$count人の当選者を選定します';
  }

  @override
  String get winnerTitle => '当選！';

  @override
  String get winnersTitle => '当選者発表！';

  @override
  String get close => '閉じる';

  @override
  String get spinAgain => 'もう一度回す';

  @override
  String get presets => 'プリセット';

  @override
  String get savePreset => '現在のリストを保存';

  @override
  String get noPresets => '📂 保存されたプリセットがありません。';

  @override
  String get presetNameHint => 'プリセット名を入力';

  @override
  String get save => '保存';

  @override
  String get loadPreset => '読み込む';

  @override
  String get deletePreset => '削除';

  @override
  String get confirmDeletePreset => 'プリセットを削除しますか？';

  @override
  String get presetLoaded => 'プリセットを読み込みました。';

  @override
  String get presetSaved => 'プリセットを保存しました。';

  @override
  String get presetNameEmpty => '名前を入力してください。';

  @override
  String presetPersonCount(int count) {
    return '$count人';
  }
}
