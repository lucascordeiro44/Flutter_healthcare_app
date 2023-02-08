import 'package:flutter/material.dart';
import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/exam.dart';
import 'package:flutter_dandelin/pages/consulta/widgets/covid_label.dart';
import 'package:flutter_dandelin/pages/perfil_medico/perfil_medico_page.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/material_container.dart';

import '../../colors.dart';

class HomeCard extends StatefulWidget {
  final dynamic consultaOuExame;
  final bool useZoom;
  final Function(dynamic consultaOuExame) onPressed;

  const HomeCard({
    Key key,
    @required this.onPressed,
    @required this.consultaOuExame,
    this.useZoom = false,
  }) : super(key: key);

  @override
  _HomeCardState createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  Color color;
  String dataHorario;
  String diaSemana;

  String nomeDoutor;
  String endereco;
  String url;
  Widget image;

  bool showCovidLabel = false;
  bool showTelemedicineLabel = false;
  bool naoAtendida = false;
  bool naoConfirmado = false;

  @override
  void initState() {
    super.initState();

    if (widget.consultaOuExame is Consulta) {
      Consulta consulta = widget.consultaOuExame;
      color = Color.fromRGBO(255, 174, 0, 1);

      DateTime dateTime = stringToDateTimeWithMinutes(consulta.scheduleAt);
      dataHorario = _buildDataHorario(dateTime);
      diaSemana = getDiaSemana(dateTime.weekday);
      nomeDoutor = Consulta.getDoctorFullName(consulta);

      showTelemedicineLabel = consulta.telemedicine ?? false;

      url = (widget.useZoom && consulta.zoomMeetingId != null && consulta.zoomUserId != null)
          ? "Videoconferência do Zoom"
          : consulta.telemedicineURL;

      endereco = showTelemedicineLabel
          ? url
          : consulta.scheduleDoctor.address.getHomeAdress;

      image = AppCircleAvatar(
        avatar: consulta.scheduleDoctor.doctor.user.avatar,
        assetAvatarNull: 'assets/images/consulta-icone.png',
      );

      showCovidLabel = consulta.scheduleDoctor.doctor.showCovidLabel ?? false;

      naoAtendida = consulta.naoAtendido;
      naoConfirmado = consulta.naoConfirmado;
    } else {
      Exam exam = widget.consultaOuExame;
      color = AppColors.blueExame;

      DateTime dateTime = stringToDateTimeWithMinutes(exam.scheduledAt);
      dataHorario = _buildDataHorario(dateTime);
      diaSemana = getDiaSemana(dateTime.weekday);

      nomeDoutor = exam.scheduleExam.exam.title;
      endereco = exam.scheduleExam.address.getHomeAdress;

      image = AppCircleAvatar(
        avatar: null,
        assetAvatarNull: 'assets/images/cone-exame.png',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StackMaterialContainer(
      onTap: () {
        widget.onPressed(widget.consultaOuExame);
      },
      child: Card(
        margin: EdgeInsets.only(top: 0, left: 0, right: 0),
        child: Container(
          padding: EdgeInsets.all(5),
          child: Row(
            children: <Widget>[
              _dados(),
              SizedBox(width: 5),
              _image(),
            ],
          ),
        ),
      ),
    );
  }

  _dados() {

    return Expanded(
      child: Container(
        padding: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(width: 2.5, color: color),
          ),
        ),
        child: Container(
          margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _status(),
              SizedBox(height: 2),
              RichText(
                text: TextSpan(
                    style: TextStyle(
                        color: color,
                        fontFamily: 'Mark',
                        fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: dataHorario,
                        style: TextStyle(fontSize: 15),
                      ),
                      TextSpan(
                        text: " ($diaSemana)",
                        style: TextStyle(fontSize: 13),
                      ),
                    ]),
              ),
              SizedBox(height: 2),
              AppText(
                nomeDoutor,
                fontSize: 13,
                color: AppColors.greyStrong,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 2),
              AppText(
                endereco ?? "",
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.greyFontLow,
                maxLines: 3,
                textOverflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      ),
    );
  }

  AppText _status() {
    String text;

    Color color;

    if (showTelemedicineLabel) {
      color = AppColors.blueExame;
      text = "Teleconsulta agendada";
    } else if (naoConfirmado) {
      color = AppColors.redWine;
      text = "Consulta não confirmada";
    } else if (naoAtendida) {
      color = AppColors.greyFontLow;
      text = "Consulta não atendida";
    } else {
      color = AppColors.blueConsultaOk;
      text = "Consulta agendada";
    }

    return AppText(
      text,
      fontWeight: FontWeight.w500,
      fontSize: 13,
      color: color,
    );
  }

  _image() {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            // Platform.isIOS
            //     ? showCovidLabel
            //         ? CovidLabel(
            //             fontSize: 10,
            //             margin: EdgeInsets.only(bottom: 5, top: 5),
            //           )
            //         : SizedBox()
            //     : SizedBox(),
            Container(
              margin: EdgeInsets.only(right: 5),
              height: 70,
              width: 70,
              child: image,
            ),
          ],
        ),
        showTelemedicineLabel
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
    );
  }

  _buildDataHorario(DateTime dateTime) {
    return "${addZeroDate(dateTime.day)} ${getMesAbreviado(dateTime.month)} • ${addZeroDate(dateTime.hour)}:${addZeroDate(dateTime.minute)}";
  }
}
