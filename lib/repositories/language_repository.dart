import 'package:geebay/app_config.dart';
import 'package:geebay/repositories/api-request.dart';
import 'package:geebay/data_model/language_list_response.dart';
import 'package:geebay/helpers/shared_value_helper.dart';

class LanguageRepository {
  Future<LanguageListResponse> getLanguageList() async {
    String url=(
        "${AppConfig.BASE_URL}/languages");
    final response = await ApiRequest.get(url: url,headers: {
      "App-Language": app_language.$!,
    }
    );
    //print(response.body.toString());
    return languageListResponseFromJson(response.body);
  }


}
