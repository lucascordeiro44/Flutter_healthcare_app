import 'package:flutter/material.dart';
import 'package:flutter_dandelin/app_bloc.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/chat/chat_detalhe_bloc.dart';
import 'package:flutter_dandelin/widgets/app_bar.dart';
import 'package:flutter_dandelin/widgets/center_text.dart';
import 'package:flutter_dandelin/widgets/progress.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatDetalhePage extends StatefulWidget {
  final User medico;

  const ChatDetalhePage({Key key, @required this.medico}) : super(key: key);

  @override
  _ChatDetalhePageState createState() => _ChatDetalhePageState();
}

class _ChatDetalhePageState extends State<ChatDetalhePage> {
  final _bloc = ChatDetalheBloc();

  User get user => appBloc.user;

  int idx = 0;

  @override
  void initState() {
    super.initState();
    _bloc.init(user, widget.medico);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DandelinAppbar("Chat"),
      body: _body(),
    );
  }

  _body() {
    return StreamBuilder(
      stream: _bloc.urlChat.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CenterText(snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return Progress();
        }

        return IndexedStack(
          index: idx,
          children: [
            Progress(),
            Container(
              padding: EdgeInsets.only(bottom: 40),
              child: WebView(
                initialUrl: snapshot.data,
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: (String url) {
                  setState(() {
                    idx = 1;
                  });
                },
                gestureNavigationEnabled: true,
              ),
            ),
          ],
        );
      },
    );
  }

}
