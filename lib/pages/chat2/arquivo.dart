
import 'dart:io';

import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/utils_livecom/dao/base_dao.dart';
import 'package:flutter_dandelin/utils_livecom/dao/entity_dao.dart';

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
  File fileUser;

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
    this.fileUser,
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

class ArquivoDAO extends BaseDAO {
  @override
  EntityDAO fromMap(Map<String, dynamic> map) {
    // TODO: implement fromMap
    throw UnimplementedError();
  }

  @override
  String getTable() {
    return "ARQUIVO";
  }

  @override
  Future createTable() async {
    await query(
        "CREATE TABLE IF NOT EXISTS ARQUIVO ( ID INTEGER PRIMARY KEY AUTOINCREMENT , DATA TEXT, ENVIADO INTEGER, EXTENSAO TEXT, FILE_PATH TEXT, FOTO TEXT, HAS_THUMBS INTEGER, HEIGHT TEXT, ID_MENSAGEM INTEGER, ID_POST INTEGER, ID_SERVER TEXT, LENGTH TEXT, NOME TEXT, TIPO TEXT, URL TEXT, URL_THUMB TEXT, WIDTH TEXT ) ");
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

class ThumbDAO extends BaseDAO {
  @override
  Future createTable() async {
    return await query(
        'CREATE TABLE IF NOT EXISTS THUMB ( ID INTEGER PRIMARY KEY AUTOINCREMENT , ARQUIVO_ID INTEGER, HEIGHT TEXT, URL TEXT, WIDTH TEXT ) ');
  }

  @override
  EntityDAO fromMap(Map<String, dynamic> map) {
    // TODO: implement fromMap
    throw UnimplementedError();
  }

  @override
  String getTable() {
    return 'THUMB';
  }
}
