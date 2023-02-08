import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/pages/login/login_page.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/prefs.dart';

class BemVindo extends StatefulWidget {
  @override
  _BemVindoState createState() => _BemVindoState();
}

class _BemVindoState extends State<BemVindo> {
  final _bloc = StepBloc();

  List<Passo> passos = [
    Passo(
        "+ acessível",
        "Faça seu cadastro em poucos minutos e tenha acesso a consultas ilimitadas com mais de 60 especialidades por R\$100 mensais.",
        "assets/images/step1_image.png"),
    Passo(
        "+ simples",
        "No dandelin todos pagam o mesmo valor e apenas uma vez ao mês, não importa sua idade, precondição ou quantidade de consultas realizadas.",
        "assets/images/step2_image.png"),
    Passo(
        "+ justo",
        " A comunidade divide as contas, fazendo com que todos paguem o valor mais barato domercado para ter acesso ilimitado por mês. Ajudamos pessoas e não grandes empresas.",
        "assets/images/step3_image.png")
  ];

  @override
  void initState() {
    super.initState();
    screenView('Bem_Vindo', "Tela Bem_Vindo");
    Prefs.setBool('bem_vindo_done.new', true);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: SafeArea(
        child: _body(),
      ),
      bottomNavigationBar: StreamBuilder(
        stream: _bloc.controller.stream,
        builder: (context, snapshot) {
          return Container(
            padding: EdgeInsets.only(bottom: 10),
            height: 30,
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: DotsIndicator(
                dotsCount: 3,
                decorator: DotsDecorator(
                    color: Color.fromRGBO(204, 204, 204, 1),
                    activeColor: AppColors.greyFont),
                position: snapshot.hasData
                    ? double.parse(snapshot.data.toString())
                    : 0.0,
              ),
            ),
          );
        },
      ),
    );
  }

  _body() {
    return BaseContainer(
      padding: EdgeInsets.only(top: 10, bottom: 5),
      child: Column(
        children: <Widget>[
          _header(),
          SizedBox(height: 20),
          _pageView(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 35,
            child: AppButtonStream(
              text: "VAMOS COMEÇAR",
              onPressed: _onClickNext,
            ),
          ),
        ],
      ),
    );
  }

  _header() {
    return Column(
      children: <Widget>[
        SizedBox(height: 15),
        AppText(
          "Bem-Vindo \nao",
          color: AppColors.greyFont,
          fontSize: 35,
          fontWeight: FontWeight.w200,
          textAlign: TextAlign.center,
          height: 0.85,
        ),
        Image.asset(
          "assets/images/dandelin-logo.png",
          height: 50,
          width: 200,
        ),
      ],
    );
  }

  _pageView() {
    return Expanded(
      child: CarouselSlider(
        viewportFraction: 1.0,
        autoPlay: true,
        enableInfiniteScroll: true,
        autoPlayInterval: Duration(seconds: 4),
        pauseAutoPlayOnTouch: Duration(seconds: 5),
        height: double.maxFinite,
        initialPage: 0,
        onPageChanged: (int v) {
          _bloc.controller.add(v);
        },
        items: <Widget>[
          _column(passos[0]),
          _columnStep2(passos[1]),
          _column(passos[2]),
        ],
      ),
    );
  }

  _column(Passo p) {
    return Container(
      width: SizeConfig.screenWidth,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _image(p.image),
            SizedBox(height: 12),
            AppText(
              p.title,
              color: AppColors.greyFont,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: AppText(
                p.subtitle,
                textAlign: TextAlign.center,
                color: AppColors.greyFont,
                fontSize: 15,
                fontFamily: 'Mark Book',
              ),
            ),
          ],
        ),
      ),
    );
  }

  _columnStep2(Passo p) {
    return Container(
      width: SizeConfig.screenWidth,
      child: Column(
        children: <Widget>[
          _image(p.image),
          SizedBox(height: 12),
          AppText(
            p.title,
            color: AppColors.greyFont,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  color: AppColors.greyFont,
                  fontFamily: 'Mark',
                  fontSize: 15,
                ),
                children: [
                  TextSpan(text: "No"),
                  TextSpan(
                    text: " dandelin ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text:
                          "todos pagam o mesmo valor e apenas uma vez ao mês, não importa sua idade, precondição ou quantidade de consultas realizadas."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _image(String image) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Image.asset(
        image,
        fit: BoxFit.fill,
      ),
      padding: EdgeInsets.only(top: 12),
      width: SizeConfig.screenWidth,
      //height: SizeConfig.screenHeight * 0.35,
    );
  }

  _onClickNext() {
    push(LoginPage(), replace: true);
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

class StepBloc {
  var controller = SimpleBloc<int>();

  dispose() {
    controller.dispose();
  }
}

class Passo {
  String title;
  String subtitle;
  String image;

  Passo(this.title, this.subtitle, this.image);
}
