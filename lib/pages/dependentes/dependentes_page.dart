import 'package:flutter/material.dart';
import 'package:flutter_dandelin/model/dependente.dart';
import 'package:flutter_dandelin/pages/dependentes/dependentes_bloc.dart';
import 'package:flutter_dandelin/pages/dependentes/dependentes_detalhe_page.dart';
import 'package:flutter_dandelin/pages/dependentes/dependetens_card.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';
import 'package:flutter_dandelin/widgets/center_text.dart';

class DependentesPage extends StatefulWidget {
  @override
  _DependentesPageState createState() => _DependentesPageState();
}

class _DependentesPageState extends State<DependentesPage>
    with SingleTickerProviderStateMixin {
  User get user => appBloc.user;

  final _bloc = DependentesBloc();

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _bloc.init(user);

    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text("Dependentes"),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: _body(),
    );
  }

  _body() {
    return Stack(
      children: <Widget>[
        Column(
          children: [
            _tabsBar(),
            _tabBarView(),
          ],
        ),
        _tabsBar(),
        _buttonAddDependentes(),
      ],
    );
  }

  _tabsBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Theme.of(context).primaryColor,
      indicatorWeight: 5,
      labelPadding: EdgeInsets.symmetric(vertical: 0),
      labelStyle: TextStyle(fontSize: 16, fontFamily: 'Mark Book'),
      tabs: [
        Container(
          height: 54,
          width: double.infinity,
          child: Tab(text: "Ativos"),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(
                color: Colors.black38,
                width: 0.2,
              ),
            ),
          ),
        ),
        Container(
          height: 54,
          width: double.infinity,
          color: Colors.white,
          child: Tab(text: "Outros"),
        ),
      ],
    );
  }

  _tabBarView() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _streamDependentes(true),
          _streamDependentes(false),
        ],
      ),
    );
  }

  _streamDependentes(bool ativos) {
    return StreamBuilder(
      stream:
          ativos ? _bloc.dependentes.stream : _bloc.dependentesOutros.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CenterText(snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return Progress();
        }

        List dependentes = snapshot.data;

        if (dependentes.isEmpty) {
          return CenterText(ativos
              ? "Você não possui dependentes cadastrados."
              : " Você não possui outros casos de dependentes.");
        }

        return _listDependentes(dependentes);
      },
    );
  }

  _listDependentes(List dependetes) {
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      onRefresh: _onRefreshIndicatorAtivos,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: SizeConfig.marginBottom + 50),
        itemCount: dependetes.length,
        itemBuilder: (context, idx) {
          return DependentesCard(
            onClickDepenenteDetalhe: _onClickDependenteDetalhe,
            dependente: dependetes[idx],
          );
        },
      ),
    );
  }

  _buttonAddDependentes() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: SizeConfig.marginBottom),
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: AppButtonStream(
          onPressed: _onClickAddDependente,
          text: "ADICIONAR DEPENDENTE",
        ),
      ),
    );
  }

  _onClickAddDependente() async {
    if (!user.isPagamentoAtivoOuPreAtivo) {
      await showSimpleDialog(
          "Você precisa possuir um método de pagamento cadastrado para poder adicionar um dependente.");

      return;
    }

    bool agree = false;

    if (user.isPreAtivo) {
      await alertConfirm(
        context,
        "Para incluir um dependente, você deverá pagar sua primeira mensalidade de R\$100. Cada pessoa inclusa como dependente também gerará uma cobrança de R\$100/mês. Deseja continuar?",
        callbackSim: () {
          agree = true;
          pop();
        },
        callbackNao: () {
          agree = false;
          pop();
        },
        sim: "SIM",
        nao: "NÃO",
      );

      if (agree) {
        bool ativado = await _onClickAtivarConta();

        if (!ativado) {
          showSimpleDialog(
              "Não foi possível ativar sua conta, entre em contato com o nosso suporte contato@dandelin.io");
          agree = false;
        }
      }
    } else {
      await alertConfirm(
        context,
        "As mensalidades do dependente incluso serão cobradas no cartão de crédito cadastrado na sua conta do dandelin.",
        callbackSim: () {
          agree = true;
          pop();
        },
        callbackNao: () {
          agree = false;
          pop();
        },
        nao: "VOLTAR",
        sim: "SEGUIR",
      );
    }

    if (!agree) {
      return;
    }

    alertConfirm(
      context,
      "Seu dependente já é cliente Dandelin?",
      callbackSim: _onClickSim,
      callbackNao: _onClickCadastrarDependente,
      nao: "NÃO",
      sim: "SIM",
    );
  }

  _onClickSim() async {
    pop();
    bool v = await push(DependentesDetalhePage());
    if (v != null && v) {
      refreshLists();
    }
  }

  _onClickCadastrarDependente() async {
    pop();
    await push(PreCadastroPage(isDependente: true));

    refreshLists();
  }

  _onClickDependenteDetalhe(Dependente dependente) async {
    bool v = await push(DependentesDetalhePage(dependente: dependente));
    if (v != null && v) {
      refreshLists();
    }
  }

  Future _onRefreshIndicatorAtivos() async {
    _bloc.fetch(true);
  }

  _onClickAtivarConta() async {
    loadingDialog(context, msg: "Estamos validando sua conta.");

    ApiResponse response = await _bloc.ativarConta();

    pop();

    return response.ok;
  }

  refreshLists() {
    _bloc.fetch(true);
    _bloc.fetch(false);
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
    _tabController.dispose();
  }
}
