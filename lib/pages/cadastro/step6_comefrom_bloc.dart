import 'dart:convert';

import 'package:flutter_dandelin/utils/imports.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';

class CameFromBloc {
  final button = ButtonBloc();
  final cameFromValue = SimpleBloc();

  final tDescricaoController = TextEditingController();

  String get value => cameFromValue.value;

  validate() {
    bool valid;

    if (value == null) {
      valid = false;
    }

    if (value == "Google") {
      valid = true;
    } else if (value != "Google" && isNotEmpty(tDescricaoController.text)) {
      valid = true;
    } else {
      valid = false;
    }

    button.setEnabled(valid);
  }

  changeCameFromValue(String v) {
    tDescricaoController.clear();
    cameFromValue.add(v);

    validate();
  }

  Future<ApiResponse> cadastrar(User user) async {
    try {
      button.setEnabled(false);
      button.setProgress(true);

      user.firebaseId = await FirebaseMessaging().getToken();
      user.cameFrom = CameFrom(
        channel: value.toUpperCase(),
        description: tDescricaoController.text,
      );

      user.so = Platform.isAndroid ? "android" : "ios";

      HttpResponse response = await CadastroApi.cadastrar(user);

      User userResponse = User.fromJson(json.decode(response.body));

      user.token = response.headers['authorization'];

      user.id = userResponse.id;
      user.status = userResponse.status;

      appBloc.setUser(user);

      Prefs.setBool('tutorial_done', false);
      Prefs.setString('user.prefs', json.encode(user.toJson()));

      return ApiResponse.ok();
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      button.setEnabled(true);
      button.setProgress(false);
    }
  }

  dispose() {
    button.dispose();
    cameFromValue.dispose();
    tDescricaoController.dispose();
  }
}
