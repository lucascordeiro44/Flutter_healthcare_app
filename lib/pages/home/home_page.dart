import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/pages/avaliar_atendimento/avaliar_atendimento_page.dart';
import 'package:flutter_dandelin/pages/chat/chat_bloc.dart';

import 'package:flutter_dandelin/pages/chat2/chat_conversas_page.dart';
import 'package:flutter_dandelin/pages/home/home_card.dart';
import 'package:flutter_dandelin/pages/pagamento/pagamento_page.dart';
import 'package:flutter_dandelin/pages/chat2/websocket/web_socket.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/scroll.dart';
import 'package:flutter_dandelin/widgets/center_text.dart';
import 'package:flutter_dandelin/widgets/tutorial_covid.dart';
import 'package:flutter_dandelin/widgets/tutorial_dicas_covid.dart';
import 'package:flutter_dandelin/widgets/tutorial_videocoferencia.dart';
import '../../utils/imports.dart';
// TODO - Teste Zoom
final bool useZoom = true;



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AfterLayoutMixin<HomePage>, WidgetsBindingObserver {
  static AppBloc get appBloc => AppBloc.get();
  User get user => appBloc.user;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _bloc = HomeBloc();
  final _chatBloc = ChatBloc();

  final _scrollController = ScrollController();

  //static final _precoKey = new GlobalObjectKey("preco");
  static final _personKey = new GlobalObjectKey("person_icon");
  static final _inboxKey = new GlobalObjectKey("inbox_icon");
  static final _agendarKey = new GlobalObjectKey("agendar_button");

  bool needKeys = true;

  @override
  void initState() {
    super.initState();
    screenView("Home", "Tela Home");
    _bloc.fetch();
    _fetchConsultaToRating();
    addScrollListener(_scrollController, _bloc.fetchMore);
    WidgetsBinding.instance.addObserver(this);
  }

  _fetchConsultaToRating() async {
    List<dynamic> list = await _bloc.getConsultasExamesToRating();

    if (list.length > 0) {
      list.forEach((consultaOuExame) async {
        if (consultaOuExame is Consulta) {
          await _openRatingPage(consultaOuExame);
        }
      });
    }

    _chatBloc.fetchTotalBadges();
  }


  @override
  void afterFirstLayout(BuildContext context) async {
    await _initTutorial();
    // if (Platform.isIOS) {
    //   await _initCovidTutorial();
    // }

    await _tutorialDicasCovid();
    await _tutorialVideoconferencia();
    await _dialogDependentsAproval();
    await _dialogDependentRemoved();
    await _listenDoctorChangedSchedules();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      body: _body(context),
      endDrawer: PerfilPage(),
    );
  }

  _body(BuildContext context) {
    return BaseContainer(
      imageBackGround: 'assets/images/sombra.png',
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              _headerContainer(),
              _streamAgendamentos(),
              Divider(height: 0, color: AppColors.greyFont),
              Container(
                height: SizeConfig.heightContainer,
                color: Colors.white,
              ),
            ],
          ),
          _buttonAgendar(),
        ],
      ),
    );
  }


  // HEADER ##########################

  _headerContainer() {
    return AppHeader(
      image: 'assets/images/home-background.png',
      elevation: 1,
      padding: EdgeInsets.only(right: 16, top: 16, left: 16, bottom: 0),
      height: 210,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _rowIcons(),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 10, 0, 0),
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/images/logo-dandelin-home.png',
                  width: 260,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _rowIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              //necessario para a bolinha da notificação fica correto
              height: 60,
              width: 60,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(right: 1),
              child: _iconHeader(
                'assets/images/inbox-icon.png',
                key: needKeys ? _inboxKey : null,
                function: _onClickNotificacao,
              ),
            ),
            _textNotification()
          ],
        ),
        Container(
          key: needKeys ? _personKey : null,
          child: MaterialOnTap(
            onTap: _onClickPerfil,
            child: Container(
              height: 50,
              width: 50,
              child: StreamBuilder(
                stream: appBloc.stream,
                builder: (context, snapshot) {
                  User u = snapshot.data?.user;

                  return u != null
                      ? AppCircleAvatar(avatar: u.avatar)
                      : SizedBox();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  _iconHeader(String caminho, {Function function, Key key}) {
    return Container(
      key: key,
      height: 50,
      width: 50,
      child: RawMaterialButton(
        padding: EdgeInsets.all(0),
        child: Image.asset(caminho),
        onPressed: function,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.resumed) {
      _onRefreshBadges();
    } else if (state == AppLifecycleState.paused) {
      _onRefreshBadges();
    }
  }

  _textNotification() {
    return StreamBuilder(
        stream: _chatBloc.badges.stream,
        builder: (context, snapshot) {
          var badges = 0;

          if (snapshot.hasData) {
            badges = snapshot.data as int;
          }

          if (snapshot.hasError) {
            return CenterText(snapshot.error);
          }

          if (!snapshot.hasData) {
            return Container(
                height: 20,
                width: 20,
                child: Progress());
          }

          if (badges == 0) {
            return SizedBox();
          }

          return Positioned(
            right: 2,
            top: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7.85),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(50),
              ),
              child: AppText(
                "$badges",
                color: Colors.white,
                fontFamily: Theme.of(context).platform == TargetPlatform.iOS
                    ? 'San Francisco'
                    : 'Roboto',
              ),
            ),
          );
        });
  }

  //SAIU NA NOVA MECANICA
  // _textMesPagamento() {
  //   return AppText(
  //       "Seu pagamento de ${DateFormat.MMMM().format(new DateTime.now())}",
  //       color: Colors.white,
  //       fontWeight: FontWeight.w700,
  //       fontSize: 16,
  //       textAlign: TextAlign.center);
  // }

  // _textValor() {
  //   return StreamBuilder<Object>(
  //     stream: _bloc.priceCommunity.stream,
  //     builder: (context, snapshot) {
  //       if (snapshot.hasError) {
  //         return CenterText(snapshot.error);
  //       }

  //       if (!snapshot.hasData) {
  //         return Container(height: 60, child: Progress(isForButton: true));
  //       }

  //       PriceCommunity priceCommunity = snapshot.data;

  //       return GestureDetector(
  //         onTap: () async {
  //           print(await AppAvailability.checkAvailability(
  //               "com.google.meetings://"));
  //         },
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             AppText(
  //               "R\$ ",
  //               fontSize: 30,
  //               color: Colors.white,
  //               fontFamily: 'Mark Book',
  //             ),
  //             AppText(
  //               priceCommunity.priceMobile.toString(),
  //               fontSize: 50,
  //               color: Colors.white,
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // END HEADER ##########################


  _streamAgendamentos() {
    return Expanded(
      child: StreamBuilder(
        stream: _bloc.consultasExames.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return CenterText(snapshot.error);
          }

          if (!snapshot.hasData) {
            return Progress();
          }

          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              _bloc.consultasExames.add(null);
              _bloc.endApiResults = false;
              _onRefresh();
              _bloc.fetchConsultasExames();
            },
            child: snapshot.data.length > 0
                ? Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: _listAgendamentos(snapshot.data))
                : _semAgendamentos(),
          );
        },
      ),
    );
  }

  _semAgendamentos() {
    return SingleChildScrollView(
      child: Container(
        height: SizeConfig.screenHeight - 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/sem-agendamentos.png', height: 200),
            SizedBox(height: 20),
            AppText(
              "Você não tem agendamentos. \nAgende agora!",
              textAlign: TextAlign.center,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  _listAgendamentos(List<dynamic> data) {
    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      itemCount: data.length + 1,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 13, right: 16, left: 16, bottom: 40),
      itemBuilder: (context, idx) {
        if (data.length == idx) {
          return _streamLoading();
        }

        Consulta consulta = data[idx];

        return HomeCard(
          consultaOuExame: consulta,
          onPressed: _onClickCardAgendado,
          useZoom: useZoom,
        );
      },
      separatorBuilder: (_, i) {
        return SizedBox(height: 10);
      },
    );
  }

  _streamLoading() {
    return StreamBuilder(
      stream: _bloc.loading.stream,
      builder: (context, snapshot) {
        bool v = snapshot.hasData ? snapshot.data : false;

        return v
            ? Container(
                child: Progress(),
                height: 30,
              )
            : SizedBox();
      },
    );
  }

  _buttonAgendar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      margin: EdgeInsets.only(bottom: SizeConfig.marginBottom),
      alignment: Alignment.bottomCenter,
      child: AppButtonStream(
        widgetKey: needKeys ? _agendarKey : null,
        onPressed: _onClickNovoAgendamento,
        text: "NOVO AGENDAMENTO",
      ),
    );
  }

  _onClickCardAgendado(dynamic consultaOuExame) async {
    _onRefresh();
    await push(ConsultaExameAgendadoPage(
      consultaOuExame: consultaOuExame,
      useZoom: useZoom,
    ));
    _bloc.fetchConsultasExames(setNull: true);
  }

  _onClickPerfil() {
    // setState(() {
    //   iconDark();
    // });
    // pushApp(context, PerfilPage(), PageTransitionType.rightToLeft);
    _onRefresh();
    screenAction('foto_perfil', "Clicou na foto do perfil");
    _scaffoldKey.currentState.openEndDrawer();
  }

  _onRefresh() {
    _chatBloc.fetchTotalBadges();
    _bloc.fetch();
  }

  _onRefreshBadges() {
    _chatBloc.fetchTotalBadges();
    _bloc.fetch();
  }

  _onClickNotificacao() async {
    // pushApp(ChatPage(), PageTransitionType.leftToRight).then((_) => _onRefresh());
    push(ChatConversasPage()).then((_) => _onRefresh());
  }

  _onClickNovoAgendamento() {
    // setState(() {
    //   iconDark();
    // });
    _onRefresh();
    screenAction('novo_agendamento', 'Na home, cliquei no Novo Agendamento');
    pushApp(ConsultaExamePage(), PageTransitionType.bottomToTop);
  }

  _openRatingPage(dynamic consultaOuExame) async {
    var rating =
        await push(AvaliarAtendimentoPage(consultaOuExame: consultaOuExame));
    if (rating != null) {
      await showSimpleDialog("Obrigado pelo o seu feedback!");
    }
  }

  //##############   TUTORIAL

  _initTutorial() async {
    bool done = await Prefs.getBool('tutorial_done');

    if (!done) {
      Tutorial _tutorial = Tutorial();

      if (user.hasCompany) {
        await _tutorial.tutorialPass2(_personKey, () async {
          await _tutorial.tutorialPass4(_agendarKey);
        });
      } else {
        await _tutorial.tutorialPass4(_agendarKey, title: "TUTORIAL");
      }

      Prefs.setBool('tutorial_done', true);
    } else {
      setState(() {
        needKeys = false;
      });
    }
  }

  _initCovidTutorial() async {
    bool value = await Prefs.getBool('home.covid_tutorialDone');

    if (value == null || !value) {
      Prefs.setBool('home.covid_tutorialDone', true);
      await showAppGeneralDialog(
        context,
        TutorialCovid(),
      );
    }
  }

  _tutorialDicasCovid() async {
    bool value = await Prefs.getBool('home.mostrar_covidDicas');

    if (value != null && value) {
      Prefs.setBool('home.mostrar_covidDicas', false);
      await showAppGeneralDialog(
        context,
        TutorialDicasCovid(),
      );
    }
  }

  _tutorialVideoconferencia() async {
    bool value = await Prefs.getBool(Platform.isIOS
        ? 'home.telemedicine_tutorialDone.ios'
        : 'home.telemedicine_tutorialDone');

    if (value == null || !value) {
      Prefs.setBool(
          Platform.isIOS
              ? 'home.telemedicine_tutorialDone.ios'
              : 'home.telemedicine_tutorialDone',
          true);
      await showAppGeneralDialog(context, TutorialVideoconferencia());
    }
  }

  _dialogDependentsAproval() async {
    if (user.approval != null && !user.approval) {
      bool aceitar;
      await alertConfirm(
        context,
        "Você foi incluso como dependente de ${user.parent.name}. Não haverão débitos no seu método de pagamento incluso previamente.",
        callbackNao: () {
          aceitar = false;
          user.status = null;
          user.parent = null;
          appBloc.setUser(user);
          pop();
        },
        callbackSim: () {
          aceitar = true;
          pop();
        },
        nao: "NÃO ACEITAR",
        sim: "ACEITAR",
        barrierDismissible: false,
      );

      if (aceitar != null) {
        loadingDialog(context);
        ApiResponse response = await _bloc.depedentsApproval(aceitar);
        pop();
        await showSimpleDialog(response.ok ? response.result : response.msg);
      }

      if (!aceitar && !idadeMaior16(user.dataCleanUser())) {
        push(LoginPage(), popAll: true);
      }
    }
  }

  _dialogDependentRemoved() async {
    if (user.dependenteRemovido) {
      await alertConfirm(
        context,
        "Você foi removido como dependente de ${user.parent.name}, deseja cadastrar um novo método de pagamento?",
        callbackSim: () {
          pop();
          push(PagamentoPage());
        },
        callbackNao: () {
          pop();
        },
      );
    }
  }

  _listenDoctorChangedSchedules() {
    _bloc.consultasExames.listen((consultas) async {
      if (consultas == null) {
        return;
      }

      List list =
          consultas.where((c) => c.doctorChangedSchedule == true).toList();

      if (list.isEmpty) {
        return;
      }

      await Future.forEach(list, (element) async {
        await _dialogScheduleChanged(element);
      });

      _bloc.fetchConsultasExames(setNull: true);
    });
  }

  Future _dialogScheduleChanged(Consulta consulta) async {
    DateTime dateTime = stringToDateTimeWithMinutes(consulta.scheduleAt);

    bool isMale = consulta.scheduleDoctor.doctor.user.isMale;

    String data =
        "${addZeroDate(dateTime.day)}/${addZeroDate(dateTime.month)}/${addZeroDate(dateTime.year)} as ${addZeroDate(dateTime.hour)}:${addZeroDate(dateTime.minute)}";

    return await alertConfirm(
      context,
      "Sua consulta com ${isMale ? "o" : "a"} ${isMale ? "doutor" : "doutora"} ${consulta.scheduleDoctor.doctor.user.getUserFullName} (${Consulta.getExpertises(consulta, fromScheduleDoctor: true)}) foi alterada para o dia $data. Deseja confirmar alteração?",
      callbackSim: () async {
        await _onClickAproveScheduleChanges(consulta, true);
      },
      callbackNao: () async {
        await _onClickAproveScheduleChanges(consulta, false);
      },
      barrierDismissible: false,
      sim: "SIM",
      nao: "NÃO",
    );
  }

  _onClickAproveScheduleChanges(Consulta consulta, bool value) async {
    loadingDialog(context);
    await _bloc.aproveScheduleChanges(consulta, value);
    pop();
    pop();
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
