import 'package:flutter_dandelin/model/notificacao.dart';
import 'package:flutter_dandelin/pages/notificacao/notificacao_api.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class NotificacoesBloc extends SimpleBloc<List<Notificacao>> {
  fetch() async {
    ApiResponse response = await NotificacaoApi.getNotificacoes();

    response.ok ? add(response.result) : addError(response.error);
  }

  clickNotificacao(Notificacao notificacao) {
    List<Notificacao> data = this.value;

    Notificacao not =
        data.firstWhere((element) => element.id == notificacao.id);
    not.checked = true;
    add(data);
  }
}
