import 'package:flutter_dandelin/pages/cupons_aplicados/cupom.dart';
import 'package:flutter_dandelin/pages/cupons_aplicados/cupons_aplicados_api.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';

class CuponsAplicadosBloc extends SimpleBloc<List<Cupom>> {
  final cuponsAplicados = PaginationBloc<List<Cupom>>();
  final selectedBar = SimpleBloc<int>();

  fetch() async {
    ApiResponse response = await CuponsAplicadosApi.getCuponsAplicados();
    ApiResponse responseCuponsMgM = await CuponsAplicadosApi.getCuponsAplicadosMgm();

    var list = response.result + responseCuponsMgM.result;

    response.ok ? add(list) : addError(response.error);
  }

  fetchMoreCuponsAplicados() async {
    if (!cuponsAplicados.endApiResults.value) {
      List<dynamic> data = cuponsAplicados.value;
      cuponsAplicados.loading.add(true);

      ApiResponse<List<Cupom>> response = await CuponsAplicadosApi.getCuponsAplicados(
              page: cuponsAplicados.getPage())
          .catchError(cuponsAplicados.addError);

      if (response == null) {
        cuponsAplicados.loading.add(false);
        return;
      }
      var list = response.result;
      if(list.isEmpty){
        cuponsAplicados.endApiResults.add(true);
      }
      cuponsAplicados.add(list);
      cuponsAplicados.loading.add(false);
    }
  }

  dispose() {
    cuponsAplicados.dispose();
    selectedBar.dispose();
  }
}
