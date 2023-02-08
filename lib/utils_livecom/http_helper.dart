import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter_dandelin/utils_livecom/validators.dart';
import 'package:http/http.dart' as http;

class HttpHelper {
  static var logUrlOn = true;
  static var logOn = false;

  static const _TIMEOUT = 30;

  static Future<Map> post(String url, {body, headers}) async {
    if (logUrlOn) {
      print("> (post): $url");
    }
    if (logOn) {
      print("> (body): $body");
      print("> (headers): $headers");
    }

    try {
      final response = await http
          .post(url, body: body, headers: headers)
          .timeout(const Duration(seconds: _TIMEOUT), onTimeout: _onTimeout);

      return parser(response);
    } catch (ex) {
      print("HttpHelper Error: $ex");
      if (ex is SocketException) {
        throw SocketException("Internet Indisponível.");
      }
      throw SocketException(
          "Erro ao consultar servidor, verifique sua conexão.");
    }
  }

  static Future<Map> get(String url, headers) async {
    var headers = {"Content-Type": "application/json"};

    if (logOn) {
      print("> (get): $url");
      print("> (headers): $headers");
    }

    final response = await http
        .get(Uri.encodeFull(url), headers: headers)
        .timeout(const Duration(seconds: _TIMEOUT), onTimeout: _onTimeout);

    if (logOn) {
      print("   < ${response.body}");
    }

    return parser(response);
  }

  static Map parser(http.Response response) {
    final s = convert.utf8.decode(response.bodyBytes);
    if (logOn) {
      print(s);
    }

    final statusCode = response.statusCode;
    if (logUrlOn) {
      print(" < ($statusCode) ${s.substring(0, 20)}...");
    }
    if (logOn) {
      print(" < ($statusCode) $s");
    }

    final ok = statusCode == 200;

    if (!ok) {
      throw SocketException("Servidor Indisponível.");
    }

    // Parser do JSON
    final map = convert.json.decode(s) as Map<String, dynamic>;
    return map;
  }

  static FutureOr<http.Response> _onTimeout() {
    throw SocketException(
        "Timeout - Não foi possível se comunicar com o servidor.");
  }
}

class HttpException implements Exception {
  int statusCode;
  String cause;

  HttpException(this.statusCode, this.cause);

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
  final headers = Map<String, String>();

  headers["Content-Type"] = "application/json";

  return headers;
}

Future<HttpResponse> get(String url, {int timeout = 30}) async {
  print("> GET: $url");

  final headers = await getHeaders();

  final response = await http
      .get(url, headers: headers)
      .timeout(Duration(seconds: timeout), onTimeout: _onTimeout);

  final r = parser(response);

  print("\t< GET: $url");
  print("");

  return r;
}

Future<HttpResponse> post(String url, Map body, {int timeout = 30}) async {
  print("> POST: $url");

  final headers = await getHeaders();

  String jsonBody = convert.json.encode(body);
  print("\t> body: $jsonBody");

  final response = await http
      .post(url, body: jsonBody, headers: headers)
      .timeout(Duration(seconds: timeout), onTimeout: _onTimeout);

  final r = parser(response);
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

HttpResponse parser(http.Response response) {
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

  if (response.statusCode == 500 || response.statusCode == 503) {
    throw HttpException(response.statusCode, "Servidor indisponível.");
  }

  if (response.statusCode != 200 && response.statusCode != 204) {
    String error;

    if (response.body != "") {
      Map body = convert.json.decode(response.body);
      error = body['errors'][0];
    } else {
      error = "Error";
    }

    throw HttpException(response.statusCode, error);
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
