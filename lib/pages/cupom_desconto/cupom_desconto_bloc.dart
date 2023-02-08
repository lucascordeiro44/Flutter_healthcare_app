import 'package:flutter_dandelin/model/discount.dart';
import 'package:flutter_dandelin/pages/cupom_desconto/cupom_desconto_api.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';

class CupomDescontoBloc {
  final button = ButtonBloc();
  final cupom = SimpleBloc<String>();

  updateFrom(String value) {
    button.setEnabled(value != null && value != "");
    cupom.add(value);
  }

  Future<ApiResponse> sendInviteDiscount() async {
    try {
      button.setProgress(true);

      ApiResponse<Discount> response =
          await CupomDescontoApi.sendInviteDiscount(cupom.value);

      return response;
    } finally {
      button.setProgress(false);
    }
  }

  dispose() {
    button.dispose();
    cupom.dispose();
  }
}
