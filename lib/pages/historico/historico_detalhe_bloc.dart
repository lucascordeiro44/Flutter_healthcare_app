import 'package:flutter/material.dart';
import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/unity.dart';
import 'package:flutter_dandelin/pages/consulta/linha_calendario.dart';
import 'package:flutter_dandelin/pages/historico/historico_api.dart';
import 'package:flutter_dandelin/pages/mapa/mapa.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/datetime_helper.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';
import 'package:flutter_dandelin/widgets/app_rating_widget.dart';

class HistoricoDetalheBloc extends AppRatingBloc {
  final button = ButtonBloc();
  final consultaExame = SimpleBloc<dynamic>();
  final dataProximaConsulta = SimpleBloc<CalendarButton>();

  fetch(dynamic _consultaExame) {
    button.setEnabled(true);
    consultaExame.add(_consultaExame);
    if (_consultaExame is Consulta && _consultaExame.isAtendido) {
      int rating = _consultaExame.rating?.rating;

      super.fetchRating(index: rating != null ? rating - 1 : null);
    }
  }

  Future<ApiResponse<dynamic>> getConsultaOuExame() async {
    button.setProgress(true);
    dynamic consultaOuExame = consultaExame.value;

    try {
      if (consultaOuExame is Consulta) {
        HttpResponse response = await HistoricoApi.getConsulta(consultaOuExame);

        DateTime dateTime =
            stringToDateTime(response.data['data']['avaliableDate']);

        dataProximaConsulta
            .add(CalendarButton.dateTimeToCalendarButton(dateTime, null, true));

        return ApiResponse.ok(
          result: Consulta.fromJson(
            response.data['data']["schedules"][0],
          ),
        );
      } else {
        HttpResponse response = await HistoricoApi.getUnity(consultaOuExame);

        DateTime dateTime =
            stringToDateTime(response.data['data']['avaliableDate']);

        dataProximaConsulta
            .add(CalendarButton.dateTimeToCalendarButton(dateTime, null, true));

        return ApiResponse.ok(
          result: Unity.fromJson(
            response.data['data']["schedules"][0],
          ),
        );
      }
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      button.setProgress(false);
    }
  }

  var mapStream = SimpleBloc<Widget>();
  startMap() {
    //DANDO ERRO QUANDO VAI DE UMA PAGINA QUE TEM MAPA PARA OUTRA PAGINA QUE TEM MAPA
    //FAZER DESSE METODO PARA DEPOIS FAZER O MAPA SUMIR COMO IGUAL NO METODO DE BAIXO
    mapStream.add(Expanded(
      child: MapaPage(
        stream: consultaExame.stream,
        onTapMarker: (value) {},
        isDetalheConsultaOuExame: true,
        isConsultaMarcada: true,
      ),
    ));
  }

  endMap() {
    mapStream.add(null);
  }

  dispose() {
    super.disposeRating();
    mapStream.dispose();
    button.dispose();
    consultaExame.dispose();
    dataProximaConsulta.dispose();
  }
}
