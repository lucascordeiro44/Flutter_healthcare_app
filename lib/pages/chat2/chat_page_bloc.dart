import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/chat2/arquivo.dart';
import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/chat_service.dart';
import 'package:flutter_dandelin/pages/chat2/services/services.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/pages/chat2/websocket/events.dart';
import 'package:flutter_dandelin/pages/chat2/websocket/web_socket.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils_livecom/bloc.dart';
import 'package:flutter_dandelin/utils_livecom/file_extentions.dart';
import 'package:random_color/random_color.dart';


class ChatPageBloc {
  final chat = SimpleBloc<List<Chat>>();
  final loading = BooleanBloc();
  final isTyping = BooleanBloc();
  final showMenuAnexos = BooleanBloc();

  final recording = BooleanBloc();
  final timeRecording = SimpleBloc<String>();
  final pathRecord = SimpleBloc<String>();

  final isDragging = BooleanBloc();
  final audioPlaying = SimpleBloc<int>();

  final isLink = BooleanBloc();
  final linkData = SimpleBloc<Entity>();

  var page = 0;

  Chat defaultChat;
  Chat newChat;
  var _idConversa;

  bool _paraPaginacao = false;
  bool _enviouReadAllMsgs = false;

  var listPainted = List<UserPaint>();

  init() {
    webSocket.blocChat.stream.listen((e) {
      _newEvent(e);
    });
  }

  fetch(Chat chat) async {
    _idConversa = chat.conversaId;
    if(chat.data != null){
      defaultChat = chat;
    } else{
      newChat = chat;
    }
     await getMenssagens();
  }

  fetchMore() async {
    if (_paraPaginacao) {
      return;
    }

    page = page + 1;

    loading.add(true);
    ApiResponse<List<Chat>> response =
        await ChatService.getChat(page: page, conversaId: _idConversa);

    if (response.ok) {
      List<Chat> list = _getChatValue();

      List<Chat> result = response.result;

      if (result != null) {
        result.addAll(list);

        chat.add(_paintList(result));
      } else {
        _paraPaginacao = true;
      }

      loading.add(false);
    } else {
      chat.addError(response.msg);
    }
  }

  readAllMsgs()  {
    if (!_enviouReadAllMsgs) {
      webSocket.readAllMsg(defaultChat != null ? defaultChat : newChat);
      _enviouReadAllMsgs = true;
    }
  }

  getMenssagens() async {
    ApiResponse response = await ChatService.getChat(page: 0, conversaId: _idConversa);

    if (response.ok) {
      List<Chat> r = response.result;

      if (r == null) {
        r = List<Chat>();
      }

      if (r.length > 0 && r[0].isGroup) {
        r = _paintList(r);
      }

       chat.add(r);
    } else {
      chat.addError(response.msg);
    }
  }

  atualizarConversa() {
    chat.add(null);
    page = 0;
    getMenssagens();
  }

  sendMessage(String msg, User usuario, {Entity entity}) async {
    if (entity == null) entity = linkData.value;
    int identifier = entity == null
        ? await webSocket.sendMsg(msg, _idConversa)
        : await webSocket.sendLink(msg, _idConversa, entity: entity);

    _addChatToListStream(identifier, usuario, TypeMessage.text,
        msg: msg, entity: entity);

    linkData.add(null);

    return defaultChat;
  }

  sendImage(File file, User usuario) async {
    List<int> imageBytes = file.readAsBytesSync();
    String base = base64.encode(imageBytes);

    int identifier = await webSocket.sendImage(base, _idConversa);

    List<Arquivos> arquivos = [
      Arquivos()
        ..tipo = "foto"
        ..file = file.name
        ..extensao = "png"
        ..fileUser = file
        ..usuario = usuario
    ];

    _addChatToListStream(
      identifier,
      usuario,
      TypeMessage.picture,
      base: base,
      arquivos: arquivos,
    );
  }

