import 'dart:convert';

class MenuMobile {
  final int id;
  String label;
  String codigo;
  String icone;
  String descricao;
  String parametro;
  int ordem;
  bool menuDefault;
  bool divider;

  MenuMobile.fromJson(Map<String, dynamic> map)
      : id = map["id"] as int,
        label = map["label"],
        codigo = map["codigo"],
        icone = map["icone"],
        descricao = map["descricao"],
        parametro = map["parametro"],
        ordem = map["ordem"],
        menuDefault = map["menuDefault"],
        divider = map["divider"];

  Map toMap() {
    return {
      "id": id,
      "label": label,
      "codigo": codigo,
      "icone": icone,
      "descricao": descricao,
      "parametro": parametro,
      "ordem": ordem,
      "menuDefault": menuDefault,
      "divider": divider,
    };
  }

  String toJson() {
    return json.encode(toMap());
  }
}
