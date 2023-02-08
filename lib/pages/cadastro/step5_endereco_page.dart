import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/address.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/cadastro/step6_comefrom_page.dart';
import 'package:flutter_dandelin/utils/clean_text.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import "package:flutter/cupertino.dart";
import 'package:flutter_dandelin/widgets/app_layout_builder.dart';

class EnderecoPage extends StatefulWidget {
  final bool isDependente;

  const EnderecoPage({Key key, this.isDependente}) : super(key: key);

  @override
  _EnderecoPageState createState() => _EnderecoPageState();
}

class _EnderecoPageState extends State<EnderecoPage> {
  final _bloc = EnderecoBloc();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _cepFn = FocusNode();
  final _ruaFn = FocusNode();
  final _numeroFn = FocusNode();
  final _complementoFn = FocusNode();
  final _cidadeFn = FocusNode();
  final _estadoFn = FocusNode();
  final _bairroFn = FocusNode();

  final _paisController = TextEditingController();
  final _cepController = MaskedTextController(mask: "00000-000");
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _neighborhoodController = TextEditingController();

  var _address = Address();

  final _sizedBox10 = SizedBox(height: 5);
  final _padding = EdgeInsets.symmetric(vertical: 7);

  bool _enableFileds = true;

  User get user => appBloc.user;
  User get dependente => appBloc.dependente;
  bool get isDependente => widget.isDependente ?? false;

