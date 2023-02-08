import 'package:flutter/material.dart';
import 'package:flutter_dandelin/colors.dart';

class AppText extends StatelessWidget {
  final String content;
  final String fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;
  final int maxLines;
  final TextOverflow textOverflow;
  final double height;
  final FontStyle fontStyle;

  const AppText(this.content,
      {Key key,
      this.fontFamily,
      this.fontSize,
      this.fontWeight,
      this.color,
      this.textAlign,
      this.maxLines,
      this.fontStyle,
      this.textOverflow,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final curScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Text(
      content ?? "",
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color == null ? AppColors.greyFont : color,
        height: height,
        fontStyle: this.fontStyle,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: textOverflow,
    );
  }
}
