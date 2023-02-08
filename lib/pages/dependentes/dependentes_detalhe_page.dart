import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dandelin/model/dependente.dart';
import 'package:flutter_dandelin/pages/dependentes/dependentes_detalhe_bloc.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/custom_checkbox.dart';
import 'package:flutter_dandelin/widgets/dialogs.dart';
import 'package:string_mask/string_mask.dart';

class DependentesDetalhePage extends StatefulWidget {
  final Dependente dependente;

  const DependentesDetalhePage({Key key, this.dependente}) : super(key: key);

  @override
  _DependentesDetalhePageState createState() => _DependentesDetalhePageState();
}

class _DependentesDetalhePageState extends State<DependentesDetalhePage> {
  final _bloc = DependentesDetalheBloc();
  final _controller = TextEditingController();

  bool get dependenteNull => widget.dependente == null;
  Dependente get dependente => widget.dependente;

  @override
  void initState() {
    super.initState();
    _bloc.init(dependente);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text(dependenteNull ? "Adicionar dependente" : "Dependente"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: dependenteNull ? _bodyDependenteNull() : _bodyDependente(),
    );
  }

  _appHeader() {
    return AppHeader(
      elevation: 0,
      height: 200,
      image: 'assets/images/dependentes-background.png',
      child: Center(
        child: dependenteNull
            ? Image.asset(
                'assets/images/dependentes-icon-white.png',
                height: 90,
              )
            : Column(
                children: [
                  AppCircleAvatar(
                    avatar: dependente.avatar,
                    assetAvatarNull: 'assets/images/dependente-icon.png',
                  ),
                  SizedBox(height: 5),
                  Expanded(
                    child: AutoSizeText(
                      dependente.dependentName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  //////////////////////////////////////// DEPENDENTE NULL

  _bodyDependenteNull() {
    return BaseContainer(
      needSingleChildScrollView: true,
      child: _columnNovoDependente(),
    );
  }

  _columnNovoDependente() {
    return Column(
      children: <Widget>[
        _appHeader(),
        Column(
          children: <Widget>[
            _inputCpfOuEmail(),
            Container(height: 20, color: Color.fromRGBO(240, 239, 244, 1)),
            SizedBox(height: 5),
            _inputNome(),
            SizedBox(height: 15),
            _labelError(),
            SizedBox(height: 20),
            _buttonAdicionarDependente(),
          ],
        )
      ],
    );
  }

  _inputCpfOuEmail() {
    return Container(
      padding: EdgeInsets.all(15),
      child: AppFormField(
        hintText: "Pesquise por CPF ou e-mail",
        isCircular: true,
        prefixIcon: Icon(Icons.search, color: Colors.black26),
        onChanged: _bloc.onChangedStream.add,
        suffixIcon: _iconSearch(),
      ),
    );
  }

  _iconSearch() {
    return StreamBuilder(
      stream: _bloc.iconSearch.stream,
      builder: (context, snapshot) {
        Color _primaryColor = Theme.of(context).primaryColor;

        if (snapshot.hasError) {
          return Icon(FontAwesomeIcons.times, size: 14, color: _primaryColor);
        } else if (!snapshot.hasData) {
          return Container(width: 30, child: Progress());
        } else if (snapshot.data) {
          return Icon(FontAwesomeIcons.check, size: 14, color: _primaryColor);
        } else {
          return SizedBox();
        }
      },
    );
  }

  _inputNome() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder(
        stream: _bloc.dependente.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            _controller.text = '';

            return Container(
              margin: EdgeInsets.only(top: 16),
              child: Text("Informe o CPF ou o e-mail do dependente"),
            );
          }

          User dependente = snapshot.data;
          _controller.text = dependente.getUserFullName;

          return StreamBuilder(
            stream: _bloc.button.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox();
              }

              ButtonState state = snapshot.data;

              bool value = state.enabled;
              bool sending = state.progress;

              return RawMaterialButton(
                onPressed: () {
                  if (sending) {
                    return;
                  }
                  _bloc.button.setEnabled(!value);
                },
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 12),
                      child: CustomCheckbox(
                        useTapTarget: false,
                        value: value,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (v) {
                          if (sending) {
                            return;
                          }
                          _bloc.button.setEnabled(!value);
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: AppFormField(
                        controller: _controller,
                        labelText: "Nome",
                        enabled: false,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  _labelError() {
    return StreamBuilder(
      stream: _bloc.errorMsg.stream,
      builder: (_, snapshot) {
        return snapshot.hasData
            ? Container(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: AppText(snapshot.data, textAlign: TextAlign.center),
              )
            : SizedBox();
      },
    );
  }

  _buttonAdicionarDependente() {
    return StreamBuilder(
      stream: _bloc.dependente.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }

        return StreamBuilder<ButtonState>(
          stream: _bloc.button.stream,
          builder: (context, snapshot) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
              alignment: Alignment.bottomCenter,
              child: AppButtonStream(
                onPressed: _onClickAddDependente,
                text: "ADICIONAR DEPENDENTE",
                stream: _bloc.button.stream,
              ),
            );
          },
        );
      },
    );
  }

  //////////////////////////// END DEPENDENTE NULL
  /////////////////////////// DEPENDENTE NOT NULL

  _bodyDependente() {
    return Column(
      children: [
        _appHeader(),
        Container(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(
            children: [
              _inputEmail(),
              SizedBox(height: 5),
              _inputCpf(),
              SizedBox(height: 5),
              _inputDataNascimento(),
            ],
          ),
        ),
        dependente.renviarConviteEnable
            ? _buttonReenviarConvite()
            : _buttonExcluirDependente(),
        SizedBox(height: SizeConfig.marginBottom)
      ],
    );
  }

  _inputEmail() {
    return AppFormField(
      labelText: "Email",
      enabled: false,
      initialValue: dependente.username,
    );
  }

  _inputCpf() {
    return AppFormField(
      labelText: "CPF",
      enabled: false,
      initialValue: dependente.document == null
          ? null
          : StringMask('000.000.000-00').apply(dependente.document),
    );
  }

  _inputDataNascimento() {
    return AppFormField(
      labelText: "Data de nascimento",
      enabled: false,
      initialValue: dependente.birthday?.replaceAll('-', '/'),
    );
  }

  _buttonReenviarConvite() {
    return _button(_onClickReenviarConvite, "REENVIAR CONVITE");
  }

  _buttonExcluirDependente() {
    return _button(
      _onClickExcluirDependente,
      "EXCLUIR DEPENDENTE",
      color: Colors.red,
    );
  }

  _button(Function onClick, String text, {Color color}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        alignment: Alignment.bottomCenter,
        child: AppButtonStream(
          color: color,
          onPressed: onClick,
          text: text,
          stream: _bloc.button.stream,
        ),
      ),
    );
  }

  /////////////////////////// END DEPENDENTE NOT NULL

  _onClickAddDependente() async {
    bool notificationToParent;

    await alertConfirm(
      context,
      "As notificações serão direcionadas para você ou para o dependente?",
      callbackSim: () {
        pop();
        notificationToParent = true;
      },
      callbackNao: () {
        pop();
        notificationToParent = false;
      },
      sim: "PARA MIM",
      nao: "PARA O DEPENDENTE",
    );

    if (notificationToParent == null) {
      return;
    }

    ApiResponse response = await _bloc.addDependente(notificationToParent);

    if (response.ok) {
      await showSimpleDialog(
          "Seu dependente foi incluido e notificado com sucesso! Assim que ele aceitar, aparecerá nesta área do aplicativo!",
          callBack: () {});

      pop(result: true);
    } else {
      showSimpleDialog(response.msg);
    }
  }

  _onClickExcluirDependente() async {
    bool excluir;

    await alertConfirm(
      context,
      "Deseja mesmo excluir este dependente?",
      callbackSim: () {
        pop();
        excluir = true;
      },
      callbackNao: () {
        pop();
        excluir = false;
      },
      sim: "SIM",
      nao: "NÃO",
    );

    if (excluir == null || !excluir) {
      return;
    }

    ApiResponse response = await _bloc.excluirDependente(dependente);

    response.ok ? pop(result: true) : showSimpleDialog(response.msg);
  }

  _onClickReenviarConvite() async {
    ApiResponse response = await _bloc.reenviarConvite(dependente);

    response.ok ? pop(result: true) : showSimpleDialog(response.msg);
  }

  // _showDialogCadastroEfetivado() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return CupertinoAlertDialog(
  //         title: Column(
  //           children: <Widget>[
  //             Image.asset('assets/images/check-imagem.png', height: 75),
  //             SizedBox(height: 15),
  //             Text("Cadastro efetivado!"),
  //           ],
  //         ),
  //         content: Text(
  //             "Estamos quase lá, só mais um passo simples! Mara recebeu um e-mail com uma chave de acesso, ela deve confirmar o cadastro para poder fazer parte da comunidade."),
  //         actions: <Widget>[
  //           CupertinoDialogAction(
  //             onPressed: () {
  //               pop();
  //             },
  //             child: Text("Ok, entendi!"),
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }
}
