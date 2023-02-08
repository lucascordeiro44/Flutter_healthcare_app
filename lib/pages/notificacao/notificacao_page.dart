import 'package:flutter_dandelin/model/notificacao.dart';
import 'package:flutter_dandelin/pages/notificacao/notificacao_card.dart';
import 'package:flutter_dandelin/pages/notificacao/notificacao_detalhe_page.dart';
import 'package:flutter_dandelin/pages/notificacao/notificacao_bloc.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_header.dart';
import 'package:flutter_dandelin/widgets/center_text.dart';

class NotificacaoPage extends StatefulWidget {
  @override
  _NotificacaoPageState createState() => _NotificacaoPageState();
}

class _NotificacaoPageState extends State<NotificacaoPage> {
  final _bloc = NotificacoesBloc();

  @override
  void initState() {
    super.initState();
    _bloc.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text("Notificações"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _body(),
    );
  }

  _body() {
    return Column(
      children: <Widget>[
        _imageHeader(),
        _notificacoesStream(),
      ],
    );
  }

  _imageHeader() {
    return AppHeader(
      image: 'assets/images/notificacao-background.png',
      elevation: 0,
      height: 200,
      child: Center(
        child: Image.asset(
          'assets/images/notificacao-header-icon.png',
          height: 80,
        ),
      ),
    );
  }

  _notificacoesStream() {
    return Expanded(
      child: StreamBuilder<List<Notificacao>>(
        stream: _bloc.stream,
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return Progress();
          }

          if (snapshot.hasError) {
            return CenterText(snapshot.error);
          }

          List<Notificacao> notificacoes = snapshot.data;

          if (isEmptyList(notificacoes)) {
            return CenterText("Você não possui notificações.");
          }

          return ListView.separated(
            itemCount: notificacoes.length,
            itemBuilder: (_, idx) {
              Notificacao notificacao = notificacoes[idx];

              return NotificacaoCard(
                leading: Image.asset(
                  'assets/images/cone-notificacao-dandelin.png',
                  height: 40,
                ),
                notificacao: notificacao,
                onClick: _onClickNotificacaoDetalhe,
              );
            },
            separatorBuilder: (_, __) {
              return Divider(height: 0);
            },
          );
        },
      ),
    );
  }

  _onClickNotificacaoDetalhe(Notificacao notificacao) {
    _bloc.clickNotificacao(notificacao);
    push(NotificacaoDetalhePage(notificacao: notificacao));
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }
}
