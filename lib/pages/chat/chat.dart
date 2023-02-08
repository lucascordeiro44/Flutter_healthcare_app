import 'package:flutter/material.dart';
import 'package:flutter_dandelin/app_bloc.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/utils/datetime_helper.dart';

class Chat {
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

  bool get msgEntregue => this.entregue == 1;
  bool get msgLida => this.lida == 1;

  myMsg() {
    return fromId == appBloc.livecomId;
  }

  getIdOtherUser(User usuario) {
    return fromId == appBloc.livecomId ? toId : fromId;
  }

  getNameChat() {
    return fromId == appBloc.livecomId ? toNome : fromNome;
  }

  getAvatar() {
    return fromId == appBloc.livecomId ? toUrlFotoThumb : fromUrlFotoThumb;
  }

  getSubTitle(User usuario) {
    return toChatOn != null && toChatOn ? "Online" : "Offline";
  }

  getTitle(User usuario) {
    return fromId == appBloc.livecomId ? toNome : fromNome;
  }

  hasMsgs() {
    return badge?.mensagens != 0;
  }

  doctor() {
    User user = User();

    user.username = fromId == appBloc.livecomId ? to : from;
    user.firstName = getNameChat();
    user.avatar = getAvatar();

    return user;
  }

  Color getColorCircleChat() {
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
      return "$horario";
    } else if (d.inDays == 1) {
      return "Ontem";
    } else {
      String dia = addZeroDate(date.day);
      String mes = addZeroDate(date.month);

      return "$dia/$mes - $horario";
    }
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
    return 'Chat{id: $id, conversaId: $conversaId, data: $data, msg: $msg, lida: $lida, badge: $badge, dataPush: $dataPush, dataString: $dataString, dataWeb: $dataWeb, entregue: $entregue, fotoGrupo: $fotoGrupo, from: $from, fromId: $fromId, fromNome: $fromNome, fromUrlFoto: $fromUrlFoto, fromUrlFotoThumb: $fromUrlFotoThumb, fromChatOn: $fromChatOn, toId: $toId, toNome: $toNome, toUrlFoto: $toUrlFoto, toUrlFotoThumb: $toUrlFotoThumb, toChatOn: $toChatOn, grupoId: $grupoId, grupoQtdeUsers: $grupoQtdeUsers, nomeGrupo: $nomeGrupo}';
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

class Arquivos {
  int id;
  String tipo;
  String file;
  String extensao;
  int length;
  String lengthHumanReadable;
  int width;
  int height;
  String data;
  String url;
  String urlThumb;
  List<Thumbs> thumbs;
  User usuario;
  bool destaque;
  int ordem;

  Arquivos({
    this.id,
    this.tipo,
    this.file,
    this.extensao,
    this.length,
    this.lengthHumanReadable,
    this.width,
    this.height,
    this.data,
    this.url,
    this.urlThumb,
    this.thumbs,
    this.usuario,
    this.destaque,
    this.ordem,
  });

  Arquivos.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tipo = json['tipo'];
    file = json['file'];
    extensao = json['extensao'];
    length = json['length'];
    lengthHumanReadable = json['lengthHumanReadable'];
    width = json['width'];
    height = json['height'];
    data = json['data'];
    url = json['url'];
    urlThumb = json['urlThumb'];
    if (json['thumbs'] != null) {
      thumbs = new List<Thumbs>();
      json['thumbs'].forEach((v) {
        thumbs.add(new Thumbs.fromJson(v));
      });
    }
    usuario =
        json['usuario'] != null ? new User.fromJson(json['usuario']) : null;
    destaque = json['destaque'];
    ordem = json['ordem'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['file'] = this.file;
    data['extensao'] = this.extensao;
    data['length'] = this.length;
    data['lengthHumanReadable'] = this.lengthHumanReadable;
    data['width'] = this.width;
    data['height'] = this.height;
    data['data'] = this.data;
    data['url'] = this.url;
    data['urlThumb'] = this.urlThumb;
    if (this.thumbs != null) {
      data['thumbs'] = this.thumbs.map((v) => v.toJson()).toList();
    }
    if (this.usuario != null) {
      data['usuario'] = this.usuario.toJson();
    }
    data['destaque'] = this.destaque;
    data['ordem'] = this.ordem;
    return data;
  }
}

class Thumbs {
  int id;
  String url;
  int width;
  int height;

  Thumbs({this.id, this.url, this.width, this.height});

  Thumbs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    width = json['width'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    data['width'] = this.width;
    data['height'] = this.height;
    return data;
  }
}
