// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get winner => 'Winner';

  @override
  String get spinRoulette => 'Spin';

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
}
