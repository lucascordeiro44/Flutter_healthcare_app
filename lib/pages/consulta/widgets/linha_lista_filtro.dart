import 'package:flutter/material.dart';
import 'package:flutter_dandelin/model/city.dart';
import 'package:flutter_dandelin/model/expertise.dart';
import 'package:flutter_dandelin/model/laboratory.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/widgets/app_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LinhaListaFiltro extends StatelessWidget {
  final dynamic item;
  final bool defaultValue;
  final Function(dynamic) onClickLinhaListaFiltro;

  const LinhaListaFiltro({
    Key key,
    @required this.item,
    this.defaultValue = false,
    @required this.onClickLinhaListaFiltro,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String legenda;
    bool isSelected = false;
    bool isCity = false;
    Widget icon;

    if (item is City) {
      City city = item;
      legenda = city.name;
      isSelected = city.isSelected;
      icon = SizedBox();
      isCity = true;
    } else if (item is User) {
      User user = item;
      legenda = user.getUserFullName;
      icon = Icon(
        FontAwesomeIcons.userMd,
        color: Colors.black26,
      );
    } else if (item is Expertise) {
      Expertise expertise = item;
      legenda = expertise.name;
      isSelected = expertise.isSelected != null ? expertise.isSelected : false;
      icon = Image.asset(
        'assets/images/cone-stethoscope.png',
        height: 23,
        color: Colors.black26,
      );
    } else {
      Laboratory laboratory = item;
      legenda = laboratory.name ?? laboratory.title ?? "";
      isSelected =
          laboratory.isSelected != null ? laboratory.isSelected : false;
      icon = SizedBox(width: 20);
    }

    return Container(
      margin: !isCity
          ? EdgeInsets.only(left: 35)
          : isSelected ? EdgeInsets.only(left: 35) : EdgeInsets.only(left: 70),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 2),
        title: Row(
          children: <Widget>[
            isSelected
                ? Image.asset('assets/images/icon-busca-recente.png',
                    height: 22)
                : icon,
            SizedBox(width: !isCity ? 12 : isSelected ? 12 : 0),
            Expanded(
              child: AppText(
                legenda ?? "",
                fontWeight: FontWeight.w500,
                color: defaultValue ? Theme.of(context).primaryColor : null,
              ),
            ),
          ],
        ),
        onTap: () {
          onClickLinhaListaFiltro(item);
        },
      ),
    );
  }
}
