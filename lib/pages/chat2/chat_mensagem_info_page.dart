import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/chat_mensagem_info_bloc.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/pages/chat2/widgets/chat_buble.dart';
import 'package:flutter_dandelin/pages/chat2/widgets/chat_checks.dart';
import 'package:flutter_dandelin/widgets/app_circle_avatar.dart';
import 'package:flutter_dandelin/widgets/progress.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ChatMensagemInfoPage extends StatefulWidget {
  final Chat chat;
  final User usuario;

  const ChatMensagemInfoPage(
      {Key key, @required this.chat, @required this.usuario})
      : super(key: key);

  @override
  _ChatMensagemInfoPageState createState() => _ChatMensagemInfoPageState();
}

class _ChatMensagemInfoPageState extends State<ChatMensagemInfoPage> {
  User get usuario => widget.usuario;
  Chat get chat => widget.chat;

  final _bloc = ChatMensagemInfoBloc();

  @override
  void initState() {
    _bloc.fetch(chat: chat, usuario: usuario);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mensagem info"),
      ),
      body: _body(),
    );
  }

  _body() {
    return StreamBuilder(
      stream: _bloc.msgInfo.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: Progress(),
          );
        }

        MsgInfo msgInfo = snapshot.data;

        return _msgInfoPage(msgInfo);
      },
    );
  }

  _msgInfoPage(MsgInfo msgInfo) {
    return Column(
      children: <Widget>[
        _msg(msgInfo),
        _msgDetails(msgInfo),
      ],
    );
  }

  _msg(MsgInfo msgInfo) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/chat_background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: usuario.id == msgInfo.fromId
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          ChatBuble(
            chat: msgInfo.msgInfoToChat(chat),
            onClick: null,
            onLongPress: null,
            usuario: usuario,
            isDragging: null,
            audioPlaying: null,
            onClickImage: null,
            onClickArquivo: null,
          ),
          msgInfo.dataPush != null && msgInfo.dataPush != ""
              ? Container(
                  margin: EdgeInsets.only(right: 16, top: 10, left: 16),
                  child: Text("Push enviado às ${msgInfo.dataPush}"),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  _msgDetails(MsgInfo msgInfo) {
    return Expanded(
      child: Container(
        width: double.infinity,
        color: Colors.black26,
        padding: EdgeInsets.all(16),
        child: msgInfo.isGrupo
            ? _streamStatusMensagem()
            : _cardBrancoInfos(msgInfo),
      ),
    );
  }

  _cardBrancoInfos(MsgInfo msgInfo) {
    bool msgInfoIsNull = msgInfo.dataLida == null || msgInfo.dataLida == "";
    bool msgEntregueIsNull =
        msgInfo.dataEntregue == null || msgInfo.dataEntregue == "";

    return Column(
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                msgInfoIsNull ? SizedBox() : _lidaEntregue(true),
                msgInfoIsNull ? SizedBox() : Text(msgInfo.dataLida),
                !msgEntregueIsNull && !msgInfoIsNull ? Divider() : SizedBox(),
                msgEntregueIsNull ? SizedBox() : _lidaEntregue(false),
                msgEntregueIsNull ? SizedBox() : Text(msgInfo.dataEntregue),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _lidaEntregue(bool lida) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        children: <Widget>[
          Icon(
            MdiIcons.checkAll,
            color: lida ? Color.fromRGBO(79, 195, 247, 1) : Colors.black38,
            size: 18,
          ),
          SizedBox(width: 5),
          Text(lida ? "Lida" : "Entregue")
        ],
      ),
    );
  }

  _streamStatusMensagem() {
    return StreamBuilder(
      stream: _bloc.statusMensagens.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Progress();
        }

        List<StatusMensagens> status = snapshot.data;

        return _cardStatusMensagem(status);
      },
    );
  }

  _cardStatusMensagem(List<StatusMensagens> status) {
    List<StatusMensagens> listVistos = status.where((s) => s.lida).toList();
    List<StatusMensagens> listEntregues =
        status.where((s) => !s.entregue || !s.lida).toList();

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          listVistos.length > 0 ? _listCard(listVistos, true) : SizedBox(),
          listEntregues.length > 0
              ? _listCard(listEntregues, false)
              : SizedBox(),
        ],
      ),
    );
  }

  _listCard(List<StatusMensagens> list, bool isVistos) {
    return Card(
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        shrinkWrap: true,
        itemCount: list.length + 1,
        itemBuilder: (context, idx) {
          if (idx == 0) {
            return _titleListView(isVistos, list.length);
          }
          return _cardUser(list[idx - 1], isVistos);
        },
        separatorBuilder: (context, idx) {
          return Divider(height: idx == 0 ? 5 : 0);
        },
      ),
    );
  }

  _titleListView(bool isLida, int tot) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(isLida ? "Lida por: $tot" : "Não recebidas"),
        isLida ? DoubleCheckViewed(iconSize: 20) : Icon(MdiIcons.check),
      ],
    );
  }

  _cardUser(StatusMensagens listVisto, bool isVisto) {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      leading: AppCircleAvatar(
        avatar: listVisto.userUrlFoto,
      ),
      title: Text(listVisto.userNome),
      subtitle: isVisto ? Text(listVisto.dataLida) : SizedBox(),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
