import 'package:flutter_dandelin/model/cv.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class PerfilMedicoApi {
  static Future<ApiResponse> getCV(int id) async {
    try {
      var url = "$baseUrl/api/doctors/$id/cv";

      HttpResponse response = await get(url);

      var data = response.data;

      return ApiResponse.ok(result: Cv.fromJson(data['data']));
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
