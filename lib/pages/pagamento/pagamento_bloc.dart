import 'package:flutter_dandelin/app_bloc.dart';
import 'package:flutter_dandelin/model/pagamento.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';

import 'pagamento_api.dart';

class PagamentoBloc extends SimpleBloc<List<Pagamento>> {
  fetch() async {
    HttpResponse response =
        await PagamentoApi.buscarTodos().catchError(addError);

    if (response == null) {
      return;
    }

    List<Pagamento> list = List<Pagamento>();

    response.data['data'].forEach((map) {
      list.add(Pagamento.fromJson(map));
    });

    add(list);
  }

  refresh() {
    _getUserPaymentStatus();
    add(null);
    fetch();
  }

  _getUserPaymentStatus() async {
    try {
      HttpResponse response = await PagamentoApi.statusPagamento();

      String status = response.data['data']['statusUser'];

      print(status);

      User user = appBloc.user;

      user.status = status;

      appBloc.setUser(user);
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
