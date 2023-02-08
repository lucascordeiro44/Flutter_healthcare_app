import 'package:flutter/material.dart';
import 'package:flutter_dandelin/widgets/app_text.dart';

class AppListTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final Function onPressed;
  final EdgeInsets padding;
  final EdgeInsets paddingTitle;
  const AppListTile({
    Key key,
    this.leading,
    this.title,
    this.onPressed,
    this.padding = const EdgeInsets.only(
      top: 7,
      bottom: 7,
      left: 25,
      right: 12,
    ),
    this.paddingTitle = const EdgeInsets.only(left: 0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: padding,
      leading: leading,
      title: Padding(
        padding: this.paddingTitle,
        child: AppText(
          title,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onPressed,
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).primaryColor,
        size: 30,
      ),
    );
  }
}
