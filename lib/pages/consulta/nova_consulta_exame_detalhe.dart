import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/address.dart';
import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/unity.dart';
import 'package:flutter_dandelin/pages/consulta/calendario_consuta_page.dart';
import 'package:flutter_dandelin/pages/chat/chat_detalhe_page.dart';
import 'package:flutter_dandelin/pages/consulta/linha_calendario.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_base.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_detalhe_bloc.dart';
import 'package:flutter_dandelin/pages/mapa/mapa.dart';
import 'package:flutter_dandelin/pages/pagamento/pagamento_page.dart';
import 'package:flutter_dandelin/pages/perfil_medico/perfil_medico_page.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/intent_utis.dart';
import 'package:flutter_dandelin/widgets/center_text.dart';
import 'package:flutter_dandelin/widgets/gradients.dart';
import 'package:flutter_dandelin/widgets/info_doctor_button.dart';

import 'package:flutter_dandelin/utils/dandelin_erros.dart';

class NovaConsultaExameDatalhe extends StatefulWidget {
  final dynamic consultaOuExame;
  final dynamic consultaOuExameMarcado;
  final CalendarButton dataEscolhida;
  final OpcaoEscolhida consultaExameEscolhido;
  final bool sendCordinates;
  final Address addressToFilter;

  const NovaConsultaExameDatalhe({
    Key key,
    @required this.consultaOuExame,
    @required this.dataEscolhida,
    @required this.consultaExameEscolhido,
    this.consultaOuExameMarcado,
    @required this.sendCordinates,
    @required this.addressToFilter,
  }) : super(key: key);

  @override
  _NovaConsultaExameDatalheState createState() =>
      _NovaConsultaExameDatalheState();
}

class _NovaConsultaExameDatalheState extends State<NovaConsultaExameDatalhe> {
  final _bloc = ConsultaExameDetalheBloc();

  var titleAppBar;

  String telefone;
  String endereco;

  num latitude;
  num longitude;

  final _scrollCalendarioController = ScrollController();

  get isConsulta => widget.consultaOuExame is Consulta;

  get mainColor => isConsulta ? AppColors.kPrimaryColor : AppColors.blueExame;

  var isCovidDoctor = false;
  var teleconferencia = false;

