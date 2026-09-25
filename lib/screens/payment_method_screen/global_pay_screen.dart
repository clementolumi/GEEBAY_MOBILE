import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geebay/app_config.dart';
import 'package:geebay/custom/toast_component.dart';
import 'package:geebay/helpers/main_helpers.dart';
import 'package:geebay/helpers/shared_value_helper.dart';
import 'package:geebay/my_theme.dart';
import 'package:geebay/repositories/payment_repository.dart';
import 'package:geebay/screens/orders/order_list.dart';
import 'package:geebay/screens/wallet.dart';
import '../../custom/lang_text.dart';
import '../profile.dart';

class GlobalPayScreen extends StatefulWidget {
  double? amount;
  String payment_type;
  String? payment_method_key;
  var package_id;
  int? orderId;

  GlobalPayScreen({
    Key? key,
    this.amount = 0.00,
    this.orderId = 0,
    this.payment_type = "",
    this.package_id = "0",
    this.payment_method_key = "",
  }) : super(key: key);

  @override
  _GlobalPayScreenState createState() => _GlobalPayScreenState();
}

class _GlobalPayScreenState extends State<GlobalPayScreen> {
  int? _combined_order_id = 0;
  bool _order_init = false;
  String? _initial_url = "";
  bool _initial_url_fetched = false;

  WebViewController _webViewController = WebViewController();

  @override
  void initState() {
    super.initState();
    if (widget.payment_type == "cart_payment") {
      createOrder();
    } else {
      globalPayInit();
    }
  }

  createOrder() async {
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponse(widget.payment_method_key);

    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(
        orderCreateResponse.message,
      );
      Navigator.of(context).pop();
      return;
    }

    _combined_order_id = orderCreateResponse.combined_order_id;
    _order_init = true;
    setState(() {});

    globalPayInit();
  }

  globalPayInit() {
    _initial_url =
        "${AppConfig.BASE_URL}/global_pay/init?payment_type=${widget.payment_type}&combined_order_id=${_combined_order_id}&amount=${widget.amount}&user_id=${user_id.$}&package_id=${widget.package_id}&order_id=${widget.orderId}";
    _initial_url_fetched = true;
    setState(() {});

    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {},
          onPageFinished: (page) {
            if (page.contains("/global_pay/payment/callback") ||
                page.contains("/global_pay/callback") ||
                page.contains("success")) {
              getData();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_initial_url!), headers: commonHeader);
  }

  void getData() {
    _webViewController
        .runJavaScriptReturningResult("document.body.innerText")
        .then((data) {
      try {
        var responseJSON = jsonDecode(data as String);
        if (responseJSON.runtimeType == String) {
          responseJSON = jsonDecode(responseJSON);
        }
        if (responseJSON["result"] == false) {
          ToastComponent.showDialog(
            responseJSON["message"],
          );
          Navigator.pop(context);
        } else if (responseJSON["result"] == true) {
          ToastComponent.showDialog(
            responseJSON["message"] ?? "Payment successful",
          );

          if (widget.payment_type == "cart_payment" ||
              widget.payment_type == "order_re_payment") {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return OrderList(from_checkout: true);
            }));
          } else if (widget.payment_type == "wallet_payment") {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return Wallet(from_recharge: true);
            }));
          } else if (widget.payment_type == "customer_package_payment") {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return Profile();
            }));
          } else {
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        print("Error parsing response: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildBody(),
      ),
    );
  }

  buildBody() {
    if (_order_init == false &&
        _combined_order_id == 0 &&
        widget.payment_type == "cart_payment") {
      return Container(
        child: Center(
          child: Text(LangText(context).local.creating_order),
        ),
      );
    } else if (_initial_url_fetched == false) {
      return Container(
        child: Center(
          child: Text("Fetching Global Pay url ..."),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: WebViewWidget(
            controller: _webViewController,
          ),
        ),
      );
    }
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        "Pay with Global Pay",
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
