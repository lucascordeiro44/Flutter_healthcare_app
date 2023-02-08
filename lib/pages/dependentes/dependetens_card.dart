import 'package:flutter/material.dart';
import 'package:flutter_dandelin/model/dependente.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_circle_avatar.dart';
import 'package:flutter_dandelin/widgets/app_text.dart';
import 'package:string_mask/string_mask.dart';

class DependentesCard extends StatelessWidget {
  final Function(Dependente) onClickDepenenteDetalhe;
  final Dependente dependente;

  const DependentesCard({
    Key key,
    @required this.onClickDepenenteDetalhe,
    @required this.dependente,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onClickDepenenteDetalhe(dependente);
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1.0, color: Colors.black12),
            ),
          ),
          padding: const EdgeInsets.only(top: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _avatar(context),
              _dados(context),
              _icon(context),
            ],
          ),
        ),
      ),
    );
  }

  _avatar(BuildContext context) {
    return Column(
      children: <Widget>[
        // Image.asset('assets/images/profile-picture.png', height: 60),
        AppCircleAvatar(
          radius: 35,
          avatar: dependente.avatar,
          assetAvatarNull: 'assets/images/dependente-icon.png',
        ),
        SizedBox(height: 15),
        Container(
          color: Theme.of(context).primaryColor,
          height: 5,
          width: 70,
        )
      ],
    );
  }

  _dados(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              dependente.dependentName,
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 18),
            ),
            _subTitle(),
          ],
        ),
      ),
    );
  }

  _subTitle() {
    String text;

    if (dependente.isDeletado || !dependente.approved) {
      text = dependente.approvalMessage;
    } else if (isNotEmpty(dependente.username)) {
      text = dependente.username;
    } else {
      text = StringMask('000.000.000-00').apply(dependente.document);
    }

    return AppText(
      text ?? "",
      color: dependente.approved ? null : Colors.red,
    );
  }

  _icon(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Icon(
        Icons.chevron_right,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
