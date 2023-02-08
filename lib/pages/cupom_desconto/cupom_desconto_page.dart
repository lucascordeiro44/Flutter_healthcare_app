import 'package:flutter/material.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/discount.dart';
import 'package:flutter_dandelin/pages/cupom_desconto/cupom_desconto_bloc.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_layout_builder.dart';

class CupomDescontoPage extends StatefulWidget {
  @override
  _CupomDescontoPageState createState() => _CupomDescontoPageState();
}

class _CupomDescontoPageState extends State<CupomDescontoPage> {
  var _bloc = CupomDescontoBloc();
  @override
  void initState() {
    super.initState();
    screenView('Cupom', "Tela Cupom");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text("Cupom de desconto"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _body(),
    );
  }

  _body() {
    return AppLayoutBuilder(
      needSingleChildScrollView: true,
      child: Column(
        children: <Widget>[
          _appHeader(),
          SizedBox(height: 30),
          AppText(
            'Insira código de cupom',
            fontFamily: 'Mark Book',
            color: AppColors.greyStrong,
          ),
          SizedBox(height: 30),
          _inputCupom(),
          _enviarCodigoButton(),
        ],
      ),
    );
  }

  _appHeader() {
    return AppHeader(
      elevation: 0,
      height: 200,
      image: 'assets/images/notificacao-background.png',
      child: Center(
        child: Image.asset('assets/images/cupom-icone.png', height: 100),
      ),
    );
  }

  _inputCupom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppFormField(
        isCircular: true,
        onChanged: (String value) {
          _bloc.updateFrom(value);
        },
      ),
    );
  }

  _enviarCodigoButton() {
    return Expanded(
      child: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: AppButtonStream(
          stream: _bloc.button.stream,
          onPressed: _onClickEnviarCodigo,
          text: 'ENVIAR CÓDIGO',
        ),
      ),
    );
  }

  _onClickEnviarCodigo() async {
    ApiResponse response = await _bloc.sendInviteDiscount();

    response.ok
        ? await _showDiscountDialog(response.result)
        : showSimpleDialog(response.msg);
  }

  _showDiscountDialog(Discount discount) async {
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0),
          ),
          children: <Widget>[
            SizedBox(height: 20),
            AppText(
              "CUPOM VALIDADO",
              textAlign: TextAlign.center,
              color: Theme.of(context).primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: AppText(
                "Pronto! Agora você terá seu desconto de ${discount.discountFormatted} aplicado na próxima cobrança da mensalidade!",
                textAlign: TextAlign.center,
                color: AppColors.greyStrong,
                fontFamily: 'Mark Book',
              ),
            ),
            SizedBox(height: 5),
            _okButton(),
          ],
        );
      },
    );

    push(HomePage(), popAll: true, replace: true);
  }

  _okButton() {
    return FlatButton(
      padding: EdgeInsets.all(0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () {
        pop();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color.fromRGBO(255, 149, 82, 1),
              Color.fromRGBO(255, 173, 87, 1),
              Color.fromRGBO(255, 195, 90, 1),
            ],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
        ),
        height: 40,
        alignment: Alignment.center,
        width: double.infinity,
        child: AppText(
          "Ok! Entendi.",
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
