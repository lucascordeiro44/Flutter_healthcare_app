import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_base.dart';
import 'package:flutter_dandelin/utils/size_config.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';
import 'package:flutter_dandelin/widgets/app_text.dart';
import 'package:flutter_dandelin/widgets/base_container.dart';
import 'package:flutter_dandelin/widgets/container_background_button.dart';

class SemConsultaBackground extends StatelessWidget {
  final Stream opcaoEscolhida;
  final Stream proximaDataButton;
  final Function onClickProximaDataDisponivel;

  const SemConsultaBackground(
      {Key key,
      @required this.opcaoEscolhida,
      @required this.proximaDataButton,
      @required this.onClickProximaDataDisponivel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseContainer(
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(height: 10),
              Image.asset(
                'assets/images/sem-medicos-icon.png',
                height: 200,
              ),
              StreamBuilder(
                  stream: opcaoEscolhida,
                  builder: (context, snapshot) {
                    OpcaoEscolhida opcao = snapshot.hasData
                        ? snapshot.data
                        : OpcaoEscolhida.consulta;
                    return AppText(
                      opcao == OpcaoEscolhida.consulta
                          ? "Nenhum médico encontrado\ntente mudar sua pesquisa"
                          : "Nenhum agendamento disponivel,\ntente mudar sua pesquisa",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.center,
                    );
                  }),
              SizedBox(height: 10),
              ContainerBackground(height: SizeConfig.heightContainer),
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: SizeConfig.marginBottom),
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AppButtonStream(
              stream: proximaDataButton,
              onPressed: () {
                onClickProximaDataDisponivel();
              },
              text: "PRÓXIMA DATA DISPONÍVEL",
            ),
          )
        ],
      ),
    );
  }
}
