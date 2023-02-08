import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_bloc.dart';

class MapaListaButton extends StatelessWidget {
  final Stream<TelaEscolhidaEnum> stream;
  final Function(TelaEscolhidaEnum) onClickMapaOuLista;

  const MapaListaButton({
    Key key,
    @required this.stream,
    @required this.onClickMapaOuLista,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TelaEscolhidaEnum>(
      stream: stream,
      builder: (context, snapshot) {
        TelaEscolhidaEnum v =
            snapshot.hasData ? snapshot.data : TelaEscolhidaEnum.lista;

        return InkWell(
          //fica alterando o valor quando o usuário clica
          onTap: () => onClickMapaOuLista(v == TelaEscolhidaEnum.lista
              ? TelaEscolhidaEnum.mapa
              : TelaEscolhidaEnum.lista),

          child: Stack(
            children: <Widget>[
              Image.asset('assets/images/map-button-background.png',
                  height: 45),
              v == TelaEscolhidaEnum.lista
                  ? Container(
                      height: 45,
                      width: 40,
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/map-button-icon.png',
                          height: 20),
                    )
                  : Container(
                      height: 42.5,
                      width: 44.5,
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/list-button-icon.png',
                          height: 13),
                    ),
            ],
          ),
        );
      },
    );
  }
}
