import 'package:flutter_dandelin/model/discount.dart';
import 'package:flutter_dandelin/pages/amigo/indique_amigo_api.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';

class IndiqueAmigoBloc {
  final button = ButtonBloc();

  Future<ApiResponse<String>> fetchInviteDiscount() async {
    try {
      button.setProgress(true);
      HttpResponse response = await IndiqueAmigoApi.getDiscountInvite();

      final json = response.data['data'];
      final code = json['code'];
      return ApiResponse.ok(result: code);
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      button.setProgress(false);
    }
  }

  dispose() {
    button.dispose();
  }
}
