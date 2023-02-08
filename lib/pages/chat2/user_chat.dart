import 'dart:convert';

import 'package:flutter_dandelin/utils_livecom/dao/base_dao.dart';
import 'package:flutter_dandelin/utils_livecom/dao/entity_dao.dart';
import 'package:flutter_dandelin/utils_livecom/prefs.dart';

import 'constants_chat.dart';
import 'grupo/grupo.dart';
import 'livecom_config.dart';

class User {
  final int id;
  String nome;
  String email;
  String login;
  String senha;

  String funcao;
  String telefone;
  String celular;

  String urlFotoUsuario;
  String urlFotoUsuarioThumb;
  String token;

  List<Grupo> grupos;

  LivecomConfig livecomConfig;
  String corHeader;

  static String authorization;

  User(
      {this.id,
        this.nome,
        this.email,
        this.login,
        this.urlFotoUsuario,
        this.urlFotoUsuarioThumb});

  User.fromJson(Map<String, dynamic> map)
      : id = map["id"] as int,
        nome = map["nome"],
        email = map["email"],
        login = map["login"],
        senha = map["senha"],
        funcao = map["funcao"],
        telefone = map["fixo"],
        celular = map["celular"],
        urlFotoUsuario = map["urlFotoUsuario"] ?? USER_PHOTO_DEFAULT,
        urlFotoUsuarioThumb = map["urlFotoUsuarioThumb"] ?? USER_PHOTO_DEFAULT,
        token = map["wstoken"],
        grupos =
        map["grupos"]?.map<Grupo>((json) => Grupo.fromJson(json))?.toList(),
        livecomConfig = map["livecomConfig"] != null
            ? LivecomConfig.fromJson(map["livecomConfig"])
            : null,
        corHeader = map["corHeader"];

  Map toMap() {
    return {
      "id": id,
      "nome": nome,
      "email": email,
      "login": login,
      "senha": senha,
      "funcao": funcao,
      "fixo": telefone,
      "celular": celular,
      "urlFotoUsuario": urlFotoUsuario,
      "urlFotoUsuarioThumb": urlFotoUsuarioThumb,
      "wstoken": token,
      "grupos": grupos.map<Map>((grupo) => grupo.toMap()).toList(),
      "livecomConfig": livecomConfig.toMap(),
      "corHeader": corHeader,
    };
  }

  String toJson() {
    return json.encode(toMap());
  }

  void savePrefs() {
    String s = toJson();
    print(s);

    Prefs.setString("userChat.prefs", s);
  }

  static Future<User> getPrefs() async {
    String s = await Prefs.getString("userChat.prefs");
    // print(" Prefss >>> $s");
    // if (s.isNullOrEmpty()) {
    //   return null;
    // }
    try {
      if (s.isNotEmpty) {
        final map = json.decode(s);
        final user = User.fromJson(map);
        return user;
      }
      return null;
    } catch (error) {
      print("Error parser user: $error");
      User.clear();
      return null;
    }
  }

  static Future<String> getToken() async {
    if (authorization != null) {
      return authorization;
    }

    User u = await User.getPrefs();
    if (u != null) {
      authorization = u.token;
    }
    return authorization;
  }

  static void clear() {
    Prefs.setString("userChat.prefs", "");
  }
}

class UserDAO extends BaseDAO {
  @override
  Future createTable() {
    return query(
        "CREATE TABLE IF NOT EXISTS USER ( ID INTEGER PRIMARY KEY AUTOINCREMENT , ADMIN_CHAT INTEGER, CANAL TEXT, CARGO TEXT, CELULAR TEXT, CHECKED INTEGER, CIDADE TEXT, COMPLEMENTO TEXT, COR_HEADER TEXT, DATA_NASC TEXT, EMAIL TEXT, FIXO TEXT, FORMACAO TEXT, FUNCAO TEXT, FUNCAO_ID INTEGER, GENERO TEXT, GRUPO_ORIGEM_STRING TEXT, ID_GRUPO TEXT, IDENTIFICACAO TEXT, IDENTIFICADOR TEXT, LOGIN TEXT, NOME TEXT, PRE_CADASTRO INTEGER, SETOR TEXT, STATUS TEXT, STRING_LISTA_GRUPOS_NOMES TEXT, TELEFONE_CELULAR TEXT, TELEFONE_FIXO TEXT, TIMESTAMP_LOGIN TEXT, TIPO TEXT, UNIDADE TEXT, URL_FOTO_USUARIO TEXT, URL_FOTO_USUARIO_THUMB TEXT, WSTOKEN TEXT ) ");
  }

  @override
  EntityDAO fromMap(Map<String, dynamic> map) {
    // TODO: implement fromMap
    throw UnimplementedError();
  }

  @override
  String getTable() {
    return "USER";
  }
}
