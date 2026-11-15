import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Asks for a Play Store review after the user has seen a few results.
///
/// Every finished result is counted. The native review sheet is requested
/// only when the result dialog is closed (not mid-flow on "spin again"),
/// and at most once per threshold. Google Play applies its own quota on top,
/// so a request may show nothing.
class ReviewPrompter {
  static const _kResultCountKey = 'review_result_count';
  static const _kPromptedThresholdKey = 'review_prompted_threshold';
  static const List<int> _kThresholds = [3, 10];

  static Future<void> onResult({required bool canPrompt}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt(_kResultCountKey) ?? 0) + 1;
      await prefs.setInt(_kResultCountKey, count);
      if (!canPrompt) return;

      final prompted = prefs.getInt(_kPromptedThresholdKey) ?? 0;
      final due = _kThresholds.lastWhere(
        (t) => t <= count,
        orElse: () => 0,
      );
      if (due == 0 || due <= prompted) return;

      await prefs.setInt(_kPromptedThresholdKey, due);
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.requestReview();
      }
    } catch (error) {
      debugPrint('In-app review request failed: $error');
    }
  }
}
