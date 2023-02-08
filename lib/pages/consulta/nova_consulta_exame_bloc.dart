import 'package:flutter/material.dart';
import 'package:flutter_dandelin/constants.dart';
import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/expertise.dart';
import 'package:flutter_dandelin/model/city.dart';
import 'package:flutter_dandelin/model/laboratory.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/consulta/linha_calendario.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_api.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_base.dart';
import 'package:flutter_dandelin/pages/mapa/mapa.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/datetime_helper.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/prefs.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';
import 'package:flutter_dandelin/model/address.dart';

class ConsultaExameBloc extends ConsultaExameBase {
  //list que guarda as consultas ou exames que vieram da api
  final listConsultaOuExame = SimpleBloc<List<dynamic>>();
  final telaEscolhida = SimpleBloc<TelaEscolhidaEnum>();
  //card do mapa
  final cardMapaConsultaExame = SimpleBloc<dynamic>();
  //controlar os containers do mapa
  final showMiniCardDetalhe = SimpleBloc<bool>();
  //behavior para guarda os valores de cada caso foi esoclhido
  final localidadeEscolhida = SimpleBloc<City>();
  final expertiseEscolhida = SimpleBloc<Expertise>();
  final doctorEscolhido = SimpleBloc<User>();
  final laboratoryEscolhido = SimpleBloc<Laboratory>();
  final tipoConsulta = SimpleBloc<TipoConsulta>();
  final acessibilidade = SimpleBloc<bool>();
  final proximaDataButton = ButtonBloc();
  final listFiltro = SimpleBloc<List<dynamic>>();
  final filtroEscolhido = SimpleBloc<FiltroEscolhidoEnum>();
  final page = SimpleBloc<int>();
  final loading = SimpleBloc<bool>();
  final mostrarListaDeBusca = SimpleBloc<bool>();
  final addressStream = SimpleBloc<List<Address>>();

  var pararPaginacao = false;

  fetch() async {
    String city = await Prefs.getString('lastCitySelected');

    localidadeEscolhida
        .add(city == null ? City.cityDefault() : City(name: city));

    laboratoryEscolhido.add(Laboratory.laboratoryDefault());
    expertiseEscolhida.add(Expertise.expertiseDefault());

    page.add(0);
    proximaDataButton.setEnabled(true);
    acessibilidade.add(false);

    fetchDiasCalendarioBase();

    _getApiData(false);
  }

  consultaDenovo() async {
    showMiniCardDetalhe.add(false);
    bool isTelemedicine = tipoConsulta.value == TipoConsulta.video;
    _getApiData(true, acessiblidade:  isTelemedicine ? false : acessibilidade.value);
  }

  _getApiData(bool setNull, {acessiblidade = false}) async {
    cardMapaConsultaExame.add(null);

    if (setNull) {
      listConsultaOuExame.add(null);
    }

    // if (isConsultaFiltrando()) {
    // } else {
    // HttpResponse response =
    //     await ConsultaExameApi.getExames(await search()).catchError((e) {
    //   listConsultaOuExame.addError(e);
    //   return;
    // });
    //
    // list = responseList
    // cd    .map<Unity>((json) =>
    //         Unity.unidadeSemHorariosInvalidos(json, getDataSelecionada()))
    //     .toList();
    //
    // list.removeWhere((unity) => unity.avaliability.length == 0);
    // }

    ApiResponse response = await ConsultaExameApi.getConsultas(
      await search(),
      getDataSelecionada(),
      removeHorarios: true,
      acessibilidade: acessiblidade,
    );

    if (!response.ok) {
      listConsultaOuExame.addError(response.msg);
      return;
    }

    if (response.result is List<Address>) {
      addressStream.add(response.result);
      listConsultaOuExame.add(List<dynamic>());
    } else {
      listConsultaOuExame.add(response.result);
    }
  }

  openCardConsultaExameMarkerTapped(dynamic dynamicClass) {
    var l = listConsultaOuExame.value;

    //não esquece de adaptar para quando tiver exame

    if (l.where((v) => v.markerSelected == true).length > 0) {
      Consulta c = l.firstWhere((v) => v.markerSelected == true);
      c.markerSelected = false;
    }

    Consulta consulta = l.where((v) => v.id == dynamicClass.id).first;
    consulta.markerSelected = true;

    listConsultaOuExame.add(l);

    cardMapaConsultaExame.add(dynamicClass);
  }

