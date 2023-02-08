import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dandelin/utils/imports.dart';

showAlertDialog(
  BuildContext context,
  String title,
  String content,
  Widget declineButton,
  Widget acceptButton, {
  bool barrierDismissible = true,
}) async {
  bool ios = Theme.of(context).platform == TargetPlatform.iOS;

  await showDialog(
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (context) {
      return ios
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


showSimpleDialog(String content,
    {String title = "dandelin",
    Function callBack,
    bool progress = false}) async {
  BuildContext context = navigatorKey.currentState.overlay.context;
  bool ios = Theme.of(context).platform == TargetPlatform.iOS;

  await showDialog(
    context: context,
    builder: (context) {
      return ios
          ? CupertinoAlertDialog(
              title: Text(title),
              content: Container(
                margin: EdgeInsets.only(top: 5),
                child: Column(
                  children: <Widget>[
                    Text(content),
                    progress ? SizedBox(height: 15) : SizedBox(),
                    progress ? Progress() : SizedBox(),
                  ],
                ),
              ),
              actions: <Widget>[
                !progress
                    ? CupertinoDialogAction(
                        onPressed: () {
                          if (callBack != null) {
                            callBack();
                          }
                          pop();
                        },
                        child: Text("OK"),
                      )
                    : Container(),
              ],
            )
          : AlertDialog(
              title: Text(title),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(content, textAlign: TextAlign.start),
                  progress ? SizedBox(height: 15) : SizedBox(),
                  progress ? Progress() : SizedBox(),
                ],
              ),
              actions: <Widget>[
                !progress
                    ? FlatButton(
                        onPressed: () {
                          if (callBack != null) {
                            callBack();
                          }
                          pop();
                        },
                        child: Text("OK"),
                      )
                    : Container(),
              ],
            );
    },
  );
}

showWidgetDialog(
    BuildContext context,
    Widget widget, {
      String title = "Livecom",
      Function callBack,
      bool progress = false,
      bool dismissible = true,
      bool showButton = false,
    }) async {
  bool ios = Theme.of(context).platform == TargetPlatform.iOS;

  await showDialog(
    barrierDismissible: dismissible,
    context: context,
    builder: (context) {
      return ios
          ? CupertinoAlertDialog(
        title: Text(title),
        content: Container(
          margin: EdgeInsets.only(top: 5),
          child: Row(
            children: <Widget>[
              progress ? Progress() : SizedBox(),
              progress ? SizedBox(width: 15) : SizedBox(),
              widget,
            ],
          ),
        ),
        actions: <Widget>[
          !showButton
              ? CupertinoDialogAction(
            onPressed: () {
              if (callBack != null) {
                callBack();
              }
              pop();
            },
            child: Text("OK"),
          )
              : Container(),
        ],
      )
          : AlertDialog(
        title: Text(title),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                progress ? Progress() : SizedBox(),
                progress ? SizedBox(width: 15) : SizedBox(),
                widget,
              ],
            )
          ],
        ),
        actions: <Widget>[
          !progress
              ? FlatButton(
            onPressed: () {
              if (callBack != null) {
                callBack();
              }
              pop();
            },
            child: Text("OK"),
          )
              : Container(),
        ],
      );
    },
  );
}

Future loadingDialog(context, {String title = "dandelin", String msg}) async {
  bool ios = Theme.of(context).platform == TargetPlatform.iOS;

  await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return ios
          ? CupertinoAlertDialog(
              title: Text(title),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  msg != null ? Expanded(child: Text(msg) ,) : SizedBox(),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Progress(),
                  ),
                ],
              ),
            )
          : AlertDialog(
              title: Text(title),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  msg != null
                      ? Container(
                          child: Text(msg),
                          margin: EdgeInsets.only(right: 10),
                        )
                      : SizedBox(),
                  Container(
                    child: Progress(),
                    height: 40,
                  ),
                ],
              ),
            );
    },
  );
}

Future alertConfirm(context, String msg,
    {@required Function callbackSim,
    @required Function callbackNao,
    String sim = "Sim",
    String nao = "Não",
    bool barrierDismissible = true}) async {
  Widget declineButton;
  Widget acceptButton;

  bool ios = Theme.of(context).platform == TargetPlatform.iOS;

  if (ios) {
    declineButton = CupertinoDialogAction(
      child: Text(nao),
      isDestructiveAction: true,
      onPressed: () async => await callbackNao(),
    );

    acceptButton = CupertinoDialogAction(
      child: Text(sim),
      onPressed: () async => await callbackSim(),
    );
  } else {
    declineButton = FlatButton(
      child: Text(nao),
      onPressed: () async => await callbackNao(),
    );

    acceptButton = FlatButton(
      child: Text(sim),
      onPressed: () async => await callbackSim(),
    );
  }

  return await showDialog(
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (context) {
      return ios
          ? CupertinoAlertDialog(
              title: Text('dandelin'),
              content: Container(
                padding: EdgeInsets.only(top: 5),
                child: Text(msg),
              ),
              actions: <Widget>[
                declineButton,
                acceptButton,
              ],
            )
          : AlertDialog(
              title: Text('dandelin'),
              content: Text(msg),
              actions: <Widget>[
                declineButton,
                acceptButton,
              ],
            );
    },
  );
}

Future showAppGeneralDialog(BuildContext context, Widget content,
    {EdgeInsets padding = const EdgeInsets.fromLTRB(16, 226, 16, 16)}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dialog",
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (context, __, ___) {
      return Material(
        color: Colors.black12.withOpacity(0.6),
        child: Container(
          padding: padding,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            height: double.infinity,
            width: double.infinity,
            child: content,
          ),
        ),
      );
    },
  );
}
