import 'package:flutter/material.dart';
import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/model/discount.dart';
import 'package:flutter_dandelin/pages/cupom_desconto/cupom_desconto_bloc.dart';
import 'package:flutter_dandelin/pages/cupons_aplicados/cupon_card.dart';
import 'package:flutter_dandelin/pages/home/home_page.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/nav.dart';
import 'package:flutter_dandelin/utils/scroll.dart';
import 'package:flutter_dandelin/utils/validators.dart';
import 'package:flutter_dandelin/widgets/app_button.dart';
import 'package:flutter_dandelin/widgets/app_form_field.dart';
import 'package:flutter_dandelin/widgets/app_header.dart';
import 'package:flutter_dandelin/widgets/app_layout_builder.dart';
import 'package:flutter_dandelin/widgets/app_text.dart';
import 'package:flutter_dandelin/widgets/center_text.dart';
import 'package:flutter_dandelin/widgets/dialogs.dart';
import 'package:flutter_dandelin/widgets/progress.dart';
import '../../firebase.dart';
import 'cupom.dart';
import 'cupons_aplicados_bloc.dart';

class CuponsAplicadosPage extends StatefulWidget {
  @override
  _CuponsAplicadosPageState createState() => _CuponsAplicadosPageState();
}

class _CuponsAplicadosPageState extends State<CuponsAplicadosPage>  with SingleTickerProviderStateMixin {
  final _bloc = CuponsAplicadosBloc();
  final _blocDesconto = CupomDescontoBloc();
  final _cuponsAplicadosController = ScrollController();
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    screenView('Cupom', "Tela Cupom");
    _tabController = TabController(vsync: this, length: 2);
    _tabControllerListener();
    _bloc.fetch();
    addScrollListener(_cuponsAplicadosController, _fetchMoreCuponsAplicados);
  }

  _tabControllerListener() {
    _tabController.addListener(() {
      _tabController.index == 0
          ? screenAction('cupom_desconto', 'Clicou na Tab Cupom de desconto')
          : screenAction('cupom_aplicado', 'Clicou na Tab Cupom aplicados');

      _bloc.selectedBar.add(_tabController.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text("Cupons"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _body(),
    );
  }

  _fetchMoreCuponsAplicados() {
    _bloc.fetchMoreCuponsAplicados();
  }

  _body() {
    return Column(
      children: [
        _imageHeader(),
        _tabBar(),
        Divider(
          height: 0,
          color: Colors.black38,
        ),
        _tabBarView(),
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
          'assets/images/cupom-icone.png',
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
              child: Tab(text: "Cupom de desconto"),
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
              child: Tab(text: "Cupons aplicados"),
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
          _inserirCupom(),
          _listCupons(),
        ],
      ),
    );
  }

  _inserirCupom() {
    return AppLayoutBuilder(
      needSingleChildScrollView: true,
      child: Column(
        children: <Widget>[
          SizedBox(height: 30),
          AppText(
            'Insira código de cupom',
            fontFamily: 'Mark Book',
            color: AppColors.greyStrong,
          ),
          SizedBox(height: 30),
          _inputCupom(),
          _enviarCodigoButton(),
        ],
      ),
    );
  }

  _inputCupom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppFormField(
        isCircular: true,
        onChanged: (String value) {
          _blocDesconto.updateFrom(value);
        },
      ),
    );
  }

  _enviarCodigoButton() {
    return Expanded(
      child: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: AppButtonStream(
          stream: _blocDesconto.button.stream,
          onPressed: _onClickEnviarCodigo,
          text: 'ENVIAR CÓDIGO',
        ),
      ),
    );
  }

  _listCupons() {
    return StreamBuilder<List<Cupom>>(
        stream: _bloc.stream,
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return Progress();
          }

          if (snapshot.hasError) {
            return CenterText(snapshot.error);
          }

          List<Cupom> cuponsAplicados = snapshot.data;

          if (isEmptyList(cuponsAplicados)) {
            return CenterText("Você não possui cupons aplicados.");
          }

          return _listCuponsAplicatos(cuponsAplicados);
        });
  }

   _listCuponsAplicatos(List<Cupom> cuponsAplicados) {
    return ListView.separated(
      controller: _cuponsAplicadosController,
      itemCount: cuponsAplicados.length + 1,
      itemBuilder: (_, idx) {
        if(cuponsAplicados.length != idx){
          Cupom cupom = cuponsAplicados[idx];

          return _itemList(cupom);
        } else{
          return StreamBuilder(
            stream: _bloc.cuponsAplicados.loading.stream,
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
      separatorBuilder: (BuildContext context, int index) {
        return Divider(height: 0);
      },
    );
  }

  _itemList(Cupom cupom) {
    return CupomCard(
      leading: Image.asset(
        'assets/images/cupom-icone.png',
        height: 40,
        color: Colors.orange,
      ),
      cupom: cupom,
    );
  }

  _onClickEnviarCodigo() async {
    ApiResponse response = await _blocDesconto.sendInviteDiscount();

    response.ok
        ? await _showDiscountDialog(response.result)
        : showSimpleDialog(response.msg);
  }

  _showDiscountDialog(Discount discount) async {
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0),
          ),
          children: <Widget>[
            SizedBox(height: 20),
            AppText(
              "CUPOM VALIDADO",
              textAlign: TextAlign.center,
              color: Theme.of(context).primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: AppText(
                "Pronto! Agora você terá seu desconto de ${discount.discountFormatted} aplicado na próxima cobrança da mensalidade!",
                textAlign: TextAlign.center,
                color: AppColors.greyStrong,
                fontFamily: 'Mark Book',
              ),
            ),
            SizedBox(height: 5),
            _okButton(),
          ],
        );
      },
    );

    push(HomePage(), popAll: true, replace: true);
  }

  _okButton() {
    return FlatButton(
      padding: EdgeInsets.all(0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () {
        pop();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color.fromRGBO(255, 149, 82, 1),
              Color.fromRGBO(255, 173, 87, 1),
              Color.fromRGBO(255, 195, 90, 1),
            ],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
        ),
        height: 40,
        alignment: Alignment.center,
        width: double.infinity,
        child: AppText(
          "Ok! Entendi.",
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
    _cuponsAplicadosController.dispose();
  }
}