  buscaLocalidades({String filtro}) async {
    listFiltro.add(null);

    if (filtro == "" && filtro == null) {
      mostrarListaDeBusca.add(false);
      return;
    }

    HttpResponse response = await ConsultaExameApi.getLocalidades(
            0, isConsultaFiltrando(),
            search: filtro)
        .catchError((e) {
      listFiltro.addError(e);
      return;
    });

    _addLocalidadesToStream(response, new List<City>(), addDefault: true);
  }

  buscaMaisLocalidades({String filtro}) async {
    if (pararPaginacao && filtro == kLocalidadeBase) {
      return;
    }

    loading.add(true);

    int nPage = page.value + 1;

    HttpResponse response = await ConsultaExameApi.getLocalidades(
            nPage, isConsultaFiltrando(),
            search: filtro)
        .catchError((e) {
      listFiltro.addError(e);
      return;
    });

    if (response.data['data'].length == 0) {
      pararPaginacao = true;
      loading.add(false);
      return;
    }

    _addLocalidadesToStream(response, listFiltro.value);

    page.add(nPage);
    loading.add(false);
  }

  _addLocalidadesToStream(HttpResponse response, List<dynamic> listValue,
      {bool addDefault = false}) {
    City localidadeSelected = localidadeEscolhida.value;

    List<City> list = listValue;

    // if (addDefault) {
    //   list.add(City.cityDefault(citySelected: localidadeSelected));
    // }

    response.data['data'].forEach((json) {
      City c = City.fromJson({'name': json});

      list.add(c
        ..isSelected = City.isCitySelected(
          city: c,
          citySelected: localidadeSelected,
        ));
    });

    listFiltro.add(list);
  }

  buscaEspecialidades({String filtro}) async {
    listFiltro.add(null);

    if (filtro == "" && filtro == null) {
      mostrarListaDeBusca.add(false);
      return;
    }
    //lab muda aqui
    //if (isConsultaFiltrando()) {
    HttpResponse response =
        await ConsultaExameApi.getEspecializacaoDoctor(0, search: filtro)
            .catchError((e) {
      listFiltro.addError(e);
      return;
    });

    _addEspecialidadesUsersToStream(response, new List<dynamic>(),
        addDefault: true);
    // } else {
    //   HttpResponse response =
    //       await ConsultaExameApi.getLaboratoriesByName(0, search: filtro)
    //           .catchError((e) {
    //     listFiltro.addError(e);
    //     return;
    //   });

    //   _addLaboratoriesToStream(response, new List<dynamic>(), addDefault: true);
    // }
  }

  buscaMaisEspecialidades({String filtro}) async {
    if (pararPaginacao && filtro == kExpertiseBase) {
      return;
    }

    loading.add(true);
    int nPage = page.value + 1;

    if (isConsultaFiltrando()) {
      HttpResponse response =
          await ConsultaExameApi.getEspecializacaoDoctor(nPage, search: filtro)
              .catchError((e) {
        listFiltro.addError(e);
        return;
      });

      if (response.data['data'].length == 0) {
        loading.add(false);
        pararPaginacao = true;
        return;
      }

      _addEspecialidadesUsersToStream(response, listFiltro.value);
    } else {
      HttpResponse response =
          await ConsultaExameApi.getLaboratoriesByName(nPage, search: filtro)
              .catchError((e) {
        listFiltro.addError(e);
        return;
      });

      if (response.data['data'].length == 0) {
        loading.add(false);
        pararPaginacao = true;
        return;
      }

      _addLaboratoriesToStream(response, listFiltro.value);
    }

    page.add(nPage);
    loading.add(false);
  }

  _addEspecialidadesUsersToStream(
      HttpResponse response, List<dynamic> listValue,
      {bool addDefault = false}) {
    Expertise expertiseSelected = expertiseEscolhida.value;

    List<dynamic> list = listValue;

    // if (addDefault) {
    //   list.add(
    //       Expertise.expertiseDefault(expertiseSelected: expertiseSelected));
    // }

    response.data['data'].forEach((json) {
      if (json['user'] == null) {
        Expertise expertise = Expertise.fromJson(json);
        expertise.isSelected = Expertise.isExpertiseSelected(
            expertise: expertise, expertiseSelected: expertiseSelected);

        list.add(expertise);
      } else {
        list.add(User.fromJson(json['user']));
      }
    });

    listFiltro.add(list);
  }

