import 'package:flutter_dandelin/constants.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class HomeApi {
  static Future<ApiResponse> getConsultasExames(int page) async {
    try {
      var url =
          "$baseUrl/api/schedules/find/byUser?search=NAO_ATENDIDO&page=$page";

      HttpResponse response = await post(url, {});

      final list = response.data['data'] as List;

      // List<dynamic> listConsultaExame = List<dynamic>();
      // listConsultaExame = list
      //     .map<dynamic>((json) => json['scheduleExam'] != null
      //         ? Exam.fromJson(json)
      //         : Consulta.fromJson(json))
      //     .toList();

      List<Consulta> listConsulta =
          list.map<Consulta>((json) => Consulta.fromJson(json)).toList();

      return ApiResponse.ok(result: listConsulta);
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

  static Future<ApiResponse> getConsultasExamesToRating() async {
    try {
      var url = "$baseUrl/api/schedules/rating/pending";

      HttpResponse response = await get(url);

      final list = response.data['data'] as List;

      List<Consulta> listConsulta =
          list.map<Consulta>((json) => Consulta.fromJson(json)).toList();

      return ApiResponse.ok(result: listConsulta);
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

  static Future<ApiResponse> depedentsAproval(bool aproval) async {
    try {
      var url = "$baseUrl/api/users/dependents?approval=$aproval";

      HttpResponse response = await patch(url, {});

      String msg = response.data['message'];

      return ApiResponse.ok(result: msg);
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

  static Future aproveChanges(Consulta consulta, bool value) async {
    try {
      var url = "$baseUrl/api/schedules/confirmation";

      var map = {
        "id": consulta.id,
        "confirmation": value,
      };

      HttpResponse response = await post(url, map);

      return response;
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
