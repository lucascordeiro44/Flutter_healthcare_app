import 'package:flutter_dandelin/constants.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';

class AlterarSenhaApi {
  static Future alterarSenha(AlterarSenhaForm form,
      {bool hasToken = false}) async {
    try {
      var url = "$baseUrl/api/users/password/redefine";
      if (hasToken) {
        url = "$url/token";
      }

      await patch(url, form.toJson(hasToken: hasToken));

      return ApiResponse.ok();
    } on ForbiddenException {
      return ApiResponse.error(ForbiddenException.msgError);
    } catch (error, stacktrace) {
      print("Login error: $error - $stacktrace");
      return ApiResponse.error(error.cause);
    }
  }
}

class AlterarSenhaForm {
  String codigo;
  String senhaAtual;
  String senhaNova;
  String confirmSenha;

  Map<String, dynamic> toJson({bool hasToken = false}) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (hasToken) {
      data['token'] = this.codigo;
      data['password'] = this.confirmSenha;
      data['newPassword'] = this.senhaNova;
    } else {
      data['password'] = this.senhaAtual;
      data['newPassword'] = this.senhaNova;
    }

    return data;
  }
}
