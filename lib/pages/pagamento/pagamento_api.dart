import 'package:flutter_dandelin/model/pagamento.dart';
import 'package:flutter_dandelin/utils/imports.dart';

import 'package:flutter_dandelin/utils/http_helper.dart';

class PagamentoApi {
  static Future<HttpResponse> buscarTodos() async {
    try {
      var url = "$baseUrl/api/payments/user";

      HttpResponse response = await get(url);

      return response;
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

  static Future checkPendings() async {
    try {
      var url = "$baseUrl/api/billings/pending";

      HttpResponse response = await get(url);

      return response;
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

  static Future save(Pagamento pagamento) async {
    try {
      final url = "$baseUrl/api/payments";

      await post(url, pagamento.toJson(), timeout: 60);

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

  static Future mudarParaPrincipal(Pagamento pagamento) async {
    try {
      final url = "$baseUrl/api/payments/credCardToggleMain/${pagamento.id}";

      HttpResponse response = await patch(url, pagamento.toJson());

      return response;
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

  static Future statusPagamento() async {
    try {
      final url = "$baseUrl/api/payments/user/details";

      HttpResponse response = await get(url);
      print(response);

      return response;
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

  static Future excluir(Pagamento pagamento) async {
    try {
      final url = "$baseUrl/api/payments/${pagamento.id}";

      await delete(url);
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
