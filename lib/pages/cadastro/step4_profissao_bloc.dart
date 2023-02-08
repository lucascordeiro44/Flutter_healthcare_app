import 'package:flutter_dandelin/model/ocupation.dart';
import 'package:flutter_dandelin/pages/cadastro/step4_profissao_api.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';

class ProfissaoBloc {
  final button = BooleanBloc();

  var listOcupation = SimpleBloc<List<Ocupation>>();
  var pageStream = SimpleBloc<int>();
  var searchStream = SimpleBloc<String>();

  final showProgress = SimpleBloc<bool>();

  final hasPartnership = BooleanBloc();
  final checkingPartnership = BooleanBloc()..add(false);

  bool endApiResults = false;

  fetch({String search}) async {
    pageStream.add(0);

    await ProfissaoApi.getOcupation(page: pageStream.value, search: search)
        .then((response) {
      final l = response.data['data'] as List;

      List<Ocupation> list =
          l.map<Ocupation>((json) => Ocupation.fromJson(json)).toList();

      listOcupation.add(list);
    }).catchError((error) {
      listOcupation.addError(error.toString());
    });
  }

  fetchMore() async {
    if (!endApiResults) {
      showProgress.add(true);
      int page = pageStream.value;
      page = page + 1;

      List<Ocupation> data = listOcupation.value;

      await ProfissaoApi.getOcupation(page: page, search: searchStream.value)
          .then((response) {
        final l = response.data['data'] as List;

        List<Ocupation> list =
            l.map<Ocupation>((json) => Ocupation.fromJson(json)).toList();

        if (list.length > 0) {
          list.forEach((l) {
            if (data.where((v) => v.id == l.id).length == 0) {
              data.add(l);
            }
          });
        } else {
          endApiResults = true;
        }

        listOcupation.add(data);
        pageStream.add(page);
      });

      showProgress.add(false);
    }
  }

  searchMethod(String value) {
    searchStream.add(value);
    listOcupation.add(null);
    fetch(search: value);
  }

  checkPartnership(String code, String cpf) async {
    checkingPartnership.add(null);
    HttpResponse response =
        await ProfissaoApi.validatePartnership(code, cpf).catchError((error) {
      checkingPartnership.addError(error);
      return null;
    });

    if (response == null) {
      return;
    }
    checkingPartnership.add(true);

    return true;
  }

  dispose() {
    searchStream.dispose();
    button.dispose();
    listOcupation.dispose();
    pageStream.dispose();
    showProgress.dispose();
    hasPartnership.dispose();
    checkingPartnership.dispose();
  }
}
