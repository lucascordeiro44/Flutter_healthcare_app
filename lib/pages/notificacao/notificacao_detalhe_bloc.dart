import 'package:flutter_dandelin/model/notificacao.dart';
import 'package:flutter_dandelin/pages/notificacao/notificacao_api.dart';

class NotificacaoDetalheBloc {
  read(Notificacao notificacao) async {
    await NotificacaoApi.readNotificacao(notificacao);
  }
}
