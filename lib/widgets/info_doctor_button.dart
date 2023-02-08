import 'package:flutter/material.dart';
import 'package:flutter_dandelin/widgets/app_text.dart';

class InfoDoctorButton extends StatelessWidget {
  final String icon;
  final String legend;
  final Function onPressed;
  final EdgeInsets padding;
  final bool value;

  const InfoDoctorButton(
      {Key key,
      this.icon,
      this.legend,
      this.onPressed,
      this.padding,
      this.value = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: padding,
      onPressed: onPressed,
      child: Row(
        children: <Widget>[
          icon != null
              ? Image.asset(
                  icon,
                  height: 20,
                  width: 20,
                )
              : Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  value: value,
                  onChanged: (bool value) {},
                ),
          SizedBox(width: 10),
          Expanded(
              child: AppText(legend == null ? '' : legend,
                  fontSize: 14, maxLines: 4))
        ],
      ),
    );
  }
}
