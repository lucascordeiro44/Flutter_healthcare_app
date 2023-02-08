import 'package:flutter_dandelin/utils_livecom/dao/base_dao.dart';
import 'package:flutter_dandelin/utils_livecom/dao/entity_dao.dart';

class Tags {
  int id;
  String nome;
  int ordem;
  String tipo;
  bool visivel;
  bool isSelected;

  Tags({
    this.id,
    this.nome,
    this.ordem,
    this.tipo,
    this.visivel,
  });

  Tags.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    ordem = json['ordem'];
    tipo = json['tipo'];
    visivel = json['visivel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nome'] = this.nome;
    data['ordem'] = this.ordem;
    data['tipo'] = this.tipo;
    data['visivel'] = this.visivel;

    return data;
  }
}

class TagDAO extends BaseDAO {
  @override
  Future createTable() async {
    return await query(
        'CREATE TABLE IF NOT EXISTS TAG ( ID INTEGER PRIMARY KEY AUTOINCREMENT , ID_POST INTEGER, NOME TEXT )');
  }

  @override
  EntityDAO fromMap(Map<String, dynamic> map) {
    // TODO: implement fromMap
    throw UnimplementedError();
  }

  @override
  String getTable() {
    return 'TAG';
  }
}
