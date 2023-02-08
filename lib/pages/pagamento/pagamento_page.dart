import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/pagamento.dart';
import 'package:flutter_dandelin/pages/pagamento/pagamento_bloc.dart';
import 'package:flutter_dandelin/pages/pagamento/pagamento_card.dart';
import 'package:flutter_dandelin/pages/pagamento/pagamento_detalhe_page.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/center_text.dart';

class PagamentoPage extends StatefulWidget {
  @override
  _PagamentoPageState createState() => _PagamentoPageState();
}

class _PagamentoPageState extends State<PagamentoPage> {
  final _bloc = PagamentoBloc();

  User get user => appBloc.user;

  @override
  void initState() {
    super.initState();

    screenView("Pagamento", "Tela Pagamento");
    _bloc.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text("Pagamento"),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _body(),
    );
  }

  _body() {
    return BaseContainer(
      child: Column(
        children: <Widget>[
          _appHeader(),
          _titleContainer(),
          _listMetodos(),
        ],
      ),
    );
  }

  _appHeader() {
    return AppHeader(
      height: 200,
      image: 'assets/images/pagamento-background.png',
      child: Center(
        child: Image.asset(
          'assets/images/pagamento-icon-white.png',
          height: 90,
        ),
      ),
    );
  }

  _titleContainer() {
    return Container(
      height: 50,
      color: Color.fromRGBO(246, 246, 246, 1),
      padding: EdgeInsets.only(left: 20, bottom: 5),
      alignment: Alignment.bottomLeft,
      child: AppText(
        "MÉTODOS DE PAGAMENTO",
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  _listMetodos() {
    return Expanded(
      child: StreamBuilder<List<Pagamento>>(
        stream: _bloc.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return CenterText(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return Progress();
          }

          if (snapshot.data.length == 0) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Text("Você não possui método de pagamento cadastrado."),
                  _addButton(true, false),
                ],
              ),
            );
          }

          return _listCartoes(snapshot.data);
        },
      ),
    );
  }

  _listCartoes(List<Pagamento> list) {
    return ListView.separated(
      itemCount: list.length + 1,
      itemBuilder: (context, idx) {
        if (list.length != idx) {
          return PagamentoCard(
            pagamento: list[idx],
            onClickPagamentoDetalhe: _onClickPagamentoDetalhe,
            showDeletarButton: true,
            moreThanOnePayment: list.length > 1,
          );
        } else {
          return _addButton(list.length == 0 ? true : false, list.length >= 1);
        }
      },
      separatorBuilder: (context, idx) {
        return Divider(height: 0);
      },
    );
  }

  _addButton(bool mainPagamento, bool moreThanOnePayment) {
    return ListTile(
      onTap: () {
        _onClickPagamentoDetalhe(
          null,
          mainPagamento: mainPagamento,
          moreThanOnePayment: moreThanOnePayment,
        );
      },
      contentPadding: EdgeInsets.symmetric(
        vertical: 5,
        horizontal: moreThanOnePayment ? 16 : 0,
      ),
      title: Text(
        "Adicionar método de pagamento",
        style: TextStyle(
          color: Color.fromRGBO(3, 191, 236, 1),
          fontSize: 14,
        ),
      ),
    );
  }

  _onClickPagamentoDetalhe(Pagamento pagamento,
      {bool mainPagamento, bool moreThanOnePayment}) async {
    bool accept = true;

    if (user.isDependente) {
      await alertConfirm(
        context,
        "Ao incluir um método de pagamento, o seu titular ${user.parent.name}, não pagará mais a mensalidade do dandelin. Deseja continuar?",
        callbackSim: () {
          accept = true;
          pop();
        },
        callbackNao: () {
          accept = false;
          pop();
        },
      );
    }

    if (!accept) {
      return;
    }

    bool v = await push(
      PagamentoDetalhePage(
        pagamento: pagamento,
        mainPagamento: mainPagamento,
        moreThanOnePayment: moreThanOnePayment,
      ),
    );

    if (v != null && v) {
      _bloc.refresh();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }
}
