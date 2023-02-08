

import 'package:flutter_dandelin/utils_livecom/dao/base_dao.dart';
import 'package:flutter_dandelin/utils_livecom/dao/entity_dao.dart';

class CategoriaPost {
  int id;
  String nome;
  String cor;
  bool menu;
  List arquivos;
  String userCreate;
  int userCreateId;
  bool likeable;
  bool hideData;
  int ordem;

  CategoriaPost({this.cor, this.id, this.nome});

  CategoriaPost.fromJson(Map<String, dynamic> map)
      : id = map["id"] as int,
        nome = map["nome"],
        cor = map["cor"],
        likeable = map["likeable"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nom]e'] = this.nome;
    data['cor'] = this.cor;
    data['menu'] = this.menu;
    //n esquece
    // if (this.arquivos != null) {
    //   data['arquivos'] = this.arquivos.map((v) => v.toJson()).toList();
    // }
    data['userCreate'] = this.userCreate;
    data['userCreateId'] = this.userCreateId;
    data['likeable'] = this.likeable;
    data['ordem'] = this.ordem;
    return data;
  }

  int getCor() {
    var hexColor = cor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    } else if (hexColor.length == 0) {
      hexColor = "FF000000";
    }
    return int.parse(hexColor, radix: 16);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CategoriaPost &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CategoriaDAO extends BaseDAO {
  @override
  Future createTable() async {
    return await query(
        "CREATE TABLE IF NOT EXISTS CATEGORIA ( ID INTEGER PRIMARY KEY AUTOINCREMENT , CODIGO TEXT, COR TEXT, ICONE TEXT, ID_POST INTEGER, NOME TEXT, PADRAO INTEGER ) ");
  }

  @override
  EntityDAO fromMap(Map<String, dynamic> map) {
    // TODO: implement fromMap
    throw UnimplementedError();
  }

  @override
  String getTable() {
    return "CATEGORIA";
  }
}
