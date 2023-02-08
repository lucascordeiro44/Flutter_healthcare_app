import 'dart:convert';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as AuthUser;
import 'package:flutter/cupertino.dart';
import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/bem_vindo/bem_vindo.dart';
import 'package:flutter_dandelin/pages/cadastro/cadastro_login_social.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/clean_text.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/prefs.dart';
import 'package:flutter_dandelin/utils/secure_storage.dart';
import 'package:flutter_dandelin/widgets/app_layout_builder.dart';
import 'package:flutter_dandelin/widgets/custom_checkbox.dart';
import 'package:flutter_dandelin/widgets/dialogs.dart';
import 'package:string_mask/string_mask.dart';
import 'package:firebase_core/firebase_core.dart';

import 'apple_auth_service.dart';
import 'facebook_sign_in.dart';
import 'google_sign_in.dart';
import 'login_bloc.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _loginForm = LoginForm();
  final _bloc = LoginBloc();

  // bool _isCpf = false;
  final _formKey = GlobalKey<FormState>();

  final _emailFn = FocusNode();
  final _senhaFn = FocusNode();

  var _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });

    screenView('Login', 'Tela Login');
    // appBloc.cleanAuth();

    _checkOtp();
  }

  _checkOtp() async {
    await _checkTutorial();

    _initRememberUser();
  }

  _checkTutorial() async {
    var v = await Prefs.getBool('bem_vindo_done.new');
    if (!v) {
      push(BemVindo(), replace: true);
    }
  }

  _initRememberUser() async {
    bool rememberUser = await Prefs.getBool('remember.user');

    if (rememberUser) {
      String userPrefs = await Prefs.getString('user.prefs');

      User user = User.fromJson(json.decode(userPrefs));

      bool otp = await Prefs.getBool('otp.ok');
      if (otp) {
        appBloc.setUser(user);
        push(HomePage(), replace: true, popAll: true);
        return;
      }

      _emailController.text = user.username;
      _senhaController.text =
          user.password = await SecureStorage.getValue('senhaLogin');

      _loginForm.username = _emailController.text;
      _loginForm.password = _senhaController.text;

      _updateForm();
      _bloc.button.setEnabled(true);
      _bloc.checkButton.add(true);
    } else {
      appBloc.logout();
      appBloc.cleanAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: AppText("Login"),
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        centerTitle: true,
        elevation: 1,
      ),
      body: _body(),
    );
  }

  _body() {
    return AppLayoutBuilder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      needSingleChildScrollView: true,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // _emailFake.text = "henrique.wojcik@livetouch.com.br";
                // _senhaController.text = "teste";
                // _loginForm
                //   ..username = _emailFake.text
                //   ..password = _senhaController.text;
                // _updateForm();
              },
              child: MiniLogo(),
            ),
            SizedBox(height: 20),
            AppText(
              "Bem-vindo de volta!",
              fontSize: 32,
              fontFamily: 'Mark Book',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            _emailInput(),
            SizedBox(height: 10),
            _senhaInput(),
            SizedBox(height: 10),
            Container(
              height: 30,
              width: SizeConfig.screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildRememberUserButton(),
                  _buildForgotPasswordButton(),
                ],
              ),
            ),
            SizedBox(height: 30),
            AppButtonStream(
              text: "ENTRAR",
              onPressed: _onClickEntrar,
              stream: _bloc.button.stream,
            ),
            SizedBox(height: 20),
             _signInGoogleButton(),
            _signInFacebookButton(),
            _signInAppleButton(),
            SizedBox(height: 40),
            _cadastrarButton(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  _signInGoogleButton() {
    return _socialButton("assets/logos/google_logo.png",
        "Iniciar sessão com Google", Colors.white, TipoLoginSocial.google);
  }

  _onClickSignInGoogle() {
    GoogleAuthService.signInWithGoogle().then((result) {
      if (result != null) {
        String socialEmail = result.email;
        String token = GoogleAuthService.idToken;
        String uid = GoogleAuthService.uid;
        String firstName = GoogleAuthService.firstName;
        String lastName = GoogleAuthService.lastName;
        _onClickLoginSocial(socialEmail, token, uid, firstName, lastName,
            TipoLoginSocial.google);
      }
    });
  }

  _signInFacebookButton() {
    return _socialButton(
        "assets/logos/facebook_logo.png",
        "Iniciar sessão com Facebook",
        Color(0xFF3B5998),
        TipoLoginSocial.facebook);
  }

  _onClickSignInFb() {
    FacebookAuthService.signInFB().then((result) {
      if (result != null) {
        String socialEmail = FacebookAuthService.email;
        String token = FacebookAuthService.tokenId;
        String uid = FacebookAuthService.uid;
        String firstName = FacebookAuthService.firstName;
        String lastName = FacebookAuthService.lastName;
        _onClickLoginSocial(socialEmail, token, uid, firstName, lastName,
            TipoLoginSocial.facebook);

      }
    });
  }

  _socialButton(String logo, String text, Color backgroundColor,
      TipoLoginSocial tipoLoginSocial) {
    return Container(
      margin: EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
        padding: EdgeInsets.only(right: 20, top: 3.0, bottom: 3.0, left: 20),
        color: backgroundColor,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              logo,
              height: 24.0,
              color: tipoLoginSocial == TipoLoginSocial.google
                  ? null
                  : Colors.white,
            ),
            Container(
                padding: EdgeInsets.only(left: 18.0, right: 10.0),
                child: new Text(
                  text,
                  style: TextStyle(
                      color: tipoLoginSocial == TipoLoginSocial.google
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold),
                )),
          ],
        ),
        onPressed: () async {
          switch (tipoLoginSocial) {
            case TipoLoginSocial.google:
              _onClickSignInGoogle();
              break;

            case TipoLoginSocial.facebook:
              _onClickSignInFb();
              break;

            case TipoLoginSocial.apple:
              _onClickSignInApple();
              break;
          }
        },
      ),
    );
  }

  _signInAppleButton() {
    return FutureBuilder(
      future: AppleSignIn.isAvailable(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return _socialButton(
              'assets/logos/apple_logo.png',
              "Iniciar sessão com a Apple",
              Colors.black,
              TipoLoginSocial.apple);
        } else {
          return Container();
        }
      },
    );
  }

  _onClickSignInApple() async {
    AuthUser.User user = await AppleAuthService.signInWithApple();
    if (user != null) {
      String socialEmail = user.email;
      String token = AppleAuthService.tokenId;
      String uid = AppleAuthService.uid;

      String firstName = AppleAuthService.firebaseName.split(" ")[0];
      String lastName = AppleAuthService.firebaseName.split(" ")[1];

      _onClickLoginSocial(
          socialEmail, token, uid, firstName, lastName, TipoLoginSocial.apple);
      }

    print("$user");
  }

  _emailInput() {
    return AppFormField(
      isCircular: true,
      controller: _emailController,
      focusNode: _emailFn,
      onFieldSubmitted: (_) =>
          fieldFocusChangeFunction(context, _emailFn, _senhaFn),
      suffixIcon: PersonImageAsIcon(),
      hintText: 'e-mail ou cpf',
      textInputType: TextInputType.emailAddress,
      onChanged: (String value) {
        _loginForm.username = value;
        _updateForm();
      },
      onSaved: (String value) {
        if (num.tryParse(value) is num) {
          var formatter = new StringMask('000.000.000-00');
          var result = formatter.apply(_emailController.text); // 129.658.156-20
          _emailController.text = result;
        }
      },
      validator: (String value) {
        if (isEmpty(value)) {
          return "Campo obrigátorio";
        }
        return null;
      },
    );
  }

  _senhaInput() {
    return AppFormField(
      isCircular: true,
      focusNode: _senhaFn,
      controller: _senhaController,
      suffixIcon: SenhaImageAsIcon(),
      hintText: 'senha',
      onChanged: (String value) {
        _loginForm.password = value;
        _updateForm();
      },
      isPassword: true,
      validator: (String value) {
        if (isEmpty(value)) {
          return "Campo obrigátorio";
        }
        return null;
      },
    );
  }

  _buildRememberUserButton() {
    return StreamBuilder(
      stream: _bloc.checkButton.stream,
      builder: (context, snapshot) {
        bool value = snapshot.hasData ? snapshot.data : false;
        return Expanded(
          child: RawMaterialButton(
            padding: EdgeInsets.all(0),
            onPressed: () => _onChagedLembrarUsuario(!value),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 5),
                CustomCheckbox(
                  useTapTarget: false,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (_) => _onChagedLembrarUsuario(!value),
                  value: value,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: AutoSizeText(
                    "Lembrar usuário",
                    maxFontSize: double.infinity,
                    minFontSize: 12,
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: AppColors.greyFont),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _buildForgotPasswordButton() {
    return Expanded(
      child: Row(
        children: <Widget>[
          //mesma largura do check box.
          SizedBox(width: 18),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: RawMaterialButton(
                padding: EdgeInsets.only(right: 5),
                onPressed: _onClickEsqueciSenha,
                child: AutoSizeText(
                  "Esqueceu a senha?",
                  maxFontSize: double.infinity,
                  minFontSize: 12,
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: AppColors.greyFont),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _cadastrarButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AppText('Não possui conta?', fontWeight: FontWeight.w500),
        SizedBox(width: 20),
        RawMaterialButton(
          onPressed: () {
            push(PreCadastroPage());
          },
          child: AppText(
            "Cadastre-se",
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }

  _onChagedLembrarUsuario(bool value) {
    _bloc.checkButton.add(value);
  }

  _onClickEsqueciSenha() {
    screenAction('esqueci_senha', 'Tocou em "Esqueceu a senha?"');
    push(RecuperarSenhaPage(emailDigitado: _loginForm.username));
  }

  _onClickEntrar() async {
    _formKey.currentState.save();
    screenAction('entrar', 'Tocou em "Entrar"');
    ApiResponse response = await _bloc.login(_loginForm);
    if (response.ok) {
      _bloc.fetchHasUpdateTermos().then((update) => {
            if (update)
              {_showDialog(context)}
            else
              {push(HomePage(), replace: true, popAll: true)}
          });
    } else {
      String value = cleanCpf(_emailController.text);
      if (num.tryParse(value) is num) {
        _emailController.text = value;
      }
      showSimpleDialog(response.msg);
    }
  }

  _onClickLoginSocial( String email, String token, String uid, String firstName,
      String lastName, TipoLoginSocial tipo) async {
    screenAction('entrar', 'Tocou em "Entrar"');
    var _loginSocialForm = LoginForm();
    _loginSocialForm.username = email;
    _loginSocialForm.password = token;
    ApiResponse emailApi = await _bloc.checkEmailExists(email);
    if (!emailApi.ok) {
      ApiResponse response = await _bloc.loginSocial(_loginSocialForm, tipo);
      if (response.ok) {
        _bloc.fetchHasUpdateTermos().then((update) => {
              if (update)
                {_showDialog(context)}
              else
                {push(HomePage(), replace: true, popAll: true)}
            });
      } else {
        print("cadastro");
        push(PreCadastroPage(
          email: email,
          firstName: firstName == null || firstName == "null" ? "" : firstName,
          lastName: lastName == null || lastName == "null" ? "" : lastName,
          uid: uid,
        ));
      }
    } else {
    print("cadastro");
      push(PreCadastroPage(
        email: email,
        firstName: firstName == null || firstName == "null" ? "" : firstName,
        lastName: lastName == null || lastName == "null" ? "" : lastName,
        uid: uid,
      ));
    }
  }

  _updateForm() {
    _bloc.validate(_loginForm);
  }

  _showDialog(BuildContext context) async {
    bool ios = Theme.of(context).platform == TargetPlatform.iOS;

    bool checkBoxValue = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ios
            ? WillPopScope(
                onWillPop: () {},
                child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return CupertinoAlertDialog(
                    title: Text("Atenção"),
                    content: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                            child: Text(
                          "Para prosseguir com seu acesso será necessário que você aceite os novos termos de uso.",
                        )),
                        SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        child: Text("Cancelar", style: TextStyle(fontSize: 16)),
                        onPressed: () => pop(),
                      ),
                      CupertinoDialogAction(
                        child: Text(
                          'Ver termos',
                          style: TextStyle(color: Colors.blue, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () => launch("https://dandelin.io/termos/"),
                      ),
                      CupertinoDialogAction(
                        child: Text("Aceitar", style: TextStyle(fontSize: 16)),
                        onPressed: () => _fetchAgreeUserTerms(),
                      ),
                    ],
                  );
                }),
              )
            : WillPopScope(
                onWillPop: () {},
                child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                    title: Text("Atenção"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                            child: Text(
                          "Para prosseguir com seu acesso será necessário que você aceite os novos termos de uso.",
                        )),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            CustomCheckbox(
                              useTapTarget: false,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  checkBoxValue = value;
                                });
                              },
                              value: checkBoxValue,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            InkWell(
                                child: Text(
                                  'Li e aceito os Termos',
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () =>
                                    launch("https://dandelin.io/termos/")),
                          ],
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                          child:
                              Text("Cancelar", style: TextStyle(fontSize: 16)),
                          onPressed: () => pop()),
                      FlatButton(
                          child: Text("Entrar", style: TextStyle(fontSize: 16)),
                          onPressed: checkBoxValue
                              ? () => _fetchAgreeUserTerms()
                              : null),
                    ],
                  );
                }),
              );
      },
    );
  }

  _fetchAgreeUserTerms() async {
    _bloc.agreeuserTerms();
    await Navigator.of(context).pop();
    push(HomePage(), replace: true, popAll: true);
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
    _emailFn.dispose();
    _senhaFn.dispose();
    _emailController.dispose();
    _senhaController.dispose();
  }
}
