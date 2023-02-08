import 'package:flutter_dandelin/utils/imports.dart';

class ConsultaExameMapa extends StatefulWidget {
  final Function(dynamic) onTapMarker;
  final ConsultaExameBloc bloc;
  final Function onTapMiniCard;

  ConsultaExameMapa(
      {Key key,
      @required this.onTapMarker,
      @required this.bloc,
      @required this.onTapMiniCard})
      : super(key: key);

  @override
  _ConsultaExameMapaState createState() => _ConsultaExameMapaState();
}

class _ConsultaExameMapaState extends State<ConsultaExameMapa>
    with TickerProviderStateMixin {
  @override
  void initState() {
    widget.bloc.startMap(widget.onTapMarker);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: widget.bloc.showMiniCardDetalhe.stream,
        builder: (context, snapshot) {
          bool up = snapshot.hasData ? snapshot.data : false;
          return Stack(
            children: <Widget>[
              _map(),
              _containerBackground(up),
              _cardConsultaExame(up),
            ],
          );
        },
      ),
    );
  }

  _map() {
    return StreamBuilder(
      stream: widget.bloc.mapStream.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data;
        } else {
          return Container(
            child: Progress(),
          );
        }
      },
    );
  }

  _cardConsultaExame(bool up) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _cardAnimado(up),
        _pseudoMargin(up),
      ],
    );
  }

  _cardAnimado(bool up) {
    return StreamBuilder(
      stream: widget.bloc.cardMapaConsultaExame.stream,
      builder: (context, snapshot) {
        print(snapshot.data);
        return AnimatedSize(
          vsync: this,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOutQuint,
          child: SingleChildScrollView(
            child: snapshot.hasData
                ? Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: ConsultaExameCard(
                      dataEscolhida: widget.bloc.getDataEscolhidaBase(),
                      onPressed: widget.onTapMiniCard,
                      dynamicClass: snapshot.data,
                    ),
                  )
                : Container(),
          ),
        );
      },
    );
  }

  _containerBackground(bool up) {
    return Align(
      child: AnimatedContainer(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1, color: Colors.black38),
          ),
          color: Colors.white,
        ),
        height: up ? 40 : 0,
        duration: Duration(milliseconds: 400),
      ),
      alignment: Alignment.bottomCenter,
    );
  }

  _pseudoMargin(bool up) {
    return AnimatedContainer(
      duration: Duration(milliseconds: up ? 800 : 100),
      height: up ? 10 : 0,
    );
  }
}