  _addLaboratoriesToStream(HttpResponse response, List<dynamic> listValue,
      {bool addDefault = false}) {
    Laboratory laboratorySelected = laboratoryEscolhido.value;

    List<dynamic> list = listValue;

    // if (addDefault) {
    //   list.add(
    //       Laboratory.laboratoryDefault(laboratorySelected: laboratorySelected));
    // }

    response.data['data'].forEach((json) {
      Laboratory laboratory = Laboratory.fromJson(json);
      laboratory.isSelected = Laboratory.isLaboratorySelected(
          laboratory: laboratory, laboratorySelected: laboratorySelected);
      list.add(laboratory);
    });

    listFiltro.add(list);
  }

  filtrarEspecialidadeOuLocaldiade(item) {
    pararPaginacao = false;
    page.add(0);
    if (item is Expertise) {
      expertiseEscolhida.add(item);
      doctorEscolhido.add(null);
    } else if (item is City) {
      Prefs.setString(
          'lastCitySelected', item.name == kLocalidadeBase ? null : item.name);
      localidadeEscolhida.add(item);
    } else if (item is User) {
      doctorEscolhido.add(item);
      expertiseEscolhida.add(null);
    } else {
      laboratoryEscolhido.add(item);
    }

    filtroEscolhido.add(null);
    listFiltro.add(null);
    mostrarListaDeBusca.add(null);
    consultaDenovo();
  }

  City getLocalizacaoSelected() {
    City loc = localidadeEscolhida.value;
    return loc != null ? loc : null;
  }

  int getEspecilidadeSelected() {
    Expertise exp = expertiseEscolhida.value;
    return exp != null ? exp.id : null;
  }

  OpcaoEscolhida getConsultaExameEscolhido() {
    return consultaExameEscolhidoBase.value;
  }

  Future<Map<String, dynamic>> search({bool toGA = false}) async {
    City city = localidadeEscolhida.value;

    bool sendCordinates =
        city != null && city.name != kLocalidadeBase ? false : true;

    bool isTelemedicina = tipoConsulta.value == TipoConsulta.video;

    Map<String, dynamic> search = await searchBase(getDataEscolhidaBase(),
        sendCordinates: isTelemedicina ? false : sendCordinates);

    search['telemedicine'] = isTelemedicina;

    if (!isTelemedicina && !sendCordinates) {
      search['location'] = city.name;
    }

    //lab muda aqui
    // if (isConsultaFiltrando()) {
    if (expertiseEscolhida.value != null) {
      Expertise expertises = expertiseEscolhida.value;
      if (expertises.id != 0) {
        if (toGA) {
          search['expertise_id'] = expertises.id;
        } else {
          search['expertise'] = {
            'id': expertises.id,
          };
        }
      }
    }

    if (doctorEscolhido.value != null) {
      User user = doctorEscolhido.value;

      if (toGA) {
        search['doctor_id'] = user.id;
      } else {
        search['doctor'] = {
          'id': user.id,
        };
      }
    }

    // } else {
    //   if (laboratoryEscolhido.value != null &&
    //       laboratoryEscolhido.value.id != 0) {
    //     Laboratory laboratory = laboratoryEscolhido.value;
    //     search['exam'] = {
    //       'id': laboratory.id,
    //     };
    //   }
    // }

    return search;
  }

