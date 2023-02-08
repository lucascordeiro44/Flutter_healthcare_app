import 'package:intl/intl.dart';

extension DateTimeHelper on DateTime {
  static String getHorarioConsultaExame(String horario) {
    DateTime dateTime = stringToDateTimeWithMinutes(horario);

    String dia = addZeroDate(dateTime.day);
    String mes = addZeroDate(dateTime.month);
    String ano = dateTime.year.toString();

    String hora = addZeroDate(dateTime.hour);
    String minutos = addZeroDate(dateTime.minute);

    return "$dia/$mes/$ano | $hora:$minutos";
  }

  static String mesAtualEscrito() {
    return DateFormat.MMMM().format(new DateTime.now());
  }
}

removeHorariosInvalidos(List<String> avaliability, DateTime datetimeFiltro) {
  final DateTime dateTimeLimit = DateTime.now().add(Duration(hours: 24));

  List<String> horariosToRemove = List<String>();
  for (final horario in avaliability) {
    var array = horario.split(':');
    String hora = array[0];
    String minuto = array[1];

    DateTime datetime = datetimeFiltro
        .add(Duration(hours: int.parse(hora), minutes: int.parse(minuto)));

    if (datetime.isBefore(dateTimeLimit)) {
      horariosToRemove.add(horario);
    }
  }
  List<String> newAvaliabilityList = List<String>();

  avaliability.forEach((horario) {
    //se não tem nas duas listas, é porque é um horario válido
    if (!horariosToRemove.contains(horario)) {
      newAvaliabilityList.add(horario);
    }
  });

  return newAvaliabilityList;
}

String getMesEscrito(DateTime dateTime) {
  return DateFormat.MMMM().format(dateTime).toString();
}

String dateTimeFormatHMS({DateTime dateTime}) {
  var date = dateTime == null ? new DateTime.now() : dateTime;

  String dia = addZeroDate(date.day);
  String mes = addZeroDate(date.month);
  String ano = date.year.toString();

  String hora = addZeroDate(date.hour);
  String minuto = addZeroDate(date.minute);
  String segundo = addZeroDate(date.second);

  return "$dia-$mes-$ano $hora:$minuto:$segundo";
}

String addZeroDate(int value) {
  return value < 10 ? "0$value" : value.toString();
}

String dateToStringBd(DateTime dateTime) {
  String dia = addZeroDate(dateTime.day);
  String mes = addZeroDate(dateTime.month);

  return "$dia-$mes-${dateTime.year}";
}

//fromDB = false: dia-mes-ano
//fromDB = true: ano-mes-dia
DateTime stringToDateTime(String data, {bool fromDB = false}) {
  var array = data.split('-');

  return !fromDB
      ? DateTime(int.parse(array[2]), int.parse(array[1]), int.parse(array[0]))
      : DateTime(int.parse(array[0]), int.parse(array[1]), int.parse(array[2]));
}

DateTime stringToDateTimeWithMinutes(String data) {
  var array = data.split('-');

  int ano = int.parse(array[2].substring(0, 4));
  int mes = int.parse(array[1]);
  int dia = int.parse(array[0]);

  var arrayHorario = data.split(':');

  if (arrayHorario.length > 0) {
    int hora = int.parse(arrayHorario[0].substring(arrayHorario[0].length - 2));
    int minutos = int.parse(arrayHorario[1]);
    return DateTime(ano, mes, dia, hora, minutos);
  }

  return DateTime(ano, mes, dia);
}

//passar a data tudo junto, por exemplo 20190730 (ano-mes-dia)
bool isValidDate(String input) {
  if (input.length == 8) {
    final date = DateTime.parse(input);
    final originalFormatString = toOriginalFormatString(date);
    return input == originalFormatString;
  } else {
    return false;
  }
}

String toOriginalFormatString(DateTime dateTime) {
  final y = dateTime.year.toString().padLeft(4, '0');
  final m = dateTime.month.toString().padLeft(2, '0');
  final d = dateTime.day.toString().padLeft(2, '0');
  return "$y$m$d";
}

bool idadeMaior16(String input) {
  final date = DateTime.parse(input);
  var d = DateTime.now().difference(date);

  return ((d.inDays / 365.2425) > 16);
}

String getDiaSemana(int dia, {bool numberWeek = false}) {
  switch (dia) {
    case 1:
      return numberWeek ? "2ª Feira" : "Segunda-feira";
      break;
    case 2:
      return numberWeek ? "3ª Feira" : "Terça-feira";
      break;
    case 3:
      return numberWeek ? "4ª Feira" : "Quarta-feira";
      break;
    case 4:
      return numberWeek ? "5ª Feira" : "Quinta-feira";
      break;
    case 5:
      return numberWeek ? "6ª Feira" : "Sexta-feira";
      break;
    case 6:
      return "Sábado";
      break;
    case 7:
      return "Domingo";
      break;
  }
  return null;
}

String getMesAbreviado(int mes) {
  switch (mes) {
    case 1:
      return "Jan";
      break;
    case 2:
      return "Fev";
      break;
    case 3:
      return "Mar";
      break;
    case 4:
      return "Abr";
      break;
    case 5:
      return "Mai";
      break;
    case 6:
      return "Jun";
      break;
    case 7:
      return "Jul";
      break;
    case 8:
      return "Ago";
      break;
    case 9:
      return "Set";
      break;
    case 10:
      return "Out";
      break;
    case 11:
      return "Nov";
      break;
    case 12:
      return "Dez";
      break;
  }

  return null;
}
