import 'package:flutter_dandelin/utils/imports.dart';

class NascimentoBloc {
  final button = ButtonBloc();
  final menorIdade = BooleanBloc();
  final agreeMenorIdade = BooleanBloc();

  bool _isDependente;

  init(bool isDependente) {
    _isDependente = isDependente;
  }

  updateForm(BirthdayForm form) {
    bool v = form.validate();

    if (!_isDependente) {
      button.setEnabled(v);
      return;
    }

    if (v) {
      bool menor = !idadeMaior16(form.dataClean());
      menorIdade.set(menor);
      button.setEnabled(
        //caso for menor, ver se o usuário já aceitou, senão for menor já deixa o botão enabled
        menor ? agreeMenorIdade.value != null && agreeMenorIdade.value : true,
      );
    }
  }

  dispose() {
    button.dispose();
    menorIdade.dispose();
    agreeMenorIdade.dispose();
  }
}

class BirthdayForm {
  int year;
  int month;
  int day;

  bool validate() {
    return (isNotEmpty(year.toString()) && year.toString().length == 4) &&
        isNotEmpty(month.toString()) &&
        isNotEmpty(day.toString());
  }

  String dataClean() {
    return "$year${addZeroDate(month)}${addZeroDate(day)}";
  }

  @override
  String toString() {
    return "${addZeroDate(day)}-${addZeroDate(month)}-${year.toString()}";
  }
}
