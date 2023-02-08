import 'dart:async';

import 'package:flutter_dandelin/pages/chat2/app_bloc_chat.dart';
import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/chat_service.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/pages/chat2/websocket/events.dart';
import 'package:flutter_dandelin/pages/chat2/websocket/web_socket.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils_livecom/bloc.dart';


class ChatConversasBloc extends SimpleBloc<List<Chat>> {
  ChatDAO _dao = ChatDAO();
  int page = 0;

  final loading = BooleanBloc();
  final isSearching = BooleanBloc()..add(false);
  final syncingChats = SimpleBloc<SyncingChats>();
  final syncing = BooleanBloc();

  bool _paraPaginacao = false;
  User user;

  Chat _defaultChat;
  Chat _openedChat;
  List<Chat> _defaultList;

  AppBloc _appBloc;

  init(AppBloc bloc, User usuario) async {
    add(null);
    webSocket.blocChat.stream.listen((e) {
      _newEvent(e);
    });

    user = usuario;
    _appBloc = bloc;
  }

  fetch() async {
    page = 0;
//    List<Chat> _dbList = await _dao.findAll();
//
//    if (_dbList.length > 0) {
//      //sincronizar as conversas
//      Chat c = _dbList.first;
//      webSocket.getAll(c.id, c.conversaId);
//
//      _defaultList = _dbList;
//
//      add(_dbList);
//
//      return;
//    }

    ApiResponse<List<Chat>> response = await ChatService.getConversas(page);

    if (response.ok) {
      _defaultList = response.result;
      add(response.result);

      response.result.forEach((chat) {
        _dao.save(chat);
      });
    } else {
      addError("Erro ao buscar o chat");
    }
  }

  fetchMore() async {
    if (_paraPaginacao) {
      return;
    }
    loading.add(true);

    page++;

    ApiResponse<List<Chat>> response = await ChatService.getConversas(page);

    List<Chat> list = super.value;

    if (response.ok) {
      List<Chat> listResult = response.result;

      if (listResult.length == 0) {
        _paraPaginacao = true;
      }
      list.addAll(response.result);
      add(list);
    } else {
      addError("Erro ao buscar o chat");
    }

    loading.add(false);
  }

  refresh() {
    add(null);
    fetch();
  }

  _newEvent(ChatEvent event) {
    switch (event.chatEventEnum) {
      case ChatEventEnum.userStatus:
        _updateChatOnlineEvent(event);
        break;
      case ChatEventEnum.typing:
        _updateListTypingEvent(event);
        break;
      case ChatEventEnum.message:
        _updateListMessageEvent(event);
        break;
      case ChatEventEnum.c2a:
        _updateChatC2a(event);
        break;
      case ChatEventEnum.msg2C:
        _updateChatMsg2C(event);
        break;
      case ChatEventEnum.CLOSE_AND_SHOW_RECONECT:
        break;
      case ChatEventEnum.keepAlive:
        _keepAliveOk();
        break;
      case ChatEventEnum.online:
        _updateUsersStatus(event);
        break;
      case ChatEventEnum.msgs:
        _syncConversas(event);
        break;
      default:
    }
  }

  _getList() {
    return value ?? List<Chat>();
  }

  newChat(Chat chat) {
    _defaultChat = chat;
  }

  _updateChatOnlineEvent(ChatEvent event) {
    List<Chat> list = _getList();

    if (list.isNotEmpty) {
      Chat chat = list.firstWhere(
          (c) => c.fromId == user.id && c.toId == event.from && !c.isGroupGet,
          orElse: () {
        return list.firstWhere(
            (c) => c.toId == user.id && c.fromId == event.from && !c.isGroupGet,
            orElse: () => Chat());
      });

      chat.entregue = 1;
      chat.statusChat = event.getStatus();

      add(list);
    }
  }

  _updateListTypingEvent(ChatEvent event) {
    List<Chat> list = _getList();

    if (list.isNotEmpty) {
      Chat chat = list.firstWhere(
          (c) => c.fromId == user.id && c.toId == event.from && !c.isGroupGet,
          orElse: () {
        return list.firstWhere(
            (c) => c.toId == user.id && c.fromId == event.from && !c.isGroupGet,
            orElse: () => Chat());
      });

      chat.isTyping = event.typing;
      add(list);

      Timer.periodic(Duration(seconds: 1), (_) {
        chat.isTyping = false;
        add(list);
      });
    }
  }

