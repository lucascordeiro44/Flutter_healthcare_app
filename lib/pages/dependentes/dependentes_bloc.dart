import 'package:flutter_dandelin/app_bloc.dart';
import 'package:flutter_dandelin/model/dependente.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/dependentes/dependentes_api.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/bloc.dart';

class DependentesBloc {
  final dependentes = SimpleBloc<List<Dependente>>();
  final dependentesOutros = SimpleBloc<List<Dependente>>();

  User _user;

  init(User user) async {
    _user = user;

    // dependentes.add(_user.dependents ?? List());
    fetch(true);
    fetch(false);
  }

  fetch(bool ativos) async {
    ativos ? dependentes.add(null) : dependentesOutros.add(null);

    ApiResponse response = await DependentesApi.getDepedentens(ativos);

    if (!response.ok) {
      ativos
          ? dependentes.addError(response.msg)
          : dependentesOutros.addError(response.msg);
      return;
    }

    if (ativos) {
      dependentes.add(response.result);
    } else {
      dependentesOutros.add(response.result);
    }
  }

  ativarConta() async {
    ApiResponse response = await DependentesApi.ativarConta();

    if (response.ok) {
      _user.status = response.result;
      appBloc.setUser(_user);
    }

    return response;
  }

  dispose() {
    dependentes.dispose();
    dependentesOutros.dispose();
  }
}
