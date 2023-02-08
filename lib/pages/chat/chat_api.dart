import 'dart:convert';

import 'package:flutter_dandelin/pages/chat/chat.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:http/http.dart' as http;

class ChatApi {
  static fetchChats(int page) async {
    try {
      var url = "https://dandelin.livetouchdev.com.br/ws/conversas.htm";
      print(url);

      final body = {
        "mode": "json",
        "form_name": "form",
        "search": "",
        "user_id": appBloc.livecomId.toString(),
        "page": "$page",
        "maxRows": "10",
        "wsVersion": "3",
      };

      print("body chat $body");

      final response = await http.post(url, body: body);

      final b = response.body;
      // print(json);

      final map = json.decode(b);

      String status = map["status"];
      String msg = map["mensagem"];

      bool ok = "OK" == status;
      if (ok) {
        final mapConversas = map["mensagens"];
        List<Chat> listConversas =
            mapConversas.map<Chat>((json) => Chat.fromJson(json)).toList();
        return ApiResponse.ok(result: listConversas);
      }

      return ApiResponse.error(msg);
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
        return ApiResponse.error(msg);
      }
      msg = error.toString();
      return ApiResponse.error(msg);
    }
  }

  static Future<ApiResponse> getTotalBadges() async {
    try {
      var url = "$WS/rest/chat/badges";

      String wstoken = await Prefs.getString('livecom.wstoken');

      final headers = {
        "Content-Type": "application/json",
        "Authorization": wstoken,
      };

      print("headers > $headers");

      HttpResponse response = await getBadges(url, headers);

      print(response);
      final mensagens = response.data['mensagens'] as int;

      return ApiResponse.ok(result: mensagens);
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

  FutureOr<http.Response> onTimeout() {
    throw SocketException(
        "Timeout - Não foi possível se comunicar com o servidor.");
  }
}
