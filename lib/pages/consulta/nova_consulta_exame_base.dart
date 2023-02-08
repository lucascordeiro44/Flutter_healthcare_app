//métodos usados na 'nova_consuta_exame.bloc' e 'nova_consulta_eame_detalhe_bloc'
//visto que ambos usam streams iguais, porém independetes.
import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/unity.dart';
import 'package:flutter_dandelin/pages/consulta/linha_calendario.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/gps_utils.dart';
import 'package:location/location.dart';
import 'package:location_permissions/location_permissions.dart' as lp;

abstract class ConsultaExameBase {
  final consultaExameEscolhidoBase = SimpleBloc<OpcaoEscolhida>();

  //guarda os dias dos calendario e qual é o botão que deve mostrar o indicador de escolhido
  //recupero o dia selecionado pelo campo 'isSelected' quando é true
  final listDiasCalendarioBase = SimpleBloc<List<CalendarButton>>();

  Future<Map<String, dynamic>> searchBase(String date,
      {dynamic consultaOuExame, bool sendCordinates = true}) async {
    Map<String, dynamic> search = {
      'date': date,
    };

    if (sendCordinates) {
      lp.PermissionStatus permission =
          await lp.LocationPermissions().checkPermissionStatus();

      if (permission == lp.PermissionStatus.granted) {
        await getMapLoc().then((map) {
          if (map != null) {
            search['coordinates'] = map;
          }
        });
      } else if (permission == lp.PermissionStatus.unknown) {
        await getMapLoc().then((map) {
          if (map != null) {
            search['coordinates'] = map;
          }
        });
      } else {
        await lp.LocationPermissions().requestPermissions().then((p) async {
          if (p == lp.PermissionStatus.granted) {
            await getMapLoc().then((map) {
              if (map != null) {
                search['coordinates'] = map;
              }
            });
          }
        });
      }
    }

    if (consultaOuExame != null) {
      if (consultaOuExame is Consulta) {
        search['doctor'] = {
          'id': consultaOuExame.doctor.id,
        };
      } else {
        Unity unity = consultaOuExame;
        search['unity'] = {'id': unity.id};
        search['exam'] = {'id': unity.exam.id};
      }
    }

    return search;
  }

  Future<Map<String, dynamic>> getMapLoc() async {
    return await GPSUtils.getLoc().then((LocationData latLng) {
      if (latLng != null) {
        return {
          'latitude': latLng.latitude,
          'longitude': latLng.longitude,
        };
      } else {
        return null;
      }
    }).timeout(Duration(seconds: 5),
        onTimeout: () async =>
            await GPSUtils.getLoc().then((LocationData latLng) {
              if (latLng != null) {
                return {
                  'latitude': latLng.latitude,
                  'longitude': latLng.longitude,
                };
              } else {
                return null;
              }
            }));
  }

  void fetchDiasCalendarioBase() {
    final listCalendar = List<CalendarButton>();

    for (int i = 0; i < 15; i++) {
      DateTime dateTime = DateTime.now().add(Duration(days: i));
      listCalendar.add(CalendarButton.dateTimeToCalendarButton(
          dateTime, i, i == 0 ? true : false));
    }
    listDiasCalendarioBase.add(listCalendar);
  }

  void updateListCalendarioBase(CalendarButton btn) {
    List<CalendarButton> data = listDiasCalendarioBase.value;

    CalendarButton b;
    List<CalendarButton> lb = data.where((v) => v.isSelected == true).toList();

    if (lb.length > 0) {
      lb.forEach((b) {
        b.isSelected = false;
      });
    }

    if (btn.id == null) {
      for (final b in data) {
        if (CalendarButton.compareTwoButtons(btn, b)) {
          btn.id = b.id;
          break;
        }
      }
    }

    if (data.where((v) => v.id == btn.id).length == 0) {
      addDateFromCalendarPageBase(btn.calendarButtonToDateTime());
      data = listDiasCalendarioBase.value;
    }

    b = data.where((v) => v.id == btn.id).first;

    b.isSelected = true;

    listDiasCalendarioBase.add(data);
  }

  //método para adicionar ou escolher uma data vindo do calendario.
  //deixo 'false' no dateTimetoCalendarButton por conta que o metodo 'updateListCalendar' se encarrega de mudar o botao para selecionado
  addDateFromCalendarPageBase(DateTime date) {
    List<CalendarButton> data = listDiasCalendarioBase.value;
    bool achou = false;
    CalendarButton btn = CalendarButton();

    //vejo se a data escolhida está dentro dos 15 dias.
    for (CalendarButton b in data) {
      DateTime d = b.calendarButtonToDateTime();

      if (date.compareTo(d) == 0) {
        b.isSelected = true;
        achou = true;
        btn = CalendarButton.dateTimeToCalendarButton(date, b.id, false);
        break;
      }
    }

    //removo caso o usuário escolheu duas datas que estão fora dos 15 dias
    if (data.length > 15) {
      data.removeLast();
    }

    //só adiciono se o usuário escolheu uma data fora dos 15 dias
    if (!achou) {
      btn = CalendarButton.dateTimeToCalendarButton(date, data.length, false);
      data.add(btn);
    }

    //updates
    listDiasCalendarioBase.add(data);
    updateListCalendarioBase(btn);
  }

  dynamic getDataEscolhidaBase({bool returnAsString = true}) {
    List<CalendarButton> l = listDiasCalendarioBase.value;

    CalendarButton btn = l.where((v) => v.isSelected == true).first;

    return returnAsString ? btn.calendarButtonToString() : btn;
  }

  changeBtnSelecionadoPorDateTime(DateTime dateTime) {
    addDateFromCalendarPageBase(dateTime);
  }

  disposeBase() {
    consultaExameEscolhidoBase.dispose();
    listDiasCalendarioBase.dispose();
  }
}

enum OpcaoEscolhida {
  consulta,
  exame,
}
