import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Handles Apple's App Tracking Transparency (ATT) consent.
///
/// App Store Guideline 5.1.2(i) requires the ATT prompt to be shown before any
/// data that could be used to track the user across apps or websites is
/// collected. The prompt is iOS-only; every other platform is a no-op.
class TrackingPermissionService {
  const TrackingPermissionService._();

  static bool _alreadyAsked = false;

  /// True once the user has allowed tracking on this device.
  static bool isAuthorized = false;

  /// Shows the system ATT prompt the first time the app runs on iOS.
  ///
  /// Safe to call more than once: the system only ever shows the dialog while
  /// the status is `notDetermined`, and this guards against asking twice in a
  /// single session.
  static Future<void> requestIfNeeded() async {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.iOS ||
        _alreadyAsked) return;
    _alreadyAsked = true;

    try {
      var status = await AppTrackingTransparency.trackingAuthorizationStatus;

      if (status == TrackingStatus.notDetermined) {
        // iOS silently drops the prompt if the app is not fully active yet, so
        // let the first screen settle before asking.
        await Future.delayed(const Duration(milliseconds: 700));
        status = await AppTrackingTransparency.requestTrackingAuthorization();
      }

      isAuthorized = status == TrackingStatus.authorized;
    } catch (e) {
      // Consent is optional - the app must keep working if the plugin or the
      // platform call fails.
      isAuthorized = false;
    }
  }
}
