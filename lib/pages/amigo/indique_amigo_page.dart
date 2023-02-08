import 'package:flutter/material.dart';
import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/discount.dart';
import 'package:flutter_dandelin/pages/amigo/indique_amigo_bloc.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/size_config.dart';
import 'package:flutter_dandelin/widgets/app_bar.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';
import 'package:flutter_dandelin/widgets/app_header.dart';
import 'package:flutter_dandelin/widgets/base_container.dart';
import 'package:flutter_dandelin/widgets/dialogs.dart';
import 'package:share/share.dart';

class IndiqueUmAmigoPage extends StatefulWidget {
  @override
  _IndiqueUmAmigoPageState createState() => _IndiqueUmAmigoPageState();
}

class _IndiqueUmAmigoPageState extends State<IndiqueUmAmigoPage> {
  final _bloc = IndiqueAmigoBloc();

  @override
  void initState() {
    super.initState();

    screenView('Indique_Amigo', 'Tela Indique Amigo');
    _bloc.button.setEnabled(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DandelinAppbar(
        "Indique um amigo",
        iconThemeColor: AppColors.kPrimaryColor,
      ),
      body: _body(),
    );
  }

  _text() {
    return RichText(textAlign: TextAlign.center,
        text: TextSpan(
          children: <TextSpan>[
            new TextSpan(text: 'Indique um amigo para assinar o '),
            new TextSpan(
                text: 'dandelin!\n',
                style: new TextStyle(fontWeight: FontWeight.bold)),
            new TextSpan(
                text: 'Assim que a assinatura for ativada,\n você e seu amigo ganham R\$50,00 de desconto na próxima mensalidade!')
          ],
          style: TextStyle(
              color: Color.fromARGB(255, 91, 91, 91),
              fontSize: 18,
              fontWeight: FontWeight.w400),
        ));
  }

  _body() {
    return BaseContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _appHeader(),
          Container(
            padding: EdgeInsets.only(top: 32),
            child: Center(
              child: _text(),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: SizeConfig.marginBottom,
                ),
                child: AppButtonStream(
                  stream: _bloc.button.stream,
                  text: "ESCOLHER AMIGO",
                  onPressed: () => _onClickIndicarAmigo(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _appHeader() {
    return AppHeader(
      height: 200,
      image: 'assets/images/indique-amigo-background.png',
      child: Center(
        child: Image.asset(
          'assets/images/indique-amigo-head-icon.png',
          height: 100,
          color: Colors.white,
        ),
      ),
    );
  }

  _onClickIndicarAmigo() async {
    ApiResponse response = await _bloc.fetchInviteDiscount();

    if (response.ok) {
      String code = response.result;

//      Share.share(
////          'Olá! Estou usando o Dandelin para ter acesso à consultas médicas ilimitadas com o médico de minha escolha pelo menor preço do mercado.'
////          ' Faça parte da comunidade para ter os mesmos benefícios através do código $code. Link para Play store: https://play.google.com/store/apps/details?id=io.dandelin .'
////          ' Link para Apple Store: https://apps.apple.com/us/app/dandelin/id1294305831?l=pt&ls=1');

      Share.share("Assine agora o dandelin com R\$50 de desconto! "
          "Faça quantas consultas precisar assinando o dandelin por apenas R\$100 "
          "mensais e cuide da sua saúde preventivamente com qualidade! "
          "Baixe o app e adicione o código $code para ativar o desconto de R\$50,00 "
          "na primeira mensalidade. https://cutt.ly/Jzh5PtI");
    } else {
      showSimpleDialog(response.msg);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }
}
