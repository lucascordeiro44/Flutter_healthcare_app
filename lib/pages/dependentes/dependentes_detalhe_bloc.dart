import 'package:flutter_dandelin/model/dependente.dart';
import 'package:flutter_dandelin/pages/dependentes/dependentes_api.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/clean_text.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';
import 'package:rxdart/rxdart.dart';

class DependentesDetalheBloc {
  final onChangedStream = PublishSubject<String>();
  final button = ButtonBloc();
  final iconSearch = BooleanBloc()..add(false);
  final dependente = SimpleBloc();
  final errorMsg = SimpleBloc<String>();

  init(Dependente dependente) {
    if (dependente != null) {
      button.setEnabled(
        dependente.renviarConviteEnable ? true : !dependente.isDeletado,
      );
    } else {
      _listenOnChanged();
    }
  }

  _listenOnChanged() {
    onChangedStream.stream
        .debounceTime(Duration(milliseconds: 500))
        .listen(_getDependente);
  }

  _getDependente(String search) async {
    if (search.length <= 2) {
      return;
    }
    dependente.add(null);
    button.setEnabled(false);

    if (isEmpty(search)) {
      iconSearch.add(false);
      return;
    }
    try {
      iconSearch.add(null);
      HttpResponse response = await DependentesApi.searchUser(
          int.tryParse(cleanCpf(search)) is int ? cleanCpf(search) : search);

      User user = User.fromJson(response.data['data']);

      dependente.add(user);
      iconSearch.add(true);
      errorMsg.add(null);
    } catch (e) {
      errorMsg.add(e);
      iconSearch.addError(e);
    }
  }

  addDependente(bool notificationToParent) async {
    button.setProgress(true);
    try {
      User user = dependente.value;

      await DependentesApi.addDependente(user.id, notificationToParent);

      return ApiResponse.ok();
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      button.setProgress(false);
    }
  }

  excluirDependente(Dependente dependente) async {
    button.setProgress(true);
    try {
      await DependentesApi.excluirDependente(dependente.id);

      return ApiResponse.ok();
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      button.setProgress(false);
    }
  }

  validate(DependentesForm form) {
    button.setEnabled(form.validate());
  }

  reenviarConvite(Dependente dependente) async {
    button.setProgress(true);

    ApiResponse response = await DependentesApi.reenviarConvite(dependente);

    button.setProgress(false);

    return response;
  }

  dispose() {
    onChangedStream.close();
    iconSearch.dispose();
    dependente.dispose();
    button.dispose();
    errorMsg.dispose();
  }
}
