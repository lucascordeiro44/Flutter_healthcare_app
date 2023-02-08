import 'package:flutter/material.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/progress.dart';

import 'package:flutter_dandelin/pages/precos/alerta_preco.dart';
import 'package:flutter_dandelin/pages/precos/alerta_preco_bloc.dart';

class AlertaDePrecos extends StatefulWidget {
  @override
  _AlertaDePrecosState createState() => _AlertaDePrecosState();
}

class _AlertaDePrecosState extends State<AlertaDePrecos> {
  final _bloc = AlertaPrecoBloc();

  @override
  void initState() {
    super.initState();
    screenView("Alerta_Precos", "Tela Alerta_Precos");
    _bloc.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text(
          "Alerta de preços",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _body(),
    );
  }

  _body() {
    return BaseContainer(
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _appHeader(),
              _stream(),
              Divider(height: 0, color: AppColors.greyFont),
              Container(height: 40, color: Colors.white),
            ],
          ),
          _button(),
        ],
      ),
    );
  }

  _appHeader() {
    return AppHeader(
      height: SizeConfig.screenHeight * 0.3,
      image: 'assets/images/alerta-precos-backround.png',
      child: Center(
        child: Image.asset(
          'assets/images/alerta-precos.png',
          height: 100,
          color: Colors.white,
        ),
      ),
    );
  }

  _stream() {
    return StreamBuilder<List<AlertaPreco>>(
      stream: _bloc.controller.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Expanded(child: Center(child: Progress()));
        }

        List<AlertaPreco> alertas = snapshot.data;
        if (isEmptyList(alertas)) {
          return Center(
            child: Text(
              "Sem alertas",
              style: TextStyle(
                  color: Color.fromARGB(255, 148, 148, 148), fontSize: 24),
            ),
          );
        }
        return Expanded(child: _list(alertas));
      },
    );
  }

  _list(List<AlertaPreco> alertas) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: alertas.length,
      itemBuilder: (context, index) {
        AlertaPreco p = alertas[index];
        return _item(p);
      },
    );
  }

  _item(AlertaPreco p) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "R\$ ${p.preco.round()}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 148, 148, 148),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 5,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: <Widget>[
                AppText(
                  p.alerta,
                  textOverflow: TextOverflow.ellipsis,
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(width: 10),
                AppText(
                  p.data,
                  textOverflow: TextOverflow.ellipsis,
                  fontSize: 14,
                  color: Color.fromARGB(255, 148, 148, 148),
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Align _button() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: AppButtonStream(
          text: "CRIAR ALERTA",
          onPressed: () => _onClickCriarAlerta(),
        ),
      ),
    );
  }

  _onClickCriarAlerta() {}

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }
}
