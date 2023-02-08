import 'package:flutter_dandelin/model/discount.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class CupomDescontoApi {
  static Future<ApiResponse<Discount>> sendInviteDiscount(String code) async {
    try {
      var url = "$baseUrl/api/partnerships/discount/apply/$code";

      HttpResponse response = await post(url, {});

      Discount discount = Discount.fromJson(response.data);
      return ApiResponse.ok(result: discount);
    } on SocketException {
      return ApiResponse.error(kOnSocketException);
    } on ForbiddenException {
      return ApiResponse.error(ForbiddenException.msgError);
    } on TimeoutException {
      return ApiResponse.error(TimeoutException.msgError);
    } catch (error) {
      String msg;
      msg = error?.cause != null ? error.cause.toString() : error.toString();
      return ApiResponse.error(msg);
    }
  }
}
