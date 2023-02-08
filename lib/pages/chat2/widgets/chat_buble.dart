import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/chat2/arquivo.dart';
import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/pages/chat2/widgets/chat_audio_buble.dart';
import 'package:flutter_dandelin/pages/chat2/widgets/link_infos_card.dart';
import 'package:flutter_dandelin/utils_livecom/bloc.dart';
import 'package:flutter_dandelin/widgets/progress.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ChatBuble extends StatelessWidget {
  final User usuario;
  final Chat chat;
  final bool marginTop;
  final bool marginBottom;
  final Function(Chat) onLongPress;
  final Function(Chat) onClick;
  final Function(Chat) onClickArquivo;
  final Function(ImageProvider, String) onClickImage;
  final BooleanBloc isDragging;
  final SimpleBloc audioPlaying;

  const ChatBuble({
    Key key,
    @required this.usuario,
    @required this.chat,
    this.marginBottom = false,
    this.marginTop = false,
    @required this.onLongPress,
    @required this.onClick,
    @required this.isDragging,
    @required this.audioPlaying,
    @required this.onClickImage,
    @required this.onClickArquivo,
  }) : super(key: key);

  _isMe() {
    if(chat.fromId != null){
      return chat.fromId == usuario.id;
    } else {
      return chat.from == usuario.id.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        onLongPress(chat);
      },
      onTap: () {
        onClick(chat);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        color: chat.isSelected != null && chat.isSelected
            ? Colors.lightBlueAccent.withOpacity(.65)
            : Colors.transparent,
        margin: EdgeInsets.only(
          bottom: marginBottom ? 5 : 0,
          top: marginTop ? 5 : 0,
        ),
        child: Column(
          crossAxisAlignment:
          _isMe() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .7),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              margin: EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: _isMe() ? Color.fromRGBO(220, 248, 198, 1) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: .5,
                    spreadRadius: 1.0,
                    color: Colors.black.withOpacity(.12),
                  )
                ],
                borderRadius: _isMe()
                    ? BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  bottomLeft: Radius.circular(5.0),
                  bottomRight: Radius.circular(10.0),
                )
                    : BorderRadius.only(
                  topRight: Radius.circular(5.0),
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(5.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  chat.isGroup != null && chat.isGroup
                      ? _userSenderMsg()
                      : SizedBox(),
                  _msgWidget(context),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _dataText(),
                      SizedBox(width: 3.0),
                      _checkIcon(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _userSenderMsg() {
    return Container(
      margin: EdgeInsets.only(bottom: 3),
      child: Text(
        chat.fromNome,
        style: TextStyle(
          color: chat.colorNameGroup,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  _msgWidget(BuildContext context) {
    if (chat.isImagem) {
      return _msgLikeImage(context);
    } else if (chat.isAudio) {
      return _msgLikeAudio();
    } else if (chat.isPdf) {
      return _msgLikeArquivo(context);
    } else {
      return _msgLikeText(context);
    }
  }

  _msgLikeImage(BuildContext context) {
    Arquivos arquivo = chat.arquivos.first;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      height: 120,
      width: 120,
      child: arquivo.fileUser == null
          ? CachedNetworkImage(
        imageUrl: arquivo.url,
        imageBuilder: (context, imageProvider) {
          return GestureDetector(
            onTap: () {
              onClickImage(imageProvider, null);
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider),
              ),
            ),
          );
        },
        placeholder: (context, url) => Container(
          constraints: BoxConstraints(
            maxHeight: 80,
            maxWidth: 80,
          ),
          child: Progress(),
        ),
      )
          : GestureDetector(
          onTap: () {
            onClickImage(null, arquivo.fileUser.path);
          },
          child: Image.asset(arquivo.fileUser.path)),
    );
  }

  _msgLikeAudio() {
    return ChatAudioBuble(
      chat: chat,
      usuario: usuario,
      isDragging: isDragging,
      audioPlaying: audioPlaying,
    );
  }

  _msgLikeArquivo(context) {
    if (chat.isPdf)
      return RawMaterialButton(
        onPressed: () {
          onClickArquivo(chat);
        },
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                'assets/chat/icons/ic_file_pdf.png',
                height: 110,
              ),
              Text(chat.firtsArquivo.file)
            ],
          ),
        ),
      );
  }

  _msgLikeText(context) {
    return Container(
      margin: EdgeInsets.only(bottom: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          chat.isLink
              ? LinkInfosCard(
            imageLink: chat.imageLink,
            descricao: chat.descricaoLink,
            titleLink: chat.titleLink,
            url: chat.urlLink,
            color: _isMe()
                ? Color.fromRGBO(205, 237, 184, 1)
                : Colors.grey[200],
          )
              : SizedBox(),
          Linkify(
            text: chat.msg ?? "",
            textAlign: TextAlign.start,
            onOpen: (link) async {
              onClick(chat);
            },
          ),
        ],
      ),
    );
  }

  _dataText() {
    return chat.isAudio
        ? SizedBox()
        : Text(
      chat.getMsgDataChat(),
      style: TextStyle(
        color: Colors.black38,
        fontSize: 11.0,
      ),
    );
  }

  _checkIcon() {
    return _isMe() && !chat.isAudio
        ? Icon(
      chat.entregue == 1 ? MdiIcons.checkAll : MdiIcons.check,
      size: 15.0,
      color: chat.lida == 1
          ? Color.fromRGBO(79, 195, 247, 1)
          : Colors.black38,
    )
        : SizedBox();
  }
}
