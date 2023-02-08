DateTime stringToDateTimeWithMinutes(String data, {String plit = "/"}) {
  var array = data.split('/');

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

String addZeroDate(int value) {
  return value < 10 ? "0$value" : value.toString();
}
