import 'package:flutter_dandelin/pages/cadastro/pre_cadastro_api.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/validators.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';

class PreCadastroBloc {
  final button = ButtonBloc();

  final termos = BooleanBloc();
  final nomeCompleted = BooleanBloc();
  final sobrenomeCompleted = BooleanBloc();
  final cpfCorrect = BooleanBloc();
  final emailCorrect = BooleanBloc();
  final confirmEmailCorrect = BooleanBloc();
  final senhaCorrect = BooleanBloc();
  final confirmarSenhaCorrect = BooleanBloc();

  final isEstrangeiro = BooleanBloc();

  validate(PreCadastroForm preCadastroForm) {
    button.setEnabled(preCadastroForm.validar());
  }

  validaSenhas(senha, repetirSenha) {
    bool v = validateConfirmarSenha(senha, repetirSenha);

    senhaCorrect.add(senha != null && senha.length >= 4 ? true : false);

    if (repetirSenha != null) {
      confirmarSenhaCorrect.add(v);
    }
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
    button.dispose();
    termos.dispose();
    nomeCompleted.dispose();
    sobrenomeCompleted.dispose();
    cpfCorrect.dispose();
    emailCorrect.dispose();
    senhaCorrect.dispose();
    confirmarSenhaCorrect.dispose();
    confirmEmailCorrect.dispose();
    isEstrangeiro.dispose();
  }
}
