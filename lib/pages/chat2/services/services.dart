import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/constants_chat.dart';
import 'package:flutter_dandelin/pages/chat2/post/file_serv.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:dio/dio.dart';

int maxRows = 20;
int maxComments = 5;
int timeOut = 15;

final headers = {
  "Content-Type": "application/json",
};

String handleError(error, {String msg = "Ocorreu um erro na consulta."}) {
  print(error);
  return error is SocketException
      ? "Internet indisponível. Por favor, verifique a sua conexão"
      : msg;
}

Future<ApiResponse> uploadFile(File file) async {
  try {
    Dio dio = Dio();
    final User user = await User.getPrefs();

    var url = BASE_URL + "/uploadFile.htm?mode=json&form_name=form";

    FormData formData = FormData.fromMap({
      "user_id": user.id.toString(),
      "dir": "arquivos",
      "mode": "json",
      "dimensao": "original",
      "tipo": "1",
      "form_name": "form",
      "fileField": await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last),
    });

    var response = await dio.post(url, data: formData);

    var map = response.data;

    if (map['file'] != null) {
      return ApiResponse.ok(result: FileServ.fromJson(map['file']));
    }

    return ApiResponse.error(map['error']);
  } catch (error) {
    return ApiResponse.error(
        handleError(error, msg: "Não foi possível postar post"));
  }
}

Future<ApiResponse> getLinkInfo(String u) async {
  try {
    var url = BASE_URL2 + "/rest/v1/links/info?url=$u";

    print(url);

    final response = await http
        .get(url, headers: headers)
        .timeout(Duration(seconds: timeOut), onTimeout: onTimeout);

    final json = response.body;

    print(json);

    final map = convert.json.decode(json);

    String status = map["status"];

    bool ok = "OK" == status;

    if (ok) {
      return ApiResponse.ok(result: Entity.fromJson(map['entity']));
    }

    return ApiResponse.error(map['error']);
  } catch (e) {
    return ApiResponse.error(
        handleError(e, msg: "Não foi possível obter infos do link"));
  }
}

FutureOr<http.Response> onTimeout() {
  throw SocketException(
      "Timeout - Não foi possível se comunicar com o servidor.");
}

verifyConnectivity() async {
  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult == ConnectivityResult.none) {
    return ApiResponse.error("Internet indisponível.");
  }
}
