import 'package:flutter_dandelin/pages/cadastro/pre_cadastro_api.dart';
import 'package:flutter_dandelin/pages/home/home_api.dart';
import 'package:flutter_dandelin/pages/login/login_api.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/otp_handler.dart';
import 'package:flutter_dandelin/utils/prefs.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';

class LoginBloc {
  final button = ButtonBloc();
  final checkButton = BooleanBloc();
  final updateTerms = SimpleBloc<bool>();

  validate(LoginForm loginForm) {
    button.setEnabled(loginForm.validate());
  }

  Future<ApiResponse> login(LoginForm loginForm) async {
    button.setProgress(true);
    ApiResponse response = await OtpHandler.loginHandler(loginForm);

    bool check = checkButton.value ?? false;
    Prefs.setBool('remember.user', check);

    button.setProgress(false);

    return response;
  }



  Future<ApiResponse> loginSocial(LoginForm loginForm, TipoLoginSocial tipo) async {
    button.setProgress(true);
    ApiResponse response = await OtpHandler.loginHandler(loginForm, tipo: tipo);

    bool check = checkButton.value ?? false;
    Prefs.setBool('remember.user', check);
    button.setProgress(false);
    return response;
  }

  Future<bool> fetchHasUpdateTermos() async {
    ApiResponse response = await LoginApi.getHasUpdateTermos();
    bool hasUpdate = false;
    if (response.ok) {
      hasUpdate = response.result as bool;
    }
    updateTerms.add(hasUpdate);
    return hasUpdate;
  }

  void agreeuserTerms() async {
    await LoginApi.postUpdateTerms();
  }

  Future<ApiResponse> checkEmailExists(String email) async {
    try {
      HttpResponse response = await CadastroApi.checkEmailExists(email);

      if (response.statusCode == 204) {
        return ApiResponse.ok();
      } else {
        return ApiResponse.error(response.statusCode == 200
            ? response.data['data']
            : 'Algo deu errado.');
      }
    } catch (e) {
      return ApiResponse.error(e);
    }
  }


  dispose() {
    checkButton.dispose();
    button.dispose();
    updateTerms.dispose();
  }
}

enum TipoLoginSocial {
  facebook,
  google,
  apple
}


