import 'package:flutter_dandelin/constants.dart';
import 'package:flutter_dandelin/utils/clean_text.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';

class TelefoneApi {
  static Future<int> sendSms(String telefone) async {
    var url = "$baseUrl/api/users/confirm/${cleanTelefone(telefone)}";

    HttpResponse response = await post(url, {});

    return response.data['data'];
  }
}
