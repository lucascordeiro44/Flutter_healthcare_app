import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_detalhe_bloc.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/model/address.dart';
import 'package:flutter_dandelin/utils/dandelin_erros.dart';

import 'package:flutter_dandelin/utils/imports.dart';

class ConsultaExameApi {
  static Future<ApiResponse> getConsultas(Map search, DateTime dateFilter,
      {bool covid = false,
      bool removeHorarios = false,
      bool acessibilidade = false}) async {
    try {
      if (acessibilidade) {
        search['accessibility'] = acessibilidade;
      } else {
        search['accessibility'] = null;
      }

      if (covid) {
        search['covid19'] = true;
      }

      var url = "$baseUrl/api/schedules/filter";
      HttpResponse response = await post(url, search);

      var data = response.data['data'] as List;
      List<dynamic> list = [];

      if (data.length > 0 && data[0]['addresses'] != null) {
        list = data[0]['addresses']
            .map<Address>((json) => Address.fromJson(json))
            .toList();
      } else {
        list = data.map<Consulta>((json) => Consulta.fromJson(json)).toList();

        // if (removeHorarios) {
        //   list.removeWhere((consulta) => consulta.avaliability.length == 0);
        // }
      }

      return ApiResponse.ok(result: list);
    } on SocketException {
      return ApiResponse.error(kOnSocketException);
    } on ForbiddenException {
      return ApiResponse.error(ForbiddenException.msgError);
    } on TimeoutException {
      return ApiResponse.error(TimeoutException.msgError);
    } catch (error) {
      String msg = "";
      if (error?.cause != null) {
        msg = error.cause.toString();
      } else {
        msg = error.toString();
      }
      return ApiResponse.error(msg);
    }
  }

  static Future<HttpResponse> getExames(Map search) async {
    try {
      var url = "$baseUrl/api/laboratories/schedule/find";
      HttpResponse response = await post(url, search);

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

  static Future<HttpResponse> getLocalidades(int page, bool isConsultaCities,
      {String search}) async {
    try {
      var url = "$baseUrl/api/addresses/cities?page=$page&size=100";
      //lab muda aqui
      // var url = isConsultaCities
      //     ? "$baseUrl/api/addresses/cities?page=$page&size=100"
      //     : "$baseUrl/api/units/cities?page=$page&size=100";

      if (search != null) {
        url = "$url&search=$search";
      }

      HttpResponse reponse = await get(url);

      return reponse;
    } on SocketException {
      throw kOnSocketException;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } on ForbiddenException {
      throw TimeoutException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause;
      }
      throw error.toString();
    }
  }

  static Future<HttpResponse> getEspecializacaoDoctor(int page,
      {String search}) async {
    try {
      int size = 20;
      String orderBy = "name";
      String filter = "ASC";

      var url =
          "$baseUrl/api/expertises/doctors?size=$size&orderBy=$orderBy&filter=$filter&page=$page";

      if (search != null) {
        url = "$url&search=$search";
      }

      HttpResponse reponse = await get(url);

      return reponse;
    } on SocketException {
      throw kOnSocketException;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } on ForbiddenException {
      throw TimeoutException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause;
      }
      throw error.toString();
    }
  }

  static Future<HttpResponse> getLaboratoriesByName(int page,
      {String search}) async {
    try {
      int size = 20;
      String orderBy = "title";
      String filter = "ASC";

      var url =
          "$baseUrl/api/exams/available?size=$size&orderBy=$orderBy&filter=$filter&page=$page";

      if (search != null) {
        url = "$url&search=$search";
      }

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

  static Future<HttpResponse> agendarConsulta(Agendar agendar) async {
    try {
      var url = "$baseUrl/api/schedules";

      HttpResponse response = await post(url, agendar.toJsonAsConsulta());

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } catch (error) {
      if (isNotEmpty(error.code)) {
        throw DandelinError.create(error.cause, error.code);
      }
      if (isNotEmpty(error.cause)) {
        throw error.cause;
      }
      throw error.toString();
    }
  }

  static Future<HttpResponse> editarConsulta(Agendar agendar, int id) async {
    try {
      var url = "$baseUrl/api/schedules/$id";

      HttpResponse response = await put(url, agendar.toJsonAsConsulta());

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

  static Future<HttpResponse> editarExame(Agendar agendar, int id) async {
    try {
      var url = "$baseUrl/api/laboratories/schedule/$id";

      HttpResponse response = await put(url, agendar.toJsonAsExam());

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

  static Future<HttpResponse> proximaDataDisponivelConsulta(Map search,
      {bool covid = false, bool acessibilidade = false}) async {
    try {
      if (acessibilidade) {
        search['accessibility'] = acessibilidade;
      } else {
        search['accessibility'] = null;
      }

      if (covid) {
        search['covid19'] = true;
      }
      var url = "$baseUrl/api/schedules/next";
      HttpResponse response = await post(url, search);

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

  static Future<HttpResponse> proximaDataDisponivelExame(Map search) async {
    try {
      var url = "$baseUrl/api/laboratories/schedule/next";
      HttpResponse response = await post(url, search);

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

  static Future<HttpResponse> agendarExame(Agendar agendar) async {
    try {
      var url = "$baseUrl/api/laboratories/schedule";
      HttpResponse response = await post(url, agendar.toJsonAsExam());

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

  static Future<ApiResponse> getBadges(String email) async {
    try {
      var url =
          "https://dandelin.livetouchdev.com.br/rest/chat/dandelin/badges/$email";

      String wstoken = await Prefs.getString('livecom.wstoken');

      HttpResponse response = await get(url, header: {
        "Content-Type": "application/json",
        "Authorization": wstoken,
      });

      print(response);
      Map data = response.data;

      return ApiResponse.ok(result: data['mensagens']);
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
}
