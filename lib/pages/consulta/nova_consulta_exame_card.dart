import 'package:flutter_dandelin/model/unity.dart';
import 'package:flutter_dandelin/pages/consulta/widgets/covid_label.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/material_container.dart';

class ConsultaExameCard extends StatefulWidget {
  final dynamic dynamicClass;
  final Function onPressed;
  final String dataEscolhida;

  ConsultaExameCard(
      {Key key, this.dynamicClass, this.onPressed, this.dataEscolhida})
      : super(key: key);

  @override
  _ConsultaExameCardState createState() => _ConsultaExameCardState();
}

class _ConsultaExameCardState extends State<ConsultaExameCard> {
  final _key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    String title = '';
    Color color;
    ImageProvider image;
    String subtitle;
    List<String> horariosDisponiveis = List<String>();
    String location;
    bool hasAvatar = false;
    bool showCovidLabel = false;
    bool teleconferencia = false;

    if (widget.dynamicClass is Consulta) {
      Consulta consulta = widget.dynamicClass;

      if (consulta.doctor.user.avatar == null ||
          consulta.doctor.user.avatar == "") {
        image = AssetImage('assets/images/consulta-icone.png');
      } else {
        hasAvatar = true;
        image = NetworkImage(consulta.doctor.user.avatar);
      }

      title = Consulta.getExpertises(consulta, fromScheduleDoctor: false);
      subtitle =
          Consulta.getDoctorFullName(consulta, fromScheduleDoctor: false);

      color = Theme.of(context).primaryColor;

      location =
          "${consulta.address.getClinica} - ${consulta.address.neighborhood}";
      horariosDisponiveis = consulta.avaliability;

      showCovidLabel = consulta.doctor.showCovidLabel;
      teleconferencia = consulta.telemedicine ?? false;
    } else {
      Unity unity = widget.dynamicClass;

      hasAvatar = false;
      image = AssetImage('assets/images/cone-exame.png');
      title = unity.exam.title;
      subtitle = unity.exam.description;

      color = AppColors.blueExame;

      location =
          "${unity.address.address}, ${unity.address.addressNumber} - ${unity.address.neighborhood}";

      horariosDisponiveis = unity.avaliability;
    }

    return StackMaterialContainer(
      onTap: () {
        widget.onPressed(widget.dynamicClass);
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 0),
        child: Container(
          key: _key,
          padding: EdgeInsets.only(left: 5, right: 10, top: 5, bottom: 5),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(width: 2.5, color: color),
              ),
            ),
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _columnDados(
                    title: title,
                    color: color,
                    subtitle: subtitle,
                    horariosDisponiveis: horariosDisponiveis,
                    location: location,
                    teleconferencia: teleconferencia),
                SizedBox(width: 5),
                _columnImage(
                    showCovidLabel, hasAvatar, context, image, teleconferencia),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _columnDados(
      {String title,
      Color color,
      String subtitle,
      List<String> horariosDisponiveis,
      String location,
      bool teleconferencia}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppText(
              title,
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            AppText(
              subtitle,
              fontWeight: FontWeight.w500,
              color: AppColors.greyStrong,
              fontSize: 17,
            ),
            SizedBox(height: 2),
            location != " - null" && !teleconferencia
                ? AppText(
                    location,
                    fontWeight: FontWeight.w500,
                    color: AppColors.greyStrong,
                    fontSize: 14,
                  )
                : SizedBox(),
            SizedBox(height: 5),
            Container(
              width: double.infinity,
              child: WrapHorarios(
                horariosDisponiveis: horariosDisponiveis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _columnImage(bool showCovidLabel, bool hasAvatar, BuildContext context,
      ImageProvider image, bool teleconferencia) {
    return Column(
      children: <Widget>[
        // Platform.isIOS
        //     ? showCovidLabel ? CovidLabel() : SizedBox()
        //     : SizedBox(),
        Stack(
          children: <Widget>[
            Container(
              decoration: hasAvatar
                  ? new BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    )
                  : null,
              padding: hasAvatar ? EdgeInsets.all(1) : null,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 40.0,
                backgroundImage: image,
              ),
            ),
            teleconferencia
                ? Positioned(
                    bottom: 0,
                    left: 0,
                    child: Image.asset(
                      'assets/images/ic-videocoferencia-mini.png',
                      height: 30,
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ],
    );
  }
}
