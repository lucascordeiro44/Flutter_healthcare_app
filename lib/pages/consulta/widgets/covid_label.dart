import 'package:flutter/material.dart';
import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/widgets/app_text.dart';

class CovidLabel extends StatelessWidget {
  final double fontSize;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const CovidLabel({
    Key key,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
    this.margin = const EdgeInsets.only(bottom: 10),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: this.margin,
      padding: this.padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.blueExame, width: 0.8),
        borderRadius: BorderRadius.circular(5),
      ),
      child: AppText(
        "COVID-19",
        color: AppColors.blueExame,
        fontWeight: FontWeight.w600,
        fontSize: this.fontSize,
      ),
    );
  }
}
