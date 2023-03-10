import 'package:flutter/cupertino.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/biling.dart';
import 'package:flutter_dandelin/model/pagamento.dart';
import 'package:flutter_dandelin/pages/pagamento/pagamento_detalhe_bloc.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_bar.dart';

class PagamentoDetalhePage extends StatefulWidget {
  final Pagamento pagamento;
  final bool mainPagamento;
  final bool moreThanOnePayment;

  const PagamentoDetalhePage({
    Key key,
    @required this.pagamento,
    this.mainPagamento,
    this.moreThanOnePayment,
  }) : super(key: key);
  @override
  _PagamentoDetalhePageState createState() =>
      _PagamentoDetalhePageState(this.pagamento);
}

class _PagamentoDetalhePageState extends State<PagamentoDetalhePage> {
  final Pagamento pagamento;

  _PagamentoDetalhePageState(this.pagamento);

  final _bloc = PagamentoDetalheBloc();

  final _nameFn = FocusNode();
  final _numberFn = FocusNode();
  final _dataValidFn = FocusNode();
  final _ccvFn = FocusNode();

  var _numberController;
  final _dataValidController = MaskedTextController(mask: '00/00');
  final _ccvController = MaskedTextController(mask: '0000');

  Pagamento _pagamento;

  bool enabledButton = true;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get isPagamentoNotNull => pagamento != null;
  bool get isMainPayment => widget.pagamento != null && widget.pagamento.isMain;

  @override
  void initState() {
    super.initState();
    screenView("Pagamento_Detalhe", "Tela Pagamento_Detalhe");

    if (pagamento == null) {
      _pagamento = Pagamento();
      _numberController = MaskedTextController(mask: '0000 0000 0000 0000');
    } else {
      _pagamento = Pagamento(
        ccv: pagamento.ccv,
        dataValidade: pagamento.dataValidade,
        creditor: pagamento.creditor,
        id: pagamento.id,
        main: pagamento.main,
        month: pagamento.month,
        name: pagamento.name,
        number: pagamento.number,
        year: pagamento.year,
      );
      _numberController = MaskedTextController(mask: '**** **** **** 0000');
      _numberController.text = _pagamento.number;
      _dataValidController.text = _pagamento.dataValidade;
      _ccvController.text = _pagamento.ccv;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: DandelinAppbar(
        _pagamento.creditor != null
            ? _pagamento.creditor
            : "Detalhes do pagamento",
        iconThemeColor: Theme.of(context).primaryColor,
      ),
      body: _body(),
    );
  }

