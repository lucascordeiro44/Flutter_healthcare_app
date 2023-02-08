import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/chat2/notificacao/notificacao.dart';
import 'package:flutter_dandelin/pages/chat2/notificacao/notificacoes_bloc.dart';
import 'package:flutter_dandelin/pages/chat2/route_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void initLocalNotificationPlugin(BuildContext context) {
  final notificacoesBloc = NotificacoesBloc.get(context);

  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings(
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      // print(id, title, body, payload);
      print(payload);
      final notificacao = Notificacao.fromPayload(json.decode(payload));
      // appBloc.newNotification(notificacao);
      notificacoesBloc.newNotification(notificacao);
    },
  );

  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  var _routeBloc = RouteBloc.get(context);

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (payload) async {
      FcmNotification notification =
          FcmNotification.fromJson(json.decode(payload));

      _routeBloc.addNotification(notification);
    },
  );
}

void showLocalNotification(int id, String title, String body, payload) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'all', 'all', 'All',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');

  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(id, title, body, platformChannelSpecifics, payload: payload);
}

class FcmNotification {
  Notification notification;
  Data data;
  String appStatus;

  FcmNotification({this.notification, this.data, this.appStatus});

  FcmNotification.fromJson(Map<String, dynamic> json) {
    notification = json['notification'] != null
        ? new Notification.fromJson(json['notification'])
        : null;
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    appStatus = json['appStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.notification != null) {
      data['notification'] = this.notification.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['appStatus'] = this.appStatus;
    return data;
  }
}

class Notification {
  String title;
  String body;

  Notification({this.title, this.body});

  Notification.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['body'] = this.body;
    return data;
  }
}

class Data {
  String postId;
  String pushId;
  String tipo;

  Data({this.postId, this.pushId, this.tipo});

  Data.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    pushId = json['pushId'];
    tipo = json['tipo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['pushId'] = this.pushId;
    data['tipo'] = this.tipo;
    return data;
  }
}
