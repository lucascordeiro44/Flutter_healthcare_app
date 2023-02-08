import 'dart:async';

import 'package:flutter_dandelin/pages/chat2/constants_chat.dart';
import 'package:flutter_dandelin/pages/chat2/notificacao/badges.dart';
import 'package:flutter_dandelin/pages/chat2/notificacao/notificacao.dart';
import 'package:flutter_dandelin/pages/chat2/services/services.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils_livecom/http_helper.dart';
class NotificacoesService {
  static Future<ApiResponse<List<Notificacao>>> getNotificacoes(
      int page) async {
    try {
      final User user = await User.getPrefs();

      var url = "$BASE_URL/notifications.htm";
      print(url);

      final body = {
        "form_name": "form",
        "mode": "json",
        "user_id": user.login,
        "page": "$page",
        "buscaPosts": "1",
        "wsVersion": "3",
      };

      final map = await HttpHelper.post(url, body: body);

      String status = map["status"];
      String msg = map["msg"];
      bool ok = "OK" == status;

      if (ok) {
        final mapNotifications = map["notifications"];
        final mapList = mapNotifications["list"];
        print(mapList);
        List<Notificacao> list = mapList
            .map<Notificacao>((json) => Notificacao.fromJson(json))
            .toList();
        return ApiResponse.ok(result: list);
      }

      return ApiResponse.error(msg);
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }

  static Future<ApiResponse<Badges>> getNotificacoesCount() async {
    try {
      final User user = await User.getPrefs();

      var url = "$BASE_URL/notifications.htm";
      print(url);

      final body = {
        "form_name": "form",
        "mode": "json",
        "user_id": user.login,
        "list": "0",
        "count": "1",
        "wsVersion": "3",
      };

      final map = await HttpHelper.post(url, body: body);

      String status = map["status"];
      print(map);
      String msg = map["msg"];
      bool ok = "OK" == status;

      if (ok) {
        final mapNotifications = map["notifications"];
        Badges badges = Badges.fromJson(mapNotifications["badges"]);

        return ApiResponse.ok(result: badges);
      }

      return ApiResponse.error(msg);
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }

  static Future<ApiResponse<void>> markAsRead(
      {int notifId, bool readAll = false}) async {
    assert(notifId == null ||
        readAll == null && notifId != null ||
        readAll != null);

    try {
      final User user = await User.getPrefs();

      var url = "$BASE_URL/notifications.htm";
      print(url);

      final body = {
        "form_name": "form",
        "mode": "json",
        "user_id": user.login,
        "count": "1",
        "wsVersion": "3",
      };

      if (readAll) {
        body["markAllAsRead"] = "1";
      } else {
        body["id_notification"] = "$notifId";
        body["markAsRead"] = "1";
      }

      final map = await HttpHelper.post(url, body: body);

      String status = map["status"];
      print(map);
      String msg = map["msg"];
      bool ok = "OK" == status;

      if (ok) {
        return ApiResponse.ok();
      }

      return ApiResponse.error(msg);
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }

// static FutureOr<http.Response> _onTimeout() {
//   throw SocketException(
//       "Timeout - Não foi possível se comunicar com o servidor.");
// }
}
