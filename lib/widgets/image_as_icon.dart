import 'package:flutter/material.dart';

class EmailImageAsIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.5),
      child: new Image(
        image: new AssetImage("assets/images/email-icon.png"),
        width: 15,
        height: 15,
      ),
    );
  }
}

class SenhaImageAsIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(13),
      child: new Image(
        image: new AssetImage("assets/images/senha-icon.png"),
        width: 20,
        height: 20,
      ),
    );
  }
}

class PersonImageAsIcon extends StatelessWidget {
  final Color color;

  const PersonImageAsIcon({Key key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(13),
      child: new Image(
        color: color,
        image: new AssetImage("assets/images/profile-icon.png"),
        width: 20,
        height: 20,
      ),
    );
  }
}
