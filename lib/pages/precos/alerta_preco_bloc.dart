import 'package:flutter_dandelin/utils/bloc.dart';

import 'package:flutter_dandelin/pages/precos/alerta_preco.dart';

class AlertaPrecoBloc {
  var controller = SimpleBloc<List<AlertaPreco>>();

  fetch() async {
    controller.add(await AlertaPrecoApi.getAlertasPrecos());
  }


  dispose(){
    controller.dispose();
  }
}

class AlertaPrecoApi {
  static Future<List<AlertaPreco>> getAlertasPrecos() async {
    List<AlertaPreco> alertaPrecos = List<AlertaPreco>();

    await Future.delayed(Duration(seconds: 2));

    alertaPrecos = [
      AlertaPreco(30, "Alerta de preco 1", "04/02/2019"),
      AlertaPreco(52, "Alerta de preco 2", "04/01/2019"),
      AlertaPreco(53, "Alerta de preco 3", "04/01/2019"),
      AlertaPreco(54, "Alerta de preco 4", "04/01/2019"),
      AlertaPreco(52, "Alerta de preco 5", "04/01/2019"),
    ];

    return alertaPrecos;
  }



}
