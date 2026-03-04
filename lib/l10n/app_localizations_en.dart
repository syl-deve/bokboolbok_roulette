// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Luck Roulette';

  @override
  String get participants => 'Participants';

  @override
  String get roulette => 'Roulette';

  @override
  String get history => 'History';

  @override
  String get enterParticipantName => 'Enter participant name';

  @override
  String get exampleName => 'Ex: John Doe';

  @override
  String get noParticipants => '🙋‍♀️ Please add participants!';

  @override
  String get winner => 'No. of Winners';

  @override
  String get spinRoulette => 'Spin!';

  @override
  String get finalWinner => 'Final Winner';

  @override
  String get noHistory => '📭 No winning history yet.';

  @override
  String get times => ' times';

  @override
  String get resetHistory => 'Reset History';

  @override
  String get confirmResetHistory =>
      'Are you sure you want to reset the entire history?';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get personUnit => 'person';

  @override
  String get clearAll => 'Clear All';

  @override
  String findingWinner(int current, int total) {
    return 'Finding winner $current of $total...';
  }

  @override
  String selectingWinners(int count) {
    return 'Selecting $count winner(s) sequentially';
  }

  @override
  String get winnerTitle => 'Winner!';

  @override
  String get winnersTitle => 'Winners!';

  @override
  String get close => 'Close';

  @override
  String get spinAgain => 'Spin Again';

  @override
  String get presets => 'Presets';

  @override
  String get savePreset => 'Save Current List';

  @override
  String get noPresets => '📂 No saved presets.';

  @override
  String get presetNameHint => 'Enter preset name';

  @override
  String get save => 'Save';

  @override
  String get loadPreset => 'Load';

  @override
  String get deletePreset => 'Delete';

  @override
  String get confirmDeletePreset => 'Delete this preset?';

  @override
  String get presetLoaded => 'Preset loaded.';

  @override
  String get presetSaved => 'Preset saved.';

  @override
  String get presetNameEmpty => 'Please enter a name.';

  @override
  String presetPersonCount(int count) {
    return '$count person(s)';
  }
}