  _body() {
    return LayoutBuilder(
      builder: (context, constraint) {
        return BaseContainer(
          needSingleChildScrollView: true,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraint.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _appHeader(),
                  Expanded(
                    flex: 3,
                    child: _inputsColumn(),
                  ),
                  _buttonColumn(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _appHeader() {
    return Image.asset('assets/images/pagamento-background-mini.png');
  }

  _inputsColumn() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _titleText(),
          _inputNome(),
          _inputNumeroCartao(),
          _inputDataValidade(),
          _inputCCV(),
          SizedBox(height: 10),
          isPagamentoNotNull
              ? isMainPayment
                  ? Text("Este ?? o cart??o de pagamento")
                  : SizedBox(height: 5)
              : widget.moreThanOnePayment
                  ? Text("Cart??o principal")
                  : SizedBox(),
          !isPagamentoNotNull && widget.moreThanOnePayment
              ? _switch()
              : SizedBox(),
        ],
      ),
    );
  }

  _titleText() {
    return isPagamentoNotNull
        ? Container()
        : Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Voc?? pode mudar a qualquer momento na configura????o de pagamento",
            ),
          );
  }

  _inputNome() {
    return AppFormField(
      labelText: "Nome do titular",
      initialValue: isPagamentoNotNull ? _pagamento.name : null,
      focusNode: _nameFn,
      textCapitalization: TextCapitalization.words,
      enabled: !isPagamentoNotNull,
      onChanged: (String value) {
        _pagamento.name = value;
        _updateForm();
      },
      onFieldSubmitted: (_) {
        fieldFocusChangeFunction(context, _nameFn, _numberFn);
      },
    );
  }

  _inputNumeroCartao() {
    return AppFormField(
      textInputType: TextInputType.number,
      controller: _numberController,
      inputFormatterrs: [LengthLimitingTextInputFormatter(19)],
      labelText: "N??mero do cart??o",
      focusNode: _numberFn,
      enabled: !isPagamentoNotNull,
      onChanged: (String value) {
        print(value.length);
        _pagamento.number = value;
        _updateForm();
      },
      onFieldSubmitted: (_) {
        fieldFocusChangeFunction(context, _numberFn, _dataValidFn);
      },
    );
  }

  _inputDataValidade() {
    return AppFormField(
      textInputType: TextInputType.number,
      controller: _dataValidController,
      inputFormatterrs: [LengthLimitingTextInputFormatter(5)],
      labelText: "Data de validade",
      focusNode: _dataValidFn,
      enabled: !isPagamentoNotNull,
      onChanged: (String value) {
        _pagamento.dataValidade = value;
        _updateForm();
      },
      onFieldSubmitted: (_) {
        fieldFocusChangeFunction(context, _dataValidFn, _ccvFn);
      },
    );
  }

  _inputCCV() {
    return AppFormField(
      textInputType: TextInputType.number,
      labelText: "CCV",
      focusNode: _ccvFn,
      inputFormatterrs: [LengthLimitingTextInputFormatter(4)],
      controller: _ccvController,
      enabled: !isPagamentoNotNull,
      onChanged: (String value) {
        _pagamento.ccv = value;
        _updateForm();
      },
    );
  }

  _switch() {
    return CupertinoSwitch(
      value: _pagamento.main == "1" ? true : false,
      onChanged: isPagamentoNotNull
          ? null
          : (value) {
              setState(() {
                _pagamento.main = value ? "1" : "0";
              });
            },
      activeColor: Theme.of(context).primaryColor,
    );
  }

  _buttonColumn() {
    return isPagamentoNotNull ? _buttonComCartao() : _buttonSemCartao();
  }

  _buttonComCartao() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            pagamento.isMain ? SizedBox() : _editarButton(),
            Divider(height: 0),
            _excluirButton(),
            Divider(height: 0),
          ],
        ),
      ),
    );
  }

  _editarButton() {
    return StreamBuilder(
      initialData: true,
      stream: _bloc.buttonEnable.stream,
      builder: (context, snapshot) {
        return FlatButton(
          textColor: Color.fromRGBO(3, 191, 236, 1),
          disabledTextColor: Colors.grey,
          padding: EdgeInsets.symmetric(horizontal: 0),
          onPressed: snapshot.data ? _onClickTornarCartaoPrincipal : null,
          child: Text(
            "Tornar este o cart??o de pagamento",
          ),
        );
      },
    );
  }

  _excluirButton() {
    return StreamBuilder(
      initialData: true,
      stream: _bloc.buttonEnable.stream,
      builder: (context, snapshot) {
        return FlatButton(
          disabledTextColor: Colors.grey,
          padding: EdgeInsets.symmetric(horizontal: 0),
          onPressed: snapshot.data ? _onClickExcluirMetodoPagamento : null,
          child: Text(
            "Excluir m??todo de pagamento",
            style: TextStyle(
              color:
                  snapshot.data ? Color.fromRGBO(255, 85, 78, 1) : Colors.grey,
            ),
          ),
        );
      },
    );
  }

  _buttonSemCartao() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.marginBottom),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: AppButtonStream(
        text: "SALVAR",
        onPressed: _onClickSalvar,
        stream: _bloc.button.stream,
      ),
    );
  }

  _onClickSalvar() async {
    screenAction('salvar_cartao', 'Clicou em salvar Cart??o');
    if (_checkDataValidade()) {
      widget.moreThanOnePayment
          ? _submitCartao()
          : _showDialogConfirmarMetodoPagamento();
    } else {
      showSimpleDialog(
        'Data de validade inv??lida. Por favor, verifique.',
      );
      _dataValidFn.requestFocus();
    }
  }

  Future _showDialogConfirmarMetodoPagamento() async {
    alertConfirm(
      context,
      widget.pagamento == null
          ? "Ao inserir os dados do seu cart??o de cr??dito, voc?? passar?? a fazer parte do pagamento mensal e poder?? agendar quantas consultas quiser. Lembre-se, o valor da assinatura mensal ?? R\$100, cobrado todo primeiro dia do m??s."
          : "Seu cart??o ser?? alterado assim que for validado um novo cart??o.",
      nao: "Cancelar",
      sim: "Concluir",
      callbackNao: () {
        pop();
      },
      callbackSim: () {
        _checkPendings();
        pop();
      },
    );
  }

  _checkPendings() async {
    ApiResponse response = await _bloc.checkPendings();

    if (response.ok) {
      if (response.result == null) {
        _submitCartao();
      } else {
        Biling biling = response.result;
        _showPendingDialog(biling.price);
      }
    } else {
      showSimpleDialog(response.msg);
    }
  }

  _showPendingDialog(num value) {
    String v = value.toString().replaceAll('.', ',');

    alertConfirm(
      context,
      "Voc?? possui um pagamento pendente de meses anteriores no valor de R\$$v. "
      "Para voltar ?? comunidade e continuar tendo acesso aos m??dicos dandelin, o valor pendente ser?? cobrado assim que seu cadastro for reativado e o cart??o de cr??dito for validado. "
      "Lembre-se que voc?? tamb??m voltar?? a pagar a mensalidade normalmente.Tem certeza que deseja reativar sua conta?",
      nao: "Cancelar",
      sim: "Confirmar",
      callbackNao: () {
        pop();
      },
      callbackSim: () {
        _submitCartao();
        pop();
      },
    );
  }

  _submitCartao() async {
    ApiResponse response = await _save();

    if (response.ok) {
      pop(result: true);
    } else {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      showSimpleDialog(response.msg);
    }
  }

  _onClickTornarCartaoPrincipal() {
    screenAction(
        'alterar_cartao_principal', 'Clicou em alterar cart??o principal');
    alertConfirm(
      context,
      "Deseja mesmo tornar esse o cart??o de pagamento?",
      callbackSim: _onClickConfirmarTrocaPrincipal,
      callbackNao: () => pop(),
    );
  }

  _onClickConfirmarTrocaPrincipal() async {
    pop();
    _showSnackBar("Salvando altera????o");

    ApiResponse response =
        await _bloc.mudarParaPrincipal(pagamento..main = "1");

    response.ok ? pop(result: true) : showSimpleDialog(response.msg);
  }

  _onClickExcluirMetodoPagamento() async {
    screenAction('excluir_cartao', 'Clicou em excluir cart??o');
    if (pagamento.isMain) {
      if (widget.moreThanOnePayment) {
        showSimpleDialog(
            "Para excluir o cart??o habilitado para pagamento, voc?? deve antes excluir os outros cart??es secund??rios cadastrados no aplicativo." +
                " Se prefere habilitar outro cart??o para pagamento, entre na tela de detalhes do cart??o desejado e configure este como habilitado para pagamento.");
      } else {
        alertConfirm(
          context,
          "Ao excluir este cart??o voc?? ficar?? sem meio de pagamento no aplicativo, portanto, n??o poder?? mais fazer consultas." +
              " Qualquer consulta pr??-agendada ser?? cancelada. Para usar novamente o aplicativo ser?? necess??rio cadastrar um novo cart??o",
          callbackSim: _deletar,
          callbackNao: () => pop(),
        );
      }
    } else {
      alertConfirm(
        context,
        "Deseja mesmo excluir esse cart??o?",
        callbackSim: _deletar,
        callbackNao: () => pop(),
      );
    }
  }

  _deletar() async {
    pop();
    _showSnackBar("Deletando forma de pagamento..");
    ApiResponse response = await _bloc.excluir(_pagamento);

    response.ok ? pop(result: true) : showSimpleDialog(response.msg);
  }

  _save() async {
    if (widget.mainPagamento != null && _pagamento.main == null) {
      _pagamento.main = widget.mainPagamento ? "1" : "0";
    }

    return await _bloc.salvar(_pagamento);
  }

  _checkDataValidade() {
    var array = _pagamento.dataValidade.split('/');
    var now = DateTime.now();

    var month = now.month;
    var year = int.parse(
        now.year.toString().substring(now.year.toString().length - 2));

    if (int.parse(array[0]) >= 13) {
      return false;
    }

    if (int.parse(array[1]) < year) {
      return false;
    }

    if (int.parse(array[0]) < month && int.parse(array[1]) <= year) {
      return false;
    }

    return true;
  }

  _updateForm() {
    _bloc.updateForm(_pagamento);
  }

  _showSnackBar(String msg) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: Duration(seconds: 30),
        content: Container(
          height: 40,
          child: Row(
            children: <Widget>[
              Progress(),
              SizedBox(width: 10),
              Text(msg),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    _ccvFn.dispose();
    _nameFn.dispose();
    _numberFn.dispose();
    _dataValidFn.dispose();
    _numberController.dispose();
    _dataValidController.dispose();
    _ccvController.dispose();
    super.dispose();
  }
}
