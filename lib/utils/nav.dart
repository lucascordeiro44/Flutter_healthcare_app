import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';


final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

Future pushApp(
  Widget page,
  PageTransitionType pageTransitionType, {
  bool replace = false,
  popAll = false,
  String tag,
}) {
  if (popAll) {
    pop(all: true);
  }

  return navigatorKey.currentState
      .push(PageTransition(type: pageTransitionType, child: page));
}

Future push(
  Widget page, {
  bool replace = false,
  popAll = false,
  String tag,
  bool rootNavigator = true,
  bool fullScreen = false,
}) {
  if (popAll) {
    pop(all: true);
  }

  if (replace) {
    return navigatorKey.currentState.pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return page;
        },
        fullscreenDialog: fullScreen,
      ),
    );
  } else {
    return navigatorKey.currentState.push(
      MaterialPageRoute(
        builder: (context) {
          return page;
        },
        settings: RouteSettings(name: tag ?? page.toString()),
        fullscreenDialog: fullScreen,
      ),
    );
  }
}

bool pop<T extends Object>(
    {bool all = false, String tag, bool rootNavigator = true, T result}) {
  if (all) {
    // Usado se vc faz algum push
    navigatorKey.currentState.popUntil((route) {
      return route.isFirst;
    });
    return true;
  }
  if (tag != null) {
    // Voltar para a Rota que possui esta Tag
    navigatorKey.currentState.popUntil((route) {
      return route.settings.name == tag;
    });
    return true;
  }

  if (all == null || !all) {
    navigatorKey.currentState.pop(result);
    return true;
  }

  return false;
}
