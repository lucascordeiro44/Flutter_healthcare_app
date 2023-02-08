import 'package:flutter_dandelin/model/rating.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class AvaliarAtendimentoApi {
  static Future<ApiResponse> sendRating(Rating rating) async {
    try {
      var url = "$baseUrl/api/ratings";

      HttpResponse response = await post(url, rating.toJson());

      print(response);

      return ApiResponse.ok();
    } on SocketException {
      return ApiResponse.error(kOnSocketException);
    } on ForbiddenException {
      return ApiResponse.error(ForbiddenException.msgError);
    } on TimeoutException {
      return ApiResponse.error(TimeoutException.msgError);
    } catch (error) {
      String msg;
      if (error?.cause != null) {
        msg = error.cause.toString();
        return ApiResponse.error(msg);
      }
      msg = error.toString();
      return ApiResponse.error(msg);
    }
  }

  static Future<ApiResponse> editRating(Rating rating) async {
    try {
      var url = "$baseUrl/api/ratings/${rating.id}";

      HttpResponse response = await put(url, rating.toJson());

      print(response);

      return ApiResponse.ok(result: rating);
    } on SocketException {
      return ApiResponse.error(kOnSocketException);
    } on ForbiddenException {
      return ApiResponse.error(ForbiddenException.msgError);
    } on TimeoutException {
      return ApiResponse.error(TimeoutException.msgError);
    } catch (error) {
      String msg;
      if (error?.cause != null) {
        msg = error.cause.toString();
        return ApiResponse.error(msg);
      }
      msg = error.toString();
      return ApiResponse.error(msg);
    }
  }
}
