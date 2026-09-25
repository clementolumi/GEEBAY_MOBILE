import 'package:geebay/app_config.dart';
import 'package:geebay/custom/box_decorations.dart';
import 'package:geebay/helpers/shared_value_helper.dart';
import 'package:geebay/my_theme.dart';
import 'package:geebay/presenter/home_presenter.dart';
import 'package:geebay/screens/filter.dart';
import 'package:geebay/screens/flash_deal/flash_deal_list.dart';
import 'package:geebay/screens/product/todays_deal_products.dart';
import 'package:geebay/screens/top_sellers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../custom/feature_categories_widget.dart';
import '../custom/featured_product_horizontal_list_widget.dart';
import '../custom/home_all_products_2.dart';
import '../custom/home_banner_one.dart';
import '../custom/home_banner_two.dart';
import '../custom/home_carousel_slider.dart';
import '../custom/home_search_box.dart';
import '../custom/pirated_widget.dart';

class Home extends StatefulWidget {
  Home({
    Key? key,
    this.title,
    this.show_back_button = false,
    go_back = true,
  }) : super(key: key);

  final String? title;
  bool show_back_button;
  late bool go_back;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  HomePresenter homeData = HomePresenter();

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) {
      change();
    });
    // change();
    // TODO: implement initState
    super.initState();
  }

  change() {
    try {
      if (mounted) {
        homeData.onRefresh();
        homeData.mainScrollListener();
        homeData.initPiratedAnimation(this);
      }
    } catch (e) {
      print("Error in Home.change(): $e");
    }
  }

  @override
  void dispose() {
    homeData.pirated_logo_controller.dispose();
    //  ChangeNotifierProvider<HomePresenter>.value(value: value)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      final double statusBarHeight = MediaQuery.of(context).padding.top;
      final localizations = AppLocalizations.of(context);
      // Safely get RTL setting with fallback
      final isRtl = (() {
        try {
          return app_language_rtl.$ ?? false;
        } catch (e) {
          print("Error accessing app_language_rtl: $e");
          return false;
        }
      })();

      return WillPopScope(
        onWillPop: () async {
          return widget.go_back;
        },
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: SafeArea(
          child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(50),
                child: buildAppBar(statusBarHeight, context),
              ),
              body: ListenableBuilder(
                  listenable: homeData,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        RefreshIndicator(
                          color: MyTheme.accent_color,
                          backgroundColor: Colors.white,
                          onRefresh: homeData.onRefresh,
                          displacement: 0,
                          child: CustomScrollView(
                            controller: homeData.mainScrollController,
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            slivers: <Widget>[
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  AppConfig.purchase_code == ""
                                      ? PiratedWidget(homeData: homeData)
                                      : Container(),
                                  // home slider
                                  HomeCarouselSlider(
                                      context: context, homeData: homeData),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      18.0,
                                      0.0,
                                      18.0,
                                      0.0,
                                    ),
                                    child: buildHomeMenuRow1(context, homeData),
                                  ),
                                  HomeBannerOne(
                                      context: context, homeData: homeData),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      18.0,
                                      0.0,
                                      18.0,
                                      0.0,
                                    ),
                                    child: buildHomeMenuRow2(context),
                                  ),
                                ]),
                              ),

                              // featured categories
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      18.0,
                                      20.0,
                                      18.0,
                                      0.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localizations?.featured_categories_ucf ?? "Featured Categories",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                              SliverToBoxAdapter(
                                child: SizedBox(
                                  height: 154,
                                  child: FeaturedCategoriesWidget(
                                    homeData: homeData,
                                  ),
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  Container(
                                    color: MyTheme.accent_color,
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 180,
                                          width: double.infinity,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Image.asset(
                                                  "assets/background_1.png")
                                            ],
                                          ),
                                        ),

                                        // featured products section
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0,
                                                  right: 18.0,
                                                  left: 18.0),
                                              child: Text(
                                                localizations?.featured_products_ucf ?? "Featured Products",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                            FeaturedProductHorizontalListWidget(
                                                homeData: homeData)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                              SliverList(
                                delegate: SliverChildListDelegate(
                                  [
                                    HomeBannerTwo(
                                        context: context, homeData: homeData),
                                  ],
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      18.0,
                                      18.0,
                                      20.0,
                                      0.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localizations?.all_products_ucf ?? "All Products",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        HomeAllProducts2(
                                            context: context,
                                            homeData: homeData),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 80,
                                  )
                                ]),
                              ),
                            ],
                          ),
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: buildProductLoadingContainer(homeData))
                      ],
                    );
                  })),
        ),
      ),
    );
    } catch (e) {
      print("Error building Home widget: $e");
      // Return a safe fallback
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
  }

  Widget buildHomeMenuRow1(BuildContext context, HomePresenter homeData) {
    final localizations = AppLocalizations.of(context);
    return Row(
      children: [
        if (homeData.isTodayDeal)
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return TodaysDealProducts();
                }));
              },
              child: Container(
                height: 90,
                decoration: BoxDecorations.buildBoxDecoration_1(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                          height: 20,
                          width: 20,
                          child: Image.asset("assets/todays_deal.png")),
                    ),
                    Text(localizations?.todays_deal_ucf ?? "Today's Deal",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          ),
        if (homeData.isTodayDeal && homeData.isFlashDeal) SizedBox(width: 14.0),
        if (homeData.isFlashDeal)
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FlashDealList();
                }));
              },
              child: Container(
                height: 90,
                decoration: BoxDecorations.buildBoxDecoration_1(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                          height: 20,
                          width: 20,
                          child: Image.asset("assets/flash_deal.png")),
                    ),
                    Text(localizations?.flash_deal_ucf ?? "Flash Deal",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          )
      ],
    );
  }

  Widget buildHomeMenuRow2(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Filter(
                  selected_filter: "brands",
                );
              }));
            },
            child: Container(
              height: 90,
              width: MediaQuery.of(context).size.width / 3 - 4,
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset("assets/brands.png")),
                  ),
                  Text(localizations?.brands_ucf ?? "Brands",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromRGBO(132, 132, 132, 1),
                          fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ),
        ),
        if (vendor_system.$)
          SizedBox(
            width: 10,
          ),
        if (vendor_system.$)
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return TopSellers();
                }));
              },
              child: Container(
                height: 90,
                width: MediaQuery.of(context).size.width / 3 - 4,
                decoration: BoxDecorations.buildBoxDecoration_1(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                          height: 20,
                          width: 20,
                          child: Image.asset("assets/top_sellers.png")),
                    ),
                    Text(localizations?.top_sellers_ucf ?? "Top Sellers",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      // Don't show the leading button
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      flexibleSpace: Padding(
        // padding:
        //     const EdgeInsets.only(top: 40.0, bottom: 22, left: 18, right: 18),
        padding:
            const EdgeInsets.only(top: 10.0, bottom: 10, left: 18, right: 18),
        child: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Filter();
            }));
          },
          child: HomeSearchBox(context: context),
        ),
      ),
    );
  }

  Container buildProductLoadingContainer(HomePresenter homeData) {
    final localizations = AppLocalizations.of(context);
    return Container(
      height: homeData.showAllLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(
          homeData.totalAllProductData == homeData.allProductList.length
              ? (localizations?.no_more_products_ucf ?? "No more products")
              : (localizations?.loading_more_products_ucf ?? "Loading more products..."),
        ),
      ),
    );
  }
}
