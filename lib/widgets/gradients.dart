import 'package:flutter/material.dart';

final LinearGradient linearDisabled = new LinearGradient(
  colors: <Color>[
    Color.fromRGBO(204, 204, 204, 1),
    Color.fromRGBO(211, 211, 211, 1),
    Color.fromRGBO(218, 218, 218, 1),
  ],
);

final LinearGradient linearEnabled = new LinearGradient(
  colors: <Color>[
    Color.fromRGBO(245, 145, 32, 1),
    Color.fromRGBO(246, 177, 42, 1),
    Color.fromRGBO(249, 208, 52, 1),
  ],
);

//YTO = yellow to orange, usado no botão do terceiro tutorial
final LinearGradient linearEnabledYTO = new LinearGradient(
  colors: <Color>[
    Color.fromRGBO(249, 208, 52, 1),
    Color.fromRGBO(246, 177, 42, 1),
    Color.fromRGBO(245, 145, 32, 1),
  ],
);
