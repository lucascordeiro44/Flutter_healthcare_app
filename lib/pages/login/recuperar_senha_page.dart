import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/pages/home/alterar_senha_page.dart';
import 'package:flutter_dandelin/pages/login/recuperar_senha_bloc.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/dialogs.dart';

class RecuperarSenhaPage extends StatefulWidget {
  final String emailDigitado;

  const RecuperarSenhaPage({Key key, this.emailDigitado}) : super(key: key);
  @override
  _RecuperarSenhaPageState createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
  final _bloc = RecuperarSenhaBloc();
  String email;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    screenView('Recuperar_Senha', 'Tela Recuperar Senha');

    if (widget.emailDigitado != null) {
      _controller.text = widget.emailDigitado;
      email = widget.emailDigitado;
      _udpateForm();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _body(),
    );
  }

  _body() {
    return BaseContainer(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.symmetric(horizontal: 16),
      needSingleChildScrollView: true,
      child: StreamBuilder(
          stream: _bloc.sentEmail.stream,
          builder: (context, snapshot) {
            bool sent = snapshot.hasData ? snapshot.data : false;
            return !sent ? _columnInputSenha() : _infoEnvio();
          }),
    );
  }

  _columnInputSenha() {
    return Column(
      children: <Widget>[
        SizedBox(height: 30),
        MiniLogo(),
        SizedBox(height: 30),
        AppText("Recuperar senha", fontSize: 30),
        SizedBox(height: 30),
        AppFormField(
          controller: _controller,
          isCircular: true,
          textInputType: TextInputType.emailAddress,
          hintText: 'e-mail',
          suffixIcon: EmailImageAsIcon(),
          onChanged: (value) {
            email = value;
            _udpateForm();
          },
          onSaved: (value) {
            email = value;
            _udpateForm();
          },
        ),
        SizedBox(height: 15),
        AppButtonStream(
          text: "ENVIAR CÓDIGO POR SMS",
          stream: _bloc.button.stream,
          onPressed: _onClickEnviar,
        ),
      ],
    );
  }

  _infoEnvio() {
    return Column(
      children: <Widget>[
        SizedBox(height: 30),
        MiniLogo(),
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: AppText(
            "Enviamos um e-mail para $email e um SMS contendo o código necessário.",
            textAlign: TextAlign.center,
            fontFamily: 'Mark Book',
          ),
        ),
      ],
    );
  }

  _udpateForm() {
    _bloc.updateForm(email);
  }

  _onClickEnviar() async {
    ApiResponse response = await _bloc.enviar(email);

    if (response.ok) {
      _bloc.sentEmail.add(true);
      Timer(Duration(seconds: 4), () {
        _bloc.sentEmail.add(false);
        push(AlterarSenhaPage(
          hasToken: true,
        ));
      });
    } else {
      showSimpleDialog(response.msg);
    }
  }

  @override
  void dispose() {
    _bloc.dispose();
    _controller.dispose();
    super.dispose();
  }
}
