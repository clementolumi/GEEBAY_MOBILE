import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class OtherConfig {
  static bool get _isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Push notifications need a Firebase project.
  ///
  /// iOS has no `GoogleService-Info.plist` in the Runner target yet, so
  /// `Firebase.initializeApp()` fails there. Asking for the notification
  /// permission when no notification can ever arrive is both a poor experience
  /// and an App Review risk, so push stays off on iOS until the Firebase
  /// config file is added.
  static bool get USE_PUSH_NOTIFICATION => !_isIOS;

  /// Google sign-in needs an iOS OAuth client ID plus its reversed-client URL
  /// scheme in `Info.plist`; Facebook login needs `FacebookAppID` and
  /// `FacebookClientToken`. Neither is set up for iOS, so the buttons are
  /// hidden there rather than shown as dead controls.
  static bool get USE_GOOGLE_LOGIN => !_isIOS;

  static bool get USE_FACEBOOK_LOGIN => !_isIOS;

  /// The map picker needs a Google Maps API key (iOS: `GMSServices`, Android:
  /// `com.google.android.geo.API_KEY`). Neither is configured, and the iOS
  /// Maps SDK aborts the process when it is used without a key, so the map
  /// entry points stay hidden until [GOOGLE_MAP_API_KEY] is filled in.
  static const bool USE_GOOGLE_MAP = false;
  static const String GOOGLE_MAP_API_KEY = "";
}
