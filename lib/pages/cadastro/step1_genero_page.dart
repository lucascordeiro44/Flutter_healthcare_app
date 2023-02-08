import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/cadastro/step1_genero_bloc.dart';
import 'package:flutter_dandelin/pages/cadastro/step2_nascimento_page.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_layout_builder.dart';
import 'package:flutter_dandelin/widgets/next_button_cadastro.dart';

class GeneroPage extends StatefulWidget {
  final bool isDependente;

  const GeneroPage({Key key, this.isDependente}) : super(key: key);

  @override
  _GeneroPageState createState() => _GeneroPageState();
}

class _GeneroPageState extends State<GeneroPage> {
  final _bloc = GeneroBloc();

  User get user => appBloc.user;
  User get dependente => appBloc.dependente;

  Color _primaryColor;

  bool get isDependente => widget.isDependente;

  @override
  void initState() {
    super.initState();
    screenView("Cadastro_Step1_Genero", "Tela Cadastro_Genero");
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
    return AppLayoutBuilder(
      needSingleChildScrollView: true,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Hero(tag: 'mini-logo', child: MiniLogo1()),
              SizedBox(height: 30),
              _rowOlaUsuario(),
              SizedBox(height: 50),
              _rowOpcaoGenero(),
            ],
          ),
          StreamBuilder<Object>(
            stream: _bloc.button.stream,
            builder: (context, snapshot) {
              Function function = snapshot.hasData ? _onClickProximo : null;
              return NextButtonCadastro(function: function);
            },
          )
        ],
      ),
    );
  }

  _rowOlaUsuario() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        RichText(
          text: TextSpan(
            text: "Olá ",
            style: TextStyle(
              fontSize: 30,
              color: Colors.grey,
              fontFamily: 'Mark',
            ),
            children: <TextSpan>[
              TextSpan(
                  text: "${user.firstName}",
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              TextSpan(
                  text:
                      ",\npor favor selecione\n${isDependente ? "o gênero do seu \ndependente" : "seu gênero"}"),
            ],
          ),
        ),
      ],
    );
  }

  _rowOpcaoGenero() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _masculinoButton(),
        _femininoButton(),
      ],
    );
  }

  _masculinoButton() {
    return StreamBuilder(
      stream: _bloc.masculino.stream,
      builder: (context, snapshot) {
        Color color =
            snapshot.hasData ? snapshot.data ? _primaryColor : null : null;
        return _buildGeneroButton('assets/images/masculino-unselected.png',
            'masculino', color, _onClickMasculinoSelecionado);
      },
    );
  }

  _femininoButton() {
    return StreamBuilder(
      stream: _bloc.feminino.stream,
      builder: (context, snapshot) {
        Color color =
            snapshot.hasData ? snapshot.data ? _primaryColor : null : null;
        return _buildGeneroButton('assets/images/feminino-unselected.png',
            'feminino', color, _onClickFemininoSelecionado);
      },
    );
  }

  _buildGeneroButton(
      String image, String genero, Color color, Function function) {
    return RawMaterialButton(
      padding: EdgeInsets.all(10),
      onPressed: function,
      child: Column(
        children: <Widget>[
          Container(
            height: 100,
            width: 100,
            child: Image.asset(image, color: color),
          ),
          SizedBox(height: 10),
          AppText(
            genero,
            fontWeight: FontWeight.w500,
            color: color == null ? AppColors.greyFontLow : color,
          ),
        ],
      ),
    );
  }

  _onClickMasculinoSelecionado() {
    _bloc.masculino.set(true);
    _bloc.feminino.set(false);
    _bloc.button.set(true);
    isDependente ? dependente.gender = "male" : user.gender = "male";
  }

  _onClickFemininoSelecionado() {
    _bloc.masculino.set(false);
    _bloc.feminino.set(true);
    _bloc.button.set(true);
    isDependente ? dependente.gender = "female" : user.gender = "female";
  }

  _onClickProximo() {
    isDependente ? appBloc.setDependente(dependente) : appBloc.setUser(user);
    push(NascimentoPage(isDependente: isDependente));
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
