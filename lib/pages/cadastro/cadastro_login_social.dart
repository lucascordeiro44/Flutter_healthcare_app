import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/login/apple_auth_service.dart';
import 'package:flutter_dandelin/pages/login/facebook_sign_in.dart';
import 'package:flutter_dandelin/pages/login/google_sign_in.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart' as AuthUser;
import 'package:firebase_core/firebase_core.dart';

import '../../firebase.dart';

class EscolherTipoCadastroPage extends StatefulWidget {
  @override
  _EscolherTipoCadastroPageState createState() =>
      _EscolherTipoCadastroPageState();
}

class _EscolherTipoCadastroPageState extends State<EscolherTipoCadastroPage> {
  Color _primaryColor;

  final _bloc = PreCadastroBloc();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: _primaryColor),
        elevation: 1,
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        title: Text("Cadastro"),
        centerTitle: true,
      ),
      body: _body(),
    );
  }

  _body() {
    return Column(
      children: <Widget>[
        //InkWell(child: MiniLogo()),
        SizedBox(height: 30),
        AppText("Escolha seu meio de cadastro", fontSize: 26),
        SizedBox(height: 20),
        _signUpGoogleButton(),
        _signUpFacebookButton(),
        _signUpAppleButton(),
        SizedBox(height: 16),
        _cadastrarButton()
      ],
    );
  }

  _cadastrarButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RawMaterialButton(
          onPressed: () {
            push(PreCadastroPage());
          },
          child: AppText(
            "Cadastre-se com email",
            color: Colors.blue,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        )
      ],
    );
  }

  _signUpFacebookButton() {
    return _socialButton(
        "assets/logos/facebook_logo.png",
        "Cadastre-se com Facebook",
        Color(0xFF3B5998),
        TipoLoginSocial.facebook);
  }

  _onClickSignInFb() {
    FacebookAuthService.signInFB().then((result) {
      if (result != null) {
        String socialEmail = FacebookAuthService.email;
        String socialFirstName = FacebookAuthService.firstName;
        String socialLastName = FacebookAuthService.lastName;
        String uid = FacebookAuthService.uid;
        _onClickCadastrase(
            email: socialEmail,
            firstName: socialFirstName,
            lastName: socialLastName,
            uid: uid);
      }
    });
  }

  _signUpGoogleButton() {
    return _socialButton("assets/logos/google_logo.png",
        "Cadastre-se com Google", Colors.white, TipoLoginSocial.google);
  }

  _onClickSignInGoogle() {
    GoogleAuthService.signInWithGoogle().then((result) {
      if (result != null) {
        String socialEmail = result.email;
        String socialFirstName = GoogleAuthService.firstName;
        String socialLastName = GoogleAuthService.lastName;
        String uid = GoogleAuthService.uid;
        _onClickCadastrase(
            email: socialEmail,
            firstName: socialFirstName,
            lastName: socialLastName,
            uid: uid);
      }
    });
  }

  _signUpAppleButton() {
    return FutureBuilder(
      future: AppleSignIn.isAvailable(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return _socialButton('assets/logos/apple_logo.png',
              "Cadastre-se com a Apple", Colors.black, TipoLoginSocial.apple);
        } else {
          return Container();
        }
      },
    );
  }

  _onClickSignInApple() async {
    AuthUser.User user = await AppleAuthService.signInWithApple();
    if (user != null) {
      String socialEmail = AppleAuthService.email;
      String socialFirstName = AppleAuthService.firstName;
      String socialLastName = AppleAuthService.lastName;
      String uid = AppleAuthService.uid;

      if (socialEmail == null) {
        return;
      }

      _onClickCadastrase(
          email: socialEmail,
          firstName: socialFirstName,
          lastName: socialLastName,
          uid: uid);
    }
    print("$user");
  }

  _socialButton(String logo, String text, Color backgroundColor,
      TipoLoginSocial tipoLoginSocial) {
    return Container(
      margin: EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
        padding: EdgeInsets.only(right: 20, top: 5.0, bottom: 5.0, left: 20),
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

  _onClickCadastrase(
      {String email = "",
      String firstName = "",
      String lastName = "",
      String uid = ""}) async {
    screenAction('cadastrar', "Tocou em 'Cadastre-se'");
    if (email.isEmpty) {
      push(PreCadastroPage());
    } else {
      ApiResponse emailApi = await _bloc.checkEmailExists(email);
      if (!emailApi.ok) {
        await showSimpleDialog(emailApi.msg);
      } else {
        push(PreCadastroPage(
          email: email,
          firstName: firstName == null || firstName == "null" ? "" : firstName,
          lastName: lastName == null || lastName == "null" ? "" : lastName,
          uid: uid,
        ));
      }
    }
  }
}
