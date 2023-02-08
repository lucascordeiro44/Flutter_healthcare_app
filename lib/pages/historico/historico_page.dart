import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/biling.dart';
import 'package:flutter_dandelin/model/exam.dart';
import 'package:flutter_dandelin/pages/historico/historico_bloc.dart';
import 'package:flutter_dandelin/pages/historico/historico_card.dart';
import 'package:flutter_dandelin/pages/historico/historico_detalhe_page.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/scroll.dart';
import 'package:flutter_dandelin/widgets/app_bar.dart';
import 'package:flutter_dandelin/widgets/center_text.dart';
import 'package:flutter_dandelin/widgets/progress.dart';

class HistoricoPage extends StatefulWidget {
  @override
  _HistoricoPageState createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage>
    with SingleTickerProviderStateMixin {
  final _bloc = HistoricoBloc();

  final _agendamentosScrollController = ScrollController();
  final _pagamentosScrollController = ScrollController();

  TabController _tabController;
  @override
  void initState() {
    super.initState();
    screenView('Historico', "Tela Historico");

    _tabController = TabController(vsync: this, length: 2);
    _tabControllerListener();

    _bloc.fetch();

    addScrollListener(_agendamentosScrollController, _fecthMoreConsultas);
    addScrollListener(_pagamentosScrollController, _fetchMorePagamentos);
  }

  _tabControllerListener() {
    _tabController.addListener(() {
      _tabController.index == 0
          ? screenAction('historico_tab_agendamentos',
              'Clicou na Tab Agendamentos na tela de Historico')
          : screenAction('historico_tab_pagamentos',
              'Clicou na Tab Pagamentos na tela de Historico');

      _bloc.selectedBar.add(_tabController.index);
    });
  }

  void _fetchMorePagamentos() {
    _bloc.fetchMorePagamentos();
  }

  void _fecthMoreConsultas() {
    _bloc.fecthMoreConsultasExames();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: DandelinAppbar(
          "Histórico",
          iconThemeColor: AppColors.kPrimaryColor,
        ),
        body: _body(),
      ),
    );
  }

  _body() {
    return BaseContainer(
      child: Column(
        children: <Widget>[
          _appHeader(),
          _tabBar(),
          Divider(
            height: 0,
            color: Colors.black38,
          ),
          _tabBarView(),
        ],
      ),
    );
  }

  _appHeader() {
    return AppHeader(
      height: 200,
      image: 'assets/images/historico-background.png',
      child: Center(
        child: Image.asset(
          'assets/images/historico-icon-white.png',
          height: 100,
        ),
      ),
    );
  }

  _tabBar() {
    return StreamBuilder<Object>(
      stream: _bloc.selectedBar.stream,
      builder: (context, snapshot) {
        int tabSelected = snapshot.hasData ? snapshot.data : 0;
        return TabBar(
          onTap: (int v) {
            _bloc.selectedBar.add(v);
          },
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 5,
          labelPadding: EdgeInsets.symmetric(vertical: 0),
          labelStyle: TextStyle(fontSize: 16, fontFamily: 'Mark Book'),
          tabs: [
            Container(
              height: 54,
              width: double.infinity,
              child: Tab(text: "Agendamentos"),
              decoration: BoxDecoration(
                color:
                    tabSelected == 0 ? Color.fromRGBO(240, 240, 240, 1) : null,
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
              color: tabSelected == 1 ? Color.fromRGBO(240, 240, 240, 1) : null,
              child: Tab(text: "Pagamentos"),
            ),
          ],
        );
      },
    );
  }

  _tabBarView() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _streamConsultas(),
          _streamPagamentos(),
        ],
      ),
    );
  }

  _streamConsultas() {
    return StreamBuilder(
      stream: _bloc.consultasExames.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CenterText(snapshot.error);
        }

        if (!snapshot.hasData) {
          return Progress();
        }

        return snapshot.data.length > 0
            ? _listConsultas(snapshot.data)
            : CenterText(
                "Você não possui histórico de consultas.",
                fontWeight: FontWeight.w400,
              );
      },
    );
  }

  _listConsultas(List<dynamic> data) {
    return ListView.builder(
      controller: _agendamentosScrollController,
      itemCount: data.length + 1,
      padding: EdgeInsets.only(left: 15, bottom: 20),
      itemBuilder: (context, idx) {
        if (data.length != idx) {
          var consultaExame = data[idx];
          return HistoricoCard(
            consulta: consultaExame is Consulta ? consultaExame : null,
            exam: consultaExame is Exam ? consultaExame : null,
            onClickHistoricoDetalhe: _onClickHistoricoDetalhe,
          );
        } else {
          return StreamBuilder(
            stream: _bloc.consultasExames.loading.stream,
            builder: (context, snapshot) {
              bool v = snapshot.hasData ? snapshot.data : false;

              return v
                  ? Container(
                      height: 60,
                      child: Progress(),
                    )
                  : SizedBox();
            },
          );
        }
      },
    );
  }

  _streamPagamentos() {
    return StreamBuilder(
      stream: _bloc.pagamentos.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CenterText(snapshot.error);
        }

        if (!snapshot.hasData) {
          return Progress();
        }

        return snapshot.data.length > 0
            ? _listPagamentos(snapshot.data)
            : CenterText(
                "Você não possui pagamentos registrados.",
                fontWeight: FontWeight.w400,
              );
      },
    );
  }

  _listPagamentos(List<Biling> data) {
    return ListView.builder(
      controller: _pagamentosScrollController,
      itemCount: data.length,
      padding: EdgeInsets.only(left: 15, bottom: 20),
      itemBuilder: (context, idx) {
        if (data.length != idx) {
          return HistoricoCard(
            biling: data[idx],
            onClickHistoricoDetalhe: _onClickHistoricoDetalhe,
          );
        } else {
          return StreamBuilder(
            stream: _bloc.pagamentos.loading.stream,
            builder: (context, snapshot) {
              bool v = snapshot.hasData ? snapshot.data : false;
              return v
                  ? Container(
                      height: 60,
                      child: Progress(),
                    )
                  : SizedBox();
            },
          );
        }
      },
    );
  }

  _onClickHistoricoDetalhe(dynamic consultaOuExame) async {
    dynamic map = consultaOuExame.toGA() as Map<String, dynamic>;
    screenAction('historico_agendamento',
        'Na lista de agendamentos, clicou no Agendamento',
        param: map);

    var value = await push(
      HistoricoDetalhePage(
        consultaOuExame: consultaOuExame,
      ),
    );

    if (value != null) {
      _bloc.fetch(setNull: true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
    _agendamentosScrollController.dispose();
    _tabController.dispose();
    _pagamentosScrollController.dispose();
  }
}
