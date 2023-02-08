import 'package:flutter/material.dart';
import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/pages/cupons_aplicados/cupom.dart';
import 'package:flutter_dandelin/widgets/app_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CupomCard extends StatelessWidget {
  final Widget leading;
  final Cupom cupom;
  final Function(Cupom) onClick;

  const CupomCard({
    Key key,
    this.leading,
    this.cupom,
    this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.16,
      child: Container(
        color: cupom.status == "APPLIED"
            ? Colors.transparent
            : Color.fromRGBO(247, 247, 247, 1),
        child: ListTile(
          onTap: () => onClick(this.cupom),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          leading: leading,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                cupom.partnership != null ?cupom.partnership.name : cupom.code,
                color: AppColors.greyStrong,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 4,),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Nome do cupom: ",
                      style: TextStyle(
                        color: AppColors.greyFont,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Mark',
                      ),
                    ),
                    TextSpan(
                      text: cupom.partnership != null ? cupom.partnership.couponCode : cupom.code,
                      style: TextStyle(
                        color: AppColors.greyFontLow,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Mark',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4,),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Aplicado em: ",
                          style: TextStyle(
                            color: AppColors.greyFont,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Mark',
                          ),
                        ),
                        TextSpan(
                          text: cupom.stringDtappliedAt,
                          style: TextStyle(
                            color: AppColors.greyFontLow,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Mark',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4,),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Desconto: ",
                          style: TextStyle(
                            color: AppColors.greyFont,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Mark',
                          ),
                        ),
                        TextSpan(
                          text: cupom.partnership != null ? cupom.partnership.discountFormatted : "R\$ ${cupom.discount}",
                          style: TextStyle(
                            color: AppColors.greyFontLow,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Mark',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppText(
                cupom.status == "APPLIED" ? "ATIVO" : "EXPIRADO",
                color: cupom.status == "APPLIED"
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
