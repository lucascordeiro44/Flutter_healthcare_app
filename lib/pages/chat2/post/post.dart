import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/chat2/arquivo.dart';
import 'package:flutter_dandelin/pages/chat2/grupo/grupo.dart';
import 'package:flutter_dandelin/pages/chat2/post/categoria_post.dart';
import 'package:flutter_dandelin/pages/chat2/post/tags.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/utils_livecom/dao/base_dao.dart';
import 'package:flutter_dandelin/utils_livecom/dao/entity_dao.dart';

import '../constants_chat.dart';


class Post {
  int id;
  String titulo;
  String tags;
  String arquivosId;
  String tagsCadastro;
  String mensagem;
  bool rascunho;
  CategoriaPost categoria;
  int usuarioId;
  int usuarioUpdateId;
  String usuarioNomeUpdate;
  String usuarioLogin;
  String usuarioNome;
  String urlFotoUsuario;
  String urlFotoUsuarioThumb;
  String dataStr;
  int timestamp;
  String status;
  String dataPubStr;
  int statusPub;
  String statusPubStr;
  String dataEdit;
  int timestampPub;
  int timestampEdit;
  List<Grupo> grupos;
  String checkDestaque;
  String visibilidade;
  int likeCount;
  bool sendPush;
  bool sendNotification;
  bool likeable;
  bool prioritario;
  bool webview;
  bool html;
  bool favorito;
  bool like;
  Destaque destaque;
  List<Arquivos> arquivos;
  int commentCount;
  int lastNotificationUsuarioId;

  List<File> files;
  List<Tags> tagsList;

  Post({
    this.id = 0,
    @required this.titulo,
    @required this.mensagem,
    @required this.categoria,
    @required this.grupos,
  });

  getIdGrupos() {
    String gruposIds;
    this.grupos?.forEach((element) {
      gruposIds = gruposIds == null
          ? element.id.toString()
          : gruposIds + ",${element.id.toString()}";
    });

    return gruposIds;
  }

  getNomeTags() {
    String tagsId = "";

    this.tagsList?.forEach((element) {
      tagsId = tagsId == null
          ? element.nome.toString()
          : tagsId + ",${element.nome.toString()}";
    });

    return tagsId;
  }

  int maxLength = 200;
  bool get isLongText =>
      this.mensagem != null ? this.mensagem.length > maxLength : false;
  String get msg => this.mensagem != null
      ? "${this.mensagem.substring(0, this.mensagem.length < maxLength ? this.mensagem.length : maxLength)}${isLongText ? ".." : ""}"
      : null;

  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    titulo = json['titulo'];
    tags = json['tags'];
    tagsCadastro = json['tagsCadastro'];
    mensagem = json['mensagem'];
    rascunho = json['rascunho'];
    categoria = json['categoria'] != null
        ? new CategoriaPost.fromJson(json['categoria'])
        : null;
    usuarioId = json['usuarioId'];
    usuarioUpdateId = json['usuarioUpdateId'];
    usuarioNomeUpdate = json['usuarioNomeUpdate'];
    usuarioLogin = json['usuarioLogin'];
    usuarioNome = json['usuarioNome'];
    urlFotoUsuario = json["urlFotoUsuario"] ?? USER_PHOTO_DEFAULT;
    urlFotoUsuarioThumb = json['urlFotoUsuarioThumb'];
    dataStr = json['dataStr'];
    timestamp = json['timestamp'];
    status = json['status'];
    dataPubStr = json['dataPubStr'];
    statusPub = json['statusPub'];
    statusPubStr = json['statusPubStr'];
    dataEdit = json['dataEdit'];
    timestampPub = json['timestampPub'];
    timestampEdit = json['timestampEdit'];
    favorito = json["favorito"] == "1" ? true : false;
    like = json["like"] == "1" ? true : false;
    if (json['grupos'] != null) {
      grupos = new List<Grupo>();
      json['grupos'].forEach((v) {
        grupos.add(new Grupo.fromJson(v));
      });
    }
    checkDestaque = json['checkDestaque'];
    visibilidade = json['visibilidade'];
    likeCount = json["likeCount"] ?? 0;
    sendPush = json['sendPush'];
    sendNotification = json['sendNotification'];
    likeable = json['likeable'];
    prioritario = json['prioritario'];
    webview = json['webview'];
    html = json['html'];
    commentCount = json["commentCount"] ?? 0;
    lastNotificationUsuarioId = json['lastNotificationUsuarioId'];
    arquivosId = json['arquivos_id'];
    destaque = json['destaque'] != null
        ? new Destaque.fromJson(json['destaque'])
        : null;
    if (json['arquivos'] != null) {
      arquivos = new List<Arquivos>();
      json['arquivos'].forEach((v) {
        arquivos.add(new Arquivos.fromJson(v));
      });
    }
  }

  @override
  String toString() {
    return 'Post{id: $id, titulo: $titulo}';
  }

  imprimeGrupo() {
    if (grupos != null)
      return grupos?.length != 0
          ? "${grupos.toString().replaceAll("[", "").replaceAll("]", "")}"
          : "Somente Eu";
  }

  Future<Map<String, dynamic>> toJson() async {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    User user = await User.getPrefs();

    data['id'] = this.id == 0 ? null : this.id;
    data['titulo'] = this.titulo;

    data['tagsCadastro'] = this.tagsCadastro;
    data['user'] = user.toMap();
    data['mensagem'] = this.mensagem;
    data['rascunho'] = this.rascunho;
    if (this.categoria != null) {
      data['categoria'] = this.categoria.toJson();
    }
    data['usuarioId'] = this.usuarioId ?? user.id;
    data['usuarioUpdateId'] = this.usuarioUpdateId ?? user.id;
    data['usuarioNomeUpdate'] = this.usuarioNomeUpdate ?? user.nome;
    data['usuarioLogin'] = this.usuarioLogin ?? user.email;
    data['usuarioNome'] = this.usuarioNome ?? user.nome;
    data['urlFotoUsuario'] = this.urlFotoUsuario ?? user.urlFotoUsuario;
    data['urlFotoUsuarioThumb'] =
        this.urlFotoUsuarioThumb ?? user.urlFotoUsuarioThumb;
    data['dataStr'] = this.dataStr;
    data['timestamp'] = this.timestamp;
    data['status'] = this.status;
    data['dataPubStr'] = this.dataPubStr;
    data['statusPub'] = this.statusPub;
    data['statusPubStr'] = this.statusPubStr;
    data['dataEdit'] = this.dataEdit;
    data['timestampPub'] = this.timestampPub;
    data['timestampEdit'] = this.timestampEdit;
    data['favorito'] = this.favorito;
    data['like'] = this.like;
    if (this.grupos != null) {
      data['grupos'] = this.grupos.map((v) => v.toJson()).toList();
    }
    data['checkDestaque'] = this.checkDestaque;
    data['visibilidade'] = this.visibilidade;
    data['likeCount'] = this.likeCount;
    data['sendPush'] = this.sendPush ?? true;
    data['sendNotification'] = this.sendNotification ?? true;
    data['likeable'] = this.likeable ?? true;
    data['prioritario'] = this.prioritario ?? false;
    data['webview'] = this.webview ?? false;
    data['html'] = this.html ?? false;
    data['lastNotificationUsuarioId'] = this.lastNotificationUsuarioId;
    if (this.tagsList != null) {
      this.tagsList.forEach((element) {
        tags = tags.isEmpty
            ? element.id.toString()
            : tags + ",${element.id.toString()}";
      });
      data['tags'] = this.tags;
    }
    data['arquivos_id'] = this.arquivosId;
    return data;
  }
}

class PostDAO extends BaseDAO {
  @override
  Future createTable() {
    return query(
        "CREATE TABLE IF NOT EXISTS POST ( ID INTEGER PRIMARY KEY AUTOINCREMENT , ANIM_CARD INTEGER, ANO INTEGER, ARQUIVO_IDS TEXT, BADGES TEXT, CATEGORIA INTEGER, CATEGORIA_ID TEXT, COMMENT_BADGE_COUNT INTEGER, COMMENT_COUNT INTEGER, DATA_EXPIRACAO TEXT, DATA_PUB_STR TEXT, DATA_PUBLICACAO TEXT, DATA_STR TEXT, DATEDD_MMYYYY TEXT, DIA_DO_MES INTEGER, GRUPOS_NOMES TEXT, HAS_ARQUIVOS INTEGER, HAS_DESTAQUE INTEGER, HORA_EXPIRACAO TEXT, HORA_PUBLICACAO TEXT, IDENTIFICADOR TEXT, INDIMG1 INTEGER, INDIMG2 INTEGER, IS_POST_DESTAQUE TEXT, IS_POST_PRIORITARIO INTEGER, ISFAVORITO INTEGER, ISLIKE INTEGER, LIKE_COUNT INTEGER, MENSAGEM TEXT, MES INTEGER, NUMERO_DE_IMAGENS INTEGER, PUSH_ON INTEGER, SEND_PUSH INTEGER, SHOW_STATUS_NAO_ENVIADO INTEGER, STATUS TEXT, TIME_H_HMM TEXT, TIMESTAMP INTEGER, TIMESTAMP_PUB INTEGER, TITULO TEXT, TO_UPLOAD INTEGER, UPLOADED INTEGER, URL_FOTO_USUARIO TEXT, URL_FOTO_USUARIO_THUMB TEXT, URL_IMAGEM TEXT, URL_SITE TEXT, URL_VIDEO TEXT, USUARIO_LOGIN TEXT, USUARIO_NOME TEXT, VISIBILIDADE TEXT ) ");
  }

  @override
  EntityDAO fromMap(Map<String, dynamic> map) {
    // TODO: implement fromMap
    throw UnimplementedError();
  }

  @override
  String getTable() {
    return "POST";
  }
}

class Destaque {
  String url;
  String descricao;
  String titulo;
  int tipo;
  String link;
  int postId;
  String usuario;

  Destaque(
      {this.url,
        this.descricao,
        this.titulo,
        this.tipo,
        this.link,
        this.postId,
        this.usuario});

  Destaque.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    descricao = json['descricao'];
    titulo = json['titulo'];
    tipo = json['tipo'];
    link = json['link'];
    postId = json['postId'];
    usuario = json['usuario'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['descricao'] = this.descricao;
    data['titulo'] = this.titulo;
    data['tipo'] = this.tipo;
    data['link'] = this.link;
    data['postId'] = this.postId;
    data['usuario'] = this.usuario;
    return data;
  }
}

class DestaqueDAO extends BaseDAO {
  @override
  Future createTable() async {
    return await query(
        'CREATE TABLE IF NOT EXISTS DESTAQUE ( ID INTEGER PRIMARY KEY AUTOINCREMENT , DESCRIPTION TEXT, ID_POST INTEGER, IMAGE_URL TEXT, LINK TEXT, TIPO INTEGER, TITLE TEXT ) ');
  }

  @override
  EntityDAO fromMap(Map<String, dynamic> map) {
    // TODO: implement fromMap
    throw UnimplementedError();
  }

  @override
  String getTable() {
    return 'DESTAQUE';
  }
}
