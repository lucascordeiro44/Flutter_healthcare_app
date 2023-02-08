import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class PerfilApi {
  static Future<ApiResponse> excluirConta() async {
    try {
      var url = "$baseUrl/api/users/";

      await delete(url);

      return ApiResponse.ok();
    } on TimeoutException {
      return ApiResponse.error(TimeoutException.msgError);
    } on ForbiddenException {
      return ApiResponse.error(ForbiddenException.msgError);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
