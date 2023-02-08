import 'package:flutter/material.dart';
import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/size_config.dart';

class WrapHorarios extends StatelessWidget {
  final List<String> horariosDisponiveis;
  final bool isDetalhePage;

  const WrapHorarios({
    Key key,
    this.horariosDisponiveis,
    this.isDetalhePage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return horariosDisponiveis.length > 0
        ? _listHorarios(horariosDisponiveis)
        : Container();
  }

  _listHorarios(List<String> listHorarios) {
    List<Widget> _listWidget1 = List<Widget>();
    List<Widget> _listWidget2 = List<Widget>();
    List<Widget> _listWidget3 = List<Widget>();
    List<Widget> _listWidget4 = List<Widget>();
    List<Widget> _listWidget5 = List<Widget>();
    List<Widget> _listWidget6 = List<Widget>();
    List<Widget> _listWidget7 = List<Widget>();

    int y = 0;

    for (var i = 0; i < listHorarios.length; i++) {
      if (i < 8) {
        //mostrar máximo 8 nos cards
        if (y == 0) {
          _listWidget1.add(_autoSizeText(listHorarios[i]));
          if (i != listHorarios.length - 1) {
            _listWidget2.add(_autoSizeText(null));
          }
        } else if (y == 1) {
          _listWidget3.add(_autoSizeText(listHorarios[i]));
          if (i != listHorarios.length - 1) {
            _listWidget4.add(_autoSizeText(null));
          }
        } else if (y == 2) {
          _listWidget5.add(_autoSizeText(listHorarios[i]));
          if (i != listHorarios.length - 1) {
            _listWidget6.add(_autoSizeText(null));
          }
        } else if (y == 3) {
          _listWidget7.add(_autoSizeText(listHorarios[i]));
        }

        y++;
        if (y == 4) {
          y = 0;
        }
      }
    }

    if (listHorarios.length > 8) {
      _listWidget1.add(AutoSizeText(
        "•••",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.greyFontLow,
        ),
        minFontSize: 5,
        maxFontSize: 13,
        textAlign: TextAlign.center,
        maxLines: 1,
      ));
    }

    return Container(
      padding: EdgeInsets.only(right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _expandedColumn(5, _listWidget1),
          _expandedColumn(2, _listWidget2),
          _expandedColumn(5, _listWidget3),
          _expandedColumn(2, _listWidget4),
          _expandedColumn(5, _listWidget5),
          _expandedColumn(2, _listWidget6),
          _expandedColumn(5, _listWidget7),
        ],
      ),
    );
  }

  _autoSizeText(String horario) {
    String text;
    if (horario != null) {
      var array = horario.split(':');
      text = array[0] + ":" + array[1];
    } else {
      text = '•  ';
    }
    return AutoSizeText(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: AppColors.greyFontLow,
      ),
      minFontSize: 5,
      maxFontSize: 13,
      textAlign: TextAlign.center,
      maxLines: 1,
    );
  }

  _expandedColumn(int flex, List<Widget> children) {
    return Expanded(
      flex: flex,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

List<String> horariosListStrings(List<String> horarios, bool isDetalhePage) {
  int iMax = SizeConfig.screenWidth >= 375 ? 3 : 2;

  int i = 0;

  List<String> list = List<String>();

  horarios.forEach((h) {
    //retirar os segundos
    var array = h.split(':');

    list.add("${array[0]}:${array[1]}");

    if (!isDetalhePage) {
      if (i != iMax) {
        list.add('• ');
        i++;
      } else {
        i = 0;
      }
    }
  });

  if (!isDetalhePage && list[list.length - 1] == ' • ') list.removeLast();

  return list;
}
