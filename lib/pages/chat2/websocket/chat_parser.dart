import 'dart:convert' as convert;

import 'package:flutter_dandelin/pages/chat2/websocket/events.dart';
import 'package:flutter_dandelin/pages/chat2/websocket/web_socket.dart';


parserChat(String message) {
  Map map = convert.json.decode(message);

  webSocket.blocChat.add(ChatEvent.fromMap(map));
}
