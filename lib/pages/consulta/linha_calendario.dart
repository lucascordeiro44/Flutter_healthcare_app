import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_base.dart';
import 'package:flutter_dandelin/utils/imports.dart';

import 'package:intl/intl.dart';

class LinhaCalendario extends StatefulWidget {
  LinhaCalendario(
      {Key key,
      @required this.consultaExameEscolhidoStream,
      @required this.listDiasCalendarioStream,
      @required this.onClickDiaCalendario,
      @required this.onClickCalendarIcon,
      //@required this.isDetalhePage,
      this.needFocusChild = false,
      @required this.scrollController})
      : super(key: key);

  final Function(CalendarButton) onClickDiaCalendario;
  final SimpleBloc<OpcaoEscolhida> consultaExameEscolhidoStream;
  final SimpleBloc<List<CalendarButton>> listDiasCalendarioStream;
  final Function onClickCalendarIcon;
  //final bool isDetalhePage;
  final bool needFocusChild;
  final ScrollController scrollController;

  @override
  _LinhaCalendarioState createState() => _LinhaCalendarioState();
}

class _LinhaCalendarioState extends State<LinhaCalendario> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        children: <Widget>[
          _imagemCalendario(),
          SizedBox(width: 8),
          _rowDias(),
        ],
      ),
    );
  }

  _imagemCalendario() {
    return StreamBuilder(
      stream: widget.consultaExameEscolhidoStream.stream,
      builder: (context, snapshot) {
        OpcaoEscolhida opcao =
            snapshot.hasData ? snapshot.data : OpcaoEscolhida.consulta;
        return Expanded(
          child: InkWell(
            onTap: () {
              widget.onClickCalendarIcon();
            },
            child: Image.asset(
              opcao == OpcaoEscolhida.consulta
                  ? 'assets/images/calendario-consulta-icon.png'
                  : 'assets/images/calendario-exames-icon.png',
              height: 35,
            ),
          ),
        );
      },
    );
  }

  _rowDias() {
    return StreamBuilder(
      stream: widget.listDiasCalendarioStream.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container(height: 60);
        List<CalendarButton> listDiasCalendario = snapshot.data;

        if (widget.needFocusChild) {
          int idx = listDiasCalendario.indexWhere((v) => v.isSelected);

          Future.delayed(Duration(seconds: 1), () {
            widget.scrollController.animateTo(
                double.parse((idx * 75).toString()),
                curve: Curves.linear,
                duration: Duration(milliseconds: 500));
          });
        }

        return _listDias(listDiasCalendario, context);
      },
    );
  }

  _listDias(List<CalendarButton> listDiasCalendario, BuildContext context) {
    return Expanded(
      flex: 7,
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: listDiasCalendario.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, idx) {
                CalendarButton btn = listDiasCalendario[idx];

                return _diaButton(btn, context);
              },
            ),
          ),
          _degradePontas(true),
          _degradePontas(false),
        ],
      ),
    );
  }

  _degradePontas(bool left) {
    // Color colorDegrade =
    //     widget.isDetalhePage ? Colors.white : Color.fromRGBO(247, 247, 247, 1);
    Color colorDegrade = Colors.white;
    return Align(
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: 5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: left ? Alignment.centerLeft : Alignment.centerRight,
            end: !left ? Alignment.centerLeft : Alignment.centerRight,
            colors: [
              colorDegrade.withOpacity(0.9),
              colorDegrade.withOpacity(0.9),
              colorDegrade.withOpacity(0.8),
              colorDegrade.withOpacity(0.7),
              colorDegrade.withOpacity(0.7),
              colorDegrade.withOpacity(0.2),
              colorDegrade.withOpacity(0.2),
              colorDegrade.withOpacity(0.2),
            ],
          ),
        ),
      ),
    );
  }

  _diaButton(CalendarButton btn, BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onClickDiaCalendario(btn);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10.0, right: 30),
            child: Text(
              "${btn.dia}\n${btn.mes}",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: btn.isSelected
                    ? AppColors.greyStrong
                    : AppColors.greyFontLow,
                fontSize: 16,
              ),
            ),
          ),
          _indicator(btn, context),
        ],
      ),
    );
  }

  _indicator(CalendarButton btn, BuildContext context) {
    return StreamBuilder(
      stream: widget.consultaExameEscolhidoStream.stream,
      builder: (context, snapshot) {
        OpcaoEscolhida v =
            snapshot.hasData ? snapshot.data : OpcaoEscolhida.consulta;

        return Container(
          height: btn.isSelected ? 3 : 0,
          width: 55,
          color: v == OpcaoEscolhida.consulta
              ? Theme.of(context).primaryColor
              : AppColors.blueExame,
        );
      },
    );
  }
}

class CalendarButton {
  int id;
  String dia;
  String mes;
  int nMes;
  int ano;
  bool isSelected;

  CalendarButton({
    this.ano,
    this.dia,
    this.id,
    this.isSelected,
    this.nMes,
  });

  String calendarButtonToString() {
    DateTime dateTime = DateTime(ano, nMes, int.parse(dia));
    return dateToStringBd(dateTime);
  }

  static CalendarButton dateTimeToCalendarButton(
      DateTime dateTime, int id, bool isSelected) {
    String mes = new DateFormat.MMMM("pt_BR").format(dateTime).toString();

    String mesAbrev = "${mes[0]}${mes[1]}${mes[2]}";
    return CalendarButton()
      ..id = id
      ..dia = dateTime.day.toString()
      ..mes = mesAbrev.toUpperCase()
      ..nMes = dateTime.month
      ..ano = dateTime.year
      ..isSelected = isSelected;
  }

  DateTime calendarButtonToDateTime() {
    return DateTime(ano, nMes, int.parse(dia));
  }

  static bool compareTwoButtons(CalendarButton btn1, CalendarButton btn2) {
    bool isEqual = false;

    DateTime dateTimeBtn1 = btn1.calendarButtonToDateTime();
    DateTime dateTimeBtn2 = btn2.calendarButtonToDateTime();

    if (dateTimeBtn1.compareTo(dateTimeBtn2) == 0) {
      isEqual = true;
    }

    return isEqual;
  }
}
