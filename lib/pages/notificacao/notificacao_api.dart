import 'package:flutter_dandelin/model/notificacao.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class NotificacaoApi {
  static Future getNotificacoes() async {
    try {
      var url = "$baseUrl/api/notifications/user";

      HttpResponse response = await get(url);

      print(response);

      final list = response.data['data'] as List;

      List<Notificacao> listNot =
          list.map<Notificacao>((json) => Notificacao.fromJson(json)).toList();

      return ApiResponse.ok(result: listNot);
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

  static Future<ApiResponse> readNotificacao(Notificacao notificacao) async {
    try {
      var url = "$baseUrl/api/notifications/checked/${notificacao.id}";

      HttpResponse response = await get(url);

      print(response);

      return ApiResponse.ok();
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
}
