import 'package:flutter_dandelin/model/biling.dart';
import 'package:flutter_dandelin/model/pagamento.dart';
import 'package:flutter_dandelin/pages/pagamento/pagamento_api.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';

class PagamentoDetalheBloc {
  var button = ButtonBloc();
  var buttonEnable = BooleanBloc()..add(true);

  void updateForm(Pagamento pagamento) {
    button.setEnabled(pagamento.validate());
  }

  Future<ApiResponse> salvar(Pagamento pagamento) async {
    try {
      button.setProgress(true);
      print(pagamento);
      await PagamentoApi.save(pagamento);

      return ApiResponse.ok();
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      button.setProgress(false);
    }
  }

  Future excluir(Pagamento pagamento) async {
    try {
      buttonEnable.add(false);
      await PagamentoApi.excluir(pagamento);

      return ApiResponse.ok();
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      buttonEnable.add(true);
    }
  }

  Future checkPendings() async {
    try {
      button.setProgress(true);
      HttpResponse response = await PagamentoApi.checkPendings();

      if (response.data['data'].length == 0) {
        return ApiResponse.ok();
      } else {
        var data = response.data['data'];
        return ApiResponse.ok(result: Biling.fromJson(data));
      }
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      button.setProgress(false);
    }
  }

  Future mudarParaPrincipal(Pagamento pagamento) async {
    try {
      buttonEnable.add(false);

      HttpResponse response = await PagamentoApi.mudarParaPrincipal(pagamento);

      print(response);

      return ApiResponse.ok();
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      buttonEnable.add(true);
    }
  }

  dispose() {
    button.dispose();
    buttonEnable.dispose();
  }
}
