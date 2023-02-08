import 'dart:convert';

import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dandelin/constants.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/validators.dart';

import '../../app_bloc.dart';

class LoginForm {
  String username;
  String password;
  String codigo;

  LoginForm({this.username, this.password, this.codigo});

  bool validate() {
    return isNotEmpty(username) &&
        (isValidEmail(username) || CPFValidator.isValid(username)) &&
        isNotEmpty(password);
  }

  Map toMap() {
    Map map = {
      CPFValidator.isValid(username) ? "document" : "username": username,
      "password": password,
      // "os": Platform.isAndroid ? "android" : "ios",
    };

    if (isNotEmpty(this.codigo)) {
      map["code"] = this.codigo;
    }
    return map;
  }

  LoginForm.fromJson(Map json) {
    this.username = json["username"];
    this.password = json["password"];
  }

  savePrefs() {
    Prefs.setString('login_form', json.encode(this.toMap()));
  }

  static getPrefs() async {
    String form = await Prefs.getString('login_form');

    return LoginForm.fromJson(json.decode(form));
  }
}

class LoginApi {
  static Future<HttpResponse> login(LoginForm loginForm) async {
    try {
      final url = "$baseUrl/api/login";

      loginForm.savePrefs();

      HttpResponse response = await post(url, loginForm.toMap(), task: "login");

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause.toString();
      }

      throw error.toString();
    }
  }

  static Future<HttpResponse> loginSocial(LoginForm loginForm, TipoLoginSocial tipo) async {
    try {
      var url;
      if(tipo == TipoLoginSocial.google){
        url = "$baseUrl/api/login/google";
      } else if (tipo == TipoLoginSocial.facebook) {
        url = "$baseUrl/api/login/facebook";
      } else {
        url = "$baseUrl/api/login/apple";
      }

      loginForm.savePrefs();

      HttpResponse response = await post(url, loginForm.toMap(), task: "login", tipoLoginSocial: tipo);

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause.toString();
      }
      throw error.toString();
    }
  }


  static Future<ApiResponse> getHasUpdateTermos() async {
    try {
      var url = "$baseUrl/api/terms/has/update";

      HttpResponse response = await get(url);

      final data = response.data['data'];
      final update = data['update'] as bool;

      return ApiResponse.ok(result: update);
    } on SocketException {
      return ApiResponse.error(kOnSocketException);
    } on ForbiddenException {
      return ApiResponse.error(ForbiddenException.msgError);
    } on TimeoutException {
      return ApiResponse.error(TimeoutException.msgError);
    } catch (error) {
      String msg;
      if (error?.cause != null) {
        msg = error.cause.toString();
      }
      msg = error.toString();
      return ApiResponse.error(msg);
    }
  }

  static Future<HttpResponse> postUpdateTerms() async {
    try {
      final url = "$baseUrl/api/terms/agree";
      HttpResponse response = await post(url, {});

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } on TypeError {
      throw "Error serv";
    } catch (error, stacktrace) {
      print("Login error: $error - $stacktrace");
      if (error.cause != null) {
        throw error.cause.toString();
      }

      throw error.toString();
    }
  }

  static Future patchFirebaseId(String firebaseId) async {
    try {
      final url = "$baseUrl/api/users/firebase/$firebaseId";

      HttpResponse response = await patch(url, {});
      print(response);
    } catch (e) {
      print(e);
    }
  }

  static Future getLivecomToken(User user) async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceName;
      String deviceOsVersion;
      String deviceOs;

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceOs = "android";
        deviceName = androidInfo.model;
        deviceOsVersion = androidInfo.version.sdkInt.toString();
      } else {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceOs = "ios";
        deviceName = iosInfo.model;
        deviceOsVersion = iosInfo.systemVersion;
      }

      var url = "https://dandelin.livetouchdev.com.br/rest/chat/login";

      var map = {
        "getBadges": true,
        "user": {
          "login": user.username,
          "email": user.username,
          "nome": user.getUserFullName,
          "urlFoto": user.avatar,
          "device": {
            "registrationId": await FirebaseMessaging().getToken(),
            "deviceName": deviceName,
            "deviceOs": deviceOs,
            "deviceOsVersion": deviceOsVersion,
            "appVersionCode": kAppVersionCode,
            "appVersion": kAppVersion,
          },
        }
      };

      HttpResponse response = await post(url, map);

      print(response);

      Map data = response.data;

      bool ok = data['status'] == "OK";
      if (ok) {
        Map entity = data['entity'];
        String wstoken = entity['wstoken'];
        int livecomId = entity['userId'];
        print("livecom token: " + wstoken);



        User user = appBloc.user;
        user.livecomId = livecomId;
        appBloc.setUser(user);
      }
    } on SocketException {
      throw kOnSocketException;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause.toString();
      }

      throw error.toString();
    }
  }
}
