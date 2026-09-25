import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_pay/global_pay.dart';
import 'package:geebay/custom/toast_component.dart';
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
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.payment_type == "cart_payment") {
      createOrder();
    } else {
      initGlobalPay();
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

    initGlobalPay();
  }

  initGlobalPay() async {
    setState(() {
      _isProcessing = true;
    });

    String email = user_email.$ != null && user_email.$.isNotEmpty
        ? user_email.$
        : "user@example.com";
    String phone = user_phone.$ != null && user_phone.$.isNotEmpty
        ? user_phone.$
        : "07000000000";
    String username = user_name.$ != null && user_name.$.isNotEmpty
        ? user_name.$
        : "User";

    // Try launching GlobalPay SDK
    try {
      GlobalPay.launchGlobalPay(
        context,
        email: email,
        amount: widget.amount ?? 0.0,
        currency: 'NGN',
        merchantId: 'merchantId', // Replaced dynamically or via backend settings
        username: username,
        userPhone: phone,
        environment: GlobalPayEnvironment.test,
        apiKey: 'apikey',
        redirectURL: 'redirecturl',
        onClose: (result) {
          ToastComponent.showDialog(
            "Checkout closed",
          );
          Navigator.of(context).pop();
        },
        onSuccess: (TransactionData transactionData) {
          onPaymentSuccess(transactionData);
        },
        onError: (String errorMessage) {
          ToastComponent.showDialog(
            errorMessage,
          );
          Navigator.of(context).pop();
        },
      );
    } catch (e) {
      print("GlobalPay error: $e");
      ToastComponent.showDialog(
        "Could not launch Global Pay: ${e.toString()}",
      );
      Navigator.of(context).pop();
    }
  }

  onPaymentSuccess(TransactionData transactionData) async {
    ToastComponent.showDialog("Payment successful!");

    if (widget.payment_type == "cart_payment" ||
        widget.payment_type == "order_re_payment") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return OrderList(from_checkout: true);
      }));
    } else if (widget.payment_type == "wallet_payment") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Wallet(from_recharge: true);
      }));
    } else if (widget.payment_type == "customer_package_payment") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Profile();
      }));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: MyTheme.accent_color),
              SizedBox(height: 16),
              Text(
                LangText(context).local.please_wait_ucf,
                style: TextStyle(color: MyTheme.font_grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
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
