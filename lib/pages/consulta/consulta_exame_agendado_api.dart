import 'package:flutter_dandelin/constants.dart';
import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/exam.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class ConsultaExameAgendadoApi {
  static Future<ApiResponse> cancelarConsulta(Consulta consulta) async {
    try {
      var url = "$baseUrl/api/schedules/user/${consulta.id}";

      await patch(url, {});

      return ApiResponse.ok();
    } on ForbiddenException {
      return ApiResponse.error(ForbiddenException.msgError);
    } on TimeoutException {
      return ApiResponse.error(TimeoutException.msgError);
    } catch (e) {
      if (e.cause != null) {
        return ApiResponse.error(e.cause);
      }

      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse> cancelarExame(Exam exam) async {
    try {
      var url = "$baseUrl/api/laboratories/schedule/user/${exam.id}";

      await patch(url, {});

      return ApiResponse.ok();
    } on SocketException {
      return ApiResponse.error(kOnSocketException);
    } on ForbiddenException {
      return ApiResponse.error(ForbiddenException.msgError);
    } on TimeoutException {
      return ApiResponse.error(TimeoutException.msgError);
    } catch (e) {
      if (e.cause != null) {
        return ApiResponse.error(e.cause);
      }

      return ApiResponse.error(e.toString());
    }
  }
}
