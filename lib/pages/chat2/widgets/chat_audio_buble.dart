
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/utils_livecom/bloc.dart';
import 'package:flutter_dandelin/widgets/app_circle_avatar.dart';
import 'package:flutter_dandelin/widgets/progress.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ChatAudioBuble extends StatefulWidget {
  final User usuario;
  final Chat chat;
  final BooleanBloc isDragging;
  final SimpleBloc audioPlaying;

  const ChatAudioBuble({
    Key key,
    @required this.chat,
    @required this.usuario,
    @required this.isDragging,
    @required this.audioPlaying,
  }) : super(key: key);

  @override
  _ChatAudioBubleState createState() => _ChatAudioBubleState();
}

class _ChatAudioBubleState extends State<ChatAudioBuble>
    with TickerProviderStateMixin {
  Chat get chat => widget.chat;
  User get usuario => widget.usuario;

  final _bloc = ChatAudioBubleBloc();

  AnimationController _iconButtonController;

  AudioPlayer audioPlayer = new AudioPlayer();

  double maxSlider = .0000001;
  bool get isMe => chat.fromId == usuario.id;

  @override
  void initState() {
    super.initState();
    _iconButtonController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    if (chat.arquivos.first.fileUser == null) {
      audioPlayer.setUrl(chat.arquivos.first.url);
    } else {
      audioPlayer.setUrl(chat.arquivos.first.fileUser.path, isLocal: true);
    }

    audioPlayer.setVolume(1.0);

    _isPlayingListen();
    _getDuration();
    _listenAudioStateChanged();
    _listenAudioDurationChanged();
    _listenAudioPlaying();
  }

  _isPlayingListen() {
    _bloc.isPlaying.listen((v) {
      v ? _iconButtonController.forward() : _iconButtonController.reverse();
    });
  }

  _getDuration() {
    audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() {
          maxSlider = d.inMilliseconds.toDouble();
        });
      }

      _bloc.changeTempoAudio(d);
    });
  }

  _listenAudioStateChanged() async {
    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState audioState) {
      switch (audioState) {
        case AudioPlayerState.PAUSED:
          _bloc.isPlaying.add(false);
          break;
        case AudioPlayerState.STOPPED:
          _bloc.isPlaying.add(false);
          break;
        case AudioPlayerState.COMPLETED:
          _bloc.isPlaying.add(false);
          _bloc.resetTime();
          break;
        case AudioPlayerState.PLAYING:
          _bloc.isPlaying.add(true);
          break;
        default:
      }
    });
  }

  _listenAudioDurationChanged() {
    audioPlayer.onAudioPositionChanged.listen(_bloc.changeTempoAudio);
  }

  _listenAudioPlaying() {
    if (widget.audioPlaying != null) {
      widget.audioPlaying.listen((int identifier) {
        if (identifier != chat.identifier &&
            audioPlayer.state == AudioPlayerState.PLAYING) {
          audioPlayer.stop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  _iconPlayPause(),
                  _soundIndicator(),
                  SizedBox(width: 15),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _dataText(),
                  _tempoAudioText(),
                ],
              ),
            ],
          ),
        ),
        _avatar(),
      ],
    );
  }

  _iconPlayPause() {
    return StreamBuilder(
      initialData: false,
      stream: _bloc.isPlaying.stream,
      builder: (context, snapshot) {
        return IconButton(
          onPressed: snapshot.data ? _onClickResumeAudio : _onClickStartAudio,
          icon: AnimatedIcon(
            icon: AnimatedIcons.play_pause,
            progress: _iconButtonController,
          ),
        );
      },
    );
  }

  _soundIndicator() {
    return StreamBuilder(
      stream: _bloc.tempoAudioDuration.stream,
      builder: (context, snapshot) {
        Duration duration = snapshot.data ?? Duration(seconds: 1);

        double value =
        snapshot.hasData ? duration.inMilliseconds.toDouble() : 0.0;

        return Expanded(
          child: Container(
            height: 40,
            child: FlutterSlider(
              disabled: !snapshot.hasData,
              values: [value],
              min: 0.0,
              max: maxSlider,
              onDragStarted: (_, __, ___) {
                if (widget.isDragging != null) {
                  widget.isDragging.add(true);
                }
              },
              onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                _onDragEndSlider(lowerValue);
                if (widget.isDragging != null) {
                  widget.isDragging.add(false);
                }
              },
              trackBar: FlutterSliderTrackBar(
                centralWidget: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  width: 9,
                  height: 9,
                ),
              ),
              handler: FlutterSliderHandler(
                decoration: BoxDecoration(),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 10,
                    maxWidth: 10,
                    minHeight: 10,
                    minWidth: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(5),
                ),
              ),
              onDragging: (handlerIndex, lowerValue, upperValue) {},
              tooltip: FlutterSliderTooltip(disabled: true),
            ),
          ),
        );
      },
    );
  }

  _avatar() {
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      child: AppCircleAvatar(
        avatar: chat.getAvatar(usuario),
      ),
    );
  }

  _dataText() {
    return Text(
      chat.getMsgDataChat(),
      style: TextStyle(
        color: Colors.black38,
        fontSize: 12.0,
      ),
    );
  }

  _tempoAudioText() {
    return StreamBuilder(
      stream: _bloc.tempoAudioText.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 15,
            width: 15,
            child: Progress(),
          );
        }

        return Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 15),
              child: Text(
                snapshot.data,
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 12.0,
                ),
              ),
            ),
            _checkIcon(),
          ],
        );
      },
    );
  }

  _checkIcon() {
    return isMe
        ? Icon(
      chat.entregue == 1 ? MdiIcons.checkAll : MdiIcons.check,
      size: 15.0,
      color: chat.lida == 1
          ? Color.fromRGBO(79, 195, 247, 1)
          : Colors.black38,
    )
        : SizedBox();
  }

  _onClickStartAudio() {
    widget.audioPlaying.add(chat.identifier);
    if (chat.arquivos.first.fileUser == null) {
      audioPlayer.play(chat.arquivos.first.url);
    } else {
      audioPlayer.play(chat.arquivos.first.fileUser.path, isLocal: true);
    }
  }

  _onClickResumeAudio() async {
    audioPlayer.pause();
  }

  _onDragEndSlider(double lowerValue) {
    Duration d = Duration(milliseconds: lowerValue.toInt());
    _bloc.tempoAudioDuration.add(d);
    audioPlayer.seek(d);
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
    _iconButtonController.dispose();
  }
}

class ChatAudioBubleBloc {
  final isPlaying = BooleanBloc()..add(false);
  final tempoAudioText = SimpleBloc<String>();
  final tempoAudioDuration = SimpleBloc<Duration>();

  changeTempoAudio(Duration d) {
    if (isPlaying.value) {
      tempoAudioDuration.add(d);
    }
    tempoAudioText.add(durationToAudioTime(d));
  }

  resetTime() {
    tempoAudioDuration.add(Duration(milliseconds: 1));
  }

  String durationToAudioTime(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  dispose() {
    isPlaying.dispose();
    tempoAudioText.dispose();
    tempoAudioDuration.dispose();
  }
}
