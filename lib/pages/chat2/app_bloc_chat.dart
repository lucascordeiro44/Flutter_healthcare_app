

import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/notificacao/badges.dart';
import 'package:flutter_dandelin/pages/chat2/notificacoes_service.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils_livecom/bloc.dart';
import 'package:provider/provider.dart';

class AppBloc extends ChangeNotifier {
  static AppBloc get(context) => Provider.of<AppBloc>(context, listen: false);

  User user;
  final userBloc = SimpleBloc<User>();
  final badgeNotification = SimpleBloc<String>();
  final totalMensagensDrawer = SimpleBloc<int>();

  fetchBadgeNotification() async {
    ApiResponse<Badges> response =
    await NotificacoesService.getNotificacoesCount();
    if (response.ok) {
      updateBadge(response.result.total);
      totalMensagensDrawer.add(response.result.mensagens);
    }
  }

  updateUser(User user) {
    this.user = user;
    this.userBloc.add(user);
  }

  updateBadge(int count) {
    String countStr = '';
    if (count >= 10) {
      countStr = '9+';
    } else if (count > 0) {
      countStr = '$count';
    }

    if (count > 0) {
      FlutterAppBadger.updateBadgeCount(count);
    } else {
      FlutterAppBadger.removeBadge();
    }

    badgeNotification.add(countStr);
  }

  decreaseBadges(Chat chat) {
    int value = totalMensagensDrawer.value ?? -chat.badge?.mensagens;
    totalMensagensDrawer.add(null);
    print(value);
    totalMensagensDrawer.add(value);

    print(totalMensagensDrawer.value);
    notifyListeners();
  }

  logout() {
    user = null;
    User.clear();
  }

  @override
  void dispose() {
    super.dispose();
    userBloc.dispose();
    badgeNotification.dispose();
    totalMensagensDrawer.dispose();
  }
}
