import 'dart:async';
import 'package:geebay/helpers/addons_helper.dart';
import 'package:geebay/helpers/auth_helper.dart';
import 'package:geebay/helpers/business_setting_helper.dart';
import 'package:geebay/helpers/shared_value_helper.dart';
import 'package:geebay/helpers/system_config.dart';
import 'package:geebay/presenter/currency_presenter.dart';
import 'package:geebay/providers/locale_provider.dart';
import 'package:geebay/screens/main.dart';
import 'package:geebay/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Index extends StatefulWidget {
  Index({super.key, this.goBack = true});
  final bool goBack;

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  Future<String?> getSharedValueHelperData() async {
    try {
      access_token.load().whenComplete(() {
        try {
          AuthHelper().fetch_and_set();
        } catch (e) {
          print("Error in AuthHelper: $e");
        }
      });

      // Load local shared values first (these are fast)
      await app_language.load();
      await app_mobile_language.load();
      await app_language_rtl.load();
      await system_currency.load();

      // Try to load network data with timeout, but don't block app startup
      try {
        await AddonsHelper().setAddonsData().timeout(
              Duration(seconds: 5),
            );
      } on TimeoutException {
        print("AddonsHelper timeout - continuing anyway");
      } catch (e) {
        print("Error loading addons: $e");
      }

      try {
        await BusinessSettingHelper().setBusinessSettingData().timeout(
              Duration(seconds: 5),
            );
      } on TimeoutException {
        print("BusinessSettingHelper timeout - continuing anyway");
      } catch (e) {
        print("Error loading business settings: $e");
      }

      // print("new splash screen ${app_mobile_language.$}");
      // print("new splash screen app_language_rtl ${app_language_rtl.$}");

      return app_mobile_language.$ ?? "en";
    } catch (e) {
      print("Error in getSharedValueHelperData: $e");
      return "en";
    }
  }

  @override
  void initState() {
    super.initState();
    print("Index.initState() called");
    // Ensure we show the splash screen immediately
    SystemConfig.isShownSplashScreed = false;

    // Defer SharedValue loading to avoid crashes during widget construction
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Load data with timeout to prevent indefinite hanging
      getSharedValueHelperData().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print("getSharedValueHelperData timeout - showing app anyway");
          return "en";
        },
      ).then((value) {
        // Fetch currency data after widget is built (context is available)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              Provider.of<CurrencyPresenter>(context, listen: false)
                  .fetchListData();
            } catch (e) {
              print("Error fetching currency data: $e");
            }
          }
        });

        // Show app after minimum splash time or when data loads
        Future.delayed(Duration(seconds: 2)).then((value) {
          if (mounted) {
            print("Index: Showing main app after splash");
            SystemConfig.isShownSplashScreed = true;
            try {
              final langCode = (() {
                try {
                  return app_mobile_language.$ ?? "en";
                } catch (e) {
                  print("Error accessing app_mobile_language: $e");
                  return "en";
                }
              })();
              Provider.of<LocaleProvider>(context, listen: false)
                  .setLocale(langCode);
            } catch (e) {
              print("Error setting locale: $e");
            }
            setState(() {});
          }
        });
      }).catchError((error) {
        print("Error in getSharedValueHelperData: $error");
        // Show app anyway even if there's an error
        if (mounted) {
          Future.delayed(Duration(seconds: 2)).then((value) {
            if (mounted) {
              SystemConfig.isShownSplashScreed = true;
              try {
                Provider.of<LocaleProvider>(context, listen: false)
                    .setLocale("en");
              } catch (e) {
                print("Error setting locale: $e");
              }
              setState(() {});
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      print(
          "Index.build() called, isShownSplashScreed: ${SystemConfig.isShownSplashScreed}");
      SystemConfig.context ??= context;

      // Always show splash screen first, then transition after data loads
      if (!SystemConfig.isShownSplashScreed) {
        print("Index.build: Showing SplashScreen");
        return SplashScreen();
      }

      // Only show Main after splash screen is done
      print("Index.build: Creating Main widget");
      // Use a Builder to ensure context is fully available
      return Builder(
        builder: (context) {
          try {
            print("Index.build: Inside Builder, creating Main");
            // Add a small delay to ensure everything is ready
            return FutureBuilder<void>(
              future: Future.delayed(Duration(milliseconds: 100)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  try {
                    return Main(go_back: widget.goBack);
                  } catch (e, stackTrace) {
                    print("Error creating Main widget: $e");
                    print("Stack trace: $stackTrace");
                    return Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Error loading app: $e"),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }
                return SplashScreen(); // Show splash while waiting
              },
            );
          } catch (e, stackTrace) {
            print("Error in Builder: $e");
            print("Stack trace: $stackTrace");
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error loading app: $e"),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      print("Error building Index widget: $e");
      print("Stack trace: $stackTrace");
      // Return a safe fallback widget
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Loading..."),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }
  }
}
