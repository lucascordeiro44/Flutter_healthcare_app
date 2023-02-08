import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/councils.dart';
import 'package:flutter_dandelin/model/exam.dart';
import 'package:flutter_dandelin/model/unity.dart';
import 'package:flutter_dandelin/pages/chat2/websocket/web_socket.dart';
import 'package:flutter_dandelin/pages/chat2/app_bloc_chat.dart' as appBlocChat;
import 'package:flutter_dandelin/pages/consulta/consulta_exame_agendado_api.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_base.dart';
import 'package:flutter_dandelin/pages/perfil_medico/perfil_medico_page.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/pages/chat2/chat_page.dart';
import 'package:flutter_dandelin/pages/chat2/chat.dart' as chat;
import 'package:flutter_dandelin/pages/chat2/user_chat.dart' as userChat;
import 'package:flutter_dandelin/pages/chat2/chat_nova_conversa_bloc.dart';
import 'package:flutter_dandelin/pages/chat2/chat_conversas_bloc.dart';
import 'package:flutter_dandelin/model/user.dart';
import '../../native.dart';

class ConsultaExameAgendadoPage extends StatefulWidget {
  final dynamic consultaOuExame;
  final bool useZoom;

  const ConsultaExameAgendadoPage(
      {Key key, this.consultaOuExame, this.useZoom = false})
      : super(key: key);

  @override
  _ConsultaExameAgendadoPageState createState() =>
      _ConsultaExameAgendadoPageState();
}

class _ConsultaExameAgendadoPageState extends State<ConsultaExameAgendadoPage> with WidgetsBindingObserver {
  final _bloc = ConsultaExameAgendadoBloc();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _blocNovaConversa = ChatNovaConversaBloc();
  final _blocConversa = ChatConversasBloc();
  appBlocChat.AppBloc _appBlocChat = appBlocChat.AppBloc();

  bool get isConsulta => widget.consultaOuExame is Consulta;

  String get sConsultaExame => isConsulta ? 'consulta' : 'exame';

  static AppBloc get appBloc => AppBloc.get();
  User get dandelinUser => appBloc.user;

  String dataHorario;
  String endereco;
  String url;
  Widget image;

  String appBarText;
  String title = '';
  String subtitle = '';
  String avatar = '';
  String crm = '';
  String telefone;

  DateTime scheduleAt;
  bool isCovid;
  bool telemedicine = false;
  String telemedicineURL;
  userChat.User user;
  int badges;
  chat.Chat conversa;

  String zoomURL;
  int zoomMeetingId;
  String zoomUserId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _blocConversa.fetch();
    _userConnectWebSocket();

    Consulta c = widget.consultaOuExame;
    _bloc.fetch(c);
    if(c.scheduleDoctor.address.latLntOk){
      _bloc.startMap();
    } else {
      _bloc.endMap();
    }

