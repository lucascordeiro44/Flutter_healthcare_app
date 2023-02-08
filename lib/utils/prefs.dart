import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    var prefs = await SharedPreferences.getInstance();

    try {
      final b = prefs.getBool(key);
      return b ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  static void setBool(String key, bool b) async {
    var prefs = await SharedPreferences.getInstance();

    prefs.setBool(key, b);
  }

  static Future<int> getInt(String key) async {
    var prefs = await SharedPreferences.getInstance();

    try {
      return prefs.getInt(key);
    } catch (e) {
      return 0;
    }
  }

  static void setInt(String key, int i) async {
    var prefs = await SharedPreferences.getInstance();

    prefs.setInt(key, i);
  }

  static Future<String> getString(String key) async {
    var prefs = await SharedPreferences.getInstance();

    try {
      return prefs.getString(key);
    } catch (e) {
      return "";
    }
  }

  static Future setString(String key, String s) async {
    var prefs = await SharedPreferences.getInstance();

    prefs.setString(key, s);
  }
}
