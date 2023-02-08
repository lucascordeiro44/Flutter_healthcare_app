import 'package:flutter/material.dart';

class AppButtonOutline extends StatelessWidget {
  final Widget child;

  const AppButtonOutline({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      disabledBorderColor: Theme.of(context).primaryColor,
      highlightedBorderColor: Theme.of(context).primaryColor,
      borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          style: BorderStyle.solid,
          width: 1),
      padding: EdgeInsets.all(0),
      shape: StadiumBorder(),
      onPressed: null,
      child: Container(
        alignment: Alignment.center,
        height: 40,
        width: double.maxFinite,
        child: child,
      ),
    );
  }
}
