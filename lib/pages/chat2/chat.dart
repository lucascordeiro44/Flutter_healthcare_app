import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/chat2/arquivo.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/utils_livecom/dao/base_dao.dart';
import 'package:flutter_dandelin/utils_livecom/dao/entity_dao.dart';
import 'package:flutter_dandelin/utils_livecom/datetime_helper.dart';


class Chat extends EntityDAO {
  int id;
  int conversaId;
  int data;
  String msg;
  int lida;
  Badge badge;
  String dataPush;
  String dataString;
  String dataWeb;
  int entregue;
  FotoGrupo fotoGrupo;
  String from;
  int fromId;
  String fromNome;
  String fromUrlFoto;
  String fromUrlFotoThumb;
  bool fromChatOn;
  int toId;
  String toNome;
  String toUrlFoto;
  String toUrlFotoThumb;
  bool toChatOn;
  int grupoId;
  int grupoQtdeUsers;
  String nomeGrupo;
  bool isGroup;
  bool isTyping;
  int identifier;
  String dataEntregue;
  bool isSelected;
  List<Arquivos> arquivos;
  Entity entity;
  String to;
  bool isAdmin;
  int msgAdmin;
  String dataLida;
  bool isCallbackCheck1Cinza;
  bool isCallbackCheck2Azul;
  bool isCallbackCheck2Cinza;
  bool fromChatAway;
  bool toChatAway;
  int msgId;
  CardLink card;

  Color colorNameGroup;

  int idBD;

  StatusChat statusChat;

  bool get isGroupGet => this.isGroup != null && this.isGroup;

  bool get arquivosDiffNull => arquivos != null && arquivos.length > 0;
  Arquivos get firtsArquivo => arquivosDiffNull ? arquivos.first : null;

  bool get isImagem =>
      arquivosDiffNull &&
      (firtsArquivo.tipo == "foto" || firtsArquivo.extensao == "png");
  bool get isAudio => arquivosDiffNull && firtsArquivo.tipo == "audio";
  bool get isPdf => arquivosDiffNull && firtsArquivo.extensao == "pdf";

  bool get isLink => card != null || entity != null;
  String get urlLink => card == null ? entity.url : card.link;
  String get imageLink => card == null ? entity.imagem : card.url;
  String get titleLink => card == null ? entity.titulo : card.title;
  String get descricaoLink => card == null ? entity.descricao : card.subTitle;

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(data);

  String get whereUpdateDB => "CONVERSA_ID = ${this.conversaId}";

  getIdOtherUser(User usuario) {
    if (grupoId != null) {
      return;
    }
    return fromId != usuario.id ? fromId : toId;
  }

  getNameChat(User usuario) {
    return grupoId != null
        ? nomeGrupo
        : fromId != usuario.id ? fromNome : toNome;
  }

  String getAvatar(User usuario) {
    return isGroup != null && isGroup
        ? fotoGrupo?.urlThumb == null
            ? "assets/imgs/grupo-default.jpg"
            : fotoGrupo.urlThumb
        : fromId != usuario.id ? fromUrlFotoThumb : toUrlFotoThumb;
  }

  getSubTitle(User usuario) {
    return isGroup
        ? "$grupoQtdeUsers usuários"
        : toChatOn != null && toChatOn ? "Online" : "Offline";
  }

  setConversaId(int conversaId){
    if(conversaId != null){
      this.conversaId = conversaId;
    }
  }

  Color getColorCircleChat(int userId) {

    // user.id == fromId ?
    return statusChat == null ? _fromChatOn(userId) : _fromStatusChat();

  }

  Color _fromChatOn(int userId)  {
    var statusOn = userId == fromId ? toChatOn : fromChatOn;
    var statusAway = userId == fromId ? toChatAway : fromChatAway;
      if(statusOn){
        return statusAway ?  Colors.amber : Colors.green;
      } else {
        return Colors.transparent;
      }

  }

