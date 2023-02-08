import 'package:flutter_dandelin/model/cv.dart';
import 'package:flutter_dandelin/pages/perfil_medico/perfil_medico_api.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/bloc.dart';

class PerfilMedicoBloc extends SimpleBloc<Cv> {
  fetch(int id) async {
    ApiResponse response = await PerfilMedicoApi.getCV(id);

    response.ok ? add(response.result) : addError(response.msg);
  }
}
