import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/confirmar_codigo/confirmar_codigo_page.dart';
import 'package:flutter_dandelin/pages/home/alterar_senha_page.dart';
import 'package:flutter_dandelin/pages/home/editar_perfil_bloc.dart';
import 'package:flutter_dandelin/utils/clean_text.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_circle_avatar.dart';
import 'package:flutter_dandelin/widgets/country_pick.dart';
import 'package:flutter_dandelin/widgets/custom_checkbox.dart';

class EditarPerfilPage extends StatefulWidget {
  @override
  _EditarPerfilPageState createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _bloc = EditarPerfilBloc();

  User get user => appBloc.user;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final _foneController = MaskedTextController(mask: "(00) 00000-0000");

  final _foneFocus = FocusNode();
  final _senhaFocus = FocusNode();

  bool emailChanged = false;
  String telefone;
  String ddi = "";
  String mobilePhone = "";

  String urlOld;

  @override
  void initState() {
    super.initState();
    screenView("Editar_Perfil", "Tela Editar_Pefil");
    urlOld = user.avatar;
    _foneController.text = user.tel?.length == 11 ? user.tel : user.telefone;
    _bloc.twoFactor.add(user.twoFactorAuthentication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        flexibleSpace: SafeArea(
          child: Container(
            height: double.maxFinite,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buttonHeader(
                  text: "Cancelar",
                  function: _onClickCancelar,
                  color: AppColors.greyFont,
                ),
                AppText("Editar perfil", fontSize: 18),
                _buttonHeader(
                  text: "Concluir",
                  function: _onClickConcluir,
                  color: AppColors.blueExame,
                ),
              ],
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _body(),
    );
  }

  _buttonHeader({String text, Function function, Color color}) {
    return FlatButton(
      padding: EdgeInsets.all(5),
      onPressed: function,
      child: AppText(text, color: color, fontWeight: FontWeight.w500),
    );
  }

  _body() {
    return Form(
      key: _formKey,
      child: BaseContainer(
        needSingleChildScrollView: true,
        child: Column(
          children: <Widget>[
            _appHeader(),
            Divider(height: 0, color: AppColors.greyFont),
            _appBody(),
          ],
        ),
      ),
    );
  }

  _appHeader() {
    return Container(
      constraints: BoxConstraints(
        minHeight: 210,
        minWidth: SizeConfig.screenWidth,
      ),
      color: Colors.grey.withOpacity(0.1),
      padding: EdgeInsets.only(bottom: 0, top: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _appAvatar(),
          SizedBox(height: 18),
          FlatButton(
            child: Text(
              "Alterar Foto do perfil",
              style: TextStyle(
                color: AppColors.blueExame,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => _onClickEditarFoto(),
          ),
        ],
      ),
    );
  }

  _appAvatar() {
    return StreamBuilder<Object>(
      stream: _bloc.temporaryPicture.stream,
      builder: (context, snapshot) {
        return Hero(
          tag: 'appCircleAvatar',
          child: AppCircleAvatar(
            avatar: snapshot.hasData ? null : user.avatar,
            assetAvatarNull: snapshot.hasData
                ? snapshot.data
                : 'assets/images/without-avatar.png',
            dafaultImage: !snapshot.hasData,
          ),
        );
      },
    );
  }

  _appBody() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          _inputEmail(),
          _inputTelefone(),
          SizedBox(height: 10),
          _twoFactor(),
          _inputSenha(),
        ],
      ),
    );
  }

  _inputEmail() {
    return AppFormField(
      labelText: "E-mail",
      initialValue: user.username,
      textInputType: TextInputType.emailAddress,
      onSaved: (String value) {
        emailChanged = user.username == value ? false : true;
        user.username = value;
      },
    );
  }

  _inputTelefone() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CountryPick(
          initialSelection: user.ddi.contains("+") ? user.ddi : "+55",
          onChanged: _onChangedCountry,
        ),
        Expanded(
          child: AppFormField(
            labelText: "Telefone",
            controller: _foneController,
            textInputType: TextInputType.phone,
            inputFormatterrs: [LengthLimitingTextInputFormatter(15)],
            focusNode: _foneFocus,
            onFieldSubmitted: (_) {
              fieldFocusChangeFunction(context, _foneFocus, _senhaFocus);
            },
            validator: (String value) {
              if (value == null || value == "") {
                return 'Campo necessário';
              }
              return null;
            },
            onSaved: (String value) {
              //caso mudar, fica invalido

              mobilePhone = cleanTelefone(value);
              telefone = (ddi.isEmpty ? user.ddi : ddi) + cleanTelefone(value);

              user.telefoneValido = user.tel != null
                  ? cleanTelefone(telefone) == cleanTelefone(user.mobilePhone)
                  : false;
            },
          ),
        ),
      ],
    );
  }

  _twoFactor() {
    return StreamBuilder(
      initialData: false,
      stream: _bloc.twoFactor.stream,
      builder: (context, snapshot) {
        bool data = snapshot.data ?? false;
        return RawMaterialButton(
          onPressed: () => _onClickTwoFactor(!data),
          child: Row(
            children: [
              CustomCheckbox(
                activeColor: Theme.of(context).primaryColor,
                value: data,
                onChanged: (v) => _onClickTwoFactor(!data),
              ),
              Expanded(
                child: AppText(
                  "Desejo habilitar autenticação de dois fatores.",
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  _onClickTwoFactor(bool v) {
    _bloc.twoFactor.add(v);
  }

  _inputSenha() {
    return FlatButton(
      onPressed: () {
        _onClickAlterarSenha();
      },
      child: AppText(
        "Alterar Senha",
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  _onClickEditarFoto() {
    bool ios = Theme.of(context).platform == TargetPlatform.iOS;
    return showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder(
          stream: _bloc.saving.stream,
          builder: (context, snapshot) {
            bool data = snapshot.hasData ? snapshot.data : false;

            Widget carregando = Container(
              height: 150,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(height: 100, child: Progress()),
                  SizedBox(height: 10),
                  Text("Carregando foto"),
                ],
              ),
            );

            return ios
                ? CupertinoAlertDialog(
                    content: !data
                        ? Column(
                            children: <Widget>[
                              _buttonCupertino(
                                text: "Galeria",
                                function: _onClickGaleria,
                              ),
                              Divider(),
                              _buttonCupertino(
                                text: "Camera",
                                function: _onClickFotoCamera,
                              ),
                            ],
                          )
                        : carregando,
                  )
                : AlertDialog(
                    content: !data
                        ? Flex(
                            direction: Axis.vertical,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _buttonAndroid(
                                text: "Galeria",
                                function: _onClickGaleria,
                              ),
                              _buttonAndroid(
                                text: "Camera",
                                function: _onClickFotoCamera,
                              ),
                            ],
                          )
                        : carregando,
                  );
          },
        );
      },
    );
  }

  _buttonCupertino({String text, Function function}) {
    return CupertinoDialogAction(
      child: Text(text),
      onPressed: function,
    );
  }

  _buttonAndroid({String text, Function function}) {
    return FlatButton(
      child: Container(
          width: double.maxFinite,
          alignment: Alignment.center,
          child: Text(text)),
      onPressed: () => function(),
    );
  }

  _onClickFotoCamera() async {
    var file =
        await ImagePicker.pickImage(source: ImageSource.camera).then((f) {
      pop();

      return f;
    });

    if (file != null) {
      _setFile(file);
    }
  }

  _onClickGaleria() async {
    var file =
        await ImagePicker.pickImage(source: ImageSource.gallery).then((f) {
      pop();
      return f;
    });

    if (file != null) {
      _setFile(file);
    }
  }

  _setFile(File f) async {
    if (f != null) {
      ApiResponse response = await _bloc.editPicture(f, user);

      if (!response.ok) {
        showSimpleDialog(response.msg);
      }
    }
  }

  _onClickConcluir() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      if (!user.telefoneValido) {
        bool v = await push(ConfimarCodigoPage(telefone: telefone));
        if (v != null && v) {
          _bloc.statusApi.add(StatusApiEditarPerfil.savingUser);
          await _editAndClose();
        } else {
          user.telefoneValido = false;
        }
      } else {
        user.telefoneValido = true;
        if (_bloc.statusApi.value == null) {
          _bloc.statusApi.add(StatusApiEditarPerfil.savingUser);
        }
        await _editAndClose();
      }
    }
  }

  _editAndClose() async {
    _bloc.statusApi.listen(
      (statusApi) async {
          if(statusApi == StatusApiEditarPerfil.savingPicture) {
          _scaffoldKey.currentState.showSnackBar(_snackBar("Salvando foto.."));
        } else if (statusApi == null && !_bloc.hasError) {
          _bloc.statusApi.add(StatusApiEditarPerfil.savingUser);
        }
          if(statusApi == StatusApiEditarPerfil.savingUser) {
          _scaffoldKey.currentState.showSnackBar(_snackBar("Salvando dados.."));
          user..ddiMobilePhone = this.ddi.isEmpty ? user.ddi : ddi;
          ApiResponse response =
              await _bloc.editUser(user..mobilePhone = mobilePhone);
          if(response.ok) {
            appBloc.setUser(response.result);
            pop(result: true);
          } else {
            showSimpleDialog(response.msg);
            //fica 2 snacks, pra fechar os dois se caso der ruim
            _scaffoldKey.currentState.hideCurrentSnackBar();
            _scaffoldKey.currentState.hideCurrentSnackBar();
          }
        }
      },
    );
  }

  _snackBar(String text) {
    return SnackBar(
      duration: Duration(seconds: 40),
      content: Container(
        height: 30,
        child: Row(
          children: <Widget>[
            Progress(),
            SizedBox(width: 15),
            AppText(text),
          ],
        ),
      ),
    );
  }

  _onClickCancelar() {
    user.avatar = urlOld;
    pop();
  }

  _onClickAlterarSenha() {
    push(AlterarSenhaPage());
  }

  _onChangedCountry(CountryCode code) {
    setState(() {
      ddi = code.dialCode;
    });
  }

  @override
  void dispose() {
    _foneController.dispose();
    _foneFocus.dispose();
    _senhaFocus.dispose();
    _bloc.dispose();

    super.dispose();
  }
}
