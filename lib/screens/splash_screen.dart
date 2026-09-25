import 'package:geebay/app_config.dart';
import 'package:geebay/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: AppConfig.app_name,
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(body: splashScreen(context));
    } catch (e) {
      print("Error in SplashScreen.build: $e");
      return Scaffold(
        body: Container(
          color: MyTheme.splash_screen_color,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppConfig.app_name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget splashScreen(BuildContext context) {
    try {
      // Safely get MediaQuery data with fallback
      final mediaQuery = MediaQuery.maybeOf(context);
      if (mediaQuery == null) {
        // If MediaQuery is not available, use safe defaults
        return Container(
          color: MyTheme.splash_screen_color,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppConfig.app_name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        );
      }
      
      final screenHeight = mediaQuery.size.height;
      final screenWidth = mediaQuery.size.width;
      
      return Container(
        width: screenWidth,
        height: screenHeight,
        color: MyTheme.splash_screen_color,
        child: InkWell(
          child: Stack(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Hero(
                  tag: "backgroundImageInSplash",
                  child: Container(
                    child: Image.asset(
                        "assets/splash_login_registration_background_image.png"),
                  ),
                ),
                radius: 140.0,
              ),
              Positioned.fill(
                top: screenHeight / 2 - 72,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Hero(
                      tag: "splashscreenImage",
                      child: Container(
                        height: 72,
                        width: 72,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                            color: MyTheme.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: Image.asset(
                          "assets/splash_screen_logo.png",
                          filterQuality: FilterQuality.low,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      AppConfig.app_name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          color: Colors.white),
                    ),
                  ),
                  Text(
                    "V " + _packageInfo.version,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 51.0),
                  child: Text(
                    AppConfig.copyright_text,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    } catch (e) {
      print("Error building splash screen: $e");
      // Return a simple safe splash screen
      return Container(
        color: MyTheme.splash_screen_color,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppConfig.app_name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      );
    }
  }
}