    if (widget.consultaOuExame is Consulta) {
      screenView('Consulta_Agendado', "Tela Consulta_Agendado");
      Consulta consulta = widget.consultaOuExame;

      scheduleAt = stringToDateTimeWithMinutes(consulta.scheduleAt);
      dataHorario = _buildDataHorario(scheduleAt);
      appBarText = "Consulta agendada";

      isCovid = consulta.scheduleDoctor.doctor.covid19 ?? false;
      telemedicine = consulta.telemedicine ?? false;

      url = (widget.useZoom &&
              consulta.zoomMeetingId != null &&
              consulta.zoomUserId != null)
          ? "Videoconferência do Zoom"
          : consulta.telemedicineURL;

      endereco =
          telemedicine ? url : consulta.scheduleDoctor.address.getFullAddress;

      title = Consulta.getExpertises(consulta);
      subtitle = Consulta.getDoctorFullName(consulta);
      avatar = consulta.scheduleDoctor.doctor.user.avatar;

      image = AppCircleAvatar(
        avatar: consulta.scheduleDoctor.doctor.user.avatar,
        assetAvatarNull: 'assets/images/consulta-icone.png',
      );

      title = Consulta.getExpertises(consulta);

      subtitle = Consulta.getDoctorFullName(consulta);

      List<Council> councils = consulta.scheduleDoctor.doctor.councils;

      if(councils != null &&  councils.isNotEmpty){
        consulta.scheduleDoctor.doctor.councils.forEach((council) {
          crm = council.council + council.numberCouncil + "\n";
        });
        crm = crm.substring(0, crm.length - 2);
      }

      telefone = consulta.scheduleDoctor.address.telefone;
      telemedicineURL = consulta.telemedicineURL;

      zoomURL = consulta.zoomURL;
      zoomMeetingId = consulta.zoomMeetingId;
      zoomUserId = consulta.zoomUserId;
    } else {
      screenView('Exame_Agendado', "Tela Exame_Agendado");
      Exam exam = widget.consultaOuExame;

      scheduleAt = stringToDateTimeWithMinutes(exam.scheduledAt);
      dataHorario = _buildDataHorario(scheduleAt);

      appBarText = exam.scheduleExam.exam.title;

      image = AppCircleAvatar(
        avatar: null,
        assetAvatarNull: 'assets/images/cone-exame.png',
      );

      endereco = exam.scheduleExam.address.getFullAddress;

      title = "";
      subtitle = "";
      crm = "";
      telefone = "";
    }
  }

  _userConnectWebSocket() async {
    user = await userChat.User.getPrefs();
    _blocConversa.init(_appBlocChat, user);
    if (user != null) {
      print("webSocket.connect > ${user.id}");
      webSocket.connect("${user.id}");
      webSocket.listen();
      print("webSocket.login > ${user.login} - ${user.senha}");
      webSocket.login("${user.login}", "${user.senha}");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("daleeee ${MediaQuery.of(context).devicePixelRatio}");
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(155),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
          title: AppText(
            appBarText,
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          flexibleSpace: _header(),
        ),
      ),
      body: _body(),
      floatingActionButton: _fab(),
    );
  }

  // _fab() {
  //   Consulta consulta = widget.consultaOuExame;
  //
  //   return FloatingActionButton(
  //     backgroundColor: Theme.of(context).primaryColor,
  //     onPressed: () {
  //       _onClickChat(consulta);
  //     },
  //     child: StreamBuilder(
  //       stream: _bloc.badges.stream,
  //       builder: (context, snapshot) {
  //         if (!snapshot.hasData) {
  //           return Container(
  //             child: Progress(),
  //             margin: EdgeInsets.only(right: 16),
  //           );
  //         }
  //
  //         int total = snapshot.data;
  //
  //         Widget badge = Badge(
  //           badgeColor: Colors.redAccent,
  //           badgeContent: AppText(
  //             conversa.badge.mensagens.toString(),
  //             color: Colors.white,
  //             fontWeight: FontWeight.w600,
  //           ),
  //           child: Icon(Icons.chat),
  //         );
  //
  //         return IconButton(
  //           onPressed: () {
  //             _onClickChat(consulta);
  //           },
  //           icon: total == 0 ? Icon(Icons.chat) : badge,
  //         );
  //       },
  //     ),
  //   );
  // }

  _fab() {
    Consulta consulta = widget.consultaOuExame;

    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () {
        _onClickChat(consulta);
      },
      child: IconButton(
            onPressed: () {
              _onClickChat(consulta);
            },
            icon: Icon(Icons.chat),
          )

    );
  }

  _badges(){
    return  Badge(
      badgeColor: Colors.redAccent,
      badgeContent: AppText(
        conversa.badge.mensagens.toString(),
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      child: Icon(Icons.chat),
    );
  }

  _header() {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      height: double.maxFinite,
      decoration: isConsulta
          ? BoxDecoration(gradient: linearEnabled)
          : BoxDecoration(color: AppColors.blueExame),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                AppText(dataHorario,
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w500),
                AppText(
                  endereco ?? "",
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
          isConsulta
              ? SizedBox()
              : Container(
                  height: 75,
                  width: 75,
                  child: image,
                  margin: EdgeInsets.only(left: 3, bottom: 10)),
        ],
      ),
    );
  }

  _body() {
    return BaseContainer(
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              Consulta consulta = widget.consultaOuExame;
              _getConsulta(consulta);
              push(PerfilMedicoPage(consulta: consulta));
            } ,
            child: _datalhesContainer(),
          ),
          _mapa(),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _userConnectWebSocket();
    } else if(state == AppLifecycleState.paused) {
      webSocket.close();
    }
  }

  _getConsulta(Consulta consulta) {
    consulta.doctor = consulta.scheduleDoctor.doctor;
    consulta.doctor.id = consulta.scheduleDoctor.doctor.user.id;
  }

  _datalhesContainer() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            crossAxisAlignment: isConsulta
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: <Widget>[
              isConsulta
                  ? Column(
                      children: <Widget>[
                        // Platform.isIOS
                        //     ? isCovid ? CovidLabel() : SizedBox()
                        //     : SizedBox(),
                        Stack(
                          children: <Widget>[
                            Container(
                              height: 75,
                              width: 75,
                              child: image,
                            ),
                            telemedicine
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
                    )
                  : _preRequesitos(),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppText(
                      title,
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    AppText(
                      subtitle,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    AppText(
                      crm,
                      fontFamily: 'Mark Book',
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              telefone != null && telefone != ""
                  ? _listTileTelefone()
                  : Container(),
              Column(
                children: <Widget>[
                  _alterarButton(),
                  SizedBox(height: 5),
                  _abrirLink(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  _preRequesitos() {
    Exam exam = widget.consultaOuExame;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppText("PRE-REQUISITOS", fontWeight: FontWeight.w400),
        AppText(exam.scheduleExam.exam.preRequisites),
      ],
    );
  }

  _abrirLink() {
    return telemedicine
        ? Container(
            height: 30,
            child: FlatButton(
              onPressed: () {
                _onClickAbrirLinkConsulta();
              },
              color: AppColors.blueExame,
              child: AppText(
                  (useZoom && zoomUserId != null && zoomMeetingId != null)
                      ? 'Abrir Zoom'
                      : 'Abrir Link',
                  color: Colors.white),
              padding: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
            ),
          )
        : SizedBox();
  }

  _alterarButton() {
    return Container(
      height: 30,
      child: StreamBuilder(
        stream: _bloc.button.stream,
        builder: (context, AsyncSnapshot<ButtonState> snapshot) {
          bool onProgress = snapshot.hasData ? snapshot.data.progress : false;

          return FlatButton(
            onPressed: () {
              if (!onProgress) {
                _onClickAlterarConsuta();
              }
            },
            color: AppColors.blueExame,
            child: !onProgress
                ? AppText('Alterar', color: Colors.white)
                : Container(
                    height: 20,
                    width: 20,
                    child: Progress(isForButton: true),
                  ),
            padding: EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
          );
        },
      ),
    );
  }

  _mapa() {
    // return MapaPage(
    //   stream: _bloc.consultaOuEmame.stream,
    //   onTapMarker: (value) {},
    //   isDetalheConsultaOuExame: true,
    //   isConsultaMarcada: true,
    // );
    return StreamBuilder(
      stream: _bloc.mapStream.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data;
        } else {
          return Expanded(
            child: Center(
              child: Container(
                child: AppText("Não foi possível obter a localizaçâo.",),
              ),
            ),
          );
        }
      },
    );
  }

  _listTileTelefone() {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: () {
        _onClickTelefone(telefone);
      },
      child: Row(
        children: <Widget>[
          Image.asset(
            'assets/images/telefone-icon.png',
            height: 20,
            width: 20,
          ),
          SizedBox(width: 10),
          AppText(telefone),
        ],
      ),
    );
  }

  _onClickTelefone(String s) {
    callPhone(s);
  }

  _onClickAlterarConsuta() {
    if (isIOS(context)) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: Text("Alterar $sConsultaExame"),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text("Alterar dia ou horário $sConsultaExame"),
              onPressed: () {
                _onClickAlterarConsulta();
              },
            ),
            CupertinoActionSheetAction(
              child: Text("Cancelar $sConsultaExame"),
              onPressed: () {
                _onClickExcluirConsulta();
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text("Cancelar"),
            onPressed: () {
              pop();
            },
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text("Alterar dia ou horário $sConsultaExame"),
                onTap: () {
                  _onClickAlterarConsulta();
                },
              ),
              ListTile(
                title: Text("Cancelar $sConsultaExame"),
                onTap: () {
                  _onClickExcluirConsulta();
                },
              ),
              ListTile(
                title: Text("Cancelar"),
                onTap: () {
                  pop();
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  _onClickAlterarConsulta() async {
    screenAction(
        isConsulta ? 'alterar_consulta' : 'alterar_exame',
        isConsulta
            ? 'Na tela de detalhe já agendado, clicou em Alterar consulta'
            : 'Na tela de detalhe já agendado, clicou em Alterar exame',
        param: widget.consultaOuExame.toGA());
    _bloc.button.setProgress(true);

    pop();

    if (widget.consultaOuExame is Consulta) {
      ApiResponse<Consulta> response =
          await _bloc.getConsulta(widget.consultaOuExame);

      if (response.ok) {
        _bloc.endMap();

        await Future.delayed(Duration(microseconds: 500));

        push(
          NovaConsultaExameDatalhe(
            sendCordinates: false,
            consultaOuExame: response.result,
            consultaOuExameMarcado: widget.consultaOuExame,
            consultaExameEscolhido: OpcaoEscolhida.consulta,
            dataEscolhida:
                CalendarButton.dateTimeToCalendarButton(scheduleAt, null, true),
            addressToFilter: response.result.address,
          ),
        ).then((_) {
          _bloc.startMap();
        });
      } else {
        showSimpleDialog(response.msg);
      }
    } else {
      ApiResponse<Unity> response =
          await _bloc.getUnity(widget.consultaOuExame);

      if (response.ok) {
        _bloc.endMap();

        await Future.delayed(Duration(microseconds: 500));

        push(
          NovaConsultaExameDatalhe(
            sendCordinates: false,
            consultaOuExame: response.result,
            consultaOuExameMarcado: widget.consultaOuExame,
            consultaExameEscolhido: response.result is Consulta
                ? OpcaoEscolhida.consulta
                : OpcaoEscolhida.exame,
            dataEscolhida:
                CalendarButton.dateTimeToCalendarButton(scheduleAt, null, true),
            addressToFilter: response.result.address,
          ),
        ).then((_) {
          _bloc.startMap();
        });
      } else {
        showSimpleDialog(response.msg);
      }
    }
  }

  _onClickAbrirLinkConsulta() {
    if (useZoom && zoomUserId != null && zoomMeetingId != null) {
      String userName;
      if (user != null) userName = dandelinUser.getUserFullName;
      Native.callZoomActivity(
          userName, zoomUserId, zoomMeetingId, subtitle, title, avatar);
    } else {
      launch(telemedicineURL);
    }
  }

  _onClickExcluirConsulta() {
    screenAction(
        isConsulta ? 'cancelar_consulta' : 'cancelar_exame',
        isConsulta
            ? 'Na tela de detalhe já agendado, clicou em cancelar consulta'
            : 'Na tela de detalhe já agendado, clicou em cancelar exame',
        param: widget.consultaOuExame.toGA());
    pop();

    Widget declineButton = Container();
    Widget acceptButton = Container();

    if (isIOS(context)) {
      declineButton = CupertinoDialogAction(
        child: Text("Cancelar"),
        isDestructiveAction: true,
        onPressed: () {
          pop();
        },
      );

      acceptButton = CupertinoDialogAction(
        child: Text("Sim, cancelar"),
        onPressed: () {
          _onClickExcluir();
        },
      );
    } else {
      declineButton = FlatButton(
        child: Text("Cancelar"),
        onPressed: () {
          pop();
        },
      );

      acceptButton = FlatButton(
        child: Text("Sim, cancelar"),
        onPressed: () {
          _onClickExcluir();
        },
      );
    }

    showAlertDialog(
        context,
        "Dandelin",
        "Deseja mesmo cancelar ${isConsulta ? "esta" : "esse"} $sConsultaExame?",
        declineButton,
        acceptButton);
  }

  _onClickExcluir() async {
    pop();

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(seconds: 40),
      content: Container(
        height: 40,
        child: Row(
          children: <Widget>[
            Progress(),
            SizedBox(width: 15),
            AppText(
              'Cancelando $sConsultaExame..',
              color: Colors.white,
            ),
          ],
        ),
      ),
    ));

    ApiResponse response = isConsulta
        ? await ConsultaExameAgendadoApi.cancelarConsulta(
            widget.consultaOuExame)
        : await ConsultaExameAgendadoApi.cancelarExame(widget.consultaOuExame);

    response.ok ? pop() : showSimpleDialog(response.msg);
  }

  _buildDataHorario(DateTime dateTime) {
    return "${addZeroDate(dateTime.day)}/${getMesAbreviado(dateTime.month)} ${addZeroDate(dateTime.hour)}:${addZeroDate(dateTime.minute)}";
  }

  void _onClickChat(Consulta consulta) async {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Container(
        height: 40,
        child: Row(
          children: <Widget>[
            Progress(),
            SizedBox(width: 15),
            Text("Buscando a conversa.."),
          ],
        ),
      ),
    ));

    final conversa = await _blocNovaConversa.getconversa(widget.consultaOuExame.scheduleDoctor.doctor);
    final chat = await _blocNovaConversa.getChatNovaConversa(conversa.conversaId);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if(chat != null) {
      // _blocConversa.changeOpenedChat(chat);
      push(ChatPage(chat, consulta.scheduleDoctor.doctor.user.avatar, user, _blocConversa, fromConsultaAgendadoPage: true,));
    } else {
      showSimpleDialog("Não foi possível abrir a conversa.");
    }
    // push(ChatDetalhePage(medico: consulta.scheduleDoctor.doctor.user));
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
    webSocket.close();
    WidgetsBinding.instance.removeObserver(this);
  }
}
