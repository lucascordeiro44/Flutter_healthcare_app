import 'package:flutter_dandelin/model/address.dart';
import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/exam.dart';
import 'package:flutter_dandelin/model/unity.dart';
import 'package:flutter_dandelin/pages/consulta/linha_calendario.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_api.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_base.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/datetime_helper.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';
import 'package:flutter_dandelin/widgets/wrap_horarios.dart';

class ConsultaExameDetalheBloc extends ConsultaExameBase {
  //guarda a consulta ou o exame
  final consultaExameStream = SimpleBloc<dynamic>();
  //quando é para alterar, guardar os dados da consulta que foi marcada
  final consultaExameMarcadoStream = SimpleBloc<dynamic>();

  //lista de horarios disponivel do medico aquele dia
  final listHorarios = SimpleBloc<List<HorarioButton>>();

  //button agendar
  final button = ButtonBloc();

  final idxDotsIndicator = SimpleBloc<int>();

  final badges = SimpleBloc();

  fetch(OpcaoEscolhida consultaExameEscolhido, CalendarButton dataSelecionada,
      dynamic consultaExame, dynamic consultaExameMarcado) {
    fetchDiasCalendarioBase();

    updateListCalendarioBase(dataSelecionada);

    consultaExameEscolhidoBase.add(consultaExameEscolhido);

    consultaExameStream.add(consultaExame);

    consultaExameMarcadoStream.add(consultaExameMarcado);

    _buildHorariosButtons(consultaExame);

    if (consultaExame is Consulta) {
      String email = consultaExame.doctor.user.username;
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

  consultaDenovo(bool sendCortinates, Address addressToFilter) async {
    listHorarios.add(null);
    button.setEnabled(false);

    //OpcaoEscolhida opcao = consultaExameEscolhidoBase.value;

    //if (opcao == null || opcao == OpcaoEscolhida.consulta) {

    ApiResponse response = await ConsultaExameApi.getConsultas(
        await searchDetalhe(sendCortinates: false), getDataSelecionada());

    if (!response.ok) {
      consultaExameStream.addError(response.msg);
      return;
    }

    List<Consulta> listConsulta = response.result;

    if (listConsulta.length == 0) {
      listHorarios.add(new List<HorarioButton>());
      return;
    }

    if (response == null) {
      return;
    }

    Consulta consulta = listConsulta.length == 1
        ? listConsulta[0]
        : listConsulta.firstWhere((c) => c.address.id == addressToFilter.id);

    consultaExameStream.add(consulta);
    _buildHorariosButtons(consulta);
    // } else {
    //   HttpResponse response = await ConsultaExameApi.getExames(
    //           await searchDetalhe(sendCortinates: false))
    //       .catchError((e) {
    //     listHorarios.addError(e);
    //     return;
    //   });

    //   if (response == null) {
    //     return;
    //   }

    //   var list = response.data['data'];

    //   List<Unity> listUnity = list
    //       .map<Unity>((json) =>
    //           Unity.unidadeSemHorariosInvalidos(json, getDataSelecionada()))
    //       .toList();

    //   if (listUnity.length == 0) {
    //     listHorarios.add(new List<HorarioButton>());
    //     return;
    //   }

    //   Unity unity = listUnity.first;

    //   consultaExameStream.add(unity);
    //   _buildHorariosButtons(unity);
    // }
  }

  Future<Map> searchDetalhe({bool sendCortinates}) async {
    listHorarios.add(null);
    return searchBase(
      getDataEscolhidaBase(),
      consultaOuExame: consultaExameStream.value,
      sendCordinates: sendCortinates,
    );
  }

  updateButton(int id) {
    List<HorarioButton> data = listHorarios.value;

    List<HorarioButton> tirarSelecao =
        data.where((v) => v.isSelected == true).toList();
    if (tirarSelecao.length > 0) {
      tirarSelecao.forEach((v) {
        v.isSelected = false;
      });
    }

    HorarioButton horarioButton = data.firstWhere((v) => v.id == id);

    horarioButton.isSelected = true;

    listHorarios.add(data);
    button.setEnabled(true);
  }

  Future<ApiResponse> agendar() async {
    try {
      Agendar agendar = Agendar();

      agendar.customerAt = dateTimeFormatHMS();

      if (consultaExameStream.value is Consulta) {
        Consulta consulta = consultaExameStream.value;
        agendar.segment = "CONSULTA";
        agendar.price = consulta.price;
        agendar.idUser = consulta.doctor.id;

        agendar.scheduledAt = _getScheduleAt();
        agendar.telemedicine = consulta.telemedicine;

        if (consultaExameMarcadoStream.value != null) {
          Consulta c = consultaExameMarcadoStream.value;
          await ConsultaExameApi.editarConsulta(agendar, c.id);

          return ApiResponse.ok();
        } else {
          await ConsultaExameApi.agendarConsulta(agendar);

          return ApiResponse.ok();
        }
      } else {
        Unity unity = consultaExameStream.value;

        agendar.idAddress = unity.address.id;
        agendar.scheduledAt = _getScheduleAt();
        agendar.idExame = unity.exam.id;
        agendar.idLaboratory = unity.laboratory.id;

        if (consultaExameMarcadoStream.value != null) {
          Exam exam = consultaExameMarcadoStream.value;

          await ConsultaExameApi.editarExame(agendar, exam.id);

          return ApiResponse.ok();
        } else {
          await ConsultaExameApi.agendarExame(agendar);

          return ApiResponse.ok();
        }
      }
    } catch (e) {
      return e is String ? ApiResponse.error(e) : ApiResponse.errorDynamic(e);
    }
  }

  String _getScheduleAt() {
    List<HorarioButton> horario = listHorarios.value;
    String dataSelecionada = getDataEscolhidaBase();

    var arrayData = dataSelecionada.split('-');

    var arrayHorario =
        horario.firstWhere((v) => v.isSelected == true).horario.split(':');

    int ano = int.parse(arrayData[2]);
    int mes = int.parse(arrayData[1]);
    int dia = int.parse(arrayData[0]);

    int hora = int.parse(arrayHorario[0]);
    int minuto = int.parse(arrayHorario[1]);

    return dateTimeFormatHMS(dateTime: DateTime(ano, mes, dia, hora, minuto));
  }

  _buildHorariosButtons(dynamic consultaExame) {
    List<HorarioButton> horarioButtons = List<HorarioButton>();
    List<String> horarios = List<String>();

    if (consultaExame is Consulta) {
      horarios = horariosListStrings(consultaExame.avaliability, true);
    } else {
      Unity unity = consultaExame;
      horarios = horariosListStrings(unity.avaliability, true);
    }

    horarios.asMap().forEach((i, horario) {
      horarioButtons.add(HorarioButton(
        id: i,
        horario: horario,
        isSelected: false,
      ));
    });

    listHorarios.add(horarioButtons);
  }

  getDataSelecionada() {
    List<CalendarButton> data = listDiasCalendarioBase.value;

    CalendarButton calendarButton =
        data.where((v) => v.isSelected == true).first;

    return DateTime(
        calendarButton.ano, calendarButton.nMes, int.parse(calendarButton.dia));
  }

  dispose() {
    consultaExameStream.dispose();
    listHorarios.dispose();
    button.dispose();
    idxDotsIndicator.dispose();
    disposeBase();
    badges.dispose();
  }
}

class HorarioButton {
  int id;
  String horario;
  bool isSelected;

  HorarioButton({this.id, this.horario, this.isSelected});
}

class Agendar {
  String customerAt;
  String segment;
  num price;
  String scheduledAt;
  int idUser;
  int idAddress;
  int idExame;
  int idLaboratory;
  bool telemedicine;

  Agendar({
    this.customerAt,
    this.segment,
    this.price,
    this.scheduledAt,
    this.idUser,
    this.idAddress,
    this.idExame,
    this.idLaboratory,
    this.telemedicine,
  });

  Map<String, dynamic> toJsonAsConsulta() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customerAt'] = this.customerAt;
    data['segment'] = this.segment;
    data['price'] = this.price;
    data['scheduledAt'] = this.scheduledAt;
    data['doctor'] = {'id': this.idUser};

    data['telemedicine'] = this.telemedicine;

    return data;
  }

  Map<String, dynamic> toJsonAsExam() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customerAt'] = this.customerAt;
    data['scheduledAt'] = this.scheduledAt;
    data['scheduleExam'] = {
      "address": {
        'id': this.idAddress,
      },
      "exam": {
        'id': this.idExame,
      }
    };
    data['laboratory'] = {'id': this.idLaboratory};

    return data;
  }
}
