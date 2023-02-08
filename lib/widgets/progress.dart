import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Progress extends StatelessWidget {
  final bool isForButton;
  final bool isCenter;

  const Progress({Key key, this.isForButton = false, this.isCenter = true})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return isCenter
        ? Center(
            child: _progress(context),
          )
        : _progress(context);
  }

  _progress(BuildContext context) {
    bool ios = Theme.of(context).platform == TargetPlatform.iOS;
    return ios
        ? CupertinoActivityIndicator(radius: 10)
        : Container(
            height: 25,
            width: 25,
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                !isForButton ? Theme.of(context).primaryColor : Colors.white,
              ),
            ),
          );
  }
}
