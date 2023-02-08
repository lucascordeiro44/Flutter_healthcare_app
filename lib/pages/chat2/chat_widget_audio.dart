import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/chat2/chat_page_bloc.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';

class ChatWidgetAudio extends StatefulWidget {
  final User usuario;
  final ChatPageBloc bloc;

  const ChatWidgetAudio({
    Key key,
    @required this.bloc,
    @required this.usuario,
  }) : super(key: key);

  @override
  _ChatWidgetAudioState createState() => _ChatWidgetAudioState();
}

class _ChatWidgetAudioState extends State<ChatWidgetAudio> {
  FlutterSound flutterSound = new FlutterSound();

  t_CODEC _codec = t_CODEC.CODEC_AAC;

  ChatPageBloc get _bloc => widget.bloc;
  get usuario => widget.usuario;

  @override
  void initState() {
    super.initState();
    flutterSound.setSubscriptionDuration(0.01);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: false,
      stream: _bloc.recording.stream,
      builder: (context, snapshot) {
        return GestureDetector(
          onLongPressStart: _onStartRecording,
          onLongPressEnd: _onEndRecording,
          child: AnimatedContainer(
            padding: EdgeInsets.all(snapshot.data ? 25 : 13),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            duration: Duration(milliseconds: 300),
            child: Icon(
              Icons.mic,
              color: Colors.white,
              size: 22,
            ),
          ),
        );
      },
    );
  }

  _onStartRecording(LongPressStartDetails details) async {
    try {
      _bloc.recording.add(true);
      String path = await flutterSound.startRecorder(
        codec: _codec,
      );

      _bloc.pathRecord.add(path);

      flutterSound.onRecorderStateChanged.listen((e) {
        if (e != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt(),
              isUtc: true);
          String txt = DateFormat('mm:ss', 'pt_BR').format(date);

          _bloc.timeRecording.add(txt);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  _onEndRecording(LongPressEndDetails details) async {
    _bloc.recording.add(false);
    _bloc.timeRecording.add("00:00");
    await flutterSound.stopRecorder();
    _bloc.sendAudio(usuario);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
