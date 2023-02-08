import 'package:flutter_dandelin/utils/bloc.dart';

class TelefoneBloc {
  final button = BooleanBloc();

  dispose() {
    button.dispose();
  }
}