  _updateListMessageEvent(ChatEvent event) async {
    if (user == null) {
      user = await User.getPrefs();
    }

    List<Chat> list = _getList();

    if (list.isEmpty) {
      return;
    }

    Chat chat = list.firstWhere(
        (c) =>
            c.id != null
            //pegar a conversa correta
            &&
            c.conversaId == event.cId,
        orElse: () => _defaultChat);

    //quando usuário do app manda msg
    if (user.id == event.from) {
      int toId;
      String toName;
      String toPhoto;
      String toPhotoThumb;

      if (chat.fromId == user.id) {
        toId = chat.toId;
        toName = chat.toNome;
        toPhoto = chat.toUrlFoto;
        toPhotoThumb = chat.toUrlFotoThumb;
      } else {
        toId = chat.fromId;
        toName = chat.fromNome;
        toPhoto = chat.fromUrlFoto;
        toPhotoThumb = chat.fromUrlFotoThumb;
      }

      chat.toId = toId;
      chat.toNome = toName;
      chat.toUrlFoto = toPhoto;
      chat.toUrlFotoThumb = toPhotoThumb;
    } else {
      chat.toId = user.id;
      chat.toNome = user.nome;
      chat.toUrlFoto = user.urlFotoUsuario;
      chat.toUrlFotoThumb = user.urlFotoUsuarioThumb;

      //problema de duplicando msgs, if q evita
      if (chat.msgId != event.msgId) {
        if (chat.isChatOpenedUser(_openedChat)) {
          //enviar que está lendo a mensagem
          webSocket.readMsg(chat..id = event.msgId);
        } else {
          chat.badge.mensagens = chat.badge.mensagens + 1;
        }
      }
    }

    chat.msgId = event.msgId;
    chat.msg = event.msg;
    chat.data = event.date;
    chat.lida = event.status == "1C" ? 0 : 1;
    chat.entregue = event.status == "1C" ? 0 : 1;

    chat.fromId = event.from;
    chat.fromUrlFoto = event.fromUrlFoto;
    chat.fromUrlFotoThumb = event.fromUrlFotoThumb;
    chat.from = event.fromName;
    chat.arquivos = event.files;
    chat.fromNome = event.fromName;

    if (chat.id == null) {
      chat.id = event.cId;
      list.add(chat);
    }

    list.sort((a, b) {
      return b.data.compareTo(a.data);
    });

    add(list);
    _updateChatDB(chat);
  }

  _updateChatC2a(ChatEvent event) {
    List<Chat> list = _getList();

    if (list.isNotEmpty) {
      Chat chat = list.firstWhere(
          (c) => c.fromId == user.id && c.toId == event.from && !c.isGroupGet,
          orElse: () {
        return list.firstWhere(
            (c) => c.toId == user.id && c.fromId == event.from && !c.isGroupGet,
            orElse: () => Chat());
      });

      chat.lida = 1;
      add(list);
      _updateChatDB(chat);
    }
  }

  _updateChatMsg2C(ChatEvent event) {
    List<Chat> list = _getList();

    if (list.isNotEmpty) {
      Chat chat = list.firstWhere((c) => c.conversaId == event.cId);

      chat.entregue = 1;
      chat.lida = 0;
      add(list);
      _updateChatDB(chat);
    }
  }

  _updateUsersStatus(ChatEvent event) {}

  _syncConversas(ChatEvent event) {
    List<Chat> list = _getList();

    if (event.chats != null && event.chats.length > 0) {
      syncing.add(true);
      syncingChats.add(SyncingChats()
        ..count = 0
        ..total = event.chats.length);

      event.chats.asMap().forEach((idx, c) async {
        Chat chat =
            list.firstWhere((element) => element.conversaId == c.conversaId);

        if (chat.badge == null) {
          chat.badge = Badge()
            ..conversaId = c.conversaId
            ..mensagens = 1;
        } else {
          chat.badge.mensagens = chat.badge.mensagens + 1;
        }

        chat.msg = c.msg;

        add(list);

        syncingChats.add(SyncingChats()
          ..count = idx + 1
          ..total = event.chats.length);

        if (idx == event.chats.length - 1) {
          Future.delayed(Duration(seconds: 2), () {
            syncing.add(false);
          });
        }

        await _updateChatDB(c);
      });
    }

    if (event.badges != null && event.badges.length > 0) {
      event.badges.forEach((c) {
        Chat chat = list.firstWhere((element) => element.conversaId == c.cId);

        if (chat.badge == null) {
          chat.badge = Badge()
            ..conversaId = c.conversaId
            ..mensagens = c.count;
        } else {
          chat.badge.mensagens = c.count;
        }

        add(list);
      });
    }
  }

  checkBadges(Chat cc) {
    List<Chat> list = _getList();
    if (list.isNotEmpty) {
      Chat chat = list.firstWhere((c) => c.id == cc.id);

      chat.badge.mensagens = 0;
      add(list);
      _updateChatDB(chat);
    }
  }

  searchListaConversas(String value) {
    try {
      List<Chat> newData = _defaultList
          .where((element) => element.isGroup
              ? element.nomeGrupo.toLowerCase().contains(value)
              : user.id == element.fromId
                  ? element.toNome.toLowerCase().contains(value)
                  : element.fromNome.toLowerCase().contains(value))
          .toList();

      add(newData);
    } catch (e) {
      print(e);
    }
  }

  cancelSearch() {
    isSearching.add(false);
    add(_defaultList);
  }

  _keepAliveOk() {
    webSocket.keepAliveOk();
  }

  changeOpenedChat(Chat chat) {
    if (chat != null) {
      _appBloc.decreaseBadges(chat);
      checkBadges(chat);
    }
    _openedChat = chat;
  }

  Future _updateChatDB(Chat chat) async {
    return await _dao.update(chat, chat.whereUpdateDB);
  }

  dispose() {
    super.dispose();
    loading.dispose();
    isSearching.dispose();
    syncingChats.dispose();
    syncing.dispose();
  }
}

class SyncingChats {
  int total;
  int count;

  SyncingChats();
}
