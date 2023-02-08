import 'package:flutter_dandelin/model/ocupation.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/cadastro/step4_profissao_search.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class ProfissaoPage extends StatefulWidget {
  final bool isDependente;

  const ProfissaoPage({Key key, this.isDependente}) : super(key: key);
  @override
  _ProfissaoPageState createState() => _ProfissaoPageState();
}

class _ProfissaoPageState extends State<ProfissaoPage> {
  User get user => appBloc.user;
  User get dependente => appBloc.dependente;

  bool get isDependente => widget.isDependente;

  final _bloc = ProfissaoBloc();

  final _textEditingController = TextEditingController();

  Ocupation _ocupation = Ocupation();

  final _partnershipController = new MaskedTextController(mask: '0000000');

  @override
  void initState() {
    super.initState();

    Ocupation ocupation = isDependente ? dependente.ocupation : user.ocupation;

    if (ocupation != null) {
      _ocupation = ocupation;
      _textEditingController.text = ocupation.description;
      _bloc.button.set(true);
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
      child: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Hero(tag: 'mini-logo', child: MiniLogo4()),
              SizedBox(height: 30),
              _pergunta(),
              SizedBox(height: 30),
              _inputProfissao(),
              SizedBox(height: 20),
              _partnershipStream(),
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
    );
  }

  _pergunta() {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: AppText(
        isDependente
            ? "Qual a profissão ${dependente.isMale ? "do" : "da"} dependente?"
            : "Qual sua\nprofissão?",
        fontSize: 28,
        color: AppColors.greyFont,
      ),
    );
  }

  _inputProfissao() {
    return InkWell(
      onTap: _onClickSeachProfissao,
      child: AppFormField(
        enabled: false,
        hintText: "Escolha",
        controller: _textEditingController,
      ),
    );
  }

  _partnershipStream() {
    return StreamBuilder(
      initialData: false,
      stream: _bloc.hasPartnership.stream,
      builder: (coontext, snapshot) {
        bool has = snapshot.data;

        return has ? _columnPartnership() : SizedBox();
      },
    );
  }

  _columnPartnership() {
    return Column(
      children: [
        _titlePartnership(),
        SizedBox(height: 10),
        _inputPartnership(),
      ],
    );
  }

  _titlePartnership() {
    return Row(
      children: [
        Text(
          "NÚMERO SIAPE",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        Text(
          "  campo obrigatório",
          style: TextStyle(
            color: AppColors.greyFontLow,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  _inputPartnership() {
    return StreamBuilder(
      stream: _bloc.checkingPartnership.stream,
      builder: (context, snapshot) {
        Color _primaryColor = Theme.of(context).primaryColor;
        Widget icon;

        if (snapshot.hasError) {
          icon = Icon(FontAwesomeIcons.times, size: 14, color: _primaryColor);
          // showSimpleDialog( 'Código inválido');
          _bloc.button.set(false);
        } else if (!snapshot.hasData) {
          icon = Container(
            width: 30,
            child: Progress(),
          );
          _bloc.button.set(false);
        } else if (snapshot.data) {
          icon = Icon(FontAwesomeIcons.check, size: 14, color: _primaryColor);
          _bloc.button.set(true);
        } else {
          icon = SizedBox();
          _bloc.button.set(false);
        }

        return AppFormField(
          enabled: snapshot.hasData || snapshot.hasError,
          suffixIcon: icon,
          letterSpacing: 3,
          isCircular: true,
          hintText: "0000000",
          controller: _partnershipController,
          onChanged: (String value) async {
            if (value.length == 7) {
              _bloc.checkPartnership(
                value,
                user.cpfMasked,
              );
            }
          },
        );
      },
    );
  }

  _onClickSeachProfissao() async {
    _ocupation = await push(ProfissaoSearch(bloc: _bloc));

    if (_ocupation != null) {
      _textEditingController.text = _ocupation.description;
      bool hasPatnership = _ocupation.partnership != null;

      if (hasPatnership) {
        _bloc.button.set(false);
        _bloc.hasPartnership.set(_ocupation.partnership != null);
      } else {
        _bloc.button.set(true);
        _bloc.hasPartnership.set(false);
      }
    }
  }

  _onClickProximo() {
    isDependente
        ? appBloc.setDependente(dependente
          ..ocupation = _ocupation
          ..partnership = _ocupation.partnership)
        : appBloc.setUser(user
          ..ocupation = _ocupation
          ..partnership = _ocupation.partnership);

    push(EnderecoPage(isDependente: isDependente));
  }

  @override
  void dispose() {
    super.dispose();
    _partnershipController.dispose();
    _textEditingController.dispose();
    _bloc.dispose();
  }
}
