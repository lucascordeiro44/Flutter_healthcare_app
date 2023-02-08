import 'package:flutter_dandelin/pages/cadastro/step6_comefrom_bloc.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_layout_builder.dart';

class CameFromPage extends StatefulWidget {
  @override
  _CameFromPageState createState() => _CameFromPageState();
}

class _CameFromPageState extends State<CameFromPage> {
  final _bloc = CameFromBloc();

  User get user => appBloc.user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(),
    );
  }

  _appBar(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          isIOS(context) ? Icons.chevron_left : Icons.arrow_back,
          size: isIOS(context) ? 40 : 24,
        ),
        onPressed: pop,
      ),
    );
  }

  _body() {
    return AppLayoutBuilder(
      needSingleChildScrollView: true,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Hero(tag: 'mini-logo', child: MiniLogo5()),
          SizedBox(height: 30),
          _pergunta(),
          SizedBox(height: 30),
          _cameFrom(),
          Expanded(child: Container()),
          _button(),
        ],
      ),
    );
  }

  _pergunta() {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: AppText(
        "Como descobriu o dandelin?",
        fontSize: 28,
        color: AppColors.greyFont,
      ),
    );
  }

  _cameFrom() {
    return StreamBuilder(
      stream: _bloc.cameFromValue.stream,
      builder: (context, snapshot) {
        String data = snapshot.data;

        return Column(
          children: [
            _cameFromButton("Google"),
            _cameFromButton("Instagram"),
            _cameFromButton("Tiktok"),
            _cameFromButton("Facebook"),
            _cameFromButton("Matérias da impresa", value: "NEWS"),
            _cameFromButton("Outros", value: "OTHER"),
            _inputField(data),
          ],
        );
      },
    );
  }

  _cameFromButton(String text, {String value}) {
    return RawMaterialButton(
      onPressed: () => _onClickButton(value ?? text),
      child: Row(
        children: [
          Radio(
            value: value ?? text,
            groupValue: _bloc.value,
            onChanged: (_) => _onClickButton(value ?? text),
            activeColor: AppColors.kPrimaryColor,
          ),
          AppText(
            text,
            fontSize: 18,
            fontWeight: _bloc.value == text ? FontWeight.w500 : null,
          ),
        ],
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
                ? _onClickCadastrar
                : null
            : null;

        return Container(
          margin: EdgeInsets.only(bottom: 15, right: 5, top: 15),
          child: NextButtonCadastro(
            needPositioned: false,
            function: function,
            icon: btnState != null && btnState.progress ? Progress() : null,
          ),
        );
      },
    );
  }

  _inputField(String data) {
    if (data == "Google" || isEmpty(data) || data == "NEWS") {
      return SizedBox();
    }

    if (data == "OTHER") {
      return AppFormField(
        maxLines: 5,
        controller: _bloc.tDescricaoController,
        onChanged: (_) => _bloc.validate(),
        hintText: "Digite Aqui onde vc encontrou a dandelin",
      );
    }

    return AppFormField(
      controller: _bloc.tDescricaoController,
      onChanged: (_) => _bloc.validate(),
      prefixIcon: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: AppText(
              "@",
              color: AppColors.greyFontLow,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  _onClickButton(String v) => _bloc.changeCameFromValue(v);

  _onClickCadastrar() async {
    ApiResponse response = await _bloc.cadastrar(user);

    response.ok
        ? push(HomePage(), replace: true, popAll: true)
        : showSimpleDialog(response.msg);
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }
}
