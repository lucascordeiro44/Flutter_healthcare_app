import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_base.dart';

class EspecialidadeIcon extends StatelessWidget {
  final Stream<OpcaoEscolhida> stream;

  const EspecialidadeIcon({Key key, this.stream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        //lab muda aqui
        return Image.asset(
          'assets/images/cone-stethoscope.png',
          height: 23,
          color: Colors.black26,
        );
        if (!snapshot.hasData || snapshot.data == OpcaoEscolhida.consulta) {
          return Image.asset(
            'assets/images/cone-stethoscope.png',
            height: 23,
            color: Colors.black26,
          );
        } else {
          return Image.asset(
            'assets/images/exame-icon.png',
            height: 20,
            color: Colors.black26,
          );
        }
      },
    );
  }
}
