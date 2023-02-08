import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/pages/notificacao/notificacao_detalhe_bloc.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/model/notificacao.dart';

class NotificacaoDetalhePage extends StatefulWidget {
  final Notificacao notificacao;

  const NotificacaoDetalhePage({Key key, this.notificacao}) : super(key: key);

  @override
  _NotificacaoDetalhePageState createState() => _NotificacaoDetalhePageState();
}

class _NotificacaoDetalhePageState extends State<NotificacaoDetalhePage> {
  final _bloc = NotificacaoDetalheBloc();
  Notificacao get notificacao => widget.notificacao;

  @override
  void initState() {
    super.initState();
    _bloc.read(notificacao);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text("Confirmação"),
        backgroundColor: Colors.white,
        elevation: 1.5,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_horiz, color: AppColors.greyFontLow),
          ),
        ],
      ),
      body: _body(),
    );
  }

  _body() {
    return BaseContainer(
      padding: EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _titleNotificacao(),
          Container(
            child: Divider(color: Colors.black38),
            padding: EdgeInsets.only(right: 10),
          ),
          SizedBox(height: 15),
          _richTextContent(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Image.asset('assets/images/dandelin-logo.png', width: 150),
          ),
          _richTextDate(),
        ],
      ),
    );
  }

  _titleNotificacao() {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      leading: Image.asset('assets/images/cone-notificacao-dandelin.png',
          height: 40),
      title: AppText(
        notificacao.message,
        fontWeight: FontWeight.w500,
        color: AppColors.greyStrong,
      ),
      subtitle: AppText(
        'dandelin',
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
    );
  }

  _richTextContent() {
    return Container(
      width: SizeConfig.screenWidth * 0.67,
      child: AppText(
        "",
        color: AppColors.greyStrong,
        fontFamily: 'Mark Book',
      ),
    );
  }

  _richTextDate() {
    return RichText(
      text: TextSpan(
        text: notificacao.dataNotificacao,
        style: TextStyle(
            color: AppColors.greyFontLow,
            fontWeight: FontWeight.w500,
            fontFamily: 'Mark',
            fontSize: 13),
        children: [
          TextSpan(
            text: notificacao.horaNotificacao,
            style: TextStyle(color: AppColors.greyFont),
          )
        ],
      ),
    );
  }
}