  @override
  void initState() {
    super.initState();

    screenView("Cadastro_Step5_Endereco", "Tela Cadastro_Endereco");
    _paisController.text = "Brasil";
    _address.country = "Brasil";

    List<Address> address = isDependente != null && isDependente
        ? dependente.address
        : user.address;

    if (address != null) {
      Address _a = address[0];
      _cepController.text = _a.zipCode;
      _addressController.text = _a.address;
      _address.addressNumber = _a.addressNumber;
      _address.complement = _a.complement;
      _cityController.text = _a.city;
      _stateController.text = _a.state;
      _address = _a;
      _bloc.button.setEnabled(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(isIOS(context) ? Icons.chevron_left : Icons.arrow_back,
              size: isIOS(context) ? 40 : 24),
          onPressed: () {
            _onClickIconAppBar();
          },
        ),
      ),
      body: _body(),
    );
  }

  _body() {
    return AppLayoutBuilder(
      needSingleChildScrollView: true,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder(
        stream: _bloc.button.stream,
        builder: (context, snapshot) {
          //caso tiver em progress, deixa os campos disabled
          bool enable = snapshot.data == null ? true : !snapshot.data.progress;
//             bool enable = snapshot.data == null ? false : !snapshot.data.progress;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Hero(tag: 'mini-logo', child: MiniLogo5()),
              SizedBox(height: 30),
              _rowPergunta(),
              SizedBox(height: 30),
              _inputCep(enable),
              _sizedBox10,
              _inputRua(enable),
              _sizedBox10,
              Row(
                children: <Widget>[
                  _inputNumero(enable),
                  SizedBox(width: 20),
                  _inputComplemento(enable),
                ],
              ),
              _sizedBox10,
              _inputBairro(enable),
              _sizedBox10,
              _inputCidade(enable),
              Row(
                children: <Widget>[
                  _inputEstado(enable),
                  SizedBox(width: 20),
                  _inputPais(),
                ],
              ),
              Expanded(child: Container()),
              _button(),
            ],
          );
        },
      ),
    );
  }

  _rowPergunta() {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: AppText(
        isDependente
            ? dependente.isMale
                ? "Onde o depedente mora?"
                : "Onde a dependente mora?"
            : "Onde você mora?",
        fontSize: 28,
        color: AppColors.greyFont,
      ),
    );
  }

  _inputCep(bool enable) {
    return AppFormField(
      enabled: enable,
      contentPadding: _padding,
      focusNode: _cepFn,
      labelText: "CEP",
      controller: _cepController,
      //fontFamilyHint: "Mark Edit",
      textInputType: TextInputType.number,
      inputFormatterrs: [LengthLimitingTextInputFormatter(9)],
      onChanged: (String value) async {
        //para chamar só 1 vez
        if (value.length == 9 && _address.zipCode != cleanCep(value)) {
          _address.zipCode = cleanCep(value);
          _getCep(_address.zipCode);
        }

        _updateForm();
      },
      onFieldSubmitted: (_) {
        fieldFocusChangeFunction(context, _cepFn, _ruaFn);
      },
      suffixIcon: StreamBuilder(
        stream: _bloc.procurandoCep.stream,
        builder: (context, snapshot) {
          bool v = snapshot.hasData ? snapshot.data : false;
          return v
              ? Container(
                  height: 20,
                  width: 20,
                  child: Progress(),
                )
              : SizedBox();
        },
      ),
    );
  }

  _inputRua(bool enable) {
    return AppFormField(
      enabled: enable && _enableFileds,
      contentPadding: _padding,
      focusNode: _ruaFn,
      labelText: "rua",
      controller: _addressController,
      onChanged: (String value) {
        _address.address = value;
        _updateForm();
      },
      onFieldSubmitted: (_) {
        fieldFocusChangeFunction(context, _ruaFn, _numeroFn);
      },
      textCapitalization: TextCapitalization.words,
    );
  }

  _inputNumero(bool enable) {
    return Expanded(
      flex: 1,
      child: AppFormField(
        enabled: enable && _enableFileds,
        contentPadding: _padding,
        initialValue: _address.addressNumber,
        focusNode: _numeroFn,
        labelText: "número",
        //fontFamilyHint: "Mark Edit",
        onChanged: (String value) {
          _address.addressNumber = value;
          _updateForm();
        },
        onFieldSubmitted: (_) {
          fieldFocusChangeFunction(context, _numeroFn, _complementoFn);
        },
        textInputType: TextInputType.number,
      ),
    );
  }

  _inputComplemento(bool enable) {
    return Expanded(
      flex: 2,
      child: AppFormField(
        enabled: enable && _enableFileds,
        contentPadding: _padding,
        initialValue: _address.complement,
        focusNode: _complementoFn,
        //fontFamilyHint: "Mark Edit",
        labelText: "complemento",
        onChanged: (String value) {
          _address.complement = value;
          _updateForm();
        },
        onFieldSubmitted: (_) {
          fieldFocusChangeFunction(context, _complementoFn, _cidadeFn);
        },
      ),
    );
  }

  _inputCidade(bool enable) {
    return StreamBuilder<Object>(
      stream: _bloc.enableCityState.stream,
      builder: (context, snapshot) {
        bool enableCity = snapshot.hasData ? snapshot.data : true;
        return AppFormField(
          enabled: enable && enableCity && _enableFileds,
          contentPadding: _padding,
          controller: _cityController,
          focusNode: _cidadeFn,
          labelText: "cidade",
          onChanged: (String value) {
            _address.city = value;
            _updateForm();
          },
          onFieldSubmitted: (_) {
            fieldFocusChangeFunction(context, _cidadeFn, _estadoFn);
          },
          textCapitalization: TextCapitalization.words,
        );
      },
    );
  }

  _inputBairro(bool enable) {
    return AppFormField(
      enabled: enable && _enableFileds,
      contentPadding: _padding,
      focusNode: _bairroFn,
      labelText: "bairro",
      controller: _neighborhoodController,
      onChanged: (String value) {
        _address.neighborhood = value;
        _updateForm();
      },
      onFieldSubmitted: (_) {
        fieldFocusChangeFunction(context, _bairroFn, _estadoFn);
      },
      textCapitalization: TextCapitalization.words,
    );
  }

  _inputEstado(bool enable) {
    return StreamBuilder(
      stream: _bloc.enableCityState.stream,
      builder: (context, snapshot) {
        bool enableState = snapshot.hasData ? snapshot.data : true;

        return Expanded(
          flex: 1,
          child: AppFormField(
            enabled: enable && enableState && _enableFileds,
            inputFormatterrs: [LengthLimitingTextInputFormatter(2)],
            contentPadding: _padding,
            controller: _stateController,
            focusNode: _estadoFn,
            labelText: "estado",
            onChanged: (String value) {
              _address.state = value;
              _updateForm();
            },
            textCapitalization: TextCapitalization.characters,
          ),
        );
      },
    );
  }

  _inputPais() {
    return Expanded(
      flex: 2,
      child: AppFormField(
        contentPadding: _padding,
        labelText: "PAÍS",
        controller: _paisController,
        enabled: false,
      ),
    );
  }

  _button() {
    return StreamBuilder(
      stream: _bloc.button.stream,
      builder: (context, AsyncSnapshot<ButtonState> snapshot) {
        var btnState = snapshot.data;

        Function function = snapshot.hasData
            ? btnState.enabled
                ? _onClickProximo
                : null
            : null;

        return Container(
          margin: EdgeInsets.only(bottom: 15, right: 5, top: 15),
          child: NextButtonCadastro(
              needPositioned: false,
              function: function,
              icon: btnState != null && btnState.progress ? Progress() : null),
        );
      },
    );
  }

  _updateForm() {
    _address.address = _addressController.text;
    _address.city = _cityController.text;
    _address.state = _stateController.text;
    _address.neighborhood = _neighborhoodController.text;
    _bloc.button.setEnabled(_bloc.validate(_address));
  }

  _onClickProximo() async {
    if (!_bloc.validState(_address.state)) {
      showSimpleDialog("Insira um estádo brasileiro válido.");
      return;
    }

    isDependente ? await _cadastroDependente() : await _cadastroUser();
  }

  _cadastroUser() async {
    appBloc.setUser(user
      ..address = [_address]
      ..customerAt = dateTimeFormatHMS());

    ApiResponse response = await _bloc.cadastrar(user);

    response.ok
        ? push(HomePage(), replace: true, popAll: true)
        : showSimpleDialog(response.msg);
  }

  _cadastroDependente() async {
    appBloc.setDependente(dependente
      ..address = [_address]
      ..customerAt = dateTimeFormatHMS()
      ..parentId = user.id);

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

    //cadastrar o dependente
    ApiResponse response =
        await _bloc.cadastrarDependente(dependente, notificationToParent);

    if (response.ok) {
      await showSimpleDialog(
          "Seu dependente foi incluído com sucesso! Assim que ele ativar a conta, você verá na lista de seus dependentes.");

      pop();
      pop();
      pop();
      pop();
      pop();
      pop();
    } else {
      showSimpleDialog(response.msg);
    }
  }

  _onClickStep6() async {
    appBloc.setUser(
      user
        ..address = [_address]
        ..customerAt = dateTimeFormatHMS(),
    );

    push(CameFromPage());
  }

  _getCep(String zipCode) async {
    ApiResponse response = await _bloc.searchByCep(_address.zipCode);

    if (response.ok) {
      setState(() {
        _enableFileds = true;
      });

      Address a = response.result;

      if (a.address != null) {
        _addressController.text = a.address;
      }
      if (a.city != null) {
        _cityController.text = a.city;
      }
      if (a.state != null) {
        _stateController.text = a.state;
      }
      if (a.neighborhood != null) {
        _neighborhoodController.text = a.neighborhood;
      }
    } else {
      _addressController.clear();
      _cityController.clear();
      _stateController.clear();
      _neighborhoodController.clear();

      setState(() {
        _enableFileds = false;
      });

      showSimpleDialog(response.msg);
    }
  }

  _onClickIconAppBar() {
    isDependente
        ? appBloc.setDependente(dependente..address = [_address])
        : appBloc.setUser(user..address = [_address]);

    pop();
  }

  @override
  void dispose() {
    _bloc.dispose();
    _cepFn.dispose();
    _ruaFn.dispose();
    _numeroFn.dispose();
    _complementoFn.dispose();
    _cidadeFn.dispose();
    _estadoFn.dispose();
    _paisController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
