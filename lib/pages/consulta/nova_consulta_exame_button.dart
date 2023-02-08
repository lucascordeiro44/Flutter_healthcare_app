import 'package:flutter/material.dart';
import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_base.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_bloc.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/size_config.dart';
import 'package:flutter_dandelin/widgets/app_text.dart';

class ConsultaExameButton extends StatelessWidget {
  final ConsultaExameBloc bloc;

  final Function(TipoConsulta opcao) onPressed;

  const ConsultaExameButton({Key key, this.bloc, @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2.0,
            spreadRadius: 0.5,
            offset: Offset(0.5, 0.5),
          )
        ],
      ),
      width: SizeConfig.screenWidth * 0.66,
      height: 30,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _inkwellDisabled(
                  Image.asset(
                    'assets/images/cone-stethoscope.png',
                    height: 19,
                  ),
                  "Presencial",
                  TipoConsulta.presencial,
                  10,
                  0,
                ),
                _inkwellDisabled(
                  Image.asset(
                    'assets/images/telemedicina-ic-disabled.png',
                    height: 18,
                  ),
                  "Telemedicina",
                  TipoConsulta.video,
                  3,
                  7,
                ),
                //lab muda aqui
                //  _inkwellDisabled(
                // Image.asset('assets/images/exame-icon.png', height: 18),
                // "Exames",
                // OpcaoEscolhida.exame),
              ],
            ),
          ),
          IndicatorAnimado(stream: bloc.tipoConsulta.stream),
        ],
      ),
    );
  }

  _inkwellDisabled(Widget icon, String title, TipoConsulta opcao, double space,
      double startSpace) {
    return Expanded(
      child: FlatButton(
        onPressed: () {
          onPressed(opcao);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            icon,
            SizedBox(width: space),
            Expanded(
              child: AutoSizeText(
                title,
                maxLines: 1,
                maxFontSize: 13,
                minFontSize: 9,
                style: TextStyle(
                    color: AppColors.greyFont, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IndicatorAnimado extends StatelessWidget {
  final Stream stream;

  const IndicatorAnimado({Key key, this.stream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        Alignment alignment;
        Color color;
        LinearGradient linearGradient;
        String text;
        Widget icon;

        double widthComponent;
        double space;

        if (!snapshot.hasData || snapshot.data == TipoConsulta.presencial) {
          alignment = Alignment.centerLeft;
          // color = null;
          color = Theme.of(context).primaryColor;
          text = "Presencial";
          icon = Image.asset('assets/images/cone-stethoscope.png',
              height: 19, color: Colors.white);

          widthComponent = SizeConfig.screenWidth * 0.36;
          space = 10;
        } else {
          alignment = Alignment.centerRight;
          color = Color.fromRGBO(0, 192, 236, 1);
          linearGradient = null;

          //lab muda aqui
          text = "Telemedicina";
          icon = Image.asset('assets/images/telemedicina-ic.png',
              height: 18, color: Colors.white);
          // text = "Exames";
          // icon = Image.asset('assets/images/exame-icon.png',
          //     height: 18, color: Colors.white);

          widthComponent = SizeConfig.screenWidth * 0.33;

          space = 5;
        }

        return AnimatedAlign(
          duration: Duration(milliseconds: 200),
          alignment: alignment,
          child: Container(
            //padding: padding,
            decoration: BoxDecoration(
              color: color,
              gradient: linearGradient,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            height: 45,
            width: widthComponent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                icon,
                SizedBox(width: space),
                AppText(
                  text,
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
