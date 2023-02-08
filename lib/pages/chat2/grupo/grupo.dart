import 'dart:convert';

import 'package:flutter_dandelin/utils_livecom/dao/base_dao.dart';
import 'package:flutter_dandelin/utils_livecom/dao/entity_dao.dart';

import '../constants_chat.dart';

class Grupo {
  final int id;
  String nome;
  bool padrao;
  bool favorito;
  bool participa;
  bool postar;
  int countPosts;
  int countUsers;
  String dataEntrada;
  String dataSaida;
  String userAdmin;
  int userAdminId;
  bool havePost;
  String urlFoto;
  String urlFotoThumb;
  String tipo;
  bool virtual;

  Grupo(this.id);

  Grupo.fromJson(Map<String, dynamic> map)
      : id = map["id"] as int,
        nome = map["nome"],
        padrao = map["padrao"],
        favorito = map["favorito"],
        participa = map["participa"],
        postar = map["postar"],
        countPosts = map["countPosts"],
        countUsers = map["countUsers"],
        dataEntrada = map["dataEntrada"],
        dataSaida = map["dataSaida"],
        userAdmin = map["userAdmin"],
        userAdminId = map["userAdminId"],
        havePost = map["havePost"],
        urlFoto = map["urlFoto"],
        urlFotoThumb = map["urlFotoThumb"],
        tipo = map["tipo"],
        virtual = map["virtual"];

  Map toMap() {
    return {
      "id": id,
      "nome": nome,
      "padrao": padrao,
      "favorito": favorito,
      "participa": participa,
      "postar": postar,
      "countPosts": countPosts,
      "countUsers": countUsers,
      "dataEntrada": dataEntrada,
      "dataSaida": dataSaida,
      "userAdmin": userAdmin,
      "userAdminId": userAdminId,
      "havePost": havePost,
      "urlFoto": urlFoto,
      "urlFotoThumb": urlFotoThumb,
      "tipo": tipo,
      "virtual": virtual,
    };
  }

  toJson() {
    return json.encode(toMap());
  }

  String getUrlFoto() {
    if (urlFoto != null && (urlFoto.isEmpty || urlFoto == "img/grupo.jpg")) {
      return USER_PHOTO_DEFAULT;
    }

    return urlFoto;
  }

  String getUsuarios() {
    if (countUsers != null) {
      return "$countUsers " + (countUsers == 1 ? "Usuário" : "Usuários");
    }

    return "0 Usuários";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Grupo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return '$nome';
  }
}

class GrupoDAO extends BaseDAO {

  @override
  Future createTable() async {
    return await query(
        'CREATE TABLE IF NOT EXISTS GRUPO ( ID INTEGER PRIMARY KEY AUTOINCREMENT , COUNT_USERS INTEGER, ID_POST INTEGER, NOME TEXT, PADRAO INTEGER, PARTICIPA INTEGER, POSTAR INTEGER, SELECTED INTEGER, SEND_PUSH INTEGER, TIPO TEXT, URL_FOTO TEXT, URL_FOTO_THUMB TEXT ) ');
  }

  @override
  EntityDAO fromMap(Map<String, dynamic> map) {
    // TODO: implement fromMap
    throw UnimplementedError();
  }

  @override
  String getTable() {
    return 'GRUPO';
  }
}
