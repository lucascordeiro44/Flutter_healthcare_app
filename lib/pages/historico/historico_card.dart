import 'package:flutter/material.dart';
import 'package:flutter_dandelin/model/biling.dart';
import 'package:flutter_dandelin/model/exam.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class HistoricoCard extends StatelessWidget {
  final Consulta consulta;
  final Biling biling;
  final Exam exam;
  final Function onClickHistoricoDetalhe;

  HistoricoCard({
    Key key,
    this.consulta,
    this.biling,
    this.onClickHistoricoDetalhe,
    this.exam,
  }) : super(key: key);

  get isConsulta => consulta != null;
  get isExam => exam != null;
  get isBilling => biling != null;
  get cardColor => isExam ? AppColors.blueExame : AppColors.kPrimaryColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isConsulta) {
          onClickHistoricoDetalhe(consulta);
        } else if (isExam) {
          onClickHistoricoDetalhe(exam);
        }
      },
      child: Container(
        padding: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.7, color: Colors.black26),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _avatarColumn(context),
                SizedBox(width: 10),
                _dataColumn(context),
                _option(context),
              ],
            ),
            Container(
              width: 70,
              height: 3,
              color: cardColor,
            ),
          ],
        ),
      ),
    );
  }

  _avatarColumn(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      height: 70,
      width: 70,
      child: isConsulta
          ? AppCircleAvatar(
              avatar: consulta.scheduleDoctor.doctor.user.avatar,
              assetAvatarNull: 'assets/images/consulta-icone.png',
            )
          : isExam
              ? AppCircleAvatar(
                  avatar: null,
                  assetAvatarNull: 'assets/images/cone-exame.png',
                )
              : AppCircleAvatar(
                  avatar: null,
                  assetAvatarNull: 'assets/images/dandelin-cone.png',
                ),
    );
  }

  _dataColumn(BuildContext context) {
    return Expanded(
      flex: 8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppText(
            isConsulta || isExam ? _dataConsulta() : _priceBiling(biling.total),
            color: AppColors.greyFontLow,
            fontWeight: FontWeight.w400,
            fontSize: isConsulta || isExam ? 14 : 18,
          ),
          SizedBox(height: 2),
          _especialidadesMonthBilling(context),
          SizedBox(height: 2),
          _nomeDoutorOuDataBiling(),
          isConsulta && consulta.isCancelado
              ? AppText("Cancelado",
                  color: Colors.red, fontWeight: FontWeight.w500)
              : SizedBox(),
        ],
      ),
    );
  }

  _option(BuildContext context) {
    if (isBilling) {
      return SizedBox(width: 15);
    }
    return Expanded(
      flex: 2,
      child: Container(
        child: Icon(
          Icons.chevron_right,
          color: Theme.of(context).primaryColor,
          size: 30,
        ),
      ),
    );
  }

  _dataConsulta() {
    DateTime dateTime = stringToDateTimeWithMinutes(
        isConsulta ? consulta.scheduleAt : exam.scheduledAt);

    return "${getDiaSemana(dateTime.weekday, numberWeek: true)} - ${addZeroDate(dateTime.day)}. ${getMesAbreviado(dateTime.month).toUpperCase()}. ${dateTime.year}";
  }

  _priceBiling(num total) {
    String tot = total.toString().replaceAll('.', ',');

    tot = tot.length == 4 ? tot + "0" : tot;

    return "R\$ $tot";
  }

  _monthBiling(String paymentAt, {String createdAt}) {
    DateTime dateTime;
    if (paymentAt != null) {
      dateTime = stringToDateTime(paymentAt);

      return getMesEscrito(dateTime).toUpperCase();
    }

    dateTime = stringToDateTimeWithMinutes(createdAt);
    return 'Em aberto - ${getMesEscrito(dateTime).toUpperCase()}';
  }

  _especialidadesMonthBilling(BuildContext context) {
    if (isConsulta) {
      String expertieses = Consulta.getExpertises(consulta);
      return expertieses != ''
          ? AppText(
              expertieses,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).primaryColor,
            )
          : SizedBox();
    } else if (isExam) {
      return AppText(
        exam.scheduleExam.exam.title,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).primaryColor,
      );
    } else {
      return AppText(
        "${_monthBiling(biling.paymentAt, createdAt: biling.createdAt)}" +
            _isPedente(),
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).primaryColor,
      );
    }
  }

  _nomeDoutorOuDataBiling() {
    if (isConsulta) {
      return AppText(
        _nomeDoutor(),
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.greyFontLow,
        maxLines: 1,
      );
    }
    if (isExam) {
      return AppText(
        exam.scheduleExam.laboratory.name,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.greyFontLow,
        maxLines: 1,
      );
    } else {
      String _dateBilling = _fullDateBiling(biling.paymentAt);
      if (_dateBilling != '') {
        return AppText(
          _dateBilling,
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.greyFontLow,
          maxLines: 1,
        );
      } else {
        return SizedBox(height: 5);
      }
    }
  }

  _nomeDoutor() {
    return Consulta.getDoctorFullName(consulta);
  }

  _isPedente() {
    return biling.status == "PENDENTE" ? " (Pendente)" : "";
  }

  _fullDateBiling(String paymentAt) {
    if (paymentAt != null) {
      DateTime dateTime = stringToDateTime(paymentAt);

      return "${getDiaSemana(dateTime.weekday, numberWeek: true)} - ${addZeroDate(dateTime.day)}. ${getMesAbreviado(dateTime.month).toUpperCase()}. ${dateTime.year}";
    }
    return '';
  }
}
