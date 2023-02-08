import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class CalendarioConsultaPage extends StatefulWidget {
  final CalendarButton initBtn;

  const CalendarioConsultaPage({Key key, @required this.initBtn})
      : super(key: key);
  @override
  _CalendarioConsultaPageState createState() => _CalendarioConsultaPageState();
}

class _CalendarioConsultaPageState extends State<CalendarioConsultaPage> {
  DateTime _currentDate;
  int _currentYear;
  List<CalendarClass> listFeriados = List<CalendarClass>();

  @override
  void initState() {
    super.initState();
    screenView("Calendario_Consulta", "Tela Calendario_Consulta");
    _currentDate = widget.initBtn.calendarButtonToDateTime();
    _currentYear = _currentDate.year;
    CalendaraApi.getFeriados(_currentYear.toString()).then((list) {
      setState(() {
        listFeriados = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text("Calendário"),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        elevation: 1,
        actions: <Widget>[
          _okButton(),
        ],
      ),
      body: _body(),
    );
  }

  _okButton() {
    return IconButton(
      onPressed: () {
        _onClickOkButton();
      },
      icon: Icon(
        Icons.check,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  _body() {
    double fSize = SizeConfig.screenWidth < 350 ? 13 : 16;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: CalendarCarousel<Event>(
        daysTextStyle: TextStyle(
          fontFamily: 'Mark',
          fontWeight: FontWeight.w500,
          color: AppColors.greyStrong,
          fontSize: fSize,
        ),
        todayButtonColor: Colors.transparent,
        todayTextStyle: TextStyle(
          fontFamily: 'Mark',
          fontWeight: FontWeight.w500,
          color: AppColors.greyStrong,
        ),
        onDayPressed: (DateTime date, x) {
          _onClickDiaCalendario(date);
        },
        selectedDayButtonColor: Theme.of(context).primaryColor,
        selectedDayTextStyle: TextStyle(fontSize: fSize),
        weekendTextStyle: TextStyle(
          color: AppColors.greyFontLow,
          fontSize: fSize,
        ),

        headerTextStyle: TextStyle(
          fontFamily: 'Mark',
          color: AppColors.greyStrong,
          fontSize: 25,
        ),
        weekFormat: false,
        locale: 'pt_BR',
        weekdayTextStyle: TextStyle(
          color: AppColors.greyFont,
        ),
        leftButtonIcon: Icon(
          Icons.chevron_left,
          size: 26,
          color: Theme.of(context).primaryColor,
        ),
        rightButtonIcon: Icon(
          Icons.chevron_right,
          size: 26,
          color: Theme.of(context).primaryColor,
        ),
        dayPadding: 6,
        // markedDatesMap: _markedDateMap,
        height: 420.0,
        selectedDateTime: _currentDate,
        showOnlyCurrentMonthDate: true,
        inactiveDaysTextStyle: TextStyle(color: Colors.red),
      ),
    );
  }

  _onClickDiaCalendario(DateTime date) {
    if (date.weekday == 7) {
      showSimpleDialog(
          'Desculpe, mas não temos médicos atendendo aos domingos');
    } else if (_checkIsPass(date)) {
      showSimpleDialog('Só é possível escolher datas futuras.');
    } else if (_checkIsHoliday(date)) {
      showSimpleDialog(
          'Desculpe, mas nossos médicos não atendem aos feríados.');
    } else {
      setState(() {
        _currentDate = date;
      });
    }
  }

  bool _checkIsHoliday(DateTime currentDate) {
    bool isHoliday = false;

    String cdDay = addZeroDate(currentDate.day);
    String cdMonth = addZeroDate(currentDate.month);

    String cd = "${currentDate.year}-$cdMonth-$cdDay";
    if (listFeriados != null) {
      listFeriados.forEach((feriado) {
        if (feriado.date == cd) {
          isHoliday = true;
        }
      });
    }
    return isHoliday;
  }

  bool _checkIsPass(DateTime date) {
    DateTime dateClean = DateTime(date.year, date.month, date.day);
    var now = DateTime.now();
    DateTime dateNowClan = DateTime(now.year, now.month, now.day);

    return dateClean.isBefore(dateNowClan);
  }

  _onClickOkButton() {
    pop(result: _currentDate);
  }
}