  @override
  void initState() {
    super.initState();

    screenView(
        'Nova_Consulta_Exame_Detalhe', "Tela Nova_Consulta_Exame_Detalhe");

    _bloc.fetch(
      widget.consultaExameEscolhido,
      widget.dataEscolhida,
      widget.consultaOuExame,
      widget.consultaOuExameMarcado,
    );

    if (isConsulta) {
      Consulta consulta = widget.consultaOuExame;
      titleAppBar = "Consulta Médica";
      isCovidDoctor = consulta.doctor.covid19 ?? false;
      teleconferencia = consulta.telemedicine ?? false;
    } else {
      Unity unity = widget.consultaOuExame;
      titleAppBar = unity.exam.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(titleAppBar),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        centerTitle: true,
        actions: [
          // _badges(),
        ],
      ),
      body: _body(),
    );
  }

  _badges() {
    return StreamBuilder(
      stream: _bloc.badges.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            child: Progress(),
            margin: EdgeInsets.only(right: 16),
          );
        }

        int total = snapshot.data;

        Widget badge = Badge(
          badgeColor: Theme.of(context).primaryColor,
          badgeContent: AppText(
            total.toString(),
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          child: Icon(Icons.chat_bubble_outline),
        );

        return IconButton(
          onPressed: () {
            push(ChatDetalhePage(medico: widget.consultaOuExame.doctor.user));
          },
          icon: total == 0 ? Icon(Icons.chat_bubble_outline) : badge,
        );
      },
    );
  }

  _body() {
    return BaseContainer(
      child: StreamBuilder(
        stream: _bloc.consultaExameStream.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            dynamic consultaExame = snapshot.data;

            if (isConsulta) {
              Consulta consulta = consultaExame;
              telefone = consulta.address.telefone;
              endereco = Consulta.getDoctorFullAddress(consulta,
                  fromScheduleDoctor: false);

              latitude = consulta.address.latitude;
              longitude = consulta.address.longitude;
            } else {
              Unity unity = consultaExame;

              telefone = unity.laboratory.phone;
              endereco = unity.address.getFullAddress;

              latitude = unity.address.latitude;
              longitude = unity.address.longitude;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                isConsulta
                    ? _headerConsulta(consultaExame)
                    : _headerExame(consultaExame),
                teleconferencia ? SizedBox() : _map(),
                _infoContainer(),
                SizedBox(height: 10),
                _horariosStream(),
                _agendarButton(),
              ],
            );
          } else {
            return Progress();
          }
        },
      ),
    );
  }

  _headerConsulta(Consulta consulta) {
    return RawMaterialButton(
      onPressed: _onClickPerfilMedico,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: linearEnabled),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppText(
                    Consulta.getExpertises(consulta, fromScheduleDoctor: false),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  AppText(
                    Consulta.getDoctorFullName(consulta,
                        fromScheduleDoctor: false),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  consulta.doctor.councils != null &&
                          consulta.doctor.councils.length > 0
                      ? AppText(
                          Consulta.getDoctorFullCrm(consulta,
                              fromScheduleDoctor: false),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16,
                        )
                      : Container(),
                ],
              ),
            ),
            Column(
              children: <Widget>[
                // Platform.isIOS
                //     ? consulta.doctor.showCovidLabel ? CovidLabel() : SizedBox()
                //     : SizedBox(),
                Stack(
                  children: <Widget>[
                    Container(
                      height: 70,
                      width: 70,
                      child: AppCircleAvatar(
                        avatar: consulta.doctor.user.avatar,
                        assetAvatarNull: 'assets/images/consulta-icone.png',
                      ),
                    ),
                    teleconferencia
                        ? Positioned(
                            bottom: 0,
                            left: 0,
                            child: Image.asset(
                              'assets/images/ic-videocoferencia-mini.png',
                              height: 25,
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _headerExame(Unity unity) {
    return Container(
      width: double.infinity,
      color: AppColors.blueExame,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppText("PRE-REQUISITOS",
              color: Colors.white, fontWeight: FontWeight.w400),
          AppText(unity.exam.preRequisites, color: Colors.white),
        ],
      ),
    );
  }

  _map() {
    return new Expanded(
      child: new MapaPage(
        onTapMarker: (value) {},
        stream: _bloc.consultaExameStream.stream,
        isDetalheConsultaOuExame: true,
      ),
    );
  }

  _infoContainer() {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          telefone != null && telefone != ""
              ? InfoDoctorButton(
                  icon: 'assets/images/telefone-icon.png',
                  legend: telefone,
                  onPressed: () {
                    _onClickTelefone(telefone);
                  },
                )
              : SizedBox(height: 5),
          teleconferencia
              ? SizedBox()
              : InfoDoctorButton(
                  icon: 'assets/images/mapa-icon.png',
                  legend: endereco,
                  onPressed: () {
                    _onClickMapa(latitude, longitude);
                  },
                ),
          SizedBox(height: 10),
          Divider(height: 0),
          _linhaCalendario(),
          Divider(height: 0),
        ],
      ),
    );
  }

  _linhaCalendario() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: LinhaCalendario(
        scrollController: _scrollCalendarioController,
        onClickDiaCalendario: _onClickDiaCalendario,
        consultaExameEscolhidoStream: _bloc.consultaExameEscolhidoBase,
        listDiasCalendarioStream: _bloc.listDiasCalendarioBase,
        onClickCalendarIcon: _onClickCalendarIcon,
        //isDetalhePage: true,
        needFocusChild: true,
      ),
    );
  }

  _horariosStream() {
    return StreamBuilder(
      stream: _bloc.listHorarios.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CenterText(snapshot.error);
        }

        if (!snapshot.hasData) {
          return _containerMinimo(Progress());
        }

        List<HorarioButton> list = snapshot.data;

        if (list.length == 0) {
          return _containerMinimo(
              Center(child: Text("Nenhum horário disponível.")));
        }

        return _wrapHorariosButton(list);
      },
    );
  }

  _wrapHorariosButton(List<HorarioButton> list) {
    List<Widget> pageViewChildren = List<Widget>();

    List<Widget> widgets = List<Widget>();

    int i = 0;
    for (final btn in list) {
      widgets.add(_horarioButton(btn));

      if (i == 8) {
        pageViewChildren.add(
          SingleChildScrollView(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              alignment: WrapAlignment.spaceEvenly,
              runAlignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 5,
              children: widgets,
            ),
          ),
        );
        widgets = List<Widget>();
        i = 0;
      } else {
        i++;
      }
    }

    if (widgets.length > 0) {
      do {
        widgets.add(Container(
          height: 30,
          width: 100,
        ));
      } while (widgets.length != 9);

      pageViewChildren.add(
        Wrap(
          runSpacing: 5,
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.start,
          alignment: WrapAlignment.spaceEvenly,
          runAlignment: WrapAlignment.center,
          children: widgets,
        ),
      );
    }

    return Expanded(
      child: Flex(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            flex: 6,
            child: PageView(
              onPageChanged: _bloc.idxDotsIndicator.add,
              children: pageViewChildren,
            ),
          ),
          list.length > 9
              ? StreamBuilder(
                  stream: _bloc.idxDotsIndicator.stream,
                  builder: (context, snapshot) {
                    int idx = snapshot.hasData ? snapshot.data : 0;
                    return Container(
                      height: 19,
                      child: DotsIndicator(
                        decorator: DotsDecorator(
                          activeColor: mainColor,
                          color: AppColors.greyFontLow,
                        ),
                        dotsCount: pageViewChildren.length,
                        position: double.parse(idx.toString()),
                      ),
                    );
                  },
                )
              : SizedBox(),
        ],
      ),
    );
  }

  _horarioButton(HorarioButton horarioBtn) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: horarioBtn.isSelected
                ? mainColor
                : AppColors.greyFontLow.withOpacity(0.5)),
        borderRadius: BorderRadius.all(
          Radius.circular(30.0),
        ),
      ),
      height: 30,
      width: 100,
      child: FlatButton(
        color: horarioBtn.isSelected ? mainColor : Colors.white,
        onPressed: () {
          _onClickButtonHorario(horarioBtn.id);
        },
        child: AppText(
          horarioBtn.horario,
          color: horarioBtn.isSelected ? Colors.white : null,
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      ),
    );
  }

  _agendarButton() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: SizeConfig.marginBottom, top: 5),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: AppButtonStream(
        stream: _bloc.button.stream,
        text: teleconferencia ? "AGENDAR CHAMADA DE VÍDEO" : "AGENDAR",
        onPressed: () {
          _onClickAgendar();
        },
      ),
    );
  }

  _containerMinimo(Widget child) {
    return Container(
      constraints: BoxConstraints(minHeight: SizeConfig.screenHeight * 0.15),
      child: child,
    );
  }

  _onClickAgendar() async {
    if (isConsulta) {
      screenAction(
        'agendar consulta',
        'Na tela de Consulta, selecionei um horário e cliquei em agendar',
        param: widget.consultaOuExame.toGA(),
      );
    } else {
      screenAction(
        'agendar exame',
        'Na tela de Exame, selecionei um horário e cliquei em agendar',
        param: widget.consultaOuExame.toGA(),
      );
    }

    _bloc.button.setProgress(true);
    ApiResponse response = await _bloc.agendar();

    _bloc.button.setProgress(false);

    if (response.ok) {
      // await showSimpleDialog(
         //  "Sua consulta foi agendada, aguarde a confirmação do médico.");

      // if (isCovidDoctor) {
      //   Prefs.setBool('home.mostrar_covidDicas', true);
      // }

      if (teleconferencia) {
        await showSimpleDialog("Sua consulta foi agendada com sucesso.");
      } else {
        await showSimpleDialog(
            "Sua consulta foi agendada, aguarde a confirmação do médico.");

        Prefs.setBool('home.mostrar_covidDicas', true);
      }

      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
      if (response.error != null) {
        DandelinError error = response.error;
        print(error);
        _showPaymentAlert(error);
      } else {
        showSimpleDialog(response.msg);
      }
    }
  }

  _onClickDiaCalendario(CalendarButton btn) {
    _bloc.updateListCalendarioBase(btn);
    _bloc.consultaDenovo(widget.sendCordinates, widget.addressToFilter);
  }

  _onClickButtonHorario(int id) {
    _bloc.updateButton(id);
  }

  _onClickTelefone(String telefone) async {
    callPhone(telefone);
  }

  _onClickMapa(num latitude, num longitude) {
    openMaps(latitude, longitude);
  }

  _onClickCalendarIcon() async {
    DateTime date = await push(CalendarioConsultaPage(
      initBtn: _bloc.getDataEscolhidaBase(returnAsString: false),
    ));
    _bloc
        .addDateFromCalendarPageBase(DateTime(date.year, date.month, date.day));
    _bloc.consultaDenovo(widget.sendCordinates, widget.addressToFilter);
  }

  /*_checkMeetHangouts() async {
    try {
      if (Platform.isIOS) {
        await alertConfirm(
          context,
          "A consulta por videoconferência será feita pelo o aplicativo Meet Hangouts. Indicamos você possuir este aplicativo instalado no seu celular. Deseja abrir a loja para efetuar a instalação?",
          callbackSim: _onClickAbrirLoja,
          callbackNao: _onClickCancelarVideo,
        );
      } else {}
    } catch (e) {
      await alertConfirm(
        context,
        "A consulta por videoconferência será feita pelo o aplicativo Meet Hangouts. Indicamos você possuir este aplicativo instalado no seu celular. Deseja abrir a loja para efetuar a instalação?",
        callbackSim: _onClickAbrirLoja,
        callbackNao: _onClickCancelarVideo,
      );
    }
  }

  _onClickCancelarVideo() {
    pop();
  }

  _onClickAbrirLoja() async {
    if (Platform.isIOS) {
      launch('https://apps.apple.com/br/app/hangouts/id643496868');

      pop();
    } else {
      if (await canLaunch(
          'https://play.google.com/store/apps/details?id=com.google.android.apps.meetings&hl=pt_BR')) {
        launch(
            'https://play.google.com/store/apps/details?id=com.google.android.apps.meetings&hl=pt_BR');

        pop();
      } else {
        print('eaita');
      }
    }
  } */

  void _onClickPerfilMedico() {
    push(PerfilMedicoPage(consulta: widget.consultaOuExame));
  }

  _showPaymentAlert(DandelinError error) {
    alertConfirm(
      context,
      error.msg,
      sim: "OK",
      nao: "TELA DE MÉTODO DE PAGAMENTOS",
      callbackSim: pop,
      callbackNao: () {
        pop();
        push(PagamentoPage());
      },
    );
  }

  @override
  void dispose() {
    _scrollCalendarioController.dispose();
    _bloc.dispose();
    super.dispose();
  }
}
