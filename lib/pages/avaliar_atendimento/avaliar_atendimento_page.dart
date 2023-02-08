import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/exam.dart';
import 'package:flutter_dandelin/pages/avaliar_atendimento/avaliar_atendimento_bloc.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_bar.dart';
import 'package:flutter_dandelin/widgets/app_layout_builder.dart';
import 'package:flutter_dandelin/widgets/app_rating_widget.dart';

class AvaliarAtendimentoPage extends StatefulWidget {
  final dynamic consultaOuExame;

  const AvaliarAtendimentoPage({Key key, @required this.consultaOuExame})
      : super(key: key);

  @override
  _AvaliarAtendimentoPageState createState() => _AvaliarAtendimentoPageState();
}

class _AvaliarAtendimentoPageState extends State<AvaliarAtendimentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _bloc = AvaliarAtendimentoBloc();

  get isConsulta => widget.consultaOuExame is Consulta;
  get _primaryColor =>
      isConsulta ? AppColors.kPrimaryColor : AppColors.blueExame;

  Widget avatar;
  String title;
  String nome;
  String crm;

  String data;
  String endereco;

  @override
  void initState() {
    super.initState();

    screenView('Rating', "Tela Rating");

    _bloc.fetch();

    if (isConsulta) {
      Consulta consulta = widget.consultaOuExame;
      avatar = AppCircleAvatar(
        avatar: consulta.scheduleDoctor.doctor.user.avatar,
        assetAvatarNull: 'assets/images/consulta-icone.png',
      );

      title = Consulta.getExpertises(consulta, fromScheduleDoctor: true);
      nome = Consulta.getDoctorFullName(consulta, fromScheduleDoctor: true);
      crm = Consulta.getDoctorFullCrm(consulta, fromScheduleDoctor: true);
      data = Consulta.getHorarioConsulta(consulta);
      endereco =
          Consulta.getDoctorFullAddress(consulta, fromScheduleDoctor: true);
    } else {
      Exam exam = widget.consultaOuExame;

      avatar = AppCircleAvatar(
        avatar: null,
        assetAvatarNull: 'assets/images/cone-exame.png',
      );

      title = exam.scheduleExam.exam.title;
      nome = exam.scheduleExam.laboratory.name;

      data = DateTimeHelper.getHorarioConsultaExame(exam.scheduledAt);
      endereco = exam.scheduleExam.address.getFullAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DandelinAppbar(
        'Avalie seu atendimento',
        automaticallyImplyLeading: false,
        actions: <Widget>[
          _actionsIcon(),
        ],
      ),
      body: _body(),
    );
  }

  _actionsIcon() {
    return IconButton(
      onPressed: _onClickClose,
      icon: Icon(
        Icons.close,
        color: _primaryColor,
      ),
    );
  }

  _body() {
    return AppLayoutBuilder(
      needSingleChildScrollView: true,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _headerFoto(),
          SizedBox(height: 5),
          _infosAtendimentos(),
          SizedBox(height: 5),
          Divider(height: 0),
          SizedBox(height: 15),
          _starsRating(),
          SizedBox(height: 15),
          _inputComentario(),
          _buttonEnviar(),
        ],
      ),
    );
  }

  _headerFoto() {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                  color: isConsulta
                      ? Color.fromRGBO(243, 175, 3, 1)
                      : AppColors.blueExame,
                  height: 80),
              Container(color: Colors.transparent, height: 60),
            ],
          ),
          _foto()
        ],
      ),
    );
  }

  _foto() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: avatar,
    );
  }

  _infosAtendimentos() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          AppText(
            title,
            textAlign: TextAlign.center,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: _primaryColor,
          ),
          SizedBox(height: 5),
          AppText(
            nome,
            textAlign: TextAlign.center,
            fontSize: 18,
            color: AppColors.greyStrong,
            fontWeight: FontWeight.w400,
          ),
          SizedBox(height: 5),
          crm != null
              ? AppText(
                  crm,
                  textAlign: TextAlign.center,
                  fontSize: 16,
                  color: AppColors.greyStrong,
                  fontWeight: FontWeight.w400,
                )
              : SizedBox(),
          SizedBox(height: 5),
          AppText(
            data,
            textAlign: TextAlign.center,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: _primaryColor,
          ),
          SizedBox(height: 5),
          AppText(
            endereco,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  _starsRating() {
    return AppRatingStream(
      stream: _bloc.starsRating.stream,
      onPressed: _onPressedRatingStars,
    );
  }

  _inputComentario() {
    return Form(
      key: _formKey,
      child: StreamBuilder(
        stream: _bloc.showInput.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data) {
            return Expanded(child: Container());
          }

          return Expanded(
            child: Container(
              color: Color.fromRGBO(235, 235, 235, 1),
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.only(right: 10, left: 10, bottom: 10),
              child: AppFormField(
                hintText: 'Deixe um comentário',
                maxLines: 6,
                showFocusRisk: false,
                showErrorBorder: false,
                showUnfocusRisk: false,
                onChanged: _bloc.comment.add,
                validator: (String value) {
                  if (value == null || value == "") {
                    return "Campo obrigatório";
                  }
                  return null;
                },
              ),
            ),
          );
        },
      ),
    );
  }

  _onPressedRatingStars(int idx) {
    _bloc.changeRating(idx);
  }

  _buttonEnviar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: AppButtonStream(
        text: "ENVIAR",
        stream: _bloc.button.stream,
        onPressed: _onClickEnviarButton,
      ),
    );
  }

  _onClickEnviarButton() async {
    if (_formKey.currentState.validate()) {
      if (isConsulta) {
        ApiResponse response = await _bloc.sendRating(
          idConsulta: widget.consultaOuExame.id,
          idRating: widget.consultaOuExame.rating?.id,
        );

        response.ok
            ? pop(result: response.result)
            : showSimpleDialog(response.msg);
      } else {
        pop();
      }
    }
  }

  _onClickClose() {
    if (isConsulta) {
      _bloc.sendRating(idConsulta: widget.consultaOuExame.id);
    }

    pop();
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }
}
