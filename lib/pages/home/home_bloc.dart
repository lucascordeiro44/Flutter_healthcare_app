import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/exam.dart';
import 'package:flutter_dandelin/pages/home/home_api.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class HomeBloc {
  final consultasExames = SimpleBloc<List<dynamic>>();
  final _page = SimpleBloc<int>();
  final loading = SimpleBloc<bool>();

  var endApiResults = false;

  fetch() async {
    fetchConsultasExames();
  }

  Future<List<dynamic>> getConsultasExamesToRating() async {
    ApiResponse response = await HomeApi.getConsultasExamesToRating();

    return response.ok ? response.result : List();
  }




  fetchConsultasExames({bool setNull = false}) async {
    if (setNull) {
      consultasExames.add(null);
    }
    _page.add(0);

    ApiResponse response = await HomeApi.getConsultasExames(_page.value);

    response.ok
        ? consultasExames.add(response.result)
        : consultasExames.addError(response.msg);
  }

  fetchMore() async {
    if (!endApiResults) {
      loading.add(true);
      int page = _page.value + 1;
      List<dynamic> data = consultasExames.value;

      ApiResponse response = await HomeApi.getConsultasExames(page);

      if (response.ok) {
        List list = response.result;

        list.length > 0 ? data.addAll(list) : endApiResults = true;
        consultasExames.add(data);
      } else {
        consultasExames.addError(response.msg);
      }
      _page.add(page);
      loading.add(false);
    }
  }

  depedentsApproval(bool approval) async {
    return await HomeApi.depedentsAproval(approval);
  }

  Future aproveScheduleChanges(Consulta consulta, bool value) async {
    HttpResponse response = await HomeApi.aproveChanges(consulta, value);

    print(response);

    return;
  }

  dispose() {
    loading.dispose();
    _page.dispose();
    consultasExames.dispose();
  }
}
