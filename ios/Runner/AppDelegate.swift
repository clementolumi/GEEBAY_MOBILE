import Flutter
import UIKit
import flutter_downloader
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // flutter_downloader spins up a headless FlutterEngine for background
    // downloads and then calls this callback to register plugins on it.
    // The callback defaults to nil, and the plugin's nil check is an NSAssert
    // that is compiled out in Release, so leaving it unset crashes the app on
    // launch in a release build.
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerBackgroundPlugins)

    // Same story for the headless engine that handles notification actions.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func registerBackgroundPlugins(registry: FlutterPluginRegistry) {
  guard !registry.hasPlugin("FlutterDownloaderPlugin"),
        let registrar = registry.registrar(forPlugin: "FlutterDownloaderPlugin")
  else { return }
  FlutterDownloaderPlugin.register(with: registrar)
}