  Color _fromStatusChat(){
    switch (statusChat) {
      case StatusChat.online:
        return Colors.green;
        break;
      case StatusChat.away:
        return Colors.amber;
        break;
      case StatusChat.offline:
        return Colors.red;
        break;
      case StatusChat.none:
        return Colors.transparent;
        break;
      default:
        return Colors.transparent;
    }
  }

  getMsgDataChat() {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(data);

    DateTime dateTimeSemMinutos = DateTime(date.year, date.month, date.day);

    Duration d = DateTime.now().difference(dateTimeSemMinutos);

    String hora = addZeroDate(date.hour);
    String minuto = addZeroDate(date.minute);
    String horario = "$hora:$minuto";

    if (d.inDays == 0) {
      return "Hoje - $horario";
    } else if (d.inDays == 1) {
      return "Ontem - $horario";
    } else {
      String dia = addZeroDate(date.day);
      String mes = addZeroDate(date.month);

      return "$dia/$mes - $horario";
    }
  }

  getTitle(User usuario) {
    if (isGroup) {
      return nomeGrupo;
    }

    return usuario.id == fromId ? toNome : fromNome;
  }

  isChatOpenedUser(Chat openedChat) {
    return this.id == openedChat?.id;
  }

  Chat();

  Chat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversaId = json['conversaId'];
    msg = json['msg'];
    fromId = json['fromId'];
    from = json['from'];
    fromNome = json['fromNome'];
    fromUrlFoto = json['fromUrlFoto'];
    fromUrlFotoThumb = json['fromUrlFotoThumb'];
    fromChatOn = json['fromChatOn'];
    toId = json['toId'];
    to = json['to'];
    toNome = json['toNome'];
    toUrlFoto = json['toUrlFoto'];
    toUrlFotoThumb = json['toUrlFotoThumb'];
    toChatOn = json['toChatOn'];

    entregue = json['entregue'];
    lida = json['lida'];
    badge = json['badge'] != null ? new Badge.fromJson(json['badge']) : null;
    identifier = json['identifier'];
    isAdmin = json['isAdmin'];
    msgAdmin = json['msgAdmin'];
    dataWeb = json['dataWeb'];
    isGroup = json['isGroup'];
    grupoQtdeUsers = json['grupoQtdeUsers'];
    dataEntregue = json['dataEntregue'];
    dataLida = json['dataLida'];
    data = json['data'];
    dataString = json['dataString'];

