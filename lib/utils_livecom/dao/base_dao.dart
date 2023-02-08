
import 'package:sqflite/sqflite.dart';

import '../validators.dart';
import 'entity_dao.dart';
import 'sql_manager.dart';

abstract class BaseDAO<T extends EntityDAO> {
  Database get db => SQLManager.getInstance().db;

  String getTable();

  Future createTable();

  T fromMap(Map<String, dynamic> map);

  String get table => getTable();

  Future<int> save(T entity) async {
    var id = await db.insert(table, entity.toMapDB(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<int> update(T entity, String where) async {
    try {
      var id = await db.update(table, entity.toMapDB(),
          where: where, conflictAlgorithm: ConflictAlgorithm.replace);
      return id;
    } catch (e) {
      return null;
    }
  }

  Future<List<T>> query(String sql, [List<dynamic> args]) async {
    print(sql);
    final mapSql = await db.rawQuery(sql, args);
    final map = mapSql.map<T>((json) => fromMap(json)).toList();
    return map;
  }

  Future<List<C>> findByColumn<C>(String column, String table, String query,
      {int limit = 0}) async {
    List mapSql;

    String sql = "select distinct $column from $table";
    if (isNotEmpty(query)) {
      query = query.toLowerCase();
      sql += " where $column like ?";
      mapSql = await db.rawQuery(sql, ["%$query%"]);
    } else {
      if (limit != 0) {
        sql += " limit $limit";
      }
      mapSql = await db.rawQuery(sql);
    }

    List<C> result = mapSql.map<C>((map) => map["$column"]).toList();

    return result;
  }

  Future<C> queryColumn<C>(String sql, String column,
      [List<dynamic> args]) async {
    final list = await queryColumns<C>(sql, column, args);
    return list != null && list.isNotEmpty ? list.first : null;
  }

  Future<List<C>> queryColumns<C>(String sql, String column,
      [List<dynamic> args]) async {
    final mapSql = await db.rawQuery(sql, args);
    final list = mapSql.map<C>((map) => map[column]).toList();
    return list;
  }

  Future<List<T>> findAll({int limit = 0}) async {
    return limit == 0
        ? query("select * from $table")
        : query("select * from $table limit $limit");
  }

  Future<List<T>> findAllOrderBy(String orderBy, {int limit = 0}) async {
    return limit == 0
        ? query("select * from $table order by $orderBy")
        : query("select * from $table order by $orderBy limit $limit");
  }

  Future<int> queryCount(String sql, List<int> args) async {
    final result = await db.rawQuery('$sql', args);
    return Sqflite.firstIntValue(result);
  }

  Future<int> getCount() async {
    final result = await db.rawQuery('select count(*) from $table');
    return Sqflite.firstIntValue(result);
  }

  Future<T> queryOne(String sql, [List<dynamic> args]) async {
    final result = await db.rawQuery(sql, args);
    if (result.length > 0) {
      return fromMap(result.first);
    }
    return null;
  }

  Future<T> findById(int id) async {
    return queryOne('select * from $table where id = ?', [id]);
  }

  Future<bool> exists(T entity) async {
    T c = await findById(entity.getId());
    var exists = c != null;
    return exists;
  }

  Future<int> delete(T entity) async {
    return await db
        .rawDelete('delete from $table where id = ?', [entity.getId()]);
  }

  Future<int> deleteById(int id) async {
    return await db.rawDelete('delete from $table where id = ?', [id]);
  }

  Future<int> deleteAll() async {
    return await db.rawDelete('delete from $table');
  }
}
