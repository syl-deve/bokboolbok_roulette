import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'app_analytics.dart';

const _kStoreUrl =
    'https://play.google.com/store/apps/details?id=com.malee.bokboolbok_roulette';

/// Shares the result as text followed by the Play Store link.
///
/// Text only on purpose: messengers such as KakaoTalk drop the text when an
/// image is attached, and the link is what lets friends install the app
/// (KakaoTalk shows it as a store preview card).
/// Returns false if the share sheet could not be opened.
Future<bool> shareResultText(
  String message, {
  required int winners,
  Rect? origin,
}) async {
  AppAnalytics.shareTapped(winners: winners);
  try {
    final result = await SharePlus.instance.share(
      ShareParams(text: '$message\n$_kStoreUrl', sharePositionOrigin: origin),
    );
    AppAnalytics.shareResult(result.status.name);
    return result.status != ShareResultStatus.unavailable;
  } catch (error) {
    debugPrint('Result share failed: $error');
    AppAnalytics.shareResult('error');
    return false;
  }
}
