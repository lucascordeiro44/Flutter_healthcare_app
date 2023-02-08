import 'package:flutter_dandelin/pages/login/recuperar_senha_api.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/validators.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';

class RecuperarSenhaBloc {
  final button = new ButtonBloc();
  final sentEmail = BooleanBloc();

  updateForm(String email) {
    bool v = isValidEmail(email) && isNotEmpty(email);
    button.setEnabled(v);
  }

  Future<ApiResponse> enviar(String email) async {
    try {
      button.setProgress(true);
      await RecuperarSenhaApi.enviar(email);

      return ApiResponse.ok();
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      button.setProgress(false);
      button.setEnabled(false);
    }
  }

  dispose() {
    sentEmail.dispose();
    button.dispose();
  }
}
