import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/address.dart';
import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/expertise.dart';
import 'package:flutter_dandelin/model/city.dart';
import 'package:flutter_dandelin/pages/busca/busca_button.dart';
import 'package:flutter_dandelin/pages/consulta/calendario_consuta_page.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_base.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_bloc.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_detalhe.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_mapa.dart';
import 'package:flutter_dandelin/pages/consulta/linha_calendario.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_card.dart';
import 'package:flutter_dandelin/pages/consulta/widgets/especialidade_icon.dart';
import 'package:flutter_dandelin/pages/consulta/widgets/linha_lista_filtro.dart';
import 'package:flutter_dandelin/pages/consulta/widgets/lista_filtro.dart';
import 'package:flutter_dandelin/pages/consulta/widgets/mapa_lista_button.dart';
import 'package:flutter_dandelin/pages/consulta/widgets/sem_consulta_background.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/scroll.dart';
import 'package:flutter_dandelin/widgets/center_text.dart';
import 'package:flutter_dandelin/widgets/custom_checkbox.dart';
import 'package:flutter_dandelin/widgets/tutorial_covid.dart';

class ConsultaExamePage extends StatefulWidget {
  @override
  _ConsultaExamePage createState() => _ConsultaExamePage();
}

class _ConsultaExamePage extends State<ConsultaExamePage> {
  final _bloc = ConsultaExameBloc();

  final _scrollController = ScrollController();
  final _listFiltroController = ScrollController();
  final _scrollCalendarioController = ScrollController();

  final _localidadeController = TextEditingController();
  final _especialidadeController = TextEditingController();

  final _localidadeFn = FocusNode();
  final _especialidadeFn = FocusNode();

  bool _acessibilidade = false;

  @override
  void initState() {
    super.initState();
    screenView('Nova_Consulta_Exame', "Tela Nova_Consulta_Exame");

    addScrollListener(_listFiltroController, () {
      if (_bloc.filtroEscolhido.value == FiltroEscolhidoEnum.localicade) {
        _bloc.buscaMaisLocalidades(filtro: _localidadeController.text);
      } else {
        _bloc.buscaMaisEspecialidades(filtro: _especialidadeController.text);
      }
    });

    _controlLocalidadeField();
    _controlEspecialidadeField();
    _listenCovidTutorial();
    _listenTipoConsulta();
    _listenAddressStream();

    _bloc.fetch();
  }

  _listenTipoConsulta() {
    _bloc.tipoConsulta.listen((v) {
      if (v == TipoConsulta.video) {
        _bloc.filtroEscolhido.add(null);
      } else {
        City localidade = _bloc.localidadeEscolhida.value;

        if (localidade == null) {
          _localidadeController.text = kLocalidadeBase;
        } else {
          _localidadeController.text = localidade.name;
        }
      }
    });
  }

  _listenCovidTutorial() async {
    _bloc.consultaExameEscolhidoBase.listen((v) async {
      if (OpcaoEscolhida.exame == v) {
        bool value = await Prefs.getBool('nova_consulta.covid_tutorialDone');

        if (value == null || !value) {
          Prefs.setBool('nova_consulta.covid_tutorialDone', true);
          showAppGeneralDialog(
            context,
            TutorialCovid(),
          );
        }
      }
    });
  }

  _controlLocalidadeField() {
    _localidadeFn.addListener(() {
      if (_localidadeFn.hasFocus) {
        _bloc.filtroEscolhido.add(FiltroEscolhidoEnum.localicade);

        //  _bloc.buscaLocalidades();
      } else {
        City localidade = _bloc.localidadeEscolhida.value;

        if (localidade == null) {
          _localidadeController.text = kLocalidadeBase;
        } else {
          _localidadeController.text = localidade.name;
        }
      }
    });

    _bloc.localidadeEscolhida.listen((value) {
      _localidadeController.text = value.name;
    });
  }

