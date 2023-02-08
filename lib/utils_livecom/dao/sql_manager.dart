import 'dart:async';
import 'dart:io';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class SQLHelper {
  int getDbVersion();

  String getDbName();

  // Para embarcar
  String getSqlAssetsFile();

  // Para dar create
  String getSqlCreateFile();

  // Para dar upgrade
  String getSqlUpgradeFile(int oldVersion, int newVersion);
}

class SQLManager {
  SQLHelper _helper;

  // Singleton
  static final SQLManager _instance = new SQLManager.getInstance();

  factory SQLManager() => _instance;

  SQLManager.getInstance();

  SQLHelper get helper => _instance._helper;

  // Db
  static Database _db;

  Database get db {
    //TODO LUCAS REVISAR ESSE ERRO
    if (helper == null) {
      throw Exception("SQL Error - Call SQLManager.init(sqlHelper) first !!!");
    }
    if (_db == null) {
      SQLManager.getInstance().init(helper);

      print("SQL Error - Database not initialized!");
    }

    return _db;
  }

  Future init(SQLHelper helper) async {
    print("> SQLHelper.init()");
    _instance._helper = helper;

    // Abre o banco de dados
    bool b = await _initDb();

    print("< SQLHelper.init().");

    if (b) {
      _createTables();
    }

    return b;
  }

  static Future<bool> _initDb() async {
    File file = await getDbFile();
    String path = file.path;

    print("db: ${file.path}");

    // open the database
    _db = await openDatabase(path);

    return true;
  }

  static Future<File> getDbFile() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _instance.helper.getDbName());
    return File(path);
  }

  _createTables() async {
    await ChatDAO().createTable();
    await UserDAO().createTable();


    await _db.execute(
        "CREATE TABLE IF NOT EXISTS ARQUIVO_POST_BD ( ID INTEGER PRIMARY KEY AUTOINCREMENT , ID_POST INTEGER, URL TEXT )");
    await _db.execute(
        "CREATE TABLE IF NOT EXISTS CHAT_STRING ( ID INTEGER PRIMARY KEY AUTOINCREMENT , JSON TEXT ) ");
    await _db.execute(
        'CREATE TABLE IF NOT EXISTS HTTP_RESPONSE_ENTITY ( ID INTEGER PRIMARY KEY AUTOINCREMENT , METHOD TEXT, PARAMS TEXT, RESPONSE TEXT, URL TEXT ) ');
    await _db.execute(
        'CREATE TABLE IF NOT EXISTS MENSAGEM ( ID INTEGER PRIMARY KEY AUTOINCREMENT , BADGES INTEGER, CONVERSA_ID INTEGER, DATA INTEGER, FOTO_GRUPO_URL TEXT, FOTO_GRUPO_URL_THUMB TEXT, FRIEND_ONLINE INTEGER, FROM_ID INTEGER, FROM_LOGIN TEXT, FROM_NOME TEXT, FROM_URL_FOTO TEXT, FROM_URL_FOTO_THUMB TEXT, GRUPO_ID INTEGER, GRUPO_QTDE_USERS INTEGER, HAS_ARQUIVOS INTEGER, HAS_BOTOES INTEGER, HAS_CARDS INTEGER, IDENTIFIER INTEGER, IS_MSG_ADMIN INTEGER, LATITUDE FLOAT, LONGITUDE FLOAT, MSG TEXT, NOME_GRUPO TEXT, STATUS_CHECK_1_CINZA INTEGER, STATUS_CHECK_2_AZUL INTEGER, STATUS_CHECK_2_CINZA INTEGER, TITULO TEXT, TO_ID INTEGER, TO_LOGIN TEXT, TO_NOME TEXT, TO_URL_FOTO TEXT, TO_URL_FOTO_THUMB TEXT, WAS_SEND INTEGER ) ');
    await _db.execute(
        'CREATE TABLE IF NOT EXISTS CARD_BUTTON ( ID INTEGER PRIMARY KEY AUTOINCREMENT , ACTION TEXT, ID_CARD INTEGER, LABEL TEXT, VALUE TEXT ) ');
    await _db.execute(
        'CREATE TABLE IF NOT EXISTS CHAT_BUTTONS ( ID INTEGER PRIMARY KEY AUTOINCREMENT , ACTION TEXT, ID_MENSAGEM INTEGER, TITLE TEXT, VALUE TEXT ) ');
  }

  Future dropDatabase() async {
    try {
      await _db.delete(ChatDAO().getTable());
      await _db.delete(UserDAO().getTable());
      await _db.delete('ARQUIVO_POST_BD');
      await _db.delete('CHAT_STRING');
      await _db.delete('HTTP_RESPONSE_ENTITY');
      await _db.delete('MENSAGEM');
      await _db.delete('CARD_BUTTON');
      await _db.delete('CHAT_BUTTONS');
      print("dropou");
    } catch (e) {
      print(e);
    }
  }

  Future close() async {
    var dbClient = db;
    try {
      if (dbClient.isOpen) {
        await dbClient.close();
      }
      print("Fechou!");
    } catch (error) {
      print("SQL Close: $error");
    } finally {
      dbClient = null;
      _db = null;
    }
  }
}
