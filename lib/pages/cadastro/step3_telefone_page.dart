import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dandelin/app_bloc.dart';
import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/cadastro/step3_telefone_bloc.dart';
import 'package:flutter_dandelin/pages/cadastro/step4_profissao_page.dart';
import 'package:flutter_dandelin/pages/confirmar_codigo/confirmar_codigo_page.dart';
import 'package:flutter_dandelin/utils/clean_text.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/nav.dart';
import 'package:flutter_dandelin/widgets/app_form_field.dart';
import 'package:flutter_dandelin/widgets/base_container.dart';
import 'package:flutter_dandelin/widgets/country_pick.dart';
import 'package:flutter_dandelin/widgets/logos.dart';
import 'package:flutter_dandelin/widgets/next_button_cadastro.dart';

class TelefonePage extends StatefulWidget {
  final bool isDependente;

  const TelefonePage({Key key, this.isDependente}) : super(key: key);
  @override
  _TelefonePageState createState() => _TelefonePageState();
}

class _TelefonePageState extends State<TelefonePage> {
  User get user => appBloc.user;
  User get dependente => appBloc.dependente;

  bool get isDependente => widget.isDependente;

  final _bloc = TelefoneBloc();
  final _telefoneController = MaskedTextController(mask: "(00) 00000-0000");

  final _formKey = GlobalKey<FormState>();

  var _telefoneValid = false;

  String _telefone;
  String _ddi = "+55";

  bool telefoneValido;
  String mobilePhone;

  @override
  void initState() {
    super.initState();

    screenView("Cadastro_Step3_Telefone", "Tela Cadastro_Telefone");

    if (isDependente) {
      mobilePhone = dependente.tel;
      telefoneValido = dependente.telefoneValido;
    } else {
      mobilePhone = user.tel;
      telefoneValido = user.telefoneValido;
    }

    if (isNotEmpty(mobilePhone)) {
      _telefone = mobilePhone;
      _telefoneController.text = mobilePhone;
      _bloc.button.add(true);
      _telefoneValid = telefoneValido;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _body(),
    );
  }

  _body() {
    return BaseContainer(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Hero(tag: 'mini-logo', child: MiniLogo3()),
                SizedBox(height: 20),
                _rowPergunta(),
                SizedBox(height: 20),
                _telefoneInput(),
              ],
            ),
            StreamBuilder(
              stream: _bloc.button.stream,
              builder: (context, snapshot) {
                Function function = snapshot.hasData
                    ? snapshot.data
                        ? _onClickProximo
                        : null
                    : null;
                return NextButtonCadastro(function: function);
              },
            )
          ],
        ),
      ),
    );
  }

  _rowPergunta() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, right: 16),
            child: AppText(
              "Qual o melhor celular para entrarmos em contato ${isDependente ? dependente.isMale ? "com seu dependente" : "com sua dependente" : ""}?",
              fontSize: 28,
              color: AppColors.greyFont,
            ),
          ),
        ),
      ],
    );
  }

  _telefoneInput() {
    return Row(
      children: [
        CountryPick(
          initialSelection: _ddi,
          onChanged: _onChangedCountry,
        ),
        Expanded(
          child: AppFormField(
            controller: _telefoneController,
            hintText: "(00) 00000-0000",
            textInputType: TextInputType.number,
            inputFormatterrs: [LengthLimitingTextInputFormatter(15)],
            onChanged: (String value) {
              _bloc.button.set(value.length == 15 ? true : false);

              _telefone = value;
            },
            onSaved: (String value) {
              //para ver se o usuário já tinha confirmado o telefone e voltou pra tela e trocou de telefone
              if (telefoneValido != null && telefoneValido) {
                _telefoneValid =
                    cleanTelefone(value) == cleanTelefone(mobilePhone);
              }
            },
          ),
        ),
      ],
    );
  }

  _onClickProximo() async {
    _formKey.currentState.save();

    isDependente
        ? appBloc.setDependente(
            dependente
              ..mobilePhone = cleanTelefone(_telefone)
              ..ddiMobilePhone = _ddi,
          )
        : appBloc.setUser(
            user
              ..mobilePhone = cleanTelefone(_telefone)
              ..ddiMobilePhone = _ddi,
          );

    if (_telefoneValid) {
      push(ProfissaoPage(isDependente: isDependente));
      return;
    }

    var v = await push(ConfimarCodigoPage(telefone: _ddi + _telefone));

    _telefoneValid = v ?? _telefoneValid;

    if (v != null && v) {
      isDependente
          ? appBloc.setDependente(dependente..telefoneValido = true)
          : appBloc.setUser(user..telefoneValido = true);

      push(ProfissaoPage(isDependente: isDependente));
    }
  }

  _onChangedCountry(CountryCode code) {
    setState(() {
      _ddi = code.dialCode;
    });
  }

  @override
  void dispose() {
    _bloc.dispose();
    _telefoneController.dispose();
    super.dispose();
  }
}
