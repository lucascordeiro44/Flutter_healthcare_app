import 'package:flutter/material.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/pages/home/alterar_senha_api.dart';
import 'package:flutter_dandelin/pages/home/alterar_senha_bloc.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/secure_storage.dart';

class AlterarSenhaPage extends StatefulWidget {
  final bool hasToken;

  const AlterarSenhaPage({Key key, this.hasToken = false}) : super(key: key);
  @override
  _AlterarSenhaPageState createState() => _AlterarSenhaPageState();
}

class _AlterarSenhaPageState extends State<AlterarSenhaPage> {
  final _key = GlobalKey<FormState>();

  final _tokenFn = FocusNode();
  final _senhaAntigaFn = FocusNode();
  final _senhaNovaFn = FocusNode();
  final _confirmSenhaFn = FocusNode();

  final _senhaNovaController = TextEditingController();

  final _form = AlterarSenhaForm();
  final _bloc = AlterarSenhaBloc();

  Widget sizedBox;

  @override
  void initState() {
    super.initState();
    screenView("Alterar_Senha", "Tela Alterar_Senha");
    _bloc.button.setEnabled(true);
  }

  @override
  Widget build(BuildContext context) {
    sizedBox = widget.hasToken ? SizedBox(height: 15) : Container();
    return Scaffold(
      appBar: AppBar(
        title: Text("Alterar senha"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: _body(),
    );
  }

  _body() {
    return BaseContainer(
      padding: EdgeInsets.only(right: 16, left: 16),
      child: Form(
        key: _key,
        child: Column(
          children: <Widget>[
            widget.hasToken ? _inputToken() : _inputSenhaAntiga(),
            _inputSenhaNova(),
            _inputConfirmarSenha(),
            _button()
          ],
        ),
      ),
    );
  }

  _inputToken() {
    return AppFormField(
      focusNode: _tokenFn,
      labelText: "Código",
      onFieldSubmitted: (_) {
        fieldFocusChangeFunction(context, _tokenFn, _senhaNovaFn);
      },
      onChanged: (String value) {
        _form.codigo = value;
      },
      validator: (_) {
        if (_form.codigo == null) {
          return 'Este campo é obrigatório';
        }
        return null;
      },
    );
  }

  _inputSenhaAntiga() {
    return AppFormField(
      focusNode: _senhaAntigaFn,
      labelText: "Senha atual",
      isPassword: true,
      onFieldSubmitted: (_) {
        fieldFocusChangeFunction(context, _senhaAntigaFn, _senhaNovaFn);
      },
      onChanged: (String value) {
        _form.senhaAtual = value;
      },
      validator: (_) {
        if (_form.senhaNova == null) {
          return 'Este campo é obrigatório';
        }
        return null;
      },
    );
  }

  _inputSenhaNova() {
    return AppFormField(
      controller: _senhaNovaController,
      focusNode: _senhaNovaFn,
      labelText: "Senha nova",
      isPassword: true,
      onFieldSubmitted: (_) {
        fieldFocusChangeFunction(context, _senhaNovaFn, _confirmSenhaFn);
      },
      onChanged: (String value) {
        _form.senhaNova = value;
      },
      validator: (_) {
        if (_form.senhaNova == null) {
          return 'Este campo é obrigatório';
        }
        if (_form.confirmSenha != _form.senhaNova) {
          return 'As senhas devem ser as mesmas.';
        }
        return null;
      },
    );
  }

  _inputConfirmarSenha() {
    return AppFormField(
      focusNode: _confirmSenhaFn,
      labelText: "Confirmar senha nova",
      isPassword: true,
      onChanged: (String value) {
        _form.confirmSenha = value;
      },
      validator: (_) {
        if (_form.confirmSenha == null) {
          return 'Este campo é obrigatório';
        }
        if (_form.confirmSenha != _form.senhaNova) {
          return 'As senhas devem ser as mesmas.';
        }
        return null;
      },
    );
  }

  _button() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(bottom: SizeConfig.marginBottom),
        alignment: Alignment.bottomCenter,
        child: AppButtonStream(
          stream: _bloc.button.stream,
          onPressed: () {
            _onClickConfirmar();
          },
          text: "Confirmar",
        ),
      ),
    );
  }

  _onClickConfirmar() async {
    if (_key.currentState.validate()) {
      _bloc.button.setProgress(true);
      _key.currentState.save();
      ApiResponse response =
          await AlterarSenhaApi.alterarSenha(_form, hasToken: widget.hasToken);

      _bloc.button.setProgress(false);
      if (response.ok) {
        SecureStorage.writeValue('senhaLogin', _senhaNovaController.text);

        await showSimpleDialog("Sua senha foi alterada!");

        if (widget.hasToken) {
          push(LoginPage(), replace: true, popAll: true);
        } else {
          pop();
        }
      } else {
        showSimpleDialog(response.msg);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _senhaAntigaFn.dispose();
    _senhaNovaFn.dispose();
    _bloc.dispose();
    _confirmSenhaFn.dispose();

    _tokenFn.dispose();

    _senhaNovaController.dispose();
  }
}
