import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/widgets/app_circle_avatar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatConversaCard extends StatefulWidget {
  final User usuario;
  final Chat chat;
  final Function(Chat, String) onClickConversa;

  const ChatConversaCard(
      {Key key,
      @required this.usuario,
      @required this.chat,
      @required this.onClickConversa})
      : super(key: key);

  @override
  _ChatConversaCardState createState() => _ChatConversaCardState();
}

class _ChatConversaCardState extends State<ChatConversaCard> {
  Chat get c => widget.chat;
  User get usuario => widget.usuario;
  String get avatar => c.getAvatar(usuario);

  bool get isMe => c.fromId == usuario.id;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.all(0),
      shape: UnderlineInputBorder(
          borderSide: BorderSide(width: 0.3, style: BorderStyle.solid)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onClickConversa(c, avatar),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            leading: _avatar(),
            title: _nomeText(),
            subtitle:
                c.isTyping == null || !c.isTyping ? _msgRow() : _isTyping(),
          ),
        ),
      ),
    );
  }

  _avatar() {
    return Stack(
      children: <Widget>[
        Container(
          height: 50,
          width: 50,
          child: AppCircleAvatar(avatar: avatar),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 10,
            height: 10,
            decoration: new BoxDecoration(
              color: c.getColorCircleChat(usuario.id),
              shape: BoxShape.circle,
            ),
          ),
        )
      ],
    );
  }

  _nomeText() {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              c.getNameChat(usuario),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(width: 15),
          _getData(),
        ],
      ),
    );
  }

  _getData() {
    return Text(
      c.getMsgDataChat(),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 14, color: Colors.black54),
    );
  }

  _msgRow() {
    bool needSpace = c.isAudio || c.isImagem || c.isPdf;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _readIcon(c),
        _msg(c),
        _icon(c),
        needSpace ? Expanded(child: SizedBox()) : SizedBox(),
        _badge(c),
      ],
    );
  }

  _readIcon(Chat c) {
    if (!isMe) {
      return SizedBox();
    }
    return Container(
      margin: EdgeInsets.only(right: 5),
      child: c.entregue == 1
          ? c.lida == 1
              ? Icon(
                  Icons.done_all,
                  color: Colors.lightBlueAccent,
                  size: 18,
                )
              : Icon(Icons.done_all, size: 18, color: Colors.black54)
          : Icon(Icons.done, size: 18, color: Colors.black54),
    );
  }

  _msg(Chat c) {
    var split = c.fromNome.trim().split(" ");

    TextStyle textStyle = TextStyle(
      fontSize: 15.0,
      color: c.badge.mensagens > 0 ? Colors.black54 : Colors.black38,
    );

    String msg = c.isGroup ? "${split[0]}: " : '';

    if (c.isImagem) {
      String img = "Imagem";
      return Text(
        "$msg$img",
        overflow: TextOverflow.ellipsis,
        style: textStyle,
        maxLines: 1,
      );
    }

    if (c.isAudio) {
      return Text(
        "Àudio",
        overflow: TextOverflow.ellipsis,
        style: textStyle,
        maxLines: 1,
      );
    }

    if (c.isPdf) {
      return Text(
        "Arquivo",
        overflow: TextOverflow.ellipsis,
        style: textStyle,
        maxLines: 1,
      );
    }

    return Expanded(
      child: Text(
        "$msg${c.msg?.replaceAll('\n', '')}",
        overflow: TextOverflow.ellipsis,
        style: textStyle,
        maxLines: 1,
      ),
    );
  }

  _icon(Chat c) {
    if (c.isImagem) {
      return Container(
        margin: EdgeInsets.only(left: 5),
        child: Icon(
          Icons.image,
          size: 20,
          color: Colors.black54,
        ),
      );
    }

    if (c.isAudio) {
      return Container(
        margin: EdgeInsets.only(left: 5),
        child: Icon(
          FontAwesomeIcons.volumeUp,
          size: 16,
          color: Colors.black54,
        ),
      );
    }

    if (c.isPdf) {
      return Container(
        margin: EdgeInsets.only(left: 5),
        child: Icon(
          FontAwesomeIcons.file,
          size: 16,
          color: Colors.black54,
        ),
      );
    }

    return SizedBox();
  }

  _badge(Chat c) {
    if (c.badge.mensagens == 0) {
      return SizedBox();
    }
    return Container(
      margin: EdgeInsets.all(0),
      height: 22,
      width: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(72, 144, 226, 1),
      ),
      child: Text(
        c.badge.mensagens.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  _isTyping() {
    return Text("${c.fromNome} está digitando..");
  }
}
