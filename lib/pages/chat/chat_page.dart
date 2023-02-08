import 'package:flutter_dandelin/pages/chat/chat.dart';
import 'package:flutter_dandelin/pages/chat/chat_bloc.dart';
import 'package:flutter_dandelin/pages/chat/chat_detalhe_page.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/scroll.dart';
import 'package:flutter_dandelin/widgets/app_bar.dart';
import 'package:flutter_dandelin/widgets/center_text.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _bloc = ChatBloc();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc.fetch();
    addScrollListener(_scrollController, _bloc.fetchMore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DandelinAppbar(
        "Chats",
        actions: [
          _refresh(),
        ],
      ),
      body: _body(),
    );
  }

  _refresh() {
    return IconButton(
      icon: Icon(Icons.refresh),
      onPressed: _onClickRefresh,
    );
  }

  _body() {
    return StreamBuilder<List<Chat>>(
      stream: _bloc.chats.stream,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return Progress();
        }

        if (snapshot.hasError) {
          return CenterText(snapshot.error);
        }

        var chats = snapshot.data;

        if (chats.length == 0) {
          return CenterText("Você não possui conversas");
        }

        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          onRefresh: _onClickRefresh,
          child: ListView.separated(
            controller: _scrollController,
            itemCount: chats.length,
            itemBuilder: (_, idx) {
              return _item(chats[idx]);
            },
            separatorBuilder: (_, __) {
              return Divider(
                height: 0,
                indent: 83,
              );
            },
          ),
        );
      },
    );
  }

  _item(Chat chat) {
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: () async {
          _onClickChatDetalhe(chat);
        },
        leading: _leading(chat),
        title: _title(chat),
        subtitle: _subTitle(chat),
        trailing: _trailing(chat),
      ),
    );
  }

  _leading(Chat chat) {
    return AppCircleAvatar(
      avatar: chat.getAvatar(),
      radius: 25,
    );
  }

  _title(Chat chat) {
    return AppText(
      chat.getNameChat(),
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );
  }

  _subTitle(Chat chat) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        chat.myMsg() ? _check(chat) : SizedBox(),
        Expanded(
          child: AppText(
            chat.msg,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  _check(Chat chat) {
    return Container(
      margin: EdgeInsets.only(right: 5),
      child: Icon(
        chat.msgEntregue ? Icons.done_all : Icons.done,
        size: 14,
        color: chat.msgLida ? Colors.lightBlue : Colors.grey,
      ),
    );
  }

  _trailing(Chat chat) {
    return Column(
      children: [
        SizedBox(height: 10),
        AppText(
          chat.getMsgDataChat(),
          fontSize: 12,
        ),
        SizedBox(height: 3),
        chat.hasMsgs()
            ? Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
                child: AppText(
                  chat.badge.mensagens.toString(),
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Future<void> _onClickRefresh() async {
    _bloc.fetch(refresh: true);
  }

  _onClickChatDetalhe(Chat chat) async {
    Navigator.of(context)
        .push(
         new MaterialPageRoute(builder: (_) => new ChatDetalhePage(medico: chat.doctor(),)),
        )
        .then((_) => _onClickRefresh());
    //await push(ChatDetalhePage(medico: chat.doctor()));
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
    _scrollController.dispose();
  }
}
