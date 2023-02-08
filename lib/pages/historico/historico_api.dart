import 'package:flutter_dandelin/constants.dart';
import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/exam.dart';
import 'package:flutter_dandelin/utils/datetime_helper.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class HistoricoApi {
  static Future<HttpResponse> getConsultas({int page = 0}) async {
    try {
      var url = "$baseUrl/api/schedules/find/byUser?page=$page";

      HttpResponse response = await post(url, {});

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

  static Future<HttpResponse> getPagamentos({int page = 0}) async {
    try {
      var url = "$baseUrl/api/billings/byUser?page=$page";

      HttpResponse response = await post(url, {});

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

  static Future<HttpResponse> getConsulta(Consulta consulta) async {
    try {
      var url = "$baseUrl/api/schedules/next";

      HttpResponse response = await post(url, {
        'date': dateToStringBd(DateTime.now()),
        'doctor': {
          'id': consulta.scheduleDoctor.doctor.user.id,
        },
      });

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } on ForbiddenException {
      throw TimeoutException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause.toString();
      }

      throw error.toString();
    }
  }

  static Future<HttpResponse> getUnity(Exam exam) async {
    try {
      var url = "$baseUrl/api/laboratories/schedule/next";

      HttpResponse response = await post(url, {
        'date': dateToStringBd(DateTime.now()),
        'exam': {
          'id': exam.scheduleExam.exam.id,
        },
      });

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } on ForbiddenException {
      throw TimeoutException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause.toString();
      }

      throw error.toString();
    }
  }
}
