import 'dart:async';
import 'dart:convert' as convert;
import 'package:connectivity/connectivity.dart';
import 'package:flutter_dandelin/model/doctor.dart';
import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/chat_mensagem_info_bloc.dart';
import 'package:flutter_dandelin/pages/chat2/constants_chat.dart';
import 'package:flutter_dandelin/pages/chat2/services/services.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/model/user.dart' as userDandelin;
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dandelin/constants.dart';



class ChatService {
  static Future<ApiResponse<List<Chat>>> getConversas(int page) async {
    verifyConnectivity();

    try {
      final User user = await User.getPrefs();

      var url = BASE_URL + "/conversas.htm";
      print(url);

      final body = {
        "mode": "json",
        "form_name": "form",
        "search": "",
        "user_id": user.id.toString(),
        "user": user.login,
        "page": "$page",
        "maxRows": "10",
        "wsVersion": "3",
      };

      print("body chat $body");

      final response = await http.post(url, body: body);

      final json = response.body;
      // print(json);

      final map = convert.json.decode(json);

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
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }

  static Future<ApiResponse<List<Chat>>> getChat(
      {int page, int conversaId}) async {
    try {
      final User user = await User.getPrefs();

      var url = BASE_URL + "/conversa.htm";

      var body = {
        "id": conversaId.toString(),
        "user_id": user.id.toString(),
        "page": page.toString(),
        "mode": "json",
        "wsVersion": "3",
        "maxRows": "30",
        "form_name": "form",
      };

      print(body.toString());

      final response = await http
          .post(url, body: body)
          .timeout(Duration(seconds: 10), onTimeout: onTimeout);

      final json = response.body;

      final map = convert.json.decode(json);

      String status = map["status"];
      String msg = map["mensagem"];

      bool ok = "OK" == status;
      if (ok) {
        final mapConversas = map["conversa"]["mensagens"];
        if (mapConversas != null) {
          List<Chat> listConversas =
              mapConversas.map<Chat>((json) => Chat.fromJson(json)).toList();
          return ApiResponse.ok(result: listConversas);
        } else {
          return ApiResponse.ok();
        }
      }

      return ApiResponse.error(msg);
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }


  static Future<ApiResponse<Chat>> getChatNovaCoversa(
      {int page, int conversaId}) async {
    try {
      final User user = await User.getPrefs();

      var url = BASE_URL + "/conversa.htm";

      var body = {
        "id": conversaId.toString(),
        "user_id": user.id.toString(),
        "page": page.toString(),
        "mode": "json",
        "wsVersion": "3",
        "maxRows": "30",
        "form_name": "form",
      };

      print(body.toString());

      final response = await http
          .post(url, body: body)
          .timeout(Duration(seconds: 10), onTimeout: onTimeout);

      final json = response.body;

      final map = convert.json.decode(json);

      String status = map["status"];
      String msg = map["mensagem"];

      bool ok = "OK" == status;
      if (ok) {
        final json = map["conversa"];
        if (json != null) {
          Chat conversa = Chat.fromJson(json);
          return ApiResponse.ok(result: conversa);
        } else {
          return ApiResponse.ok();
        }
      }

      return ApiResponse.error(msg);
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }

  static Future<ApiResponse<MsgInfo>> getMsgInfo(int msgId) async {
    try {
      final User user = await User.getPrefs();

      var url = BASE_URL + "/mensagemInfo.htm";

      var body = {
        "id": msgId.toString(),
        "user_id": user.id.toString(),
        "mode": "json",
        "wsVersion": "3",
        "form_name": "form",
      };

      print(body.toString());

      final response = await http
          .post(url, body: body)
          .timeout(Duration(seconds: 10), onTimeout: onTimeout);

      final json = response.body;

      final map = convert.json.decode(json);

      String status = map["status"];
      String msg = map["mensagem"];

      bool ok = "OK" == status;
      if (ok) {
        final msgInfo = map["msgInfo"];
        if (msgInfo != null) {
          return ApiResponse.ok(result: MsgInfo.fromJson(msgInfo));
        } else {
          return ApiResponse.ok();
        }
      }

      return ApiResponse.error(msg);
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }

  static Future<ApiResponse<List<StatusMensagens>>> getStatusMensagem(
      int msgId) async {
    try {
      final User user = await User.getPrefs();

      var url = BASE_URL + "/statusMensagemUsuario.htm";

      var body = {
        "id": msgId.toString(),
        "user_id": user.id.toString(),
        "mode": "json",
        "wsVersion": "3",
        "form_name": "form",
      };

      print(body.toString());

      final response = await http
          .post(url, body: body)
          .timeout(Duration(seconds: 10), onTimeout: onTimeout);

      final json = response.body;

      final map = convert.json.decode(json);

      String status = map["status"];
      String msg = map["mensagem"];

      bool ok = "OK" == status;
      if (ok) {
        final msgInfo = map["statusMensagens"];
        if (msgInfo != null) {
          List<StatusMensagens> listStatus = msgInfo
              .map<StatusMensagens>((json) => StatusMensagens.fromJson(json))
              .toList();

          return ApiResponse.ok(result: listStatus);
        } else {
          return ApiResponse.ok();
        }
      }

      return ApiResponse.error(msg);
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }


  static Future<ApiResponse<List<Doctor>>> getUsersNovaConversa(
      {int page = 0, String search = "", int size = 10}) async {
    try {

      final dandelinUser = await userDandelin.User.get();
      var headers = {"Content-Type": "application/json", "Authorization": dandelinUser.token};
      var url = baseUrl + "/api/doctors/chat/scheduled?size=$size&orderBy=fullName&filter=ASC&search=&page=$page";

      var body = {
        "search": search
      };

      String jsonBody = convert.json.encode(body);

      final response = await http.post(url, body: jsonBody, headers: headers).timeout(Duration(seconds: 10), onTimeout: onTimeout);
      final json = response.body;

      final map = convert.json.decode(json);

      String msg = map["message"];

      if (response.statusCode == 200) {
        final list = map["data"];

        if (list != null) {
          List<Doctor> doctors = list.map<Doctor>((json) => Doctor.fromJson(json)).toList();

          return ApiResponse.ok(result: doctors);
        } else {
          return ApiResponse.ok();
        }
      }

      return ApiResponse.error(msg);
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }

  static Future<ApiResponse> deletarConversa(int conversaId) async {
    try {
      final User user = await User.getPrefs();

      var url = BASE_URL + "/deletar.htm";

      var body = {
        "id": conversaId.toString(),
        "user_id": user.id.toString(),
        "tipo": "conversa",
        "mode": "json",
        "wsVersion": "3",
        "form_name": "form",
      };

      print(body.toString());

      final response = await http
          .post(url, body: body)
          .timeout(Duration(seconds: 10), onTimeout: onTimeout);

      final json = response.body;

      final map = convert.json.decode(json);

      String status = map["status"];
      String msg = map["mensagem"];

      bool ok = "OK" == status;

      if (ok) {
        return ApiResponse.ok();
      }

      return ApiResponse.error(msg);
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }

  static Future<ApiResponse<Chat>> getConversaUser(int userId) async {
    try {
      final User user = await User.getPrefs();

      var headers = {"Content-Type": "application/json"};

      var url = BASE_URL2 + "/rest/chat/conversa/usuario";

      var body = {
        "user_from_id": user.id.toString(),
        "user_to_id": userId.toString(),
        "mode": "json",
        "wsVersion": "3",
        "form_name": "form",
      };

      print(body.toString());

      String jsonBody = convert.json.encode(body);

      final response = await http.post(url, body: jsonBody, headers: headers).timeout(Duration(seconds: 10), onTimeout: onTimeout);

      // final response = await http
      //     .post(url, body: body, headers: headers)
      //     .timeout(Duration(seconds: 10), onTimeout: onTimeout);

      final json = response.body;

      final map = convert.json.decode(json);

      String status = map["status"];
      String msg = map["mensagem"];

      bool ok = "OK" == status;

      if (ok) {
        var c = map['msg'];

        return ApiResponse.ok(result: Chat.fromJson(c));
      }

      return ApiResponse.error(msg);
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }

  static Future<ApiResponse> createVideoConferencia(int chatId) async {
    try {
      final User user = await User.getPrefs();

      var url = "$BASE_URL2/rest/chat/meet/$chatId/user/${user.id}";

      print(url);

      final response = await http
          .get(url)
          .timeout(Duration(seconds: 10), onTimeout: onTimeout);

      final json = response.body;

      final map = convert.json.decode(json);

      String urlMeet = map['url'];

      if (urlMeet != null) {
        return ApiResponse.ok(result: urlMeet);
      }

      return ApiResponse.error('Erro ao criar link');
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }

  static verifyConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    print(connectivityResult);
    if (connectivityResult == ConnectivityResult.none) {
      return ApiResponse.error("Internet indisponível.");
    }
  }
}
