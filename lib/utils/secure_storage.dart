import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final storage = new FlutterSecureStorage();

  static Future writeValue(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  static Future<String> getValue(String key) async {
    return await storage.read(key: key);
  }

  static Future delete(String key) async {
    await storage.delete(key: key);
  }

  static Future deleteAll() async {
    await storage.deleteAll();
  }
}
