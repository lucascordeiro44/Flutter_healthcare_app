import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Toggle extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;

  Toggle({@required this.value, @required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _buildIOS() : _buildAndroid();
  }

  _buildIOS() {
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
    );
  }

  _buildAndroid() {
    return Switch(
      value: value,
      onChanged: onChanged,
    );
  }
}
