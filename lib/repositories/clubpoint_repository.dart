import 'dart:convert';

import 'package:geebay/app_config.dart';
import 'package:geebay/data_model/clubpoint_response.dart';
import 'package:geebay/data_model/clubpoint_to_wallet_response.dart';
import 'package:geebay/helpers/shared_value_helper.dart';
import 'package:geebay/middlewares/banned_user.dart';
import 'package:geebay/repositories/api-request.dart';

class ClubpointRepository {
  Future<dynamic> getClubPointListResponse({page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/clubpoint/get-list?page=$page");
    // print("url(${url.toString()}) access token (Bearer ${access_token.$})");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        middleware: BannedUser());
    return clubpointResponseFromJson(response.body);
  }

  Future<dynamic> getClubpointToWalletResponse(int? id) async {
    var post_body = jsonEncode({
      "id": "${id}",
    });
    String url = ("${AppConfig.BASE_URL}/clubpoint/convert-into-wallet");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: post_body,
        middleware: BannedUser());
    return clubpointToWalletResponseFromJson(response.body);
  }
}
