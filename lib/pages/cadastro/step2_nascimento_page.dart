import 'package:flutter/services.dart';
import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/cadastro/step2_nascimento_bloc.dart';
import 'package:flutter_dandelin/pages/cadastro/step3_telefone_page.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/custom_checkbox.dart';
import 'package:flutter_dandelin/widgets/next_button_cadastro.dart';

class NascimentoPage extends StatefulWidget {
  final bool isDependente;

  const NascimentoPage({Key key, this.isDependente}) : super(key: key);
  @override
  _NascimentoPageState createState() => _NascimentoPageState();
}

class _NascimentoPageState extends State<NascimentoPage> {
  User get user => appBloc.user;
  User get dependente => appBloc.dependente;

  bool get isDependente => widget.isDependente;

  final _bloc = NascimentoBloc();

  final _diaController = MaskedTextController(mask: '00');
  final _mesController = MaskedTextController(mask: '00');
  final _anoController = MaskedTextController(mask: '0000');

  final _diaFn = FocusNode();
  final _mesFn = FocusNode();
  final _anoFn = FocusNode();

  Color _primaryColor;

  final _form = BirthdayForm();

  @override
  void initState() {
    super.initState();

    _bloc.init(isDependente);

    screenView(
        "Cadastro_Step2_Data_Nascimento", "Tela Cadastro_Data_Nascimento");

    String birthday;
    if (isDependente) {
      birthday = dependente.birthday;
      _bloc.menorIdade.add(dependente.underAge);
      _bloc.agreeMenorIdade.add(dependente.agreeUnderAge);
    } else {
      birthday = user.birthday;
    }

    if (isNotEmpty(birthday)) {
      var array = birthday.split('-');

      _diaController.text = array[0];
      _mesController.text = array[1];
      _anoController.text = array[2];
      _form.day = int.parse(_diaController.text);
      _form.month = int.parse(_mesController.text);
      _form.year = int.parse(_anoController.text);

      _bloc.button.setEnabled(true);
    }

    _checkText(_diaFn, _diaController);
    _checkText(_mesFn, _mesController);
  }

  @override
  Widget build(BuildContext context) {
    _primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: _primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _body(),
    );
  }

  _body() {
    return BaseContainer(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Hero(tag: 'mini-logo', child: MiniLogo2()),
              SizedBox(height: 30),
              _rowPergunta(),
              SizedBox(height: 40),
              _rowFields(),
              SizedBox(height: 10),
              _dependenteMenorCheckBox(),
            ],
          ),
          StreamBuilder(
            stream: _bloc.button.stream,
            builder: (context, snapshot) {
              final btState = snapshot.data;

              return NextButtonCadastro(
                  function: btState != null && btState.enabled
                      ? _onClickProximo
                      : null);
            },
          )
        ],
      ),
    );
  }

  _rowPergunta() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        AppText(
          isDependente
              ? "Qual a data\nde nascimento ${dependente.gender == "male" ? "dele" : "dela"}?"
              : "Qual sua data\nde nascimento?",
          fontSize: 28,
          color: AppColors.greyFont,
        ),
      ],
    );
  }

  _rowFields() {
    return Row(
      children: <Widget>[
        _expandedDia(),
        _expandedMes(),
        _expandedAno(),
      ],
    );
  }

  _expandedDia() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppText("DIA",
                color: _primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500),
            AppFormField(
              inputFormatterrs: [LengthLimitingTextInputFormatter(2)],
              controller: _diaController,
              textInputType: TextInputType.number,
              focusNode: _diaFn,
              hintText: "00",
              textAlign: TextAlign.start,
              onFieldSubmitted: (_) {
                fieldFocusChangeFunction(context, _diaFn, _mesFn);
              },
              onChanged: (String value) {
                _form.day = value == "" ? null : int.parse(value);
                _updateForm();
                if (value.length == 2) {
                  fieldFocusChangeFunction(context, _diaFn, _mesFn);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  _expandedMes() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppText("MÊS",
                color: _primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500),
            AppFormField(
              inputFormatterrs: [LengthLimitingTextInputFormatter(2)],
              controller: _mesController,
              textInputType: TextInputType.number,
              focusNode: _mesFn,
              hintText: "00",
              textAlign: TextAlign.start,
              onFieldSubmitted: (_) {
                fieldFocusChangeFunction(context, _mesFn, _anoFn);
              },
              onChanged: (String value) {
                _form.month = value == "" ? null : int.parse(value);
                _updateForm();
                if (value.length == 2) {
                  fieldFocusChangeFunction(context, _mesFn, _anoFn);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  _expandedAno() {
    return Expanded(
      flex: 2,
      child: Container(
        padding: EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppText("ANO",
                color: _primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500),
            AppFormField(
              inputFormatterrs: [LengthLimitingTextInputFormatter(4)],
              controller: _anoController,
              textInputType: TextInputType.number,
              focusNode: _anoFn,
              hintText: "0000",
              textAlign: TextAlign.start,
              onChanged: (String value) {
                _form.year = value == "" ? null : int.parse(value);
                _updateForm();
              },
            ),
          ],
        ),
      ),
    );
  }

  _dependenteMenorCheckBox() {
    return StreamBuilder(
      initialData: false,
      stream: _bloc.menorIdade.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data) {
          return SizedBox();
        }

        return StreamBuilder(
          initialData: false,
          stream: _bloc.agreeMenorIdade.stream,
          builder: (context, snapshot) {
            bool value = snapshot.hasData ? snapshot.data : false;

            return RawMaterialButton(
              onPressed: () {
                _bloc.agreeMenorIdade.set(!value);
                _updateForm();
              },
              child: Row(
                children: [
                  CustomCheckbox(
                    useTapTarget: false,
                    activeColor: Theme.of(context).primaryColor,
                    value: value,
                    onChanged: (v) {
                      _bloc.agreeMenorIdade.set(!value);
                      _updateForm();
                    },
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: AppText(
                        "Eu me responsabilizo pelos dados inclusos do menor de idade.",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _updateForm() {
    _bloc.updateForm(_form);
  }

  _onClickProximo() {
    if (!isValidDate(_form.dataClean())) {
      showSimpleDialog("Insira uma data válida.");
    } else if (!idadeMaior16(_form.dataClean()) && !isDependente) {
      showSimpleDialog("Idade miníma de 16 anos.");
    } else {
      isDependente
          ? appBloc.setDependente(dependente
            ..birthday = _form.toString()
            ..underAge = _bloc.menorIdade.value
            ..agreeUnderAge = _bloc.agreeMenorIdade.value)
          : appBloc.setUser(user..birthday = _form.toString());

      push(TelefonePage(isDependente: isDependente));
    }
  }

  _checkText(FocusNode focusNode, MaskedTextController controller) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        String text = controller.text;
        if (text.length == 1) {
          controller.text = "0$text";
        }
      }
    });
  }

  @override
  void dispose() {
    _bloc.dispose();
    _diaController.dispose();
    _mesController.dispose();
    _anoController.dispose();
    _diaFn.dispose();
    _mesFn.dispose();
    _anoFn.dispose();

    super.dispose();
  }
}
