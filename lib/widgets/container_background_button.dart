import 'package:flutter/material.dart';

class ContainerBackground extends StatelessWidget {
  final double height;

  ContainerBackground({Key key, @required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(width: 1.0, color: Colors.black12),
          ),
        ),
      ),
    );
  }
}
