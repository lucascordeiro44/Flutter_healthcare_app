import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';
import 'package:flutter_dandelin/app_bloc.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/login/login_bloc.dart';
import 'package:flutter_dandelin/utils/otp_handler.dart';
import 'package:flutter_dandelin/utils/validators.dart';
import 'package:http/http.dart' as http;

class HttpException implements Exception {
  int statusCode;
  String cause;
  String code;

  HttpException(this.statusCode, this.cause, {this.code});

  @override
  String toString() {
    return "HttpException, Statuscode: $statusCode, cause: $cause";
  }
}

class ForbiddenException implements Exception {
  static String msgError;
  ForbiddenException();
}

class TimeoutException implements Exception {
  static String msgError = "Erro ao se comunicar com o servidor.";
  TimeoutException();
}

getHeaders() async {
  User user = appBloc.user;
  final headers = Map<String, String>();

  headers["Content-Type"] = "application/json";

  //token
  String token =
      await User.getToken(currentToken: user != null ? user.token : null);
  if (token != null) headers["Authorization"] = token;

  print("\t> headers : $headers");

  return headers;
}

Future<HttpResponse> get(String url,
    {int timeout = 30, Map<String, String> header}) async {
  print("> GET: $url");

  final headers = header != null ? header : await getHeaders();

  final response = await http
      .get(url, headers: headers)
      .timeout(Duration(seconds: timeout), onTimeout: _onTimeout);

  final r = parser(response);

  print("\t< GET: $url");
  print("");

  return r;
}

Future<HttpResponse> getBadges(String url, Map<String, String> header) async {
  print("> GET: $url");

  final response = await http
      .get(url, headers: header)
      .timeout(Duration(seconds: 10), onTimeout: _onTimeout);

  final r = parser(response);

  print("\t< GET: $url");
  print("");

  return r;
}


Future<HttpResponse> post(String url, Map body,
    {int timeout = 30, String task, TipoLoginSocial tipoLoginSocial}) async {
  print("> POST: $url");

  final headers = await getHeaders();

  String jsonBody = convert.json.encode(body);
  print("\t> body: $jsonBody");

  final response = await http
      .post(url, body: jsonBody, headers: headers)
      .timeout(Duration(seconds: timeout), onTimeout: _onTimeout);

  final r = parser(response, task: task, tipoLoginSocial: tipoLoginSocial);
  print(r);
  print("\t< POST: $url");
  print("");

  return r;
}

Future<HttpResponse> put(String url, Map body, {int timeout = 30}) async {
  print("> PUT: $url");

  final headers = await getHeaders();

  String jsonBody = convert.json.encode(body);
  print("\t> body: $jsonBody");
  final response = await http
      .put(url, body: jsonBody, headers: headers)
      .timeout(Duration(seconds: timeout), onTimeout: _onTimeout);

  print(response);
  final r = parser(response);

  print("\t< PUT: $url");
  print("");

  return r;
}

Future<HttpResponse> patch(String url, Map body, {int timeout = 30}) async {
  print("> PATCH: $url");
  print("\t> body: $body");

  final headers = await getHeaders();

  String jsonBody = convert.json.encode(body);

  final response = await http
      .patch(url, body: jsonBody, headers: headers)
      .timeout(Duration(seconds: timeout), onTimeout: _onTimeout);

  print(response);
  final r = parser(response);

  print("\t< PATCH: $url");
  print("");

  return r;
}

Future<HttpResponse> delete(String url, {int timeout = 30}) async {
  print("> DELETE: $url");
  final headers = await getHeaders();

  final response = await http
      .delete(url, headers: headers)
      .timeout(Duration(seconds: timeout), onTimeout: _onTimeout);

  print(response.statusCode.toString());

  final r = parser(response);

  print("\t< DELETE: $url");
  print("");
  return r;
}

class HttpResponse {
  int statusCode;
  String body;
  dynamic data;
  Map<String, String> headers;

  HttpResponse(this.statusCode, this.body, this.data, this.headers);

  @override
  String toString() {
    return "statusCode HttpResponse: ${statusCode.toString()}";
  }
}

HttpResponse parser(http.Response response, {String task, TipoLoginSocial tipoLoginSocial}) {
  final statusCode = response.statusCode;

  print("\t< status: ${response.statusCode}");

  dynamic data;

  if (isNotEmpty(response.body)) {
    final contentType = response.headers["content-type"];
    var isUtf8 =
        contentType != null && contentType.toUpperCase().contains("UTF-8");

    if (isUtf8) {
      // Converte para UTF-8
      String sUtf8 = convert.utf8.decode(response.bodyBytes);
      data = convert.jsonDecode(sUtf8);
    } else {
      data = convert.jsonDecode(response.body);
    }

    print("\t< $data");
  }

  if (response.statusCode == 403 ||
      response.headers['header_otp'] == "OTP_REQUIRED") {
    OtpHandler.twoFactor(task, tipoLoginSocial: tipoLoginSocial);
    return null;
  }

  if (response.statusCode == 500 || response.statusCode == 503) {
    throw HttpException(response.statusCode, "Servidor indisponível.");
  }

  if (response.statusCode != 200 && response.statusCode != 204) {
    String error;
    String code;

    if (response.body != "") {
      Map body = json.decode(response.body);
      error = body['errors'][0];
      code = body['code'];
    } else {
      error = "Error";
    }

    throw HttpException(response.statusCode, error, code: code);
  }

  if (response.statusCode == 204) {
    data = {
      'data': List<dynamic>(),
    };
  }

  return HttpResponse(statusCode, response.body, data, response.headers);
}

FutureOr<http.Response> _onTimeout() {
  throw TimeoutException();
}
