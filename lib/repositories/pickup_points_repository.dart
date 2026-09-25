import 'package:geebay/app_config.dart';
import 'package:geebay/data_model/pickup_points_response.dart';
import 'package:geebay/repositories/api-request.dart';
import 'package:http/http.dart' as http;

class PickupPointRepository{
  Future<PickupPointListResponse> getPickupPointListResponse()async{
    String url=('${AppConfig.BASE_URL}/pickup-list');

    final response = await ApiRequest.get(url: url);

    //print("response ${response.body}");

    return pickupPointListResponseFromJson(response.body);
  }
}