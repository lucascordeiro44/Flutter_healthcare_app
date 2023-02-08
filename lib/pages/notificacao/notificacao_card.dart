import 'package:flutter/material.dart';
import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/model/notificacao.dart';
import 'package:flutter_dandelin/widgets/app_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotificacaoCard extends StatelessWidget {
  final Widget leading;
  final Notificacao notificacao;
  final Function(Notificacao) onClick;

  const NotificacaoCard({
    Key key,
    this.leading,
    this.notificacao,
    this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.16,
      child: Container(
        color: notificacao.checked
            ? Colors.transparent
            : Color.fromRGBO(247, 247, 247, 1),
        child: ListTile(
          onTap: () => onClick(this.notificacao),
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          leading: leading,
          title: AppText(
            notificacao.message,
            color: AppColors.greyStrong,
            fontWeight: FontWeight.w500,
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "dandelin ",
                      style: TextStyle(
                        color: AppColors.greyFont,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Mark',
                      ),
                    ),
                    TextSpan(
                      text: notificacao.dataNotificacao,
                      style: TextStyle(
                        color: AppColors.greyFontLow,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Mark',
                      ),
                    ),
                  ],
                ),
              ),
              AppText(
                notificacao.horaNotificacao,
                color: AppColors.greyFont,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ],
          ),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Deletar',
          color: Colors.red,
          icon: Icons.delete,
          // onTap: () => _showSnackBar('Delete'),
        ),
      ],
    );
  }
}
