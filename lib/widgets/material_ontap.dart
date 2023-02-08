import 'package:flutter/material.dart';

class MaterialOnTap extends StatelessWidget {
  final Widget child;
  final Function onTap;
  final StackFit fit;
  final Key key;

  MaterialOnTap({this.child, this.onTap, this.fit = StackFit.loose, this.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: key,
      fit: this.fit,
      children: <Widget>[
        child,
        Positioned.fill(
          child: new Material(
            color: Colors.transparent,
            child: new InkWell(
              onTap: onTap,
            ),
          ),
        )
      ],
    );
  }
}
