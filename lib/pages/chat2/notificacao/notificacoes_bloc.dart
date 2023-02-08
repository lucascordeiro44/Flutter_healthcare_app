import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/chat2/app_bloc_chat.dart';
import 'package:flutter_dandelin/pages/chat2/notificacao/notificacao.dart';
import 'package:flutter_dandelin/pages/chat2/notificacoes_service.dart';
import 'package:flutter_dandelin/utils_livecom/bloc.dart';
import 'package:provider/provider.dart';

class NotificacoesBloc extends ChangeNotifier {
  static NotificacoesBloc get(context) =>
      Provider.of<NotificacoesBloc>(context, listen: false);

  final notificacoes = SimpleBloc<List<Notificacao>>();
  final loading = BooleanBloc();

  final notification = SimpleBloc<Notificacao>(keepState: false);

  int page = 0;
  bool _paraPaginacao = false;

  AppBloc _appBloc;

  NotificacoesBloc(BuildContext context) {
    _appBloc = AppBloc.get(context);
  }

  fetchMore() {
    if (_paraPaginacao || loading.value) return;
    page++;
    fetch();
  }

  fetch({bool again = false}) async {
    if (again) page = 0;

    loading.set(true);
    var response = await NotificacoesService.getNotificacoes(page);
    loading.set(false);
    if (response.ok) {
      if (response.result == null) {
        _paraPaginacao = true;
        return;
      }

      List<Notificacao> result = again ? [] : notificacoes.value ?? [];
      Notificacao notificacao = await _listenNovaMensagens(again);
      if (notificacao != null) {
        result.add(notificacao);
      }
      result.addAll(response.result);
      notificacoes.add(result);
    } else {
      notificacoes.addError(response.msg);
    }
  }

  markAsRead({int notifId, bool readAll = false}) async {
    loading.set(true);
    var response = await NotificacoesService.markAsRead(
        notifId: notifId, readAll: readAll);
    if (response.ok) {
      await fetch(again: true);
    } else {
      loading.addError('Erro ao marcar como lida');
    }
    loading.set(false);
  }

  Future<Notificacao> _listenNovaMensagens(bool again) async {
    Notificacao notificacao;
    await _appBloc.totalMensagensDrawer.listen((total) {
      notificacao = total != null && total != 0
          ? Notificacao(
              0,
              "Você possui $total novas menssagens",
              "Você possui $total novas menssagens",
              DateTime.now().toString(),
              "MENSAGEM",
              "MENSAGEM",
              null,
              again,
              null,
              DateTime.now().millisecondsSinceEpoch.toString(),
              null,
              null,
              null,
            )
          : null;
    });

    return notificacao;
  }

  newNotification(Notificacao notif) {
    notification.add(notif);
  }

  @override
  void dispose() {
    super.dispose();
    notificacoes.dispose();
    loading.dispose();
    notification.dispose();
  }
}
