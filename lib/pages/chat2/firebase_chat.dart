import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/chat2/app_bloc_chat.dart';
import 'package:flutter_dandelin/pages/chat2/notificacao/notificacao.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/pages/chat2/widgets/alert.dart';
import 'package:flutter_dandelin/utils_livecom/local_notifications.dart';


FirebaseAnalytics analytics = FirebaseAnalytics();
FirebaseMessaging fcm;

void initFcm(BuildContext context) {
  AppBloc appBloc = AppBloc.get(context);

  if (fcm == null) {
    fcm = FirebaseMessaging();
  }

  fcm.getToken().then((token) {
    print("\n******\nFirebase Token $token\n******\n");
  });

  fcm.subscribeToTopic("all");
  if (Platform.isIOS) {
    fcm.subscribeToTopic("allIOS");
  } else {
    fcm.subscribeToTopic("allAndroid");
  }

  fcm.configure(
    onMessage: (Map<String, dynamic> message) async {
      try {
        print('\n\n\n*** on message $message');

        //{pushId: 822338, gcm.message_id: 1577972666053157, google.c.a.e: 1, aps: {badge: 2, alert: {title: a, body: ds}}}
        // TODO atualizar badge
        appBloc.fetchBadgeNotification();

//      Notificacao notificacao = Notificacao.fromJson(message["aps"]["alert"]);
        _showNotification(message, 'onMessage');

        if (message["aps"] != null) {
          alert(context, title: message["aps"]["alert"]["body"]);
        }

        // alert(context, title: message["aps"]["alert"]["body"]);
      } catch (error, ex) {
        print(error);
        print(ex);
      }
    },
    onResume: (Map<String, dynamic> message) async {
      print('\n\n\n*** on resume $message \n\n');

      _showNotification(message, 'onResume');
    },
    onLaunch: (Map<String, dynamic> message) async {
      print('\n\n\n*** on launch $message \n\n');

      _showNotification(message, 'onLaunch');
    },
  );

  if (Platform.isIOS) {
    fcm.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("iOS Push Settings: [$settings]");
    });
  }
}

_showNotification(dynamic message, String appStatus) {
  Notificacao notificacao = Notificacao.fromPayload(message);
  message['appStatus'] = appStatus;

  showLocalNotification(notificacao.id, notificacao.titulo, notificacao.texto,
      json.encode(message));
}

initCrashlytics() {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
//  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors to Crashlytics.
  // FlutterError.onError = Crashlytics.instance.recordFlutterError;
}

void logCrash(String s) {
  // Crashlytics.instance.log(s);
}

void crash() {
  // Crashlytics.instance.crash();
}

void setCrashUser(User user) {
  if (user != null) {
    //   Crashlytics.instance.setUserEmail(user.login);
    //   Crashlytics.instance.setUserName(user.nome);
    //   Crashlytics.instance.setUserIdentifier(user.login);
  }
}

void gaEvent(String event, Map<String, dynamic> parameters) {
  analytics.logEvent(
    name: event,
    parameters: parameters,
  );
}
