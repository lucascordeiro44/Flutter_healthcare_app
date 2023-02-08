import 'package:flutter/material.dart';

class NextButtonCadastro extends StatelessWidget {
  final Function function;
  final Widget icon;
  final bool needPositioned;

  const NextButtonCadastro(
      {Key key, this.function, this.icon, this.needPositioned = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return needPositioned
        ? Positioned(
            right: 5,
            bottom: 30,
            child: _button(),
          )
        : _button();
  }

  _button() {
    Color color = function == null
        ? Color.fromRGBO(215, 215, 215, 1)
        : Color.fromRGBO(130, 222, 245, 1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text("Próximo"),
        SizedBox(width: 10),
        ClipOval(
          child: Material(
            color: color, // button color
            child: InkWell(
              child: SizedBox(
                width: 40,
                height: 40,
                child: icon == null
                    ? Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.white,
                      )
                    : icon,
              ),
              onTap: function,
            ),
          ),
        )
      ],
    );
  }
}
