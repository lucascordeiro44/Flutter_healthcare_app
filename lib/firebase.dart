import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dandelin/app_bloc.dart';
import 'package:flutter_dandelin/model/user.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

class FirebaseHelper {
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
}

initFirebase() {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  try {
    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
    }

    _firebaseMessaging.getToken().then(print);
    _firebaseMessaging.subscribeToTopic('all');
    _firebaseMessaging.configure(
      onLaunch: (map) async {
        print(map);
      },
      onMessage: (map) async {
        print(map);
      },
      onResume: (map) async {
        print(map);
      },
    );
  } catch (e) {
    throw (e);
  }
}

screenView(String view, String descricao) {
  try {
    FirebaseHelper.observer.analytics.setCurrentScreen(
      screenName: view,
      screenClassOverride: descricao,
    );
  } catch (e) {
    print(e);
  }
}

screenAction(String event, String descricao, {Map<String, dynamic> param}) {
  try {
    User user = appBloc.user;

    Map<String, dynamic> map = new Map<String, dynamic>();

    map['descricao'] = descricao;

    if (param != null) {
      param.forEach((key, value) {
        if (value != null) {
          map[key] = value;
        }
      });
    }

    if (user != null) {
      user.toGA().forEach((key, value) {
        if (value != null) {
          map[key] = value;
        }
      });
    }

    FirebaseHelper.observer.analytics.logEvent(
      name: event,
      parameters: map,
    );
    print("mandou");
  } catch (e) {
    print(e);
  }
}
