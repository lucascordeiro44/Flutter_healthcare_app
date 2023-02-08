//{"code":"userStatus","away":true,"online":true,"from":2523,"so":"android","dateOnlineChat":1577727133712}
//{"code":"typing","cId":5056,"from":5990,"fromName":"Henrique Teste","typing":true}
//{"code":"typing","cId":5056,"from":5990,"fromName":"Henrique Teste","typing":true}
//{"code":"keepAlive"}
//{"code":"keepAlive"}
//{"fromUrlFotoThumb":"http://livecom.livetouchdev.com.br/img/user.png","date":1577735780344,"msg":"dssa","identifier":1577735926846,"code":"msg","fromUrlFoto":"http://livecom.livetouchdev.com.br/img/user.png","web":1,"fromName":"Henrique Teste","msgId":634221,"from":5990,"cId":5056,"status":"1C"}
//{"fromUrlFotoThumb":"http://livecom.livetouchdev.com.br/img/user.png","date":1577735780344,"msg":"dssa","identifier":1577735926846,"code":"msg","fromUrlFoto":"http://livecom.livetouchdev.com.br/img/user.png","web":1,"fromName":"Henrique Teste","msgId":634221,"from":5990,"cId":5056,"status":"1C"}
//{"code":"c2A","cId":5056,"from":5990}

import 'dart:convert';

import 'package:flutter_dandelin/pages/chat2/arquivo.dart';

import '../chat.dart';

class ChatEvent {
  int id;
  int from;
  String fromName;
  bool typing;
  int userId;
  bool online;
  bool away;
  String code;
  String fromUrlFotoThumb;
  int date;
  String msg;
  int identifier;
  String fromUrlFoto;
  int web;
  int msgId;
  int cId;
  String status;
  List<Arquivos> files;
  CardLink card;
  List<Chat> chats;
  num count;
  List<int> ids;
  List<int> idsAway;
  List<Badge> badges;

  ChatEventEnum get chatEventEnum => _switchEvent();

  ChatEvent.fromMap(map) {
    id = map["id"];
    from = map["from"] != null ? int.parse(map["from"].toString()) : null;
    fromName = map["fromName"];
    typing = map["typing"];
    userId = map["userId"];
    online = map["online"];
    away = map["away"];
    code = map["code"];
    fromUrlFotoThumb = map['fromUrlFotoThumb'];
    date = map['date'];
    msg = map['msg'];
    identifier = map['identifier'];

    fromUrlFoto = map['fromUrlFoto'];
    web = map['web'];
    msgId = map['msgId'];
    cId = map["cId"] != null ? int.parse(map['cId'].toString()) : null;
    status = map['status'];
    if (map['files'] != null) {
      files = new List<Arquivos>();
      map['files'].forEach((v) {
        files.add(new Arquivos.fromJson(v));
      });
    }
    card = map['card'] != null ? CardLink.fromJson(map['card']) : null;
    count = map['count'];
    if (map['msgs'] != null) {
      chats = new List<Chat>();
      map['msgs'].forEach((v) {
        chats.add(new Chat.fromJson(json.decode(v)));
      });
    }

    if (map['badges'] != null) {
      badges = new List<Badge>();
      map['badges'].forEach((v) {
        badges.add(new Badge.fromJson(v));
      });
    }
  }

  bool get isOnline => online && away == null;
  bool get isAway => online && away;

  getStatus() {
    if (isOnline) {
      return StatusChat.online;
    } else if (isAway) {
      return StatusChat.away;
    } else {
      return StatusChat.none;
    }
  }

  _switchEvent() {
    switch (code) {
      case "userStatus":
        return ChatEventEnum.userStatus;
        break;
      case "c2A":
        return ChatEventEnum.c2a;
        break;
      case "typing":
        return ChatEventEnum.typing;
        break;
      case "msg":
        return ChatEventEnum.message;
        break;
      case "keepAlive":
        return ChatEventEnum.keepAlive;
        break;
      case "msg1C":
        return ChatEventEnum.msg1C;
        break;
      case "msg2C":
        return ChatEventEnum.msg2C;
        break;
      case "CLOSE_AND_SHOW_RECONECT":
        return ChatEventEnum.CLOSE_AND_SHOW_RECONECT;
        break;
      case "online":
        return ChatEventEnum.online;
        break;
      case "msgs":
        return ChatEventEnum.msgs;
        break;
    }
  }

  @override
  String toString() {
    return chatEventEnum.toString();
  }
}

enum ChatEventEnum {
  userStatus,
  typing,
  message,
  c2a,
  keepAlive,
  msg1C,
  msg2C,
  CLOSE_AND_SHOW_RECONECT,
  online,
  msgs,
}