  _controlEspecialidadeField() {
    _especialidadeFn.addListener(() {
      if (_especialidadeFn.hasFocus) {
        _bloc.filtroEscolhido.add(FiltroEscolhidoEnum.especilidadeNome);

        // _bloc.buscaEspecialidades();
      } else {
        Expertise expertise = _bloc.expertiseEscolhida.value;

        if (expertise == null) {
          User user = _bloc.doctorEscolhido.value;
          if (user != null) {
            _especialidadeController.text = user.getUserFullName;
          }
        } else {
          if (expertise.name != kExpertiseBase) {
            _especialidadeController.text = expertise.name;
          } else {
            _especialidadeController.text = kExpertiseBase;
          }
        }
      }
    });

    _bloc.expertiseEscolhida.listen((value) {
      if (value != null) {
        _especialidadeController.text = value.name;
      }
    });

    _bloc.doctorEscolhido.listen((value) {
      if (value != null) {
        _especialidadeController.text = value.fullName;
      }
    });

    _bloc.laboratoryEscolhido.listen((value) {
      if (value != null) {
        _especialidadeController.text = value.title ?? value.name;
      }
    });
  }

  _listenAddressStream() {
    _bloc.addressStream.listen((list) {
      if (list == null) {
        return;
      }

      _dialogOtherAddress(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    return BaseContainer(
      needSingleChildScrollView: false,
      child: Column(
        children: <Widget>[
          _headerBuscas(),
          _divider(),
          _listaOuMapa(),
        ],
      ),
    );
  }

  _headerBuscas() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            color: Color.fromRGBO(247, 247, 247, 1),
            padding: EdgeInsets.only(top: 10, right: 16, left: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _rowExameConsultaMapaIcon(),
                _localidadeButton(),
                _especialidadesButton(),
                _acessibilidadeButton(),
              ],
            ),
          ),
          _calendarRow(),
        ],
      ),
      bottom: false,
    );
  }

  _divider() {
    Widget child = Divider(height: 0, color: Colors.black54);

    Widget elseChild = Expanded(
      child: _listFiltroEspecialidadeOuLocalidade(),
    );

    return _streamShowList(child, elseChild: elseChild);
  }

  _listaOuMapa() {
    Widget child = StreamBuilder(
      stream: _bloc.telaEscolhida.stream,
      builder: (context, snapshot) {
        TelaEscolhidaEnum v =
            snapshot.hasData ? snapshot.data : TelaEscolhidaEnum.lista;

        return v == TelaEscolhidaEnum.lista
            ? Expanded(
                child: _streamConsultaExameList(),
              )
            : ConsultaExameMapa(
                bloc: _bloc,
                onTapMarker: _onTapMarker,
                onTapMiniCard: _onPressedConsultaExameCard,
              );
      },
    );

    return _streamShowList(child);
  }

  _rowExameConsultaMapaIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // botão de close
        _closeHeaderButton(),
        //botão q fica torcando consulta com exame
        _tipoConsultaButton(),
        //botão do mapa ou lista
        _mapaListButton(),
      ],
    );
  }

  _closeHeaderButton() {
    Widget child = Container(
      width: 35,
      height: 35,
      child: RawMaterialButton(
        padding: EdgeInsets.all(0),
        onPressed: () {
          _onClickClosePage();
        },
        child: Image.asset(
          'assets/images/close-icon.png',
          height: 20,
        ),
      ),
    );

    Widget elseChild = GestureDetector(
      child: Icon(Icons.arrow_back, color: Colors.grey, size: 30),
      onTap: _onClickBackPesquisa,
    );

    return _streamShowList(child, elseChild: elseChild);
  }

  _tipoConsultaButton() {
    return ConsultaExameButton(
      bloc: _bloc,
      onPressed: _onClickTipoConsulta,
    );
  }

  //botão do mapa/list que fica trocando
  _mapaListButton() {
    return MapaListaButton(
      onClickMapaOuLista: _onClickMapaOuLista,
      stream: _bloc.telaEscolhida.stream,
    );
  }

  //botão filtro por distancia
  _localidadeButton() {
    return StreamBuilder(
      initialData: TipoConsulta.presencial,
      stream: _bloc.tipoConsulta.stream,
      builder: (context, snapshot) {
        TipoConsulta tipoConsulta = snapshot.data;

        if (tipoConsulta == TipoConsulta.video) {
          return SizedBox();
        }

        return StreamBuilder(
          stream: _bloc.filtroEscolhido.stream,
          builder: (context, snapshot) {
            bool selected = snapshot.hasData
                ? snapshot.data == FiltroEscolhidoEnum.localicade
                    ? true
                    : false
                : false;

            if (selected) {
              _localidadeController.clear();
            }

            return BuscaButton(
              focusNode: _localidadeFn,
              controller: _localidadeController,
              color: selected ? AppColors.greyBotaoSelecionado : Colors.white,
              icon: Icon(Icons.place, color: Colors.black26),
              onClick: _onClickDistanciaButtton,
              onChanged: _onChangedBuscaLocalidade,
            );
          },
        );
      },
    );
  }

  //botõa por filtro de especialidade
  _especialidadesButton() {
    return StreamBuilder(
      stream: _bloc.filtroEscolhido.stream,
      builder: (context, snapshot) {
        bool selected = snapshot.hasData
            ? snapshot.data == FiltroEscolhidoEnum.especilidadeNome
                ? true
                : false
            : false;

        if (selected) {
          _especialidadeController.clear();
        }

        return BuscaButton(
          focusNode: _especialidadeFn,
          controller: _especialidadeController,
          color: selected ? AppColors.greyBotaoSelecionado : Colors.white,
          icon: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: EspecialidadeIcon(
              stream: _bloc.consultaExameEscolhidoBase.stream,
            ),
          ),
          onClick: _onClickEspecialidadesButton,
          onChanged: _onChangedBuscaEspecialidade,
        );
      },
    );
  }

  _acessibilidadeButton() {
    return StreamBuilder(
      initialData: TipoConsulta.presencial,
      stream: _bloc.tipoConsulta.stream,
      builder: (context, snapshot) {
        TipoConsulta tipoConsulta = snapshot.data;

        if (tipoConsulta == TipoConsulta.video) {
          return SizedBox();
        }

        return Theme(
          data: ThemeData(
            fontFamily: 'Mark',
            unselectedWidgetColor: Colors.transparent,
          ),
          child: Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _tipoConsultaButton2(
                  "Com Acessibilidade",
                  EdgeInsets.only(right: 0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // _consultaPresencialVideoButtons() {
  //   return Theme(
  //     data: ThemeData(
  //       fontFamily: 'Mark',
  //       unselectedWidgetColor: Colors.transparent,
  //     ),
  //     child: Padding(
  //       padding: EdgeInsets.only(right: 8.0),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: <Widget>[
  //           _tipoConsultaButton2(
  //             "Com Acessibilidade",
  //             false,
  //             EdgeInsets.only(right: 5),
  //           ),
  //           SizedBox(width: 20),
  //           /*Container(
  //             decoration: BoxDecoration(
  //               color: AppColors.greyFontLow,
  //             ),
  //             height: 25,
  //             width: 1,
  //           ),
  //           SizedBox(width: 5),
  //           _tipoConsultaButton2(
  //             "Consulta por vídeo",
  //             TipoConsulta.video,
  //             EdgeInsets.only(left: 5),
  //           ),*/
  //         ],
  //       ),
  //     ),
  //   );
  // }

  _tipoConsultaButton2(String text, EdgeInsets padding) {
    return StreamBuilder(
      stream: _bloc.acessibilidade.stream,
      builder: (context, snapshot) {
        bool acessibilidade = snapshot.hasData ? snapshot.data : false;

        return Expanded(
          child: RawMaterialButton(
            onPressed: () {
              _onClickAcessibilidade(!acessibilidade);
            },
            child: Row(
              children: <Widget>[
                Image.asset(
                  'assets/images/ic-cadeira-de-rodas.png',
                  color: Colors.grey,
                  width: 30,
                  height: 30,
                ),
                Card(
                  elevation: 2.5,
                  margin: EdgeInsets.all(12),
                  child: CustomCheckbox(
                    value: acessibilidade != null ? acessibilidade : false,
                    onChanged: (v) {
                      _onClickAcessibilidade(v);
                    },
                    useTapTarget: false,
                    activeColor: Colors.white,
                    checkColor: AppColors.blueExame,
                  ),
                ),
                AutoSizeText(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyFont,
                  ),
                  maxFontSize: 13,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //linha do calendário
  _calendarRow() {
    Widget child = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.grey[300]),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: LinhaCalendario(
        scrollController: _scrollCalendarioController,
        onClickDiaCalendario: _onClickDiaCalendario,
        consultaExameEscolhidoStream: _bloc.consultaExameEscolhidoBase,
        listDiasCalendarioStream: _bloc.listDiasCalendarioBase,
        onClickCalendarIcon: _onClickCalendarIcon,
        ///isDetalhePage: false,
      ),
    );

    return _streamShowList(child);
  }

  _listFiltroEspecialidadeOuLocalidade() {
    return Column(
      children: <Widget>[
        _defaultFiltro(),
        Divider(height: 0, color: AppColors.greyFont, indent: 70),
        _listaFiltro(),
      ],
    );
  }

  _defaultFiltro() {
    return StreamBuilder(
      stream: _bloc.filtroEscolhido.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }

        return LinhaListaFiltro(
          item: snapshot.data == FiltroEscolhidoEnum.localicade
              ? City.cityDefault(citySelected: _bloc.localidadeEscolhida.value)
              : Expertise.expertiseDefault(
                  expertiseSelected: _bloc.expertiseEscolhida.value),
          onClickLinhaListaFiltro: _onClickLinhaListaFiltro,
          defaultValue: true,
        );
      },
    );
  }

  _listaFiltro() {
    return Expanded(
      child: StreamBuilder(
        stream: _bloc.mostrarListaDeBusca.stream,
        builder: (context, snapshotMostrarLista) {
          bool showLista =
              snapshotMostrarLista.hasData ? snapshotMostrarLista.data : false;

          return showLista
              ? ListFiltro(
                  filtroEscolhidoStream: _bloc.filtroEscolhido.stream,
                  listFiltroStream: _bloc.listFiltro.stream,
                  loadingStream: _bloc.loading.stream,
                  onClickLinhaListaFiltro: _onClickLinhaListaFiltro,
                  scrollController: _listFiltroController,
                )
              : CenterText("Faça uma busca.");
        },
      ),
    );
  }

  _streamConsultaExameList() {
    Widget child = StreamBuilder(
      stream: _bloc.listConsultaOuExame.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CenterText(snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return Progress();
        }

        List<dynamic> data = snapshot.data;

        return data.length > 0 ? _listConsultas(data) : _semConsultas();
      },
    );

    return _streamShowList(child);
  }

  _listConsultas(List<dynamic> data) {
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 30),
      itemCount: data.length,
      itemBuilder: (context, idx) {
        return ConsultaExameCard(
          dynamicClass: data[idx],
          dataEscolhida: _bloc.getDataEscolhidaBase(),
          onPressed: _onPressedConsultaExameCard,
        );
      },
      separatorBuilder: (context, idx) {
        return SizedBox(height: 5);
      },
    );
  }

  _semConsultas() {
    return SemConsultaBackground(
      opcaoEscolhida: _bloc.consultaExameEscolhidoBase.stream,
      proximaDataButton: _bloc.proximaDataButton.stream,
      onClickProximaDataDisponivel: _onClickProximaDataDisponivel,
    );
  }

  _streamShowList(Widget child, {Widget elseChild = const SizedBox()}) {
    return StreamBuilder(
      stream: _bloc.filtroEscolhido.stream,
      builder: (context, snapshot) {
        // false é quando é para mostrar quando não está sendo filtrado, mostra o 'child'
        // true mostra o 'elseChild'
        return !snapshot.hasData ? child : elseChild;
      },
    );
  }

  _onPressedConsultaExameCard(dynamic dynamicClass) async {
    _bloc.endMap();
    await Future.delayed(Duration(microseconds: 500));
    _bloc.showMiniCardDetalhe.add(false);

    Address addressToFilter;

    if (dynamicClass is Consulta) {
      addressToFilter = dynamicClass.address;
      screenAction(
          'clicou_medico_consulta', 'Clicou em um médico para marcar consulta',
          param: dynamicClass.toGA());
    } else {
      screenAction(
          'clicou_labororio_consulta', 'Clicou em um exame para marcar exame',
          param: dynamicClass.toGA());
    }

    push(NovaConsultaExameDatalhe(
      sendCordinates: true,
      consultaOuExame: dynamicClass,
      dataEscolhida: _bloc.getDataEscolhidaBase(returnAsString: false),
      consultaExameEscolhido: _bloc.getConsultaExameEscolhido(),
      addressToFilter: addressToFilter,
    )).then((_) {
      _bloc.startMap(_onTapMarker);
    });
  }

  _onClickLinhaListaFiltro(especialidadeOuLocalidade) {
    _bloc.filtrarEspecialidadeOuLocaldiade(especialidadeOuLocalidade);
    _especialidadeFn.unfocus();
    _localidadeFn.unfocus();
  }

  _onTapMarker(dynamic dynamicClass) {
    _bloc.openCardConsultaExameMarkerTapped(dynamicClass);
    _bloc.showMiniCardDetalhe.add(true);
  }

  _onClickMapaOuLista(TelaEscolhidaEnum v) {
    v == TelaEscolhidaEnum.mapa
        ? screenAction(
            'nova_consulta_toogle_mapa', 'Clicou no botão para mostrar o mapa')
        : screenAction('nova_consulta_toogle_lista',
            'Clicou  o botão para ver a lista de horários');

    _localidadeFn.unfocus();
    _especialidadeFn.unfocus();
    _bloc.filtrarEspecialidadeOuLocaldiade(null);
    _bloc.telaEscolhida.add(v);
  }

  _onClickConsultaOuExame(OpcaoEscolhida opcao) {
    _bloc.changeFiltroEscolhido(opcao);
    //lab muda aqui
    // _especialidadeController.text =
    //     opcao == OpcaoEscolhida.consulta ? kExpertiseBase : kLaboratoryBase;
  }

  _onClickDistanciaButtton() async {
    _bloc.filtroEscolhido.add(FiltroEscolhidoEnum.localicade);
  }

  _onClickEspecialidadesButton() async {
    _bloc.filtroEscolhido.add(FiltroEscolhidoEnum.especilidadeNome);
  }

  _onClickDiaCalendario(CalendarButton btn) async {
    _bloc.updateListCalendarioBase(btn);
    _bloc.consultaDenovo();
    screenAction('busca_por_dia',
        "Na tela de buscar por consulta, clicou para buscar uma consulta neste dia",
        param: await _bloc.toGA());
  }

  _onClickCalendarIcon() async {
    var date = await push(CalendarioConsultaPage(
      initBtn: _bloc.getDataEscolhidaBase(returnAsString: false),
    ));
    if (date != null) {
      _bloc.addDateFromCalendarPageBase(
          DateTime(date.year, date.month, date.day));
      _bloc.consultaDenovo();
    }
  }

  _onClickClosePage() {
    screenAction('nova_consulta_fechar', 'Na tela do agendamento clicou no X');
    pop();
  }

  _onClickProximaDataDisponivel() async {
    _bloc.proximaDataDisponivel().then((_) {
      List<CalendarButton> list = _bloc.listDiasCalendarioBase.value;

      list.asMap().forEach((i, btn) {
        if (btn.isSelected) {
          _scrollCalendarioController.animateTo(
              double.parse((i * 75).toString()),
              curve: Curves.linear,
              duration: Duration(milliseconds: 500));
        }
      });
    });

    screenAction(
      'proxima_data_disponivel',
      'Clicou em próxima data disponível',
      param: await _bloc.toGA(),
    );
  }

  _onChangedBuscaEspecialidade(String value) async {
    if (value != null && value != "") {
      _bloc.mostrarListaDeBusca.add(true);
    }

    if (value != kExpertiseBase) {
      screenAction(
        'busca_especialidade',
        'Foi filtrado uma nova especilidade em busca por uma consulta',
        param: await _bloc.toGA(),
      );
      _bloc.buscaEspecialidades(filtro: value);
    }
  }

  _onChangedBuscaLocalidade(String value) async {


    if (value != null && value != "") {
      _bloc.mostrarListaDeBusca.add(true);
    }
    if (value != kLocalidadeBase) {
      _bloc.buscaLocalidades(filtro: value);
    }
    screenAction(
      'busca_localidade',
      'Foi filtrado uma nova localidade em busca por uma consulta',
      param: await _bloc.toGA(),
    );
  }

  _onClickTipoConsulta(TipoConsulta tipoConsulta) {
    _bloc.changeTipoConsulta(tipoConsulta);
    _bloc.changeTipoConsulta(tipoConsulta);
  }

  _onClickAcessibilidade(bool acessibilidade) {
    print(" Acessibilidade >> $acessibilidade ");
    _bloc.changeAcessibilidade(acessibilidade);
  }

  _dialogOtherAddress(List<Address> list) {
    if (list.length == 1) {
      Address address = list.first;
      return alertConfirm(
        context,
        "O médico não atende nessa cidade, gostaria de atualizar sua pesquisa para a cidade de atendimento (${address.city}, ${address.state})?",
        callbackSim: () {
          _onClickChangeAddress(address);
        },
        callbackNao: () {
          pop();
        },
      );
    }

    Widget content = Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          AppText(
            "O médico não atende nessa cidade, gostaria de atualizar sua pesquisa para a cidade de atendimento? Se sim, selecione uma das cidades que o médico atende:",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.greyStrong,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, idx) {
                Address address = list[idx];
                return RawMaterialButton(
                  child: AppText(
                    "${address.address}, ${address.addressNumber} - ${address.city}, ${address.state}",
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    _onClickChangeAddress(address);
                  },
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlatButton(
                child: AppText("FECHAR", color: AppColors.blueExame),
                onPressed: () {
                  pop();
                },
              ),
            ],
          ),
        ],
      ),
    );

    showAppGeneralDialog(context, content, padding: EdgeInsets.all(50));
  }

  _onClickChangeAddress(Address address) {
    _onClickLinhaListaFiltro(City.fromAddress(address));

    pop();
  }

  _onClickBackPesquisa() {
    _especialidadeFn.unfocus();
    _localidadeFn.unfocus();
    _bloc.filtroEscolhido.add(null);
    _bloc.listFiltro.add(null);
    _bloc.mostrarListaDeBusca.add(null);
  }

  @override
  void dispose() {
    _bloc.dispose();
    _scrollController.dispose();
    _localidadeController.dispose();
    _especialidadeController.dispose();
    _localidadeFn.dispose();
    _especialidadeFn.dispose();
    _scrollCalendarioController.dispose();
    super.dispose();
  }
}
