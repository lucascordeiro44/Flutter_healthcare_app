import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/constants_chat.dart';
import 'package:flutter_dandelin/pages/chat2/websocket/chat_parser.dart';
import 'package:flutter_dandelin/utils_livecom/bloc.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter_dandelin/utils_livecom/network.dart';
import 'package:flutter_dandelin/utils_livecom/random.dart';
import 'package:web_socket_channel/io.dart';

final webSocket = WebSocketService();

class WebSocketService {
  String _userId;
  String _login;
  String _senha;

  // -- start -- Singleton
  WebSocketService._internal();

  static final WebSocketService _instance = new WebSocketService._internal();

  IOWebSocketChannel _channel;
  StreamSubscription _subscription;

  NetworkUtil networkUtil = NetworkUtil();

  var blocChat = SimpleBloc();

  factory WebSocketService() {
    return _instance;
  }

  Stream get stream => _channel.stream;

  connect(String userId) {
    _userId = userId;

    try {
//      String url = "wss://livecom.livetouchdev.com.br/chatApp/$userId/so/android";

      String so = Platform.isAndroid ? "android" : "iOS";

      String url = "$BASE_URL_WEBSOCKET/$userId/so/$so";

      _channel = IOWebSocketChannel.connect(url);
    } catch (e) {
      print(e);
    }
  }

  listen() {
    _subscription = _channel.stream.listen((message) {
      print(" << listen $message");
      parserChat(message);
    }, onError: (error) async {
      print("onError $error");

      if (_channel != null) {
        print(" onError ${_channel.closeReason}");
      }

      _reconnect();
    }, onDone: () async {
      if (_channel != null) {
        print(" onDone ${_channel.closeReason}");
      }
      _reconnect();
    });
  }

  _reconnect() async {
    try {
      if (await networkUtil.isConnect()) {
        if (!blocChat.isClosed) {
          close();
          print("reconnect");

          connect(_userId);

          login(_login, _senha);
        }
      } else {
        networkUtil.onConnectionChanged().listen((event) async {
          if (await networkUtil.isConnect()) {
            _reconnect();
          }
        });
      }

      listen();
    } catch (e) {
      print(e);
    }
  }

  login(String login, String senha) {
    _login = login;
    _senha = senha;
    final map = {
      "code": "login",
      "user": login,
      "pass": senha,
      "so": Platform.isAndroid ? "android" : "iOS"
    };

    _write(map);
  }

  away() {
    final map = {
      "away": true,
      "code": "userStatus",
      "from": _userId,
      "notification": false,
      "sound": false,
      "vib": false
    };

    _write(map);
  }

  online() {
    final map = {
      "code": "userStatus",
      "from": _userId,
      "notification": false,
      "online": true,
      "sound": false,
      "vib": false
    };
    _write(map);
  }

  sendMsg(String msg, int conversaId) {
    int identifier = random();
    print("identifier: $identifier");
    final map = {
      "code": "msg",
      "from": _userId,
      "identifier": identifier,
      "cId": conversaId,
      "msg": msg
    };

    _write(map);
    return identifier;
  }

  sendLink(String msg, int conversaId, {Entity entity, CardLink card}) {
    int identifier = random();

    String urlLink = card == null ? entity.url : card.link;
    String imageLink = card == null ? entity.imagem : card.url;
    String titleLink = card == null ? entity.titulo : card.title;
    String descricaoLink = card == null ? entity.descricao : card.subTitle;

    final map = {
      "cId": conversaId,
      "card": {
        "idMensagem": identifier,
        "link": urlLink,
        "subTitle": descricaoLink,
        "tipo": 1,
        "title": titleLink,
        "url": imageLink,
        "value": 0
      },
      "code": "msg",
      "from": _userId,
      "identifier": identifier,
      "msg": msg
    };

    _write(map);
    return identifier;
  }

  sendImage(String base, int conversaId) {
    int identifier = random();

    print("identifier: $identifier");

    final m = {
      "cId": conversaId,
      "code": "msgFile",
      "from": _userId,
      "identifier": identifier,
      "notification": false,
      "sound": false,
      "vib": false
    };

    _write(m);

    final map = {
      "code": "msg",
      "identifier": identifier,
      "cId": conversaId,
      "files": [
        {"base64": base}
      ],
      "dir": "arquivos",
    };

    _write(map);
    return identifier;
  }

  sendAudio(String base, int conversaId) async {
    int identifier = random();

    var map = {
      "cId": conversaId,
      "code": "msgFile",
      "from": _userId,
      "identifier": identifier,
      "notification": false,
      "sound": false,
      "vib": false
    };

    await _write(map);
    map = {
      "cId": conversaId,
      "code": "msg",
      "files": [
        {
          "base64": base,
          "nome": "audio_${identifier.toString()}.mp3",
          "tipo": "audio",
        }
      ],
      "from": _userId,
      "identifier": identifier,
      "notification": false,
      "sound": false,
      "vib": false
    };

    await _write(map);

    return identifier;
  }

  readMsg(Chat chat) {
    final map = {
      "cId": chat.conversaId,
      "code": "msg2A",
      "from": chat.fromId,
      "msgId": chat.id,
      "notification": false,
      "sound": false,
      "status": "Ok",
      "to": _userId,
      "vib": false
    };

    _write(map);
  }

  readAllMsg(Chat chat) {
    final map = {
      "cId": chat.conversaId,
      "code": "c2A",
      "from": _userId,
      "notification": false,
      "sound": false,
      "status": "OK",
      "vib": false,
    };
    _write(map);
  }

  keepAliveOk() {
    _write({
      "code": "keepAliveOk",
      "from": _userId,
      "notification": false,
      "sound": false,
      "vib": false,
    });
  }

  getAll(int lastMsgId, int cIds) {
    _write({
      "cIds": [cIds],
      "code": "getAllV2",
      "from": _userId,
      "lastMsgId": lastMsgId,
      "lastSystemMsgId": 3385,
      "notification": false,
      "sound": false,
      "vib": false
    });
  }

  _write(Map map) {
    _writeString(convert.json.encode(map));
  }

  _writeString(String string) {
    try {
      print("write > $string");

      _channel.sink.add(string);
    } catch (e) {
      print(e);
    }
  }

  disepose() {
    blocChat.dispose();
  }

  void close() {
    print("close socket");

    if (_subscription != null) {
      _subscription.cancel();
    }

    if (_channel != null) {
      _channel.sink.close(status.normalClosure);
    }

    _subscription = null;
    _channel = null;
  }
}