  sendAudio(User usuario) async {
    String path = pathRecord.value;
    File file = File(path);

    List<int> imageBytes = file.readAsBytesSync();
    String base = base64.encode(imageBytes);

    int identifier = await webSocket.sendAudio(base, _idConversa);

    List<Arquivos> arquivos = [
      Arquivos()
        ..tipo = "audio"
        ..file = "audio_${identifier.toString()}.mp3"
        ..extensao = "mp3"
        ..fileUser = file
        ..usuario = usuario
    ];

    _addChatToListStream(
      identifier,
      usuario,
      TypeMessage.sound,
      base: base,
      arquivos: arquivos,
    );
  }

  _addChatToListStream(int identifier, User usuario, TypeMessage type,
      {String msg, String base, List<Arquivos> arquivos, Entity entity}) {
    List<Chat> list = chat.value;

    DateTime now = DateTime.now();

    Chat c = list.length > 0 ? list.first : defaultChat;

    int toId;
    String toName;
    String toPhoto;
    String toPhotoThumb;

    if (!c.isGroup) {
      if (c.fromId == usuario.id) {
        toId = c.toId;
        toName = c.toNome;
        toPhoto = c.toUrlFoto;
        toPhotoThumb = c.toUrlFotoThumb;
      } else {
        toId = c.fromId;
        toName = c.fromNome;
        toPhoto = c.fromUrlFoto;
        toPhotoThumb = c.fromUrlFotoThumb;
      }
    }

    Chat newChat = Chat()
      ..fromId = usuario.id
      ..fromNome = usuario.nome
      ..identifier = identifier
      ..data = now.millisecondsSinceEpoch
      ..from = usuario.id.toString()
      ..lida = 0
      ..entregue = 0
      ..toId = toId
      ..isGroup = c.isGroup
      ..grupoId = c.grupoId
      ..toNome = toName
      ..toUrlFoto = toPhoto
      ..toUrlFotoThumb = toPhotoThumb
      ..colorNameGroup = c.colorNameGroup
      ..entity = entity
      ..arquivos = arquivos;

    if (type == TypeMessage.text) {
      newChat..msg = msg;
    } else if (type == TypeMessage.picture) {
      msg = "img";
    } else if (type == TypeMessage.sound) {
      msg = "audio";
    }

    defaultChat = newChat;

    list.add(newChat);
    chat.add(list);
  }

  _newEvent(ChatEvent event) {
    if (chat.value == null) {
      return;
    }
    if (event.chatEventEnum == ChatEventEnum.msg1C ||
        event.chatEventEnum == ChatEventEnum.msg2C) {
      _updateStatusMsg(event);
    } else if (event.chatEventEnum == ChatEventEnum.c2a) {
      _readAllMessages(event);
    } else if (event.chatEventEnum == ChatEventEnum.message) {
      _newMessage(event);
    }
  }

  _updateStatusMsg(ChatEvent event) {
    List<Chat> list = _getChatValue();

    Chat c;

    if (event.chatEventEnum == ChatEventEnum.msg1C) {
      c = list.firstWhere((cl) => cl.identifier == event.identifier,
          orElse: () => null);

      if (c == null) {
        return;
      }

      c.id = event.msgId;
      c.entregue = 0;
    } else {
      c = list.firstWhere((c) => c.id == event.msgId, orElse: () => null);

      if (c == null) {
        return;
      }

      c.entregue = 1;
    }

    chat.add(list);
  }

  _readAllMessages(ChatEvent event) {
    List<Chat> list = _getChatValue();

    list.forEach((c) {
      c.entregue = 1;
      c.lida = 1;
    });

    chat.add(list);
  }

  _newMessage(ChatEvent event) {
    List<Chat> list = _getChatValue();

    if (list.where((c) => c.id == event.msgId).length == 0 &&
        event.cId == _idConversa) {
      bool isGroup =
          list.where((c) => c.isGroup != null && c.isGroup).length > 0;

      Color color;

      if (isGroup) {
        Chat chat =
            list.firstWhere((c) => c.fromId == event.from, orElse: null);
        if (chat != null) {
          color = chat.colorNameGroup;
        }
      }

      list.add(
        Chat()
          ..data = event.date
          ..msg = event.msg
          ..identifier = event.identifier
          ..id = event.msgId
          ..from = event.from.toString()
          ..fromNome = event.fromName
          ..to = event.cId.toString()
          ..card = event.card
          ..isGroup = isGroup
          ..colorNameGroup = color
          ..entregue = event.status == "1C" ? 0 : 1,
      );
      chat.add(list);
    }
  }