  proximaDataDisponivel({bool accessibility = false}) async {
    proximaDataButton.setProgress(true);

    HttpResponse response;

    bool isTelemedicina = tipoConsulta.value == TipoConsulta.video;

    List<dynamic> list = List<dynamic>();
    if (isConsultaFiltrando()) {
      response =
          await ConsultaExameApi.proximaDataDisponivelConsulta(await search(), acessibilidade: isTelemedicina ? false : acessibilidade.value)
              .catchError((e) {
        listConsultaOuExame.addError(e);
        proximaDataButton.setProgress(false);
        return;
      });

      if (response == null) {
        return;
      }

      _changeDateFromResponse(response);
    } else {
      // HttpResponse response =
      //     await ConsultaExameApi.proximaDataDisponivelExame(await search())
      //         .catchError((e) {
      //   proximaDataButton.setProgress(false);
      //   listConsultaOuExame.addError(e);
      //   return;
      // });

      response = await ConsultaExameApi.proximaDataDisponivelConsulta(
              await search(), acessibilidade: accessibility,
              covid: true )
          .catchError((e) {
        listConsultaOuExame.addError(e);
        proximaDataButton.setProgress(false);
        return;
      });

      if (response == null) {
        return;
      }

      _changeDateFromResponse(response);

      // response.data["data"]["schedules"].forEach((json) {
      //   Unity c = Unity.unidadeSemHorariosInvalidos(json, getDataSelecionada());

      //   if (c.avaliability.length > 0) {
      //     list.add(c);
      //   }
      // });
    }

    response.data["data"]["schedules"].forEach((json) {
      Consulta c =
          Consulta.consultaSemHorariosInvalidos(json, getDataSelecionada());

      if (c.avaliability.length > 0) {
        list.add(c);
      }
    });

    listConsultaOuExame.add(list);

    proximaDataButton.setProgress(false);
  }

  _changeDateFromResponse(HttpResponse response) {
    if (response != null &&
        response.data != null &&
        response.data['data'] != null &&
        response.data["data"]["avaliableDate"] != null) {
      changeBtnSelecionadoPorDateTime(
          stringToDateTime(response.data["data"]["avaliableDate"]));
    }
  }

  getDataSelecionada() {
    List<CalendarButton> data = listDiasCalendarioBase.value;

    CalendarButton calendarButton =
        data.where((v) => v.isSelected == true).first;

    return DateTime(
        calendarButton.ano, calendarButton.nMes, int.parse(calendarButton.dia));
  }

  changeFiltroEscolhido(OpcaoEscolhida opcao) {
    doctorEscolhido.add(null);
    laboratoryEscolhido.add(null);
    expertiseEscolhida.add(null);
    consultaExameEscolhidoBase.add(opcao);
    consultaDenovo();
  }

  isConsultaFiltrando() {
    OpcaoEscolhida opcao = consultaExameEscolhidoBase.value;

    return opcao == null || opcao == OpcaoEscolhida.consulta;
  }

  toGA() async {
    Map<String, dynamic> map = await search();

    return map;
  }

  changeTipoConsulta(TipoConsulta value) {
    tipoConsulta.add(value);
    if(value == TipoConsulta.video){
      _getApiData(true);
    } else{
      _getApiData(true, acessiblidade: acessibilidade.value);
    }
  }

  changeAcessibilidade(bool value) {
    acessibilidade.add(value);
    _getApiData(true, acessiblidade: value);
  }

  var mapStream = SimpleBloc<Widget>();
  startMap(Function onTapMarker) {
    //DANDO ERRO NO IOS 13 QUANDO VAI DE UMA PAGINA QUE TEM MAPA PARA OUTRA PAGINA QUE TEM MAPA
    //FAZER DESSE METODO PARA DEPOIS FAZER O MAPA SUMIR COMO IGUAL NO METODO DE BAIXO
    mapStream.add(
      MapaPage(
        stream: listConsultaOuExame.stream,
        onTapMarker: onTapMarker,
      ),
    );
  }

  endMap() {
    mapStream.add(null);
  }

  dispose() {
    super.disposeBase();
    mapStream.dispose();
    telaEscolhida.dispose();
    cardMapaConsultaExame.dispose();
    showMiniCardDetalhe.dispose();
    expertiseEscolhida.dispose();
    localidadeEscolhida.dispose();
    listConsultaOuExame.dispose();
    page.dispose();
    loading.dispose();
    doctorEscolhido.dispose();
    proximaDataButton.dispose();
    listFiltro.dispose();
    mostrarListaDeBusca.dispose();
    filtroEscolhido.dispose();
    tipoConsulta.dispose();
    addressStream.dispose();
  }
}

enum TelaEscolhidaEnum {
  lista,
  mapa,
}

enum FiltroEscolhidoEnum {
  localicade,
  especilidadeNome,
}

enum TipoConsulta {
  presencial,
  video,
}


