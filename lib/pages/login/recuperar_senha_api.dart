import 'package:flutter_dandelin/constants.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class RecuperarSenhaApi {
  static Future enviar(String email) async {
    try {
      final url = "$baseUrl/api/users/password/forget/$email";

      await post(url, {});

      return;
    } on SocketException {
      throw kOnSocketException;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause.toString();
      }

      throw error.toString();
    }
  }
}
