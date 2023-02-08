import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

closeKeyboard() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

class CloseContainer extends GestureContainer {
  CloseContainer({child, padding, color, extraFocusNodes})
      : super(
          child: child,
          padding: padding,
          color: color,
          extraFocusNodes: extraFocusNodes,
          onTap: () {
            closeKeyboard();
            if (extraFocusNodes != null && extraFocusNodes.length > 0) {
              //usado para dar unfocus no AutoCompleteText de Revenda
              //pode passar uma lsita com os focus node q quer dar unfocus
              extraFocusNodes.forEach((v) {
                v.unfocus();
              });
            }
          },
        );
}


class GestureContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final Function onTap;
  final List<FocusNode> extraFocusNodes;

  GestureContainer(
      {this.child,
        this.padding,
        this.color = Colors.transparent,
        @required this.onTap,
        this.extraFocusNodes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      color: color,
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}
