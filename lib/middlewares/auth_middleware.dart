import 'package:geebay/helpers/main_helpers.dart';
import 'package:geebay/middlewares/route_middleware.dart';
import 'package:geebay/screens/auth/login.dart';
import 'package:flutter/cupertino.dart';

class AuthMiddleware extends RouteMiddleware {
  Widget _goto;

  AuthMiddleware(this._goto);

  @override
  Widget next() {
    if (!userIsLogedIn) {
      return Login();
    }
    return _goto;
  }
}
