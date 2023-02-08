import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/chat2/chat_conversas_bloc.dart';
import 'package:flutter_dandelin/pages/chat2/chat_nova_conversa_bloc.dart';
import 'package:flutter_dandelin/pages/chat2/chat_page.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart' as userChat;
import 'package:flutter_dandelin/pages/chat2/chat_page_bloc.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/pages/chat2/widgets/alert.dart';
import 'package:flutter_dandelin/widgets/app_circle_avatar.dart';
import 'package:flutter_dandelin/widgets/progress.dart';
import 'package:flutter_dandelin/model/doctor.dart';
import 'package:flutter_dandelin/model/expertise.dart';
import 'package:flutter_dandelin/utils/nav.dart';

class ChatNovaConversaPage extends StatefulWidget {
  final ChatConversasBloc chatConversasBloc;
  final userChat.User user;

  const ChatNovaConversaPage({Key key, @required this.chatConversasBloc, this.user})
      : super(key: key);

  @override
  _ChatNovaConversaPageState createState() => _ChatNovaConversaPageState();
}

class _ChatNovaConversaPageState extends State<ChatNovaConversaPage> {
  final _bloc = ChatNovaConversaBloc();
  final _chatPage = ChatPageBloc();

  ChatConversasBloc get _chatConversasBloc => widget.chatConversasBloc;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  userChat.User get user => widget.user;

  @override
  void initState() {
    super.initState();
    _bloc.fetch();
    _chatConversasBloc.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: pop,
        ),
        title: Text(
          "Nova Conversa",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _body(),
    );
  }

  _body() {
    return StreamBuilder(
      stream: _bloc.doctors.stream,
      builder: (context, snapshot) {
        List<Doctor> list = snapshot.data;

        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (!snapshot.hasData) {
          return Progress();
        }

        if (list.isEmpty) {
          return Center(
            child: Text("Você não possuí alguém para conversar."),
          );
        }

        return _listView(list);
      },
    );
  }

  _listView(List<Doctor> list) {
    return ListView.separated(
      itemCount: list.length,
      itemBuilder: (context, idx) {
        return _listTileDoctors(list[idx]);
      },
      separatorBuilder: (context, _) {
        return Divider(height: 0);
      },
    );
  }

  _listTileDoctors(Doctor doctor) {
    List<String> expertises = [];
    for (Expertise e in doctor.expertises) {
      expertises.add(e.name);
    }



    return ListTile(

      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      onTap: () {
        _onClickNovaConversa(doctor);
      },
      leading: Container(
        height: 50,
        width: 50,
        child: AppCircleAvatar(
          avatar: doctor.user.avatar,
        ),
      ),
      title: Text(doctor.user.fullName),
      subtitle: Text(expertises.join(", ")),
    );
  }

  _onClickNovaConversa(Doctor doctor) async {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Container(
        height: 40,
        child: Row(
          children: <Widget>[
            Progress(),
            SizedBox(width: 15),
            Text("Buscando a conversa.."),
          ],
        ),
      ),
    ));
    final conversa = await _bloc.getconversa(doctor);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    final chat = await _bloc.getChatNovaConversa(conversa.conversaId);
    if (chat != null) {
      push(
        ChatPage(chat, doctor.user.avatar, user, _chatConversasBloc),
      ).then((value) => () {
            _bloc.fetch();
          });
    } else {
      alert(context, msg: "Não foi possível abrir a conversa.");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }
}
