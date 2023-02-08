import 'package:flutter_dandelin/constants.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class ProfissaoApi {
  static Future<HttpResponse> getOcupation({int page, String search}) async {
    String s = search == null ? '' : search;

    try {
      var url = "$baseUrl/api/ocupations?page=$page&size=100&search=$s";

      final response = await get(url);

      return response;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } catch (error, stacktrace) {
      print('error get ocupation $error');
      print('stacktrace get ocupation $stacktrace');
      throw error;
    }
  }

  static Future<HttpResponse> validatePartnership(
      String code, String cpf) async {
    try {
      var map = {
        "partnerCode": code,
        "associateCode": cpf,
      };

      var url = "$baseUrl/api/associates/validate";

      final response = await post(url, map);

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause.toString();
      }

      throw error.toString();
    }
  }
}
