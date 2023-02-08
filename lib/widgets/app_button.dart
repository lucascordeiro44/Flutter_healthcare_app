import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dandelin/widgets/gradients.dart';
import 'package:flutter_dandelin/widgets/progress.dart';

class ButtonState {
  bool progress = false;
  bool enabled = false;
}

class ButtonBloc extends SimpleBloc<ButtonState> {
  final state = ButtonState();

  setProgress(b) {
    state.progress = b;
    add(state);
  }

  setEnabled(b) {
    state.enabled = b;
    add(state);
  }
}

class AppButtonStream extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Stream<ButtonState> stream;
  final Key widgetKey;
  final double height;
  final Color color;

  AppButtonStream({
    Key key,
    @required this.text,
    @required this.onPressed,
    this.stream,
    this.widgetKey,
    this.height = 40,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return stream != null
        ? StreamBuilder<ButtonState>(
            stream: this.stream,
            initialData: ButtonState(),
            builder: (context, snapshot) {
              final btState = snapshot.data;
              return _button(
                  onPressed: btState.enabled ? this.onPressed : null,
                  onProgress: btState.progress);
            },
          )
        : _button(onPressed: onPressed == null ? null : onPressed);
  }

  _button({Function onPressed, bool onProgress}) {
    return FlatButton(
      key: widgetKey,
      padding: EdgeInsets.all(0),
      onPressed: onProgress == null || !onProgress ? onPressed : () {},
      child: Container(
        decoration: BoxDecoration(
          color: this.color,
          gradient: onPressed == null
              ? linearDisabled
              : this.color == null ? linearEnabled : null,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: onProgress == null || !onProgress
            ? Text(
                this.text,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )
            : Progress(isForButton: true),
        width: double.maxFinite,
        height: height,
      ),
    );
  }
}
