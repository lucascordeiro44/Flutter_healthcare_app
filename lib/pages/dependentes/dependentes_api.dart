import 'package:flutter_dandelin/model/dependente.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class DependentesApi {
  static Future<ApiResponse> getDepedentens(bool ativos) async {
    try {
      var url =
          "$baseUrl/api/users/dependents?search=${ativos ? "actived" : "others"}";

      HttpResponse response = await get(url);

      final list = response.data['data'] as List;

      List<Dependente> dependentes =
          list.map<Dependente>((json) => Dependente.fromJson(json)).toList();

      return ApiResponse.ok(result: dependentes);
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

  static Future<HttpResponse> searchUser(String search) async {
    try {
      var url = "$baseUrl/api/users/dependents/$search";

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
        throw error.cause;
      }
      throw error.toString();
    }
  }

  static Future<HttpResponse> addDependente(
      int id, bool notificationToParent) async {
    try {
      var url = "$baseUrl/api/users/dependents/$id";

      HttpResponse response =
          await put(url, {"notificationToParent": notificationToParent});

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause;
      }
      throw error.toString();
    }
  }

  static Future<HttpResponse> excluirDependente(int id) async {
    try {
      var url = "$baseUrl/api/users/dependents/$id";

      HttpResponse response = await delete(url);

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause;
      }
      throw error.toString();
    }
  }

  static Future<ApiResponse> ativarConta() async {
    try {
      var url = "$baseUrl/api/users/tryCharge";

      HttpResponse response = await get(url);

      print(response);

      var data = response.data['data'];

      return ApiResponse.ok(result: data['status']);
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

  static Future<ApiResponse> reenviarConvite(Dependente dependente) async {
    try {
      var url = "$baseUrl/api/users/dependents/resend/${dependente.id}";

      HttpResponse response = await get(url);

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
}

class DependentesForm {
  String nome;
  String email;
  String parentesco;
  int idCartao;

  bool validate() =>
      isNotEmpty(nome) && isNotEmpty(email) && isNotEmpty(parentesco);
}
