import 'package:flutter/material.dart';
import 'package:flutter_dandelin/widgets/app_text.dart';

class CenterText extends StatelessWidget {
  final String text;
  final FontWeight fontWeight;

  const CenterText(this.text, {this.fontWeight});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppText(
        text,
        fontWeight: fontWeight,
        textAlign: TextAlign.center,
      ),
    );
  }
}
