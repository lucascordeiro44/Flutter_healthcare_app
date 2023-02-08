

import 'package:flutter_dandelin/pages/chat2/user_chat.dart';

class FileServ {
  int id;
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
  String dimensao;
  bool destaque;
  int ordem;

  FileServ(
      {this.id,
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
      this.dimensao,
      this.destaque,
      this.ordem});

  FileServ.fromJson(Map<String, dynamic> json) {
    id = json['id'];
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
    dimensao = json['dimensao'];
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
    data['dimensao'] = this.dimensao;
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
