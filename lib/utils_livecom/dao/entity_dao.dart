abstract class Mapper {
  Map toMapDB();
}

abstract class EntityDAO extends Mapper {
  int getId();

//  Map toMap();
}

// Converte para Lista de Map
List toMapList<T extends Mapper>(List<T> list, {Function mapper}) {
  if (mapper != null) {
    return list != null ? list.map<Map>(mapper).toList() : null;
  }

  return list != null ? list.map<Map>((r) => r.toMapDB()).toList() : null;
}
