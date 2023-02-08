import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dandelin/utils_livecom/nav.dart';

void snack(BuildContext context, String msg, {Color textColor}) {
  final state = Scaffold.of(context);
  snackState(state, msg, textColor: textColor);
}

void snackState(ScaffoldState state, String msg,
    {Color textColor, Duration duration}) {
  state.showSnackBar(
    SnackBar(
      duration: duration == null ? Duration(seconds: 4) : duration,
      content: new Text(msg),
      action: SnackBarAction(
          textColor: textColor ?? Colors.blue,
          label: 'OK',
          onPressed: state.hideCurrentSnackBar),
    ),
  );
}

void alert(context, {String title, String msg, Function callback}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: title != null && title.isNotEmpty
            ? Text(
          title,
          style: TextStyle(color: Colors.black),
        )
            : null,
        content: msg != null && msg.isNotEmpty
            ? Text(
          msg,
          style: TextStyle(color: Colors.black),
        )
            : null,
        actions: <Widget>[
          FlatButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              Navigator.pop(context);
              if (callback != null) {
                callback();
              }
            },
          ),
        ],
      );
    },
  );
}

showAlertConfirm(context, String msg,
    {@required Function callbackSim,
      @required Function callbackNao,
      String sim = "Sim",
      String nao = "Não"}) {
  Widget declineButton;
  Widget acceptButton;

  if (isIOS(context)) {
    declineButton = CupertinoDialogAction(
      child: Text(nao),
      isDestructiveAction: true,
      onPressed: callbackNao,
    );

    acceptButton = CupertinoDialogAction(
      child: Text(sim),
      onPressed: callbackSim,
    );
  } else {
    declineButton = FlatButton(
      child: Text(nao),
      onPressed: callbackNao,
    );

    acceptButton = FlatButton(
      child: Text(sim),
      onPressed: callbackSim,
    );
  }

  showAlertDialog(context, 'Dandelin', msg, declineButton, acceptButton);
}

showAlertDialog(BuildContext context, String title, String content,
    Widget declineButton, Widget acceptButton) {
  showDialog(
    context: context,
    builder: (context) {
      return isIOS(context)
          ? CupertinoAlertDialog(
        title: Text(title),
        content: Container(
          padding: EdgeInsets.only(top: 5),
          child: Text(content),
        ),
        actions: <Widget>[
          declineButton,
          acceptButton,
        ],
      )
          : AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          declineButton,
          acceptButton,
        ],
      );
    },
  );
}

isIOS(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS;
}

modalBottomSheet(
    BuildContext context,
    String title,
    String titleButton1,
    String titleButton2,
    Function onClickButton1,
    Function onClickButton2, {
      Widget iconButton1,
      Widget iconButton2,
    }) {
  if (isIOS(context)) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(title),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(titleButton1),
            onPressed: onClickButton1,
          ),
          CupertinoActionSheetAction(
            child: Text(titleButton2),
            onPressed: onClickButton2,
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text("Cancelar"),
          onPressed: () {
            pop();
          },
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 0, 10),
              child: Text(
                title,
                style: TextStyle(fontSize: 14),
              ),
            ),
            ListTile(
              leading: iconButton1,
              title: Text(titleButton1),
              onTap: onClickButton1,
            ),
            ListTile(
              leading: iconButton2,
              title: Text(titleButton2),
              onTap: onClickButton2,
            ),
            ListTile(
              title: Text("Cancelar"),
              onTap: () {
                pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
