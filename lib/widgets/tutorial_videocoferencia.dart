import 'package:flutter/material.dart';
import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_card.dart';
import 'package:flutter_dandelin/utils/nav.dart';
import 'package:flutter_dandelin/widgets/app_text.dart';
import 'package:flutter_dandelin/widgets/gradients.dart';

class TutorialVideoconferencia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _titleContainer(),
        _videoIcon(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _contentString(),
                _consultaContainer(),
              ],
            ),
          ),
        ),
        _button(),
      ],
    );
  }

  _titleContainer() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AppText(
            "Consulta por vídeo",
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.blueExame,
          ),
        ],
      ),
    );
  }

  _videoIcon() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Image.asset(
        'assets/images/ic-videocoferencia.png',
        height: 70,
      ),
    );
  }

  _contentString() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: AppColors.greyStrong,
            fontFamily: 'Mark',
            fontSize: 16,
          ),
          text:
              "Como forma de incentivar o distanciamento social recomendado pelo Ministério da Saúde e Organização Mundial da Saúde, o ",
          children: [
            TextSpan(
              text: "dandelin ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text:
                  "atualizou o aplicativo com a possibilidadede consulta por ",
            ),
            TextSpan(
              text: "chamada de vídeo",
              style: TextStyle(
                color: AppColors.blueExame,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text:
                  ".\n Os profissionais com agenda disponível para atendimento por chamada de vídeo estão sinalizados com este selo para facilitar a " +
                      "sua busca. Se possível, opte por esta opção",
            ),
          ],
        ),
      ),
    );
  }

  _consultaContainer() {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      child: IgnorePointer(
        child: ConsultaExameCard(
          dynamicClass: Consulta.fromJson(fakeDoctorJson),
        ),
      ),
    );
  }

  _button() {
    return FlatButton(
      padding: EdgeInsets.all(0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () {
        pop();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: linearEnabled,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
            topLeft: Radius.circular(0.0),
            topRight: Radius.circular(0.0),
          ),
        ),
        height: 40,
        alignment: Alignment.center,
        width: double.infinity,
        child: Text(
          "OK, ENTENDI!",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  var fakeDoctorJson = {
    "id": 25,
    "daysService": ["TUESDAY"],
    "duration": 30,
    "start": "08:00",
    "end": "18:00",
    "startInterval": "12:00",
    "endInterval": "13:00",
    "address": {
      "id": 259,
      "phone": "(41) 99999-9999",
      "addressNumber": " 287",
      "zipCode": "81330-540",
      "state": "PR",
      "country": "Brasil",
      "longitude": -49.3285291,
      "latitude": -25.4894554,
      "type": {"id": 2, "description": "consultorio"}
    },
    "doctor": {
      "id": 25,
      "user": {
        "id": 25,
        "createdAt": "20-01-2020 10:09:13",
        "firstName": "Dra. Ana",
        "lastName": " Paula Mendes",
        "mobilePhone": "41999999999",
        "gender": "male",
        "username": "henrique.doctor@livetouch.com.br",
        "document": "71244666017",
        "active": true,
        "blocked": false,
        "birthday": "09-12-1994",
        "status": "SEM_METODO_DE_PAGAMENTO",
        "type": "USER",
        "role": {"id": 2, "name": "doctors"},
        "address": [
          {
            "id": 259,
            "name": "Ru",
            "phone": "(41) 99999-9999",
            "address": "Rua Carlos João Goudard",
            "addressNumber": "29",
            "neighborhood": "Fazendinha",
            "zipCode": "81330-540",
            "city": "Curitiba",
            "state": "PR",
            "country": "Brasil",
            "longitude": -49.3285291,
            "latitude": -25.4894554,
            "type": {"id": 2, "description": "consultorio"}
          }
        ]
      },
      "councils": [],
      "doctorStatus": "ATIVO",
      "bankAccount": [],
      "expertises": [
        {"id": 15, "name": "Clinica Médica", "slug": "dermatologia"}
      ],
      "covid19": false,
      "telemedicine": true,
    },
    "avaliability": [
      "11:00:00",
      "11:30:00",
      "13:00:00",
      "13:30:00",
      "14:00:00",
      "14:30:00",
      "15:00:00",
      "15:30:00",
    ]
  };
}
