import 'package:flutter/material.dart';
import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/exam.dart';
import 'package:flutter_dandelin/model/unity.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_api.dart';
import 'package:flutter_dandelin/pages/historico/historico_api.dart';
import 'package:flutter_dandelin/pages/mapa/mapa.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';

class ConsultaExameAgendadoBloc {
  final button = ButtonBloc();
  final consultaOuEmame = SimpleBloc<dynamic>();
  final badges = SimpleBloc();

  fetch(dynamic consultaExame)  {
    consultaOuEmame.add(consultaExame);


    if (consultaExame is Consulta) {
      String email = consultaExame.scheduleDoctor.doctor.user.username;
      _getBadges(email);
    }
  }

  _getBadges(String email) async {
    try {
      ApiResponse response = await ConsultaExameApi.getBadges(email);
      print(response);

      badges.add(response.result == null ? 0 : response.result);
    } catch (e) {
      print(e);
    }
  }

  var mapStream = SimpleBloc<Widget>();
  startMap() {
    //DANDO ERRO QUANDO VAI DE UMA PAGINA QUE TEM MAPA PARA OUTRA PAGINA QUE TEM MAPA
    //FAZER DESSE METODO PARA DEPOIS FAZER O MAPA SUMIR COMO IGUAL NO METODO DE BAIXO
    mapStream.add(Expanded(
      child: MapaPage(
        stream: consultaOuEmame.stream,
        onTapMarker: (value) {},
        isDetalheConsultaOuExame: true,
        isConsultaMarcada: true,
      ),
    ));
  }

  endMap() {
    mapStream.add(null);
  }

  Future<ApiResponse<Consulta>> getConsulta(Consulta consulta) async {
    button.setProgress(true);
    try {
      HttpResponse response = await HistoricoApi.getConsulta(consulta);

      Map data = response.data["data"];

      var schedules = data["schedules"] as List;

      if (schedules.length == 1) {
        return ApiResponse.ok(result: Consulta.fromJson(schedules.first));
      } else {
        var listConsulta =
            schedules.map<Consulta>((json) => Consulta.fromJson(json)).toList();

        Consulta consultaToReturn = listConsulta.firstWhere(
            (c) => c.address.id == consulta.scheduleDoctor.address.id);

        return ApiResponse.ok(result: consultaToReturn);
      }
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      button.setProgress(false);
    }
  }

  Future<ApiResponse<Unity>> getUnity(Exam exam) async {
    button.setProgress(true);
    try {
      HttpResponse response = await HistoricoApi.getUnity(exam);

      Map data = response.data["data"];

      var schedules = data["schedules"] as List;

      if (schedules.length == 1) {
        return ApiResponse.ok(result: Unity.fromJson(schedules.first));
      } else {
        var listUnity =
            schedules.map<Unity>((json) => Unity.fromJson(json)).toList();

        Unity unityToReturn = listUnity
            .firstWhere((e) => e.address.id == exam.scheduleExam.address.id);

        return ApiResponse.ok(result: unityToReturn);
      }
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      button.setProgress(false);
    }
  }

  dispose() {
    mapStream.dispose();
    consultaOuEmame.dispose();
    button.dispose();
    badges.dispose();
  }
}
