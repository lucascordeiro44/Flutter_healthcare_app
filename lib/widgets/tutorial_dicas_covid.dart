import 'package:flutter/material.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/nav.dart';

import 'gradients.dart';

class TutorialDicasCovid extends StatelessWidget {
  final Widget sizedBox = SizedBox(height: 15);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: <Widget>[
                AppText(
                  "Dicas para se locomover até a consulta:",
                  fontWeight: FontWeight.bold,
                  color: AppColors.greyStrong,
                ),
                sizedBox,
                sizedBox,
                _tutorialDicas(
                  1,
                  "Não esqueça de usar uma máscara",
                  endLabel: " facial para deslocamento até o médico.",
                ),
                _tutorialDicas(
                  2,
                  "Leve um álcool gel para ",
                  endLabel:
                      "frequentemente higienizar as mãos ao tocar em objetos públicos;",
                ),
                sizedBox,
                _tutorialDicas(
                  3,
                  "Cubra a boca e o nariz ao tossir",
                  endLabel:
                      "e ao espirrar, com um lenço de papel ou com o o dorso do braço;",
                ),
                sizedBox,
                _tutorialDicas(4, "Evite aglomerações;", endLabel: ''),
                sizedBox,
                _tutorialDicas(
                  5,
                  "Se possível, cumpra o distanciamento",
                  endLabel: " social;",
                ),
                sizedBox,
              ],
            ),
          ),
        ),
        _button(),
      ],
    );
  }

  _tutorialDicas(int idx, String label, {String endLabel}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(104, 211, 238, 1),
              ),
              child: AppText(
                idx.toString(),
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 15),
            AppText(
              label,
              fontWeight: FontWeight.w600,
              color: AppColors.greyFont,
            ),
          ],
        ),
        endLabel.isEmpty
            ? SizedBox()
            : AppText(
                endLabel,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w600,
                color: AppColors.greyFont,
              ),
      ],
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
}
