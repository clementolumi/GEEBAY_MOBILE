import 'dart:async';

import 'package:geebay/custom/aiz_route.dart';
import 'package:geebay/helpers/main_helpers.dart';
import 'package:geebay/middlewares/auth_middleware.dart';
import 'package:geebay/my_theme.dart';
import 'package:geebay/other_config.dart';
import 'package:geebay/presenter/cart_counter.dart';
import 'package:geebay/presenter/cart_provider.dart';
import 'package:geebay/presenter/currency_presenter.dart';
import 'package:geebay/presenter/select_address_provider.dart';
import 'package:geebay/presenter/unRead_notification_counter.dart';
import 'package:geebay/providers/locale_provider.dart';
import 'package:geebay/screens/all_routes.dart';
import 'package:geebay/screens/auction/auction_bidded_products.dart';
import 'package:geebay/screens/auction/auction_products.dart';
import 'package:geebay/screens/auction/auction_products_details.dart';
import 'package:geebay/screens/auction/auction_purchase_history.dart';
import 'package:geebay/screens/auth/login.dart';
import 'package:geebay/screens/auth/registration.dart';
import 'package:geebay/screens/brand_products.dart';
import 'package:geebay/screens/category_list_n_product/category_list.dart';
import 'package:geebay/screens/category_list_n_product/category_products.dart';
import 'package:geebay/screens/checkout/cart.dart';
import 'package:geebay/screens/coupon/coupons.dart';
import 'package:geebay/screens/filter.dart';
import 'package:geebay/screens/flash_deal/flash_deal_list.dart';
import 'package:geebay/screens/flash_deal/flash_deal_products.dart';
import 'package:geebay/screens/followed_sellers.dart';
import 'package:geebay/screens/index.dart';
import 'package:geebay/screens/orders/order_details.dart';
import 'package:geebay/screens/orders/order_list.dart';
import 'package:geebay/screens/package/packages.dart';
import 'package:geebay/screens/product/product_details.dart';
import 'package:geebay/screens/product/todays_deal_products.dart';
import 'package:geebay/screens/profile.dart';
import 'package:geebay/screens/seller_details.dart';
import 'package:geebay/services/push_notification_service.dart';
import 'package:geebay/services/tracking_permission_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:geebay/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';
import 'package:shared_value/shared_value.dart';

import 'app_config.dart';
import 'lang_config.dart';

void main() async {
  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // In production, you might want to log to a crash reporting service
    // e.g., Firebase Crashlytics, Sentry, etc.
  };

  // Set up zone error handling for async errors
  // IMPORTANT: ensureInitialized and runApp must be in the same zone
  runZonedGuarded(() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize FlutterDownloader with timeout
      try {
        await FlutterDownloader.initialize(
          debug: false,
          ignoreSsl: true,
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            // Silently continue - app works without downloader
          },
        );
      } catch (e) {
        // Continue anyway - app should work without downloader
      }

      // Configure system UI
      try {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ));
      } catch (e) {
        // Continue if system UI configuration fails
      }

      // Start the app
      final app = SharedValue.wrapApp(MyApp());
      runApp(app);
    } catch (e) {
      // Fallback app if initialization fails
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("Unable to start application"),
                  SizedBox(height: 20),
                  Text("Please try again later"),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }, (error, stack) {
    // Log uncaught errors (in production, send to crash reporting service)
    // App should continue running if possible
  });
}

// Make routes lazy - initialize it when needed, with caching
GoRouter? _cachedRoutes;

