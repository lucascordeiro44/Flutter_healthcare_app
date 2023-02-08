

import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/chat_service.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils_livecom/bloc.dart';

class ChatMensagemInfoBloc {
  final msgInfo = SimpleBloc<MsgInfo>();
  final statusMensagens = SimpleBloc<List<StatusMensagens>>();

  fetch({Chat chat, User usuario}) async {
    ApiResponse response = await ChatService.getMsgInfo(chat.id);

    if (response.ok) {
      MsgInfo msg = response.result;

      if (msg.isGrupo) {
        await _fetchStatusMensagem(msg: msg);
      }

      msgInfo.add(msg);
    } else {
      msgInfo.addError(response.msg);
    }
  }

  _fetchStatusMensagem({MsgInfo msg}) async {
    ApiResponse response = await ChatService.getStatusMensagem(msg.id);

    if (response.ok) {
      statusMensagens.add(response.result);
    } else {
      statusMensagens.addError(response.msg);
    }
  }

  dispose() {
    msgInfo.dispose();
    statusMensagens.dispose();
  }
}

class MsgInfo {
  int id;
  int conversaId;
  String data;
  String dataPush;
  String dataEntregue;
  String dataLida;
  bool isGrupo;
  String msg;
  int fromId;
  int toId;

  MsgInfo(
      {this.id,
      this.conversaId,
      this.data,
      this.dataPush,
      this.dataEntregue,
      this.dataLida,
      this.isGrupo,
      this.msg,
      this.fromId,
      this.toId});

  MsgInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversaId = json['conversaId'];
    data = json['data'];
    dataPush = json['dataPush'];
    dataEntregue = json['dataEntregue'];
    dataLida = json['dataLida'];
    isGrupo = json['isGrupo'];
    msg = json['msg'];
    fromId = json['fromId'];
    toId = json['toId'];
  }

  msgInfoToChat(Chat chat) {
    int isLida = dataLida != null ? 1 : 0;
    int isEntregue = dataEntregue != null ? 1 : 0;

    return Chat()
      ..msg = msg
      ..isSelected = false
      ..lida = isLida
      ..entregue = isEntregue
      ..data = chat.data
      ..fromId = fromId
      ..toId = toId
      ..isGroup = isGrupo
      ..fromNome = chat.fromNome
      ..colorNameGroup = chat.colorNameGroup;
  }
}

class StatusMensagens {
  bool lida;
  String dataLida;
  String dataLidaString;
  bool entregue;
  String dataEntregue;
  String dataEntregueString;
  int userId;
  String userLogin;
  String userNome;
  String userUrlFoto;

  StatusMensagens(
      {this.lida,
      this.dataLida,
      this.dataLidaString,
      this.entregue,
      this.dataEntregue,
      this.dataEntregueString,
      this.userId,
      this.userLogin,
      this.userNome,
      this.userUrlFoto});

  StatusMensagens.fromJson(Map<String, dynamic> json) {
    lida = json['lida'];
    dataLida = json['dataLida'];
    dataLidaString = json['dataLidaString'];
    entregue = json['entregue'];
    dataEntregue = json['dataEntregue'];
    dataEntregueString = json['dataEntregueString'];
    userId = json['userId'];
    userLogin = json['userLogin'];
    userNome = json['userNome'];
    userUrlFoto = json['userUrlFoto'];
  }
}
