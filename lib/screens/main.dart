import 'dart:io';

import 'package:geebay/helpers/shared_value_helper.dart';
import 'package:geebay/my_theme.dart';
import 'package:geebay/presenter/bottom_appbar_index.dart';
import 'package:geebay/presenter/cart_counter.dart';
import 'package:geebay/screens/auth/login.dart';
import 'package:geebay/screens/category_list_n_product/category_list.dart';
import 'package:geebay/screens/checkout/cart.dart';
import 'package:geebay/screens/home.dart';
import 'package:geebay/screens/profile.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Main extends StatefulWidget {
  Main({Key? key, this.go_back = true}) : super(key: key);
  final bool go_back;

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  int _currentIndex = 0;
  List<Widget?> _children = [];
  CartCounter counter = CartCounter();
  BottomAppbarIndex bottomAppbarIndex = BottomAppbarIndex();

  fetchAll() {
    getCartCount();
  }

  void onTapped(int i) {
    try {
      fetchAll();

      final guestCheckout = guest_checkout_status.$;
      final isLoggedIn = is_logged_in.$;

      if (guestCheckout && (i == 2)) {
      } else if (!guestCheckout && (i == 2) && !isLoggedIn) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
        return;
      }

      if (i == 3) {
        // Use GoRouter to navigate
        GoRouter.of(context).go("/dashboard");
        return;
      }
      setState(() {
        _currentIndex = i;
      });
    } catch (e) {
      print("Error in onTapped: $e");
    }
  }

  getCartCount() async {
    try {
      if (mounted) {
        Provider.of<CartCounter>(context, listen: false).getCount();
      }
    } catch (e) {
      print("Error getting cart count: $e");
    }
  }

  void initState() {
    super.initState();
    // Don't create child widgets immediately - create them lazily to avoid crashes
    // Initialize children list but create widgets on demand
    _children = [];
    
    // Defer fetchAll to after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          fetchAll();
        } catch (e) {
          print("Error in fetchAll: $e");
        }
      }
    });
    
    //re appear statusbar in case it was not there in the previous page
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }
  
  Widget _getChildWidget(int index) {
    // Create widgets lazily with error handling
    if (_children.length <= index) {
      _children = List<Widget?>.generate(4, (i) => null);
    }
    
    if (_children[index] == null) {
      try {
        print("Main._getChildWidget: Creating widget at index $index");
        // Wrap widget creation in Builder to ensure context is available
        switch (index) {
          case 0:
            _children[0] = Builder(
              builder: (context) {
                try {
                  print("Main._getChildWidget: Creating Home widget");
                  return Home();
                } catch (e, stackTrace) {
                  print("Error creating Home widget: $e");
                  print("Stack trace: $stackTrace");
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Error loading home: $e"),
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
            break;
          case 1:
            _children[1] = Builder(
              builder: (context) {
                try {
                  return CategoryList(
                    slug: "",
                    is_base_category: true,
                  );
                } catch (e) {
                  print("Error creating CategoryList widget: $e");
                  return Scaffold(
                    body: Center(child: Text("Error loading categories: $e")),
                  );
                }
              },
            );
            break;
          case 2:
            _children[2] = Builder(
              builder: (context) {
                try {
                  return Cart(
                    has_bottomnav: true,
                    from_navigation: true,
                    counter: counter,
                  );
                } catch (e) {
                  print("Error creating Cart widget: $e");
                  return Scaffold(
                    body: Center(child: Text("Error loading cart: $e")),
                  );
                }
              },
            );
            break;
          case 3:
            _children[3] = Builder(
              builder: (context) {
                try {
                  return Profile();
                } catch (e) {
                  print("Error creating Profile widget: $e");
                  return Scaffold(
                    body: Center(child: Text("Error loading profile: $e")),
                  );
                }
              },
            );
            break;
          default:
            return Container();
        }
      } catch (e) {
        print("Error creating child widget at index $index: $e");
        return Scaffold(
          body: Center(
            child: Text("Error loading page: $e"),
          ),
        );
      }
    }
    return _children[index] ?? Container();
  }

  bool _dialogShowing = false;
  Future<bool> willPop() async {
    print(_currentIndex);
    if (_currentIndex != 0) {
      fetchAll();
      setState(() {
        _currentIndex = 0;
      });
    } else {
      // print("Main will back");
      // CommonFunctions(context).appExitDialog();

      if (_dialogShowing) {
        return Future.value(false); // Dialog already showing, don't show again
      }
      setState(() {
        _dialogShowing = true;
      });

      final shouldPop = (await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final localizations = AppLocalizations.of(context);
          final isRtl = app_language_rtl.$ ?? false;
          return Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: AlertDialog(
              content: Text(
                localizations?.do_you_want_close_the_app ?? "Do you want to close the app?",
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Platform.isAndroid ? SystemNavigator.pop() : exit(0);
                    },
                    child: Text(localizations?.yes_ucf ?? "Yes")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _dialogShowing =
                            false; // Reset flag after dialog is closed
                      });
                    },
                    child: Text(localizations?.no_ucf ?? "No")),
              ],
            ),
          );
        },
      )) ?? false;

      return shouldPop;
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    try {
      print("Main.build() called");
      // Safely get RTL setting with fallback
      final isRtl = (() {
        try {
          return app_language_rtl.$ ?? false;
        } catch (e) {
          print("Error accessing app_language_rtl in Main: $e");
          return false;
        }
      })();
      
      final localizations = AppLocalizations.of(context);
      if (localizations == null) {
        print("Warning: AppLocalizations is null in Main");
      }
      
      return WillPopScope(
        onWillPop: willPop,
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
          extendBody: true,
          body: _getChildWidget(_currentIndex),
          bottomNavigationBar: SizedBox(
            height: 70,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: onTapped,
              currentIndex: _currentIndex,
              backgroundColor: Colors.white.withOpacity(0.95),
              unselectedItemColor: Color.fromRGBO(168, 175, 179, 1),
              selectedItemColor: MyTheme.accent_color,
              selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: MyTheme.accent_color,
                  fontSize: 12),
              unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(168, 175, 179, 1),
                  fontSize: 12),
              items: [
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Image.asset(
                        "assets/home.png",
                        color: _currentIndex == 0
                            ? MyTheme.accent_color
                            : Color.fromRGBO(153, 153, 153, 1),
                        height: 16,
                      ),
                    ),
                    label: localizations?.home_ucf ?? "Home"),
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Image.asset(
                        "assets/categories.png",
                        color: _currentIndex == 1
                            ? MyTheme.accent_color
                            : Color.fromRGBO(153, 153, 153, 1),
                        height: 16,
                      ),
                    ),
                    label: localizations?.categories_ucf ?? "Categories"),
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: badges.Badge(
                        badgeStyle: badges.BadgeStyle(
                          shape: badges.BadgeShape.circle,
                          badgeColor: MyTheme.accent_color,
                          borderRadius: BorderRadius.circular(10),
                          padding: EdgeInsets.all(5),
                        ),
                        badgeAnimation: badges.BadgeAnimation.slide(
                          toAnimate: false,
                        ),
                        child: Image.asset(
                          "assets/cart.png",
                          color: _currentIndex == 2
                              ? MyTheme.accent_color
                              : Color.fromRGBO(153, 153, 153, 1),
                          height: 16,
                        ),
                        badgeContent: Consumer<CartCounter>(
                          builder: (context, cart, child) {
                            return Text(
                              "${cart.cartCounter}",
                              style:
                                  TextStyle(fontSize: 10, color: Colors.white),
                            );
                          },
                        ),
                      ),
                    ),
                    label: localizations?.cart_ucf ?? "Cart"),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Image.asset(
                      "assets/profile.png",
                      color: _currentIndex == 3
                          ? MyTheme.accent_color
                          : Color.fromRGBO(153, 153, 153, 1),
                      height: 16,
                    ),
                  ),
                  label: localizations?.profile_ucf ?? "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
    } catch (e) {
      print("Error building Main widget: $e");
      // Return a safe fallback
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error loading app: $e"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                child: Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }
  }
}
