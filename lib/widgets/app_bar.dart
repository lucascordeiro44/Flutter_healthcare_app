import 'package:flutter/material.dart';
import 'package:flutter_dandelin/widgets/app_text.dart';

class DandelinAppbar extends AppBar {
  DandelinAppbar(
    String title, {
    List<Widget> actions,
    centerTitle = true,
    double elevation = 0,
    Widget leading,
    Color backgroundColor,
    automaticallyImplyLeading = true,
    Color iconThemeColor,
  }) : super(
          centerTitle: centerTitle,
          elevation: elevation,
          actions: actions,
          leading: leading,
          iconTheme: IconThemeData(color: iconThemeColor),
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          title: AppText(
            title,
            fontSize: 20,
          ),
          automaticallyImplyLeading: automaticallyImplyLeading,
        );
}