  chatOnlongPress(Chat chatSelected) {
    if (!_isSelecting()) {
      List<Chat> list = _getChatValue();

      Chat ch =
          list.firstWhere((c) => c.id == chatSelected.id, orElse: () => null);

      if (ch == null) {
        return;
      }

      ch.isSelected = true;

      chat.add(list);
    }
  }

  chatOnClick(Chat chatClicked) {
    if (_isSelecting()) {
      List<Chat> list = _getChatValue();

      Chat ch =
          list.firstWhere((c) => c.id == chatClicked.id, orElse: () => null);

      if (ch == null) {
        return;
      }

      ch.isSelected = ch.isSelected == null || !ch.isSelected ? true : false;

      chat.add(list);
      return false;
    } else {
      return true;
    }
  }

  List<Chat> _getChatValue() {
    return chat.value ?? List<Chat>();
  }

  _isSelecting() {
    return _getChatValue()
            .where((c) => c.isSelected != null && c.isSelected)
            .length >
        0;
  }

  getMsgSelected() {
    return _getChatValue()
        .firstWhere((c) => c.isSelected != null && c.isSelected);
  }

  _paintList(List<Chat> list) {
    RandomColor _randomColor = RandomColor();

    list.forEach((c) {
      UserPaint userPaint =
          listPainted.firstWhere((u) => u.id == c.fromId, orElse: () => null);

      if (userPaint == null) {
        Color color = _randomColor.randomColor();
        listPainted.add(UserPaint()
          ..id = c.fromId
          ..color = color);

        c.colorNameGroup = color;
      } else {
        c.colorNameGroup = userPaint.color;
      }
    });

    return list;
  }

  showAnexos() {
    bool v = showMenuAnexos.value ?? false;

    showMenuAnexos.add(!v);
  }

  Future<ApiResponse> deletarConversa() async {
    ApiResponse response = await ChatService.deletarConversa(_idConversa);

    if (response.ok) {
      return response;
    } else {
      return response;
    }
  }

  getCopyboard() {
    List<Chat> data = _getChatValue();

    List<Chat> list = data
        .where((element) => element.isSelected != null && element.isSelected)
        .toList();

    String msg = '';

    list.forEach((element) {
      msg += msg == '' ? _buildMsg(element) : "\n${_buildMsg(element)}";
    });

    return AppCopyboard(msg: msg, total: list.length);
  }

  _buildMsg(Chat chat) {
    DateTime dateTime = chat.dateTime;

    return "[${dateTime.day}/${dateTime.month} ${dateTime.minute}:${dateTime.hour}] ${chat.fromNome}: ${chat.msg}";
  }

  unselectAll() {
    List<Chat> data = _getChatValue();

    data.forEach((element) => element.isSelected = false);

    chat.add(data);
  }

  createVideoConferencia(User usuario) async {
    ApiResponse response =
        await ChatService.createVideoConferencia(_idConversa);

    if (response.ok) {
      Entity entity = await _getLinkData(response.result);

      sendMessage(response.result, usuario, entity: entity);
    }

    return response;
  }

  _getLinkData(String url) async {
    ApiResponse response = await getLinkInfo(url);

    if (response.ok) {
      return response.result;
    }
  }

  fetchLink(String url) async {
    isLink.add(true);

    Entity entity = await _getLinkData(url);

    linkData.add(entity);

    isLink.add(false);
  }

  dispose() {
    loading.dispose();
    chat.dispose();
    showMenuAnexos.dispose();
    isTyping.dispose();
    recording.dispose();
    pathRecord.dispose();
    timeRecording.dispose();
    isDragging.dispose();
    audioPlaying.dispose();
    isLink.dispose();
    linkData.dispose();
  }
}

class UserPaint {
  int id;
  Color color;

  UserPaint();
}

enum TypeMessage {
  text,
  picture,
  sound,
}

class AppCopyboard {
  String msg;
  int total;

  AppCopyboard({this.msg, this.total});
}
