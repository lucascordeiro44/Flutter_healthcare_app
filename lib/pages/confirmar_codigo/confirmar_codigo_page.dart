import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/pages/confirmar_codigo/confirmar_codigo_bloc.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

class ConfimarCodigoPage extends StatefulWidget {
  final String telefone;
  final bool otp;
  final LoginBloc loginBloc;
  final TipoLoginSocial tipoLogin;

  const ConfimarCodigoPage({
    Key key,
    this.telefone,
    this.otp = false,
    this.loginBloc,
    this.tipoLogin
  }) : super(key: key);
  @override
  _ConfimarCodigoPageState createState() => _ConfimarCodigoPageState();
}

class _ConfimarCodigoPageState extends State<ConfimarCodigoPage> {
  int cod;
  String codDigitado;

  bool get otp => widget.otp;
  TipoLoginSocial get tipoLogin => widget.tipoLogin;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _bloc = ConfirmarCodigoBloc();

  @override
  void initState() {
    super.initState();

    screenView("Confirmar_Telefon", "Tela Confirmar_Telefone");

    if (!otp) {
      _sendSms();
    }
  }

  _sendSms() async {
    var v = await _bloc.sendSms(widget.telefone);

    setState(() => cod = v);
    print(cod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Confirmação de ${otp ? "token" : "celular"}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        centerTitle: true,
      ),
      body: _body(),
    );
  }

  _body() {
    return BaseContainer(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 15),
          AppText(
            'Digite o código',
            fontSize: 25,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 15),
          Align(
            alignment: Alignment.center,
            child: PinCodeTextField(
              maxLength: otp ? 6 : 4,
              highlight: true,
              highlightColor: AppColors.greyFontLow,
              hasTextBorderColor: AppColors.greyFontLow,
              highlightAnimation: true,
              highlightAnimationBeginColor: Theme.of(context).primaryColor,
              highlightAnimationEndColor: Colors.white,
              highlightAnimationDuration: Duration(milliseconds: 800),
              defaultBorderColor: AppColors.greyFontLow,
              autofocus: true,
              pinBoxWidth: otp ? 40 : 60,
              pinBoxDecoration:
              ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
              pinTextStyle: TextStyle(fontSize: otp ? 24 : 30),
              onDone: (String value) {
                setState(() {
                  codDigitado = value;
                });
                _bloc.button.setEnabled(true);
              },
            ),
          ),
          SizedBox(height: 20),
          _button(),
        ],
      ),
    );
  }

  _button() {
    return AppButtonStream(
      text: "Confirmar",
      stream: otp ? _bloc.button.stream : null,
      onPressed: () {
        _onClickConfirmar();
      },
    );
  }

  _onClickConfirmar() {
    if (otp) {
      _otp();
      return;
    }

    if (cod == int.parse(codDigitado)) {
      pop(result: true);
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: AppText(
          'Por favor, verifique se o código foi digitado corretamente.',
          color: Colors.white,
        ),
      ));
    }
  }


  _otp() async {
    ApiResponse response = await _bloc.login(codDigitado, tipoLogin);

    if (response.ok) {
      Prefs.setBool('otp.ok', true);
      push(HomePage(), replace: true);
    } else {
      showSimpleDialog(response.msg);
    }
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
