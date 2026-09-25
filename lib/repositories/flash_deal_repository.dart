import 'package:geebay/app_config.dart';
import 'package:geebay/data_model/flash_deal_response.dart';
import 'package:geebay/helpers/shared_value_helper.dart';
import 'package:geebay/repositories/api-request.dart';

import '../helpers/system_config.dart';

class FlashDealRepository {
  Future<FlashDealResponse> getFlashDeals() async {
    String url = ("${AppConfig.BASE_URL}/flash-deals");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
      },
    );

    return flashDealResponseFromJson(response.body.toString());
  }

  Future<FlashDealResponse> getFlashDealInfo(slug) async {
    String url = ("${AppConfig.BASE_URL}/flash-deals/info/$slug");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
        "Currency-Code": SystemConfig.systemCurrency!.code!,
        "Currency-Exchange-Rate":
            SystemConfig.systemCurrency!.exchangeRate.toString(),
      },
    );
    return flashDealResponseFromJson(response.body.toString());
  }
}
