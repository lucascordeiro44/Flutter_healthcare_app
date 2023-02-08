import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class CalendaraApi {
  static Future<List<CalendarClass>> getFeriados(String ano) async {
    List<CalendarClass> list = List<CalendarClass>();
    try {
      var url = "$baseUrl/api/holidays/2019";

      HttpResponse response = await get(url);

      response.data['data'].forEach((map) {
        list.add(CalendarClass.fromJson(map));
      });
      return list;
    } catch (e) {
      print("Calendar API ERROR $e");
      return null;
    }
  }
}

class CalendarClass {
  String date;
  String propertiesKey;
  String type;
  String description;

  CalendarClass({this.date, this.propertiesKey, this.type, this.description});

  CalendarClass.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    propertiesKey = json['propertiesKey'];
    type = json['type'];
    description = json['description'];
  }
}
