import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around Firebase Analytics.
///
/// Only counts and actions are logged. Participant names, preset names and
/// other text the user types are never sent.
class AppAnalytics {
  static bool enabled = false;

  static FirebaseAnalytics get _fa => FirebaseAnalytics.instance;

  static Future<void> _log(String name, [Map<String, Object>? params]) async {
    if (!enabled) return;
    try {
      await _fa.logEvent(name: name, parameters: params);
    } catch (error) {
      debugPrint('Analytics event "$name" failed: $error');
    }
  }

  static Future<void> spinStart({
    required int participants,
    required int winners,
    required bool again,
  }) => _log('spin_start', {
    'participants': participants,
    'winners': winners,
    'again': again ? 1 : 0,
  });

  static Future<void> resultShown({
    required int participants,
    required int winners,
  }) =>
      _log('result_shown', {'participants': participants, 'winners': winners});

  /// [mode] is `roulette`, `ladder` or `teams`. [participants] is always the
  /// participant count; [winners] is only sent by the roulette.
  static Future<void> shareTapped({
    required String mode,
    required int participants,
    int? winners,
  }) => _log('share_tapped', {
    'mode': mode,
    'participants': participants,
    if (winners != null) 'winners': winners,
  });

  /// [status] is the share sheet outcome: success, dismissed, unavailable
  /// or error.
  static Future<void> shareResult(
    String status, {
    String mode = 'roulette',
  }) async {
    if (status == 'success' && enabled) {
      try {
        await _fa.logShare(
          contentType: 'result_$mode',
          itemId: 'roulette_result',
          method: 'share_sheet',
        );
      } catch (error) {
        debugPrint('Analytics share event failed: $error');
      }
    }
    await _log('share_outcome', {'status': status, 'mode': mode});
  }

  static Future<void> modeSelected(String mode) =>
      _log('mode_select', {'mode': mode});

  static Future<void> ladderStart({required int participants}) =>
      _log('ladder_start', {'participants': participants});

  static Future<void> teamSplit({
    required int participants,
    required int teams,
  }) => _log('team_split', {'participants': participants, 'teams': teams});

  static Future<void> presetSaved({required int participants}) =>
      _log('preset_save', {'participants': participants});

  static Future<void> presetLoaded({required int participants}) =>
      _log('preset_load', {'participants': participants});

  static Future<void> historyCleared() => _log('history_clear');

  static Future<void> removeAdsTapped() => _log('remove_ads_tap');

  static Future<void> restoreTapped() => _log('restore_purchase_tap');
}
