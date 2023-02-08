import 'package:flutter/material.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/gradients.dart';

class AppHeader extends StatelessWidget {
  final String image;
  final double height;
  final double elevation;
  final Widget child;
  final EdgeInsets padding;

  const AppHeader(
      {Key key,
      this.image,
      this.height,
      this.elevation,
      this.child,
      this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      elevation: elevation,
      child: Container(
        padding: padding == null
            ? EdgeInsets.only(
                top: 20 + SizeConfig.safeBlockHorizontal,
                left: 16,
                right: 16,
                bottom: 5)
            : padding,
        decoration: image == null
            ? BoxDecoration(
                gradient: linearEnabled,
              )
            : BoxDecoration(
                image:
                    DecorationImage(image: AssetImage(image), fit: BoxFit.fill),
              ),
        width: SizeConfig.screenWidth,
        height: height,
        child: child,
      ),
    );
  }
}
