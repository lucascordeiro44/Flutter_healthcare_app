import 'package:flutter_dandelin/pages/cupons_aplicados/cupom.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class CuponsAplicadosApi {

  static Future getCuponsAplicados({int page = 0}) async {
    try {
      var url = "$baseUrl/api/discount/user/filter/discountsUser";

      Map<String, String> emptyMap = {};

      HttpResponse response = await post(url, emptyMap);

      print(response);

        var list = response.data['data'] as List;
        List<Cupom> listNot =
        list.map<Cupom>(
                (json) => Cupom.fromJson(json)
        ).toList();

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


  static Future getCuponsAplicadosMgm({int page = 0}) async {
    try {
      var url = "$baseUrl/api/discount/user/filter/discounts?page=$page&size=8&search=";

      Map<String, String> emptyMap = {};

      HttpResponse response = await post(url, emptyMap);

      print(response);

      // String status = response["status"];
      // bool ok = "OK" == status;

      var list = response.data['data'] as List;
      List<Cupom> listNot =
      list.map<Cupom>((json) => Cupom.fromJson(json)).toList();
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
}