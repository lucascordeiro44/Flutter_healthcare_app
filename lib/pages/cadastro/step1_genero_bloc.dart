import 'package:flutter_dandelin/utils/bloc.dart';

class GeneroBloc {
  final button = BooleanBloc();
  final masculino = BooleanBloc();
  final feminino = BooleanBloc();

  dispose() {
    button.dispose();
    masculino.dispose();
    feminino.dispose();
  }
}
