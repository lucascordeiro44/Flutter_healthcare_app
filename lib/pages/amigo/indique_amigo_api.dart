import 'package:flutter_dandelin/constants.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class IndiqueAmigoApi {
  static Future<HttpResponse> getDiscountInvite() async {
    try {
      var url = "$baseUrl/api/discounts/generate";
      HttpResponse response = await post(url, {});

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } catch (error) {
      throw error.toString();
    }
  }
}
