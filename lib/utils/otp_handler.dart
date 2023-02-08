import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dandelin/app_bloc.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/chat2/services/login_service.dart';
import 'package:flutter_dandelin/pages/confirmar_codigo/confirmar_codigo_page.dart';
import 'package:flutter_dandelin/pages/login/login_api.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/nav.dart';
import 'package:flutter_dandelin/utils/prefs.dart';
import 'package:flutter_dandelin/utils/secure_storage.dart';

class OtpHandler {
  static twoFactor(String task, {TipoLoginSocial tipoLoginSocial}) async {
    if (task == "login") {
      push(ConfimarCodigoPage(otp: true, tipoLogin: tipoLoginSocial,));
    } else {
      await showSimpleDialog(
          "Precisamos renovar seu Token, para isso é necessário que você efetue o login novamente.");
      appBloc.logout();
      push(LoginPage(), replace: true, popAll: true);
    }
  }

  static Future loginHandler(LoginForm loginForm, {TipoLoginSocial tipo}) async {

    HttpResponse response;
    try {
      if(tipo != null){
        response = await LoginApi.loginSocial(loginForm, tipo);
      } else {
        response = await LoginApi.login(loginForm);
      }

      User user;
      if (response.data != null) {
        user = User.fromJson(response.data);
        user.token = response.headers['authorization'];
        //tag interna para controlar caso ele queira mudar de telefone.
        user.telefoneValido = true;
        appBloc.setUser(user);
        Prefs.setString('user.prefs', json.encode(user.toJson()));
      }

      Prefs.setBool('tutorial_done', true);
      SecureStorage.writeValue('senhaLogin', loginForm.password);

      LoginApi.patchFirebaseId(await FirebaseMessaging().getToken());
      await LoginApi.getLivecomToken(user);
      await LoginChatService.loginChatDandelin(loginForm.username, "abc123", true);

      return ApiResponse.ok();
    } catch (e) {
      if (e is NoSuchMethodError) {
        return null;
      }
      return ApiResponse.error(e);
    }
  }
}
