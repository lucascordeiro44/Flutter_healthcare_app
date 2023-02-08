import 'package:flutter/material.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/exam.dart';
import 'package:flutter_dandelin/model/rating.dart';
import 'package:flutter_dandelin/pages/avaliar_atendimento/avaliar_atendimento_page.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_base.dart';
import 'package:flutter_dandelin/pages/historico/historico_detalhe_bloc.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/size_config.dart';
import 'package:flutter_dandelin/widgets/app_rating_widget.dart';
import 'package:flutter_dandelin/widgets/base_container.dart';
import 'package:flutter_dandelin/widgets/container_background_button.dart';
import 'package:flutter_dandelin/widgets/gradients.dart';
import 'package:flutter_dandelin/widgets/info_doctor_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HistoricoDetalhePage extends StatefulWidget {
  final dynamic consultaOuExame;

  const HistoricoDetalhePage({Key key, this.consultaOuExame}) : super(key: key);

  @override
  _HistoricoDetalhePageState createState() => _HistoricoDetalhePageState();
}

class _HistoricoDetalhePageState extends State<HistoricoDetalhePage> {
  final GlobalKey _stackKey = GlobalObjectKey('stack_historico');

  final _bloc = HistoricoDetalheBloc();

  String title;
  Widget foto;
  String nome;
  String crm;
  String telefone;
  String endereco;
  LatLng latLng;
  bool isAtendido = false;
  bool ratingDone;

  get isConsulta => widget.consultaOuExame is Consulta;

  @override
  void initState() {
    super.initState();

    _bloc.startMap();
    _bloc.fetch(widget.consultaOuExame);

    if (isConsulta) {
      screenView(
          "Historico_Consulta_Detalhe", "Tela Historico_Consulta_Detalhe");
      Consulta consulta = widget.consultaOuExame;

      title = Consulta.getExpertises(consulta);

      foto = AppCircleAvatar(
        avatar: consulta.scheduleDoctor.doctor.user.avatar,
        assetAvatarNull: 'assets/images/consulta-icone.png',
      );

      nome = Consulta.getDoctorFullName(consulta);
      crm = Consulta.getDoctorFullCrm(consulta);
      telefone = consulta.scheduleDoctor.doctor.user.mobilePhone;
      endereco = Consulta.getDoctorFullAddress(consulta);
      latLng = Consulta.getDoctorLatLng(consulta);
      isAtendido = consulta.isAtendido;
      ratingDone = consulta.ratingDone;
    } else {
      screenView("Historico_Exame_Detalhe", "Tela Historico_Exame_Detalhe");
      Exam exam = widget.consultaOuExame;

      title = exam.scheduleExam.exam.title;

      foto = AppCircleAvatar(
        avatar: null,
        assetAvatarNull: 'assets/images/cone-exame.png',
      );

      nome = exam.scheduleExam.laboratory.name;
      endereco = exam.scheduleExam.address.getFullAddress;
      latLng = exam.scheduleExam.address.getLatLng;
      telefone = exam.scheduleExam.laboratory.phone;
      isAtendido = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _bloc.consultaExame.add(widget.consultaOuExame);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        backgroundColor: Colors.white,
        elevation: 0,
        title: AppText(title),
        centerTitle: true,
      ),
      body: _body(),
    );
  }

  _body() {
    return Stack(
      key: _stackKey,
      children: [
        BaseContainer(
          child: Column(
            children: <Widget>[
              _appHeader(),
              _map(),
            ],
          ),
        ),
        _infoCard(),
        ContainerBackground(height: SizeConfig.heightContainer),
        _agendarButton(),
      ],
    );
  }

  _appHeader() {
    return Container(
      width: SizeConfig.screenWidth,
      padding: EdgeInsets.all(18),
      decoration: isConsulta
          ? BoxDecoration(gradient: linearEnabled)
          : BoxDecoration(color: AppColors.blueExame),
      child: Column(
        children: <Widget>[
          Container(height: 100, width: 100, child: foto),
          SizedBox(height: 5),
          AppText(
            nome,
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
          ),
          crm != null && crm != ""
              ? AppText(
                  crm,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                )
              : SizedBox(),
        ],
      ),
    );
  }

  _map() {
    return StreamBuilder(
      stream: _bloc.mapStream.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data;
        } else {
          return Container(
            child: Progress(),
          );
        }
      },
    );
  }

  _infoCard() {
    return Positioned(
      bottom: 0,
      child: Container(
        width: SizeConfig.screenWidth,
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
            color: Colors.white,
          ),
          width: SizeConfig.screenWidth * 0.75,
          padding: EdgeInsets.only(bottom: 60),
          child: Column(
            children: <Widget>[
              isNotEmpty(telefone)
                  ? InfoDoctorButton(
                      icon: 'assets/images/telefone-icon.png',
                      legend: telefone,
                      onPressed: () {
                        _onClickTelefone(telefone);
                      },
                    )
                  : SizedBox(),
              Divider(height: 10, color: Colors.grey),
              InfoDoctorButton(
                icon: 'assets/images/mapa-icon.png',
                legend: endereco,
                onPressed: () {
                  _onClickMapa(latLng.latitude, latLng.longitude);
                },
              ),
              isAtendido && ratingDone
                  ? Divider(height: 12, color: Colors.grey)
                  : SizedBox(),
              isAtendido && ratingDone
                  ? AppText(
                      isConsulta && widget.consultaOuExame.ratingDone
                          ? 'Avalie sua consulta'
                          : "Consulta avaliada",
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    )
                  : SizedBox(height: 10),
              isAtendido && ratingDone ? _rating() : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  _agendarButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: SizeConfig.marginBottom),
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: AppButtonStream(
          stream: _bloc.button.stream,
          onPressed: () {
            _onClickAgendarRetorno();
          },
          text: "AGENDAR RETORNO",
        ),
      ),
    );
  }

  _rating() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.marginBottom + 10, top: 5),
      child: AppRatingStream(
        stream: _bloc.starsRating.stream,
        onPressed: _onPressedStars,
        estrelaVazia: 'assets/images/estrela-vazia-historico.png',
      ),
    );
  }

  _onClickAgendarRetorno() async {
    screenAction('agendar_retorno',
        'No detalhes do agendamento, clicou em Agendar Retorno',
        param: widget.consultaOuExame.toGA());

    ApiResponse<dynamic> response = await _bloc.getConsultaOuExame();

    if (!response.ok) {
      showSimpleDialog(response.msg);
    }

    _bloc.endMap();
    await Future.delayed(Duration(microseconds: 500));
    await push(
      NovaConsultaExameDatalhe(
        sendCordinates: false,
        consultaOuExame: response.result,
        dataEscolhida: _bloc.dataProximaConsulta.value,
        consultaExameEscolhido: response.result is Consulta
            ? OpcaoEscolhida.consulta
            : OpcaoEscolhida.exame,
        addressToFilter: response.result.address,
      ),
    );
    _bloc.startMap();
  }

  _onClickTelefone(String s) {
    callPhone(s);
  }

  _onClickMapa(num latitude, num longitude) {
    openMaps(latitude, longitude);
  }

  _onPressedStars(int idx) async {
    if (!isConsulta) {
      return;
    }
    Consulta consulta = widget.consultaOuExame;

    Rating rating =
        await push(AvaliarAtendimentoPage(consultaOuExame: consulta));

    if (rating == null) {
      return;
    }

    _bloc.changeStars(rating.rating - 1);
    await showSimpleDialog('Obrigado pelo o seu feedback!');
    pop(result: true);
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