GoRouter getRoutes() {
  if (_cachedRoutes != null) {
    return _cachedRoutes!;
  }

  try {
    _cachedRoutes = GoRouter(
      overridePlatformDefaultLocation: false,
      navigatorKey: OneContext().key,
      initialLocation: "/",
      routes: [
        GoRoute(
            path: '/',
            name: "Home",
            pageBuilder: (BuildContext context, GoRouterState state) {
              return MaterialPage(child: Index());
            },
            routes: [
              GoRoute(
                  path: "customer_products",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(child: MyClassifiedAds())),
              GoRoute(
                  path: "customer-products",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(child: ClassifiedAds())),
              GoRoute(
                  path: "customer-product/:slug",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(
                          child: ClassifiedAdsDetails(
                        slug: getParameter(state, "slug"),
                      ))),
              GoRoute(
                  path: "product/:slug",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(
                          child: ProductDetails(
                        slug: getParameter(state, "slug"),
                      ))),
              GoRoute(
                  path: "customer-packages",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(child: UpdatePackage())),
              GoRoute(
                  path: "auction_product_bids",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(
                          child:
                              AuthMiddleware(AuctionBiddedProducts()).next())),
              GoRoute(
                  path: "users/login",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(child: Login())),
              GoRoute(
                  path: "users/registration",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(child: Registration())),
              GoRoute(
                  path: "dashboard",
                  name: "Profile",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      AIZRoute.rightTransition(Profile())),
              GoRoute(
                  path: "auction-products",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(child: AuctionProducts())),
              GoRoute(
                  path: "auction-product/:slug",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(
                          child: AuctionProductsDetails(
                        slug: getParameter(state, "slug"),
                      ))),
              GoRoute(
                  path: "auction/purchase_history",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(
                          child:
                              AuthMiddleware(AuctionPurchaseHistory()).next())),
              GoRoute(
                  path: "brand/:slug",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(
                          child: (BrandProducts(
                        slug: getParameter(state, "slug"),
                      )))),
              GoRoute(
                  path: "brands",
                  name: "Brands",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(
                          child: Filter(
                        selected_filter: "brands",
                      ))),
              GoRoute(
                  path: "cart",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(child: AuthMiddleware(Cart()).next())),
              GoRoute(
                  path: "categories",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(
                          child: (CategoryList(
                        slug: getParameter(state, "slug"),
                      )))),
              GoRoute(
                  path: "category/:slug",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(
                          child: (CategoryProducts(
                        slug: getParameter(state, "slug"),
                      )))),
              GoRoute(
                  path: "flash-deals",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(child: (FlashDealList()))),
              GoRoute(
                  path: "flash-deal/:slug",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(
                          child: (FlashDealProducts(
                        slug: getParameter(state, "slug"),
                      )))),
              GoRoute(
                  path: "followed-seller",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(child: (FollowedSellers()))),
              GoRoute(
                  path: "purchase_history",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(child: (OrderList()))),
              GoRoute(
                  path: "purchase_history/details/:id",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(
                          child: (OrderDetails(
                        id: int.parse(getParameter(state, "id")),
                      )))),
              GoRoute(
                  path: "sellers",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(
                          child: (Filter(
                        selected_filter: "sellers",
                      )))),
              GoRoute(
                  path: "shop/:slug",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(
                          child: (SellerDetails(
                        slug: getParameter(state, "slug"),
                      )))),
              GoRoute(
                  path: "todays-deal",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(child: (TodaysDealProducts()))),
              GoRoute(
                  path: "coupons",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      MaterialPage(child: (Coupons()))),
            ])
      ],
    );
    return _cachedRoutes!;
  } catch (e) {
    // Return a minimal router as fallback
    _cachedRoutes = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => MaterialPage(
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Unable to load application"),
                    SizedBox(height: 20),
                    Text("Please try again later"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
    return _cachedRoutes!;
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Ask for App Tracking Transparency consent once the first frame is on
    // screen - iOS silently ignores the request while the app is still
    // launching. Required by App Store Guideline 5.1.2(i).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TrackingPermissionService.requestIfNeeded();
    });

    // Initialize Firebase asynchronously without blocking app startup
    Future.microtask(() async {
      if (!OtherConfig.USE_PUSH_NOTIFICATION) return;
      try {
        await Firebase.initializeApp().timeout(
          const Duration(seconds: 10),
        );
        try {
          await PushNotificationService().initialise().timeout(
                const Duration(seconds: 5),
              );
        } catch (e) {
          // Continue without push notifications
        }
      } on TimeoutException {
        // Continue without Firebase
      } catch (e) {
        // Continue anyway - app should work without Firebase
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => CartCounter()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SelectAddressProvider()),
        ChangeNotifierProvider(create: (_) => UnReadNotificationCounter()),
        ChangeNotifierProvider(create: (_) => CurrencyPresenter()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, provider, snapshot) {
          final router = getRoutes();
          return MaterialApp.router(
            routerConfig: router,
            builder: OneContext().builder,
            title: AppConfig.app_name,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: MyTheme.white,
              scaffoldBackgroundColor: MyTheme.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: "PublicSansSerif",
              textTheme: MyTheme.textTheme1,
              fontFamilyFallback: const ['NotoSans'],
              scrollbarTheme: ScrollbarThemeData(
                thumbVisibility: WidgetStateProperty.all<bool>(false),
              ),
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            locale: provider.locale,
            supportedLocales: () {
              try {
                return LangConfig().supportedLocales();
              } catch (e) {
                return [const Locale('en')];
              }
            }(),
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (deviceLocale != null &&
                  AppLocalizations.delegate.isSupported(deviceLocale)) {
                return deviceLocale;
              }
              return const Locale('en');
            },
          );
        },
      ),
    );
  }
}
