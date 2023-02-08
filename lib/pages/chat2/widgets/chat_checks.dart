import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DoubleCheckViewed extends StatelessWidget {
  final double iconSize;

  const DoubleCheckViewed({Key key, this.iconSize}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Icon(
      MdiIcons.checkAll,
      size: iconSize,
      color: Color.fromRGBO(79, 195, 247, 1),
    );
  }
}

class DoubleCheck extends StatelessWidget {
  final double iconSize;

  const DoubleCheck({Key key, this.iconSize}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Icon(
      MdiIcons.checkAll,
      size: iconSize,
      color: Colors.black38,
    );
  }
}

class SimpleCheck extends StatelessWidget {
  final double iconSize;

  const SimpleCheck({Key key, this.iconSize}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Icon(
      MdiIcons.check,
      size: iconSize,
      color: Colors.black38,
    );
  }
}
