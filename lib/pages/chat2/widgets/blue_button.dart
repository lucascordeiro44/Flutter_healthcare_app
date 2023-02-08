
import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/chat2/colors.dart';

class BlueButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final double width;
  final double height;

  BlueButton(this.text, this.onPressed, { this.width = 200, this.height = 45});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: RaisedButton(
        color: AppColors.blue_button,
        onPressed: onPressed,
        child: Text(text,style: TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