    isCallbackCheck1Cinza = json['isCallbackCheck1Cinza'];
    isCallbackCheck2Azul = json['isCallbackCheck2Azul'];
    isCallbackCheck2Cinza = json['isCallbackCheck2Cinza'];
    dataPush = json['dataPush'];
    fromChatAway = json['fromChatAway'];
    toChatAway = json['toChatAway'];
    grupoId = json['grupoId'];
    nomeGrupo = json['nomeGrupo'];
    fotoGrupo = json['fotoGrupo'] != null
        ? new FotoGrupo.fromJson(json['fotoGrupo'])
        : null;
    if (json['arquivos'] != null) {
      arquivos = new List<Arquivos>();
      json['arquivos'].forEach((v) {
        arquivos.add(new Arquivos.fromJson(v));
      });
      fotoGrupo = json["fotoGrupo"] != null
          ? FotoGrupo.fromJson(json["fotoGrupo"])
          : null;
      statusChat = json["toChatOn"]
          ? StatusChat.online
          : !json["toChatOn"] ? StatusChat.away : StatusChat.none;
    }
    msgId = json['msgId'];
    card = json['card'] != null ? CardLink.fromJson(json['card']) : null;
  }

  @override
  String toString() {
    return 'Chat{id: $id, conversaId: $conversaId, data: $data, msg: $msg, lida: $lida, badge: $badge, dataPush: $dataPush, dataString: $dataString, dataWeb: $dataWeb, entregue: $entregue, fotoGrupo: $fotoGrupo, from: $from, fromId: $fromId, fromNome: $fromNome, fromUrlFoto: $fromUrlFoto, fromUrlFotoThumb: $fromUrlFotoThumb, fromChatOn: $fromChatOn, toId: $toId, toNome: $toNome, toUrlFoto: $toUrlFoto, toUrlFotoThumb: $toUrlFotoThumb, toChatOn: $toChatOn, grupoId: $grupoId, grupoQtdeUsers: $grupoQtdeUsers, nomeGrupo: $nomeGrupo, isGroup: $isGroup}';
  }

  @override
  int getId() {
    return this.id;
  }

  @override
  Map toMapDB() {
    var map = {
      'BADGES': this.badge == null ? 0 : this.badge?.mensagens,
      'DATA': this.data,
      'DATE_ONLINE': '',
      'FROM_ID': this.fromId,
      'FROM_LOGIN': this.from,
      'FROM_NOME': this.fromNome,
      'FROM_URL_FOTO': this.fromUrlFoto,
      'FROM_URL_FOTO_THUMB': this.fromUrlFotoThumb,
      'GRUPO_FOTO_URL': this.isGroup ? this.fotoGrupo?.url : "",
      'GRUPO_FOTO_URL_THUMB': this.isGroup ? this.fotoGrupo?.urlThumb : "",
      'GRUPO_ID': this.isGroup ? this.grupoId : 0,
      'GRUPO_NOME': this.isGroup ? this.nomeGrupo : "",
      'GRUPO_QTDE_USERS': this.isGroup ? this.grupoQtdeUsers : "",
      'IDX': this.id,
      'INITIALIZED': '',
      'IS_ADMIN': this.isAdmin != null && this.isAdmin ? 1 : 0,
      'LAST_MSG_ID': this.msgId ?? 0,
      'TO_ID': this.toId,
      'TO_LOGIN': this.to,
      'TO_NOME': this.toNome,
      'TO_URL_FOTO': this.toUrlFoto,
      'MENSAGEM': this.msg ?? 0,
      'TO_URL_FOTO_THUMB': this.toUrlFotoThumb,
      'STATUS_CHECK_2_AZUL': this.lida,
      'STATUS_CHECK_2_CINZA': this.entregue,
      'CONVERSA_ID': this.conversaId,
    };

    if (this.idBD != null) {
      map['ID'] = this.idBD;
    }

    return map;
  }

  Chat.fromDB(Map<String, dynamic> json) {
    var _id = json['IDX'];

    badge = Badge()
      ..mensagens = json['BADGES']
      ..conversaId = _id;
    data = json['DATA'];
    fromId = json['FROM_ID'];
    from = json['FROM_LOGIN'];
    fromNome = json['FROM_NOME'];
    fromUrlFoto = json['FROM_URL_FOTO'];
    fromUrlFotoThumb = json['FROM_URL_FOTO_THUMB'];
    fotoGrupo = FotoGrupo()
      ..url = json['GRUPO_FOTO_URL']
      ..urlThumb = json['GRUPO_FOTO_URL_THUMB'];
    grupoId = json['GRUPO_ID'] == 0 ? null : json['GRUPO_ID'];
    isGroup = json['GRUPO_ID'] != null && json['GRUPO_ID'] != 0;
    nomeGrupo = json['GRUPO_NOME'];
    grupoQtdeUsers =
        json['GRUPO_QTDE_USERS'] == "" ? 0 : json['GRUPO_QTDE_USERS'];
    id = json['IDX'];
    isAdmin = json['IS_ADMIN'] == 1 ? true : false;
    msgId = json['LAST_MSG_ID'] == 0 ? null : json['LAST_MSG_ID'];
    toId = json['TO_ID'];
    to = json['TO_LOGIN'];
    toNome = json['TO_NOME'];
    toUrlFoto = json['TO_URL_FOTO'];
    toUrlFotoThumb = json['TO_URL_FOTO_THUMB'];
    msg = json['MENSAGEM'];
    lida = json['STATUS_CHECK_2_AZUL'];
    entregue = json['STATUS_CHECK_2_CINZA'];
    conversaId = json['CONVERSA_ID'];
    idBD = json['ID'];
  }
}

class ChatDAO extends BaseDAO<Chat> {
  @override
  Future createTable() async {
    await query(
        'CREATE TABLE IF NOT EXISTS CONVERSA ( ID INTEGER PRIMARY KEY AUTOINCREMENT , BADGES INTEGER, DATA INTEGER, DATE_ONLINE INTEGER, FROM_ID INTEGER, FROM_LOGIN TEXT, FROM_NOME TEXT, FROM_URL_FOTO TEXT, FROM_URL_FOTO_THUMB TEXT, GRUPO_FOTO_URL TEXT, GRUPO_FOTO_URL_THUMB TEXT, GRUPO_ID INTEGER, GRUPO_NOME TEXT, GRUPO_QTDE_USERS INTEGER, IDX INTEGER, INITIALIZED INTEGER, IS_ADMIN INTEGER, LAST_MSG_ID INTEGER, TO_ID INTEGER, TO_LOGIN TEXT, TO_NOME TEXT, TO_URL_FOTO TEXT, TO_URL_FOTO_THUMB TEXT, MENSAGEM TEXT, STATUS_CHECK_1_CINZA INTEGER, STATUS_CHECK_2_AZUL INTEGER, STATUS_CHECK_2_CINZA INTEGER, TITULO TEXT, CONVERSA_ID INTEGER) ');
  }

  fromMap(Map<String, dynamic> map) {
    return Chat.fromDB(map);
  }

  @override
  String getTable() {
    return "CONVERSA";
  }
}

class FotoGrupo {
  int id;
  String data;
  bool destaque;
  String extensao;
  String file;
  String url;
  String urlThumb;

  FotoGrupo();

  FotoGrupo.fromJson(Map<String, dynamic> map)
      : id = map["id"] as int,
        data = map["data"],
        destaque = map["destaque"],
        extensao = map["extensao"],
        file = map["file"],
        url = map["url"],
        urlThumb = map["urlThumb"];
}

class Badge {
  int conversaId;
  int mensagens;
  int cId;
  int count;

  Badge();

  Badge.fromJson(Map<String, dynamic> map)
      : conversaId = map["conversaId"] as int,
        mensagens = map["mensagens"] as int,
        cId = map["cId"] as int,
        count = map["count"] as int;
}

enum StatusChat {
  online,
  away,
  offline,
  none,
}

class Entity {
  String titulo;
  String descricao;
  String imagem;
  String dominio;
  String url;

  Entity({this.titulo, this.descricao, this.imagem, this.dominio, this.url});

  Entity.fromJson(Map<String, dynamic> json) {
    titulo = json['titulo'];
    descricao = json['descricao'];
    imagem = json['imagem'];
    dominio = json['dominio'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['titulo'] = this.titulo;
    data['descricao'] = this.descricao;
    data['imagem'] = this.imagem;
    data['dominio'] = this.dominio;
    data['url'] = this.url;
    return data;
  }
}

class CardLink {
  String url;
  String title;
  String subTitle;
  int id;
  int tipo;
  String link;

  CardLink(
      {this.url, this.title, this.subTitle, this.id, this.tipo, this.link});

  CardLink.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    title = json['title'];
    subTitle = json['subTitle'];
    id = json['id'];
    tipo = json['tipo'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['title'] = this.title;
    data['subTitle'] = this.subTitle;
    data['id'] = this.id;
    data['tipo'] = this.tipo;
    data['link'] = this.link;
    return data;
  }
}

class CardDAO extends BaseDAO {
  @override
  Future createTable() async {
    return await query(
        'CREATE TABLE IF NOT EXISTS CARD ( ID INTEGER PRIMARY KEY AUTOINCREMENT , ID_MENSAGEM INTEGER, LINK TEXT, SUB_TITLE TEXT, TIPO INTEGER, TITLE TEXT, URL TEXT, VALUE INTEGER ) ');
  }

  @override
  EntityDAO fromMap(Map<String, dynamic> map) {
    // TODO: implement fromMap
    throw UnimplementedError();
  }

  @override
  String getTable() {
    return 'CARD';
  }
}
