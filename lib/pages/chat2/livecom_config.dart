import 'dart:convert';


import 'menu_mobile.dart';

class LivecomConfig {
  List<MenuMobile> menusMobile;

  LivecomConfig.fromJson(Map<String, dynamic> map)
      : menusMobile = map["menuMobile"]
      .map<MenuMobile>((json) => MenuMobile.fromJson(json))
      .toList();

  Map toMap() {
    return {
      "menuMobile": menusMobile.map<Map>((menu) => menu.toMap()).toList(),
    };
  }

  toJson() {
    return json.encode(toMap());
  }
}
