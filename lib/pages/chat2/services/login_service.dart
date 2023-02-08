import 'dart:async';
import 'dart:io';
import 'package:flutter_dandelin/pages/chat2/constants_chat.dart';
import 'package:flutter_dandelin/pages/chat2/services/services.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/prefs.dart';
import 'package:flutter_dandelin/utils_livecom/http_helper.dart';


class LoginChatService {
  static Future<ApiResponse<User>> loginChatDandelin(
      String login, String senha, bool keepAlive) async {
    try {
      var url = "$BASE_URL/login.htm";
      print("Login chat Dandelin $url");

      // TODO Henrique passar outros params
      final body = {
        "form_name": "form",
        "mode": "json",
        "user": login,
        "password": senha,
        "wsVersion": "3",
        "device.so": Platform.isAndroid ? "android" : "iOS"
      };

      final map = await HttpHelper.post(url, body: body);

      String status = map["status"];
      String msg = map["mensagem"];
      bool ok = "OK" == status;
      User user;

      if (ok) {
        final mapUser = map["user"];
        print(mapUser["livecomConfig"]["menuMobile"]);

        user = User.fromJson(mapUser);
        user.senha = senha;
        user.savePrefs();
        print("User prefs $user");

        Prefs.setBool("login.keepAlive", keepAlive);
        await Prefs.setString('livecom.livecomId', user.id.toString());
        await Prefs.setString('livecom.wstoken', user.token);
        return ApiResponse.ok(result: user, msg: msg);
      }

      return ApiResponse.error(msg);
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }

  static Future<ApiResponse<void>> esqueciSenha(String login) async {
    try {
      var url = "$BASE_URL/esqueciSenha.htm";

      final body = {
        "form_name": "form",
        "mode": "json",
        "login": login,
        "wsVersion": "3"
      };

      final map = (await HttpHelper.post(url, body: body));

      String status = map["status"];
      String msg = map["mensagem"];
      bool ok = "OK" == status;

      if (ok) {
        return ApiResponse.ok(msg: msg);
      }

      return ApiResponse.ok(msg: 'Erro ao tentar recuperar a senha');
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }
}
