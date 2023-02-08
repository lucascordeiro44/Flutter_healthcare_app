import 'package:flutter/material.dart';

class TextError extends StatelessWidget {
  final String msg;

  TextError(this.msg);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          msg ?? "",
          style: TextStyle(
            fontSize: 18,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}