import 'package:flutter_dandelin/model/biling.dart';
import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/exam.dart';

import 'package:flutter_dandelin/pages/historico/historico_api.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';

class HistoricoBloc {
  final consultasExames = PaginationBloc<List<dynamic>>();
  final pagamentos = PaginationBloc<List<Biling>>();

  final selectedBar = SimpleBloc<int>();

  fetch({bool setNull = false}) async {
    if (setNull) {
      consultasExames.add(null);
    }
    _fetchConsultasExames();
    _fetchBillings();
  }

  _fetchConsultasExames() async {
    List<dynamic> listConsultaExame = List<dynamic>();

    HttpResponse response =
        await HistoricoApi.getConsultas().catchError(consultasExames.addError);

    if (response == null) {
      return;
    }

    var list = response.data['data'] as List;

    listConsultaExame = list
        .map<dynamic>((json) => json["scheduleExam"] == null
            ? Consulta.fromJson(json)
            : Exam.fromJson(json))
        .toList();

    consultasExames.add(listConsultaExame);
  }

  fecthMoreConsultasExames() async {
    if (!consultasExames.endApiResults.value) {
      List<dynamic> data = consultasExames.value;

      consultasExames.loading.add(true);

      HttpResponse response =
          await HistoricoApi.getConsultas(page: consultasExames.getPage())
              .catchError(consultasExames.addError);

      if (response == null) {
        consultasExames.loading.add(false);
        return;
      }

      var list = response.data['data'] as List;

      if (list.length > 0) {
        list.forEach((map) {
          data.add(map["scheduleExam"] == null
              ? Consulta.fromJson(map)
              : Exam.fromJson(map));
        });
      } else {
        consultasExames.endApiResults.add(true);
      }

      consultasExames.add(data);
      consultasExames.loading.add(false);
    }
  }

  _fetchBillings() async {
    List<Biling> listPagamentos = List<Biling>();

    HttpResponse response =
        await HistoricoApi.getPagamentos().catchError(pagamentos.addError);

    var list = response.data['data'] as List;

    listPagamentos = list.map<Biling>((json) => Biling.fromJson(json)).toList();

    pagamentos.add(listPagamentos);
  }

  fetchMorePagamentos() async {
    if (!pagamentos.endApiResults.value) {
      List<Biling> data = pagamentos.value;

      pagamentos.loading.add(true);

      HttpResponse response =
          await HistoricoApi.getPagamentos(page: pagamentos.getPage())
              .catchError(pagamentos.addError);

      if (response == null) {
        return;
      }

      var list = response.data['data'] as List;

      if (list.length > 0) {
        list.forEach((map) {
          data.add(Biling.fromJson(map));
        });
      } else {
        pagamentos.endApiResults.add(true);
      }

      pagamentos.add(data);
      pagamentos.loading.add(false);
    }
  }

  dispose() {
    selectedBar.dispose();
    pagamentos.dispose();
    pagamentos.disposePagination();
    consultasExames.dispose();
    consultasExames.disposePagination();
  }
}
