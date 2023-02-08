import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/utils/clean_text.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/custom_checkbox.dart';

class PreCadastroPage extends StatefulWidget {
  final bool isDependente;
  final String email;
  final String firstName;
  final String lastName;
  final String uid;

  const PreCadastroPage(
      {Key key,
      this.isDependente = false,
      this.email = "",
      this.firstName = "",
      this.lastName = "",
      this.uid = ""})
      : super(key: key);

  @override
  _PreCadastroPageState createState() => _PreCadastroPageState();
}

class _PreCadastroPageState extends State<PreCadastroPage>
    with TickerProviderStateMixin {
  final _bloc = PreCadastroBloc();

  final _formKey = GlobalKey<FormState>();

  final _preCadastroForm = PreCadastroForm();

  final _nomeFn = FocusNode();
  final _sobrenomeFn = FocusNode();
  final _cpfFn = FocusNode();
  final _emailFn = FocusNode();
  final _confirmEmailFn = FocusNode();
  final _senhaFn = FocusNode();
  final _repetirSenhaFn = FocusNode();

  SizedBox _sizedBox15 = SizedBox(height: 10);
  Color _primaryColor;

  Icon _checkIcon;
  Icon _errorIcon;

  bool get isDependente => widget.isDependente;

  String get socialEmail => widget.email;

  String get socialFirstName => widget.firstName;

  String get socialLastName => widget.lastName;

  String get uid => widget.uid;

  final _cpfController = new MaskedTextController(mask: '000.000.000-00');

  @override
  void initState() {
    super.initState();
    _bloc.emailCorrect.set(socialEmail.isNotEmpty);
    _preCadastroForm.username = socialEmail;

    _bloc.confirmEmailCorrect.set(socialEmail.isNotEmpty);
    _preCadastroForm.confirmUsername = socialEmail;

    _bloc.nomeCompleted.set(socialFirstName.isNotEmpty);
    _preCadastroForm.firtsName = socialFirstName;

    _bloc.sobrenomeCompleted.set(socialLastName.isNotEmpty);
    _preCadastroForm.lastName = socialLastName;

    screenView("Pre_Cadastro", "Tela Pre_Cadastro");
  }

  @override
  Widget build(BuildContext context) {
    _primaryColor = Theme.of(context).primaryColor;
    _checkIcon = Icon(FontAwesomeIcons.check, size: 14, color: _primaryColor);
    _errorIcon = Icon(FontAwesomeIcons.times, size: 14, color: _primaryColor);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: _primaryColor),
        elevation: 1,
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        title: Text("Cadastro ${isDependente ? "de dependente" : ""}"),
        centerTitle: true,
      ),
      body: _body(),
    );
  }

  _body() {
    return BaseContainer(
      needSingleChildScrollView: true,
      padding: EdgeInsets.only(left: 16, right: 16, top: 10),
      child: StreamBuilder<ButtonState>(
        stream: _bloc.button.stream,
        builder: (context, snapshot) {
          //caso tiver em progress, deixa os campos disabled
          bool enable = snapshot.data == null ? true : !snapshot.data.progress;
          bool enableNome = socialFirstName == "";
          bool enableSobrenome = socialLastName == "";
          bool enableEmail = socialEmail == "";

          return Column(
            children: <Widget>[
              InkWell(child: MiniLogo()),
              SizedBox(height: 10),
              AppText("Muito prazer!", fontSize: 26),
              SizedBox(height: 20),
               _nomeInput(enableNome) ,
              _sizedBox15,
               _sobrenomeInput(enableSobrenome),
              _sizedBox15,
              _cpfInput(enable),
              //_souEstrangeiroButton(),
              _sizedBox15,
               _emailInput(enableEmail),
              _sizedBox15,
              _emailConfirmEmail(enableEmail),
              _sizedBox15,
              _senhaInput(enable),
              _sizedBox15,
              _repetirSenhaInput(enable),
              _streamCheckPassword(),
              SizedBox(height: 5),
              _rowTermos(enable),
              SizedBox(height: 5),
              _cadastrarButton(),
            ],
          );
        },
      ),
    );
  }

  _nomeInput(bool enabled) {
    return StreamBuilder(
      stream: _bloc.nomeCompleted.stream,
      builder: (context, snapshot) {
        bool v = snapshot.hasData ? snapshot.data : false;
        return AppFormField(
          enabled: enabled,
          isCircular: true,
          hintText: "nome",
          initialValue: socialFirstName,
          suffixIcon: PersonImageAsIcon(color: v ? _primaryColor : null),
          focusNode: _nomeFn,
          textCapitalization: TextCapitalization.words,
          onFieldSubmitted: (_) {
            fieldFocusChangeFunction(context, _nomeFn, _sobrenomeFn);
          },
          onChanged: (String value) {
            _preCadastroForm.firtsName = value;
            _bloc.nomeCompleted.set(value.isNotEmpty);
            _udpateForm();
          },
        );
      },
    );
  }

  _sobrenomeInput(bool enabled) {
    return StreamBuilder(
      stream: _bloc.sobrenomeCompleted.stream,
      builder: (context, snapshot) {
        bool v = snapshot.hasData ? snapshot.data : false;
        return AppFormField(
          enabled: enabled,
          isCircular: true,
          initialValue: socialLastName,
          hintText: "sobrenome",
          suffixIcon: PersonImageAsIcon(color: v ? _primaryColor : null),
          focusNode: _sobrenomeFn,
          textCapitalization: TextCapitalization.words,
          onFieldSubmitted: (_) {
            fieldFocusChangeFunction(context, _sobrenomeFn, _cpfFn);
          },
          onChanged: (String value) {
            _preCadastroForm.lastName = value;
            _bloc.sobrenomeCompleted.set(value.isNotEmpty);
            _udpateForm();
          },
        );
      },
    );
  }

  _cpfInput(bool enabled) {
    return StreamBuilder(
      initialData: false,
      stream: _bloc.isEstrangeiro.stream,
      builder: (context, estrangeiroSnapshot) {
        bool isEstrangeiro = estrangeiroSnapshot.data;

        return StreamBuilder(
          stream: _bloc.cpfCorrect.stream,
          builder: (context, snapshot) {
            Widget icon = snapshot.hasData
                ? snapshot.data
                    ? _checkIcon
                    : _errorIcon
                : PersonImageAsIcon();

            return AppFormField(
              enabled: enabled,
              isCircular: true,
              controller: _cpfController,
              suffixIcon: icon,
              focusNode: _cpfFn,
              inputFormatterrs: [LengthLimitingTextInputFormatter(14)],
              textInputType: TextInputType.number,
              prefix: Text(!snapshot.hasData || isEstrangeiro ? "" : "CPF "),
              hintText: snapshot.hasData
                  ? ""
                  : isEstrangeiro
                      ? "Passaporte"
                      : "CPF",
              onFieldSubmitted: (_) {
                fieldFocusChangeFunction(context, _cpfFn, _emailFn);
              },
              onChanged: (String value) async {
                _preCadastroForm.document = value;
                _preCadastroForm.cpfMasked = value;

                if (value.isNotEmpty) {
                  String cpf = cleanCpf(value);

                  bool v = isValidCpf(cpf) && CPFValidator.isValid(cpf);

                  _bloc.cpfCorrect.add(v);
                } else {
                  _bloc.cpfCorrect.add(null);
                }

                _udpateForm();
              },
            );
          },
        );
      },
    );
  }

  _souEstrangeiroButton() {
    return StreamBuilder(
      initialData: false,
      stream: _bloc.isEstrangeiro.stream,
      builder: (context, snapshot) {
        bool isEstrangeiro = snapshot.data;

        return ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          onTap: () {
            _bloc.isEstrangeiro.add(!isEstrangeiro);
          },
          leading: CustomCheckbox(
            activeColor: Theme.of(context).primaryColor,
            onChanged: (v) {
              _bloc.isEstrangeiro.add(!isEstrangeiro);
            },
            value: isEstrangeiro,
          ),
          title: Text(
            "Sou estrangeiro e não possuo CPF",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.greyFont,
            ),
          ),
        );
      },
    );
  }

  _emailInput(bool enabled) {
    return StreamBuilder(
      stream: _bloc.emailCorrect.stream,
      builder: (context, snapshot) {
        return AppFormField(
          enabled: enabled,
          isCircular: true,
          hintText: "email",
          initialValue: socialEmail,
          suffixIcon: !snapshot.hasData
              ? EmailImageAsIcon()
              : snapshot.data
                  ? _checkIcon
                  : _errorIcon,
          focusNode: _emailFn,
          textInputType: TextInputType.emailAddress,
          onFieldSubmitted: (_) {
            fieldFocusChangeFunction(context, _emailFn, _confirmEmailFn);
          },
          onChanged: (String value) {
            _preCadastroForm.username = value.toLowerCase();
            _udpateForm();
            _bloc.emailCorrect.set(value.isEmpty ? null : isValidEmail(value));
            if (_preCadastroForm.confirmUsername != null) {
              _bloc.confirmEmailCorrect.set(value.isEmpty
                  ? null
                  : _preCadastroForm.confirmEmailCorrect());
            }
          },
        );
      },
    );
  }

  _emailConfirmEmail(bool enabled) {
    return StreamBuilder(
      stream: _bloc.confirmEmailCorrect.stream,
      builder: (context, snapshot) {
        return AppFormField(
          enabled: enabled,
          isCircular: true,
          hintText: "confirmar email",
          focusNode: _confirmEmailFn,
          initialValue: socialEmail,
          suffixIcon: !snapshot.hasData
              ? EmailImageAsIcon()
              : snapshot.data
                  ? _checkIcon
                  : _errorIcon,
          textInputType: TextInputType.emailAddress,
          onFieldSubmitted: (_) {
            fieldFocusChangeFunction(context, _confirmEmailFn, _senhaFn);
          },
          onChanged: (String value) {
            _preCadastroForm.confirmUsername = value.toLowerCase();
            _udpateForm();

            _bloc.confirmEmailCorrect.set(
                value.isEmpty ? null : _preCadastroForm.confirmEmailCorrect());
          },
        );
      },
    );
  }

  _senhaInput(bool enabled) {
    return StreamBuilder(
      stream: _bloc.senhaCorrect.stream,
      builder: (context, snapshot) {
        return AppFormField(
          enabled: enabled,
          isCircular: true,
          isPassword: true,
          hintText: "senha",
          suffixIcon: !snapshot.hasData
              ? SenhaImageAsIcon()
              : snapshot.data
                  ? _checkIcon
                  : _errorIcon,
          focusNode: _senhaFn,
          onFieldSubmitted: (_) {
            fieldFocusChangeFunction(context, _senhaFn, _repetirSenhaFn);
          },
          onChanged: (String value) {
            _preCadastroForm.password = value;

            _bloc.validaSenhas(
                _preCadastroForm.password, _preCadastroForm.confirmPassword);

            _udpateForm();
          },
        );
      },
    );
  }

  _repetirSenhaInput(bool enabled) {
    return StreamBuilder(
      stream: _bloc.confirmarSenhaCorrect.stream,
      builder: (context, snapshot) {
        return AppFormField(
          enabled: enabled,
          isCircular: true,
          isPassword: true,
          hintText: "repetir senha",
          suffixIcon: !snapshot.hasData
              ? SenhaImageAsIcon()
              : snapshot.data
                  ? _checkIcon
                  : _errorIcon,
          focusNode: _repetirSenhaFn,
          onFieldSubmitted: (_) {},
          onChanged: (String value) {
            _preCadastroForm.confirmPassword = value;
            _bloc.validaSenhas(
                _preCadastroForm.password, _preCadastroForm.confirmPassword);
            _udpateForm();
            // _formKey.currentState.validate();
          },
        );
      },
    );
  }

  _streamCheckPassword() {
    return StreamBuilder(
      stream: _bloc.confirmarSenhaCorrect.stream,
      builder: (context, snapshot) {
        bool v = snapshot.hasData ? snapshot.data : true;

        return AnimatedContainer(
          width: double.infinity,
          duration: Duration(milliseconds: 200),
          height: !v ? 20 : 0,
          child: Container(
            padding: EdgeInsets.only(left: 3),
            margin: EdgeInsets.only(top: 3),
            child: AppText(
              'As senhas devem ser iguais.',
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }

  _rowTermos(bool enable) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        StreamBuilder(
          stream: _bloc.termos.stream,
          builder: (context, snapshot) {
            bool value = snapshot.hasData ? snapshot.data : false;
            return CupertinoSwitch(
              activeColor: _primaryColor,
              onChanged: (bool v) {
                if (enable) {
                  _bloc.termos.add(v);
                  _preCadastroForm.agreeTerms = v;
                  _udpateForm();
                }
              },
              value: value,
            );
          },
        ),
        Container(
          child: Row(
            children: <Widget>[
              Text(
                "Eu concordo com os",
                style: TextStyle(
                    color: _primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
              RawMaterialButton(
                onPressed: () {
                  if (enable) {
                    _onClickTermosDeUso();
                  }
                },
                child: Text(
                  " termos de uso",
                  style: TextStyle(
                      color: _primaryColor,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  _cadastrarButton() {
    return AppButtonStream(
      text: "Cadastre-se",
      stream: _bloc.button.stream,
      onPressed: _onClickCadastrar,
    );
  }

  _udpateForm() {
    _bloc.validate(_preCadastroForm);
  }

  _onClickTermosDeUso() {
    launch("https://dandelin.io/termos/");
    //push(context, TermosUso());
  }

  _onClickCadastrar() async {
    if (_preCadastroForm.password.length >= 4) {
      _bloc.button.setProgress(true);

      ApiResponse emailApi =
          await _bloc.checkEmailExists(_preCadastroForm.username);

      if (!emailApi.ok) {
        await showSimpleDialog(emailApi.msg);
        _enableButton();
        _emailFn.requestFocus();
        return;
      }

      User user = User()
        ..firstName = _preCadastroForm.firtsName
        ..lastName = _preCadastroForm.lastName
        ..uid = uid
        ..document = isNotEmpty(_preCadastroForm.document)
            ? cleanCpf(_preCadastroForm.document)
            : null
        ..username = _preCadastroForm.username
        ..password = _preCadastroForm.password
        ..cpfMasked = _preCadastroForm.cpfMasked;

      isDependente ? appBloc.setDependente(user) : appBloc.setUser(user);

      _enableButton();
      push(GeneroPage(isDependente: isDependente));
    } else {
      showSimpleDialog("A senha precisa ter no mínimo 4 digitos.");
      _senhaFn.requestFocus();
    }
  }

  _enableButton() {
    _bloc.button.setEnabled(true);
    _bloc.button.setProgress(false);
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
    _nomeFn.dispose();
    _sobrenomeFn.dispose();
    _cpfFn.dispose();
    _emailFn.dispose();
    _senhaFn.dispose();
    _repetirSenhaFn.dispose();
    _cpfController.dispose();
    _confirmEmailFn.dispose();
  }
}
