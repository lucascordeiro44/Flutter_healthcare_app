import 'package:flutter/cupertino.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/pages/cupons_aplicados/cupons_aplicados_page.dart';
import 'package:flutter_dandelin/pages/dependentes/dependentes_page.dart';
import 'package:flutter_dandelin/perfil_api.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/amigo/indique_amigo_page.dart';
import 'package:flutter_dandelin/pages/cupom_desconto/cupom_desconto_page.dart';
import 'package:flutter_dandelin/pages/historico/historico_page.dart';
import 'package:flutter_dandelin/pages/home/editar_perfil_page.dart';
import 'package:flutter_dandelin/pages/login/login_page.dart';
import 'package:flutter_dandelin/pages/pagamento/pagamento_page.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_circle_avatar.dart';
import 'package:flutter_dandelin/widgets/app_header.dart';
import 'package:flutter_dandelin/widgets/app_list_tile.dart';
import 'package:flutter_dandelin/widgets/material_ontap.dart';
import 'package:intl/intl.dart';

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  User get user => appBloc.user;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    screenView("Meu_Perfil", "Tela Meu_Perfil");
    print(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        elevation: 1,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "Meu perfil",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: _body(),
    );
  }

  _body() {
    return BaseContainer(
      needSingleChildScrollView: true,
      child: Column(
        children: <Widget>[
          _appHeader(),
          _notificacaoListTile(),
          _historicoListTile(),
          Divider(height: 0),
          _pagamentoListTile(),
          Divider(height: 0),
          user.isDependente && !user.dependenteRemovido
              ? SizedBox()
              : _dependentesListTile(),
          user.isDependente && !user.dependenteRemovido
              ? SizedBox()
              : Divider(height: 0),
          // _alertaPrecosListTile(),
          // Divider(height: 0),
          _indiqueAmigoListTile(),
          Divider(height: 0),
          _cuponsAplicados(),
          Divider(height: 0),
          _faleConoscoListTile(),
          Divider(height: 0),
          _rowExcluirContaSair(),
        ],
      ),
    );
  }

  _appHeader() {
    return MaterialOnTap(
      onTap: _onClickEditarPerfil,
      child: AppHeader(
        image: 'assets/images/profile-background.png',
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 15),
        height: 210,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Hero(
              tag: 'appCircleAvatar',
              child: StreamBuilder(
                stream: appBloc.stream,
                builder: (context, snapshot) {
                  User u = snapshot.data?.user;

                  return u != null
                      ? AppCircleAvatar(avatar: u.avatar)
                      : SizedBox();
                },
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AutoSizeText(
                  "${user.firstName} ${user.lastName}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontFamily: 'Mark Book',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _notificacaoListTile() {
    return AppListTile(
      padding: EdgeInsets.only(top: 7, bottom: 7, left: 22.2, right: 12),
      onPressed: _onClickNotificacoes,
      leading: Icon(
        Icons.notifications_none_outlined,
        size: 38,
        color: AppColors.greyFontLow,
      ),
      paddingTitle: EdgeInsets.only(left: 5),
      title: "Notificações",
    );
  }

  _historicoListTile() {
    return AppListTile(
      padding: EdgeInsets.only(top: 7, bottom: 7, left: 27.2, right: 12),
      onPressed: _onClickHistorico,
      leading: Container(
        child: Image.asset('assets/images/historico-icon.png'),
        height: 27,
      ),
      paddingTitle: EdgeInsets.only(left: 2),
      title: "Histórico",
    );
  }

  _pagamentoListTile() {
    return AppListTile(
      onPressed: _onClickPagamento,
      leading: Container(
        child: Image.asset('assets/images/pagamento-icon.png'),
        height: 27,
      ),
      paddingTitle: EdgeInsets.only(left: 4),
      title: "Pagamento",
    );
  }

  _dependentesListTile() {
    return AppListTile(
      onPressed: _onClickDependentes,
      leading: Container(
        child: Image.asset('assets/images/dependentes-icon.png'),
        height: 27,
      ),
      title: "Dependentes",
    );
  }


  _indiqueAmigoListTile() {
    return AppListTile(
      padding: EdgeInsets.only(top: 7, bottom: 7, left: 28.4, right: 12),
      onPressed: _onClickIndiqueAmigos,
      leading: Container(
        child: Image.asset('assets/images/indique-amigo-icon.png'),
        height: 27,
      ),
      paddingTitle: EdgeInsets.only(left: 1),
      title: "Indique um amigo",
    );
  }

  _cupomDescontoListTile() {
    return AppListTile(
      padding: EdgeInsets.only(top: 7, bottom: 7, left: 19, right: 12),
      onPressed: _onClickCupomDesconto,
      leading: Container(
        child: Image.asset('assets/images/cupom-desconto-icon.png'),
        height: 42,
      ),
      paddingTitle: EdgeInsets.only(left: 9),
      title: "Cupom de desconto",
    );
  }

  _cuponsAplicados() {
    return AppListTile(
      padding: EdgeInsets.only(top: 7, bottom: 7, left: 19, right: 12),
      onPressed: _onClickCuponsAplicados,
      leading: Container(
        child: Image.asset('assets/images/cupom-desconto-icon.png',),
        height: 42,
      ),
      paddingTitle: EdgeInsets.only(left: 9),
      title: "Cupons",
    );
  }

  _faleConoscoListTile() {
    return AppListTile(
      padding: EdgeInsets.only(top: 7, bottom: 7, left: 29, right: 12),
      onPressed: _onClickFaleConosco,
      leading: Container(
        child: Image.asset('assets/images/fale-conosco-icon.png'),
        height: 27,
      ),
      title: "Fale conosco",
    );
  }

  _rowExcluirContaSair() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _excluirBtn(),
          _sairBtn(),
        ],
      ),
    );
  }

  _excluirBtn() {
    return FlatButton(
      onPressed: () {
        _onClickExcluirConta();
      },
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            child: Image.asset(
              'assets/images/excluir-btn.png',
            ),
          ),
          SizedBox(width: 10),
          Text(
            "Excluir conta",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }

  _sairBtn() {
    return FlatButton(
      onPressed: _onClickSair,
      child: Row(
        children: <Widget>[
          Text("Sair",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
          SizedBox(width: 10),
          ClipOval(
            child: Material(
              color: Color.fromRGBO(0, 190, 236, 1), // button color
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _onClickNotificacoes() {
    push(NotificacaoPage());
  }

  _onClickEditarPerfil() async {
    screenAction('editar_perfil', "Clicou em Editar perfil");
    push(EditarPerfilPage());
  }

  _onClickHistorico() {
    screenAction('historico', "Na tela de Perfil, clicou no Historico");
    push(HistoricoPage());
  }

  _onClickPagamento() async {
    screenAction('pagamento', "Na tela de Perfil, clicou no Pagamento");
    await push(PagamentoPage());
    //apenas pra redesenhar a tela se o usuário fica pre ativo/ativo quando exclui ou add um novo cartão
    setState(() {});
  }

  _onClickDependentes() {
    push(DependentesPage());
  }

  // _onClickAlertaPrecos() {
  //  push( AlertaDePrecos());
  // }

  _onClickIndiqueAmigos() {
    screenAction(
        'indique_amigo', "Na tela de Perfil, clicou no Indique um amigo");
    push(IndiqueUmAmigoPage());
  }

  _onClickCupomDesconto() {
    screenAction(
        'cupom_desconto', "Na tela de Perfil, clicou no Cupom de desconto");
    push(CupomDescontoPage());
  }

  _onClickCuponsAplicados() {
    push(CuponsAplicadosPage());

  }

  _onClickFaleConosco() async {
    screenAction('fale_conosco', "Na tela de Perfil, clicou no Fale Conosco");
    bool v = await canLaunch("mailto:contato@dandelin.io");

    v
        ? launch("mailto:contato@dandelin.io")
        : _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Não foi possível abrir o aplicativo de e-mail."),
          ));
  }

  _onClickExcluirConta() async {
    screenAction('excluir_conta', "Na tela de Perfil, clicou em Excluir Conta");

    DateTime now = DateTime.now();

    String mesAtual = DateFormat.MMMM().format(now);

    DateTime date = new DateTime(now.year, now.month + 1, 0);

    String msg = user.isPagamentoAtivoOuPreAtivo
        ? 'Você pagou pelo uso do mês de $mesAtual, ao excluir sua conta agora você perderá essa garantia, válida até ${date.day}/${addZeroDate(date.month)}/${date.year}. Tem certeza que deseja continuar?'
        : "Você tem certeza que deseja excluir sua conta ?";

    alertConfirm(
      context,
      msg,
      callbackNao: () {
        pop();
      },
      callbackSim: _onClickExcluir,
      nao: "Cancelar",
      sim: "Sim, excluir",
    );
  }

  _onClickExcluir() async {
    pop();

    showSimpleDialog("Excluindo conta..", progress: true);

    ApiResponse apiResponse = await PerfilApi.excluirConta();

    pop();

    if (apiResponse.ok) {
      appBloc.logout();

      push(LoginPage(), replace: true, popAll: true);
    } else {
      showSimpleDialog(apiResponse.msg);
    }
  }

  _onClickSair() {
    screenAction('sair', "Na tela de Perfil, clicou no Sair");
    alertConfirm(
      context,
      'Tem certeza que deseja sair do app?',
      callbackSim: () {
        appBloc.logout();

        push(LoginPage(), replace: true, popAll: true);
      },
      callbackNao: () {
        pop();
      },
      sim: "Sair",
      nao: "Cancelar",
    );
  }
}
