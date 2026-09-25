import 'package:geebay/app_config.dart';
import 'package:geebay/data_model/check_response_model.dart';
import 'package:geebay/middlewares/banned_user.dart';
import 'package:geebay/repositories/api-request.dart';
import 'dart:convert';
import 'package:geebay/data_model/simple_image_upload_response.dart';
import 'package:geebay/helpers/shared_value_helper.dart';


class FileRepository {
  Future<dynamic> getSimpleImageUploadResponse(
       String image,  String filename) async {
    var post_body = jsonEncode({"image": "${image}", "filename": "$filename"});

    String url=("${AppConfig.BASE_URL}/file/image-upload");
    final response = await ApiRequest.post(url:url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: post_body,middleware: BannedUser());

    return simpleImageUploadResponseFromJson(response.body);
  }
}
