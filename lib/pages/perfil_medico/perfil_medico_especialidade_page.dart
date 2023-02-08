import 'package:flutter/material.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class PerfilMedicoEspecialidadePage extends StatefulWidget {
  final Expertise expertise;

  const PerfilMedicoEspecialidadePage({Key key, @required this.expertise})
      : super(key: key);

  @override
  _PerfilMedicoEspecialidadePageState createState() =>
      _PerfilMedicoEspecialidadePageState();
}

class _PerfilMedicoEspecialidadePageState
    extends State<PerfilMedicoEspecialidadePage> {
  Expertise get expertise => widget.expertise;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(),
       _descEcialidade()
      ],
    );
  }

  _header() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(gradient: linearEnabled),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: pop,
                        icon: Icon(Platform.isAndroid
                            ? Icons.arrow_back
                            : Icons.arrow_back_ios),
                        color: Colors.white,
                      ),
                      _icon()
                    ],
                  ),
                  Row(
                    children: [
                      _space(),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,)
          ],
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 80,
          left: 48,
          child: _especialidade(expertise.name.toUpperCase()),
        ),
      ],
    );
  }



  _especialidade(String text, {bool principal = true}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: .5, color: AppColors.greyFont),
      ),
      child: AppText(
        text,
        fontSize: 18,
        color: principal ? Colors.black : AppColors.greyFont,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  _descEcialidade() {
    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 25, top: 20),
      child: AppText(
        expertise.description,
        textAlign: TextAlign.justify,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }

  _space() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 125),
        child: AppText(
          "",
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  _icon() {
    return Container(
      child: Image.asset(
        "assets/images/ic-eye.png",
        height: 70,
        width: 70,
      ),
    );
  }
}
