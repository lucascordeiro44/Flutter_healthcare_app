import 'package:flutter_dandelin/pages/confirmar_codigo/confirmar_codigo_api.dart';
import 'package:flutter_dandelin/pages/login/login_api.dart';
import 'package:flutter_dandelin/pages/login/login_bloc.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/otp_handler.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';

class ConfirmarCodigoBloc {
  final button = ButtonBloc();

  login(String token, TipoLoginSocial tipo) async {
    button.setProgress(true);
    LoginForm form = await LoginForm.getPrefs();
    form.codigo = token;
    ApiResponse response = await OtpHandler.loginHandler(form, tipo: tipo);

    button.setProgress(false);
    return response;
  }

  sendSms(String telefone) async {
    return await TelefoneApi.sendSms(telefone);
  }

  dispose() {
    button.dispose();
  }
}
