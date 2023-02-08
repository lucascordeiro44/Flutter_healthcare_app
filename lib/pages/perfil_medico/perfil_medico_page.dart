import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/cv.dart';
import 'package:flutter_dandelin/model/doctor.dart';
import 'package:flutter_dandelin/model/schedule_doctor.dart';
import 'package:flutter_dandelin/pages/perfil_medico/perfil_medico_bloc.dart';
import 'package:flutter_dandelin/pages/perfil_medico/perfil_medico_especialidade_page.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_layout_builder.dart';

class PerfilMedicoPage extends StatefulWidget {
  final Consulta consulta;

  const PerfilMedicoPage({Key key, @required this.consulta}) : super(key: key);

  @override
  _PerfilMedicoPageState createState() => _PerfilMedicoPageState();
}

class _PerfilMedicoPageState extends State<PerfilMedicoPage> {
  PerfilMedicoBloc _bloc = PerfilMedicoBloc();

  Consulta get consulta => widget.consulta;

  Doctor get doctor => consulta.doctor;

  @override
  void initState() {
    super.initState();
    _bloc.fetch(consulta.doctor.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    return AppLayoutBuilder(
      needSingleChildScrollView: true,
      child: StreamBuilder<Cv>(
        stream: _bloc.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _header(null),
                Expanded(child: Progress()),
              ],
            );
          }

          Cv cv = snapshot.data;

          List<Universitie> univer = cv.universities;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(cv),
              _especializao(cv),
              _acessibilidades(cv),
              _apresentacao(cv),
              _formacao(cv),
            ],
          );
        },
      ),
    );
  }

  _header(Cv cv) {
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
                  IconButton(
                    onPressed: pop,
                    icon: Icon(Platform.isAndroid
                        ? Icons.arrow_back
                        : Icons.arrow_back_ios),
                    color: Colors.white,
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      _nome(),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            SizedBox(height: 5),
            cv != null
                ? Container(
                    margin: EdgeInsets.only(left: 125),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _crm(cv),
                        SizedBox(height: 5),
                        _nota(cv),
                      ],
                    ),
                  )
                : SizedBox(height: 40),
            SizedBox(height: 16),
          ],
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 53,
          left: 16,
          child: AppCircleAvatar(
            avatar: doctor.user.avatar,
            assetAvatarNull: 'assets/images/consulta-icone.png',
            radius: 45,
          ),
        ),
      ],
    );
  }

  _nome() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 125),
        child: AppText(
          (doctor.user.isMale ? "Dr. " : "Dra. ") + doctor.user.getUserFullName,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  _crm(Cv cv) {
    return AppText(
      cv.crms(),
      color: AppColors.greyFont,
      fontWeight: FontWeight.w600,
      fontSize: 20,
    );
  }

  _nota(Cv cv) {
    if (cv.ratingDoctor == null) {
      return SizedBox();
    }

    List<Widget> children = List<Widget>();

    for (var i = 1; i <= 5; i++) {
      children.add(Image.asset(
        i <= cv.ratingDoctor
            ? 'assets/images/ic-estrela-preenchida.png'
            : 'assets/images/ic-estrela-vazada.png',
        height: 20,
      ));
    }

    return Row(children: children);
  }

  _especializao(Cv cv) {
    return Flexible(
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.all(16),
        color: Color.fromRGBO(241, 241, 241, 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _especializacoes(cv),
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              height: 1,
              width: 27,
              color: AppColors.greyFontLow,
            ),
            _subEspec(cv),
            _focoEm(cv),
            _tratamentoDoencas(cv),
          ],
        ),
      ),
    );
  }

  _especializacoes(Cv cv) {
    if (isEmptyList(cv.expertises)) {
      return SizedBox();
    }
    List<Widget> widgets = List<Widget>();

    widgets.add(
      AppText(
        "ESPECIALIZAÇÃO:  ",
        color: AppColors.kPrimaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );

    widgets.addAll(cv.expertises
        .map((e) => _especialidade(e.name.toUpperCase(), e: e))
        .toList()
        .cast<Widget>());

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.start,
      children: widgets,
    );
  }

  _subEspec(Cv cv) {
    if (isEmptyList(cv.subExpertises)) {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          "Subespecialidades",
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        SizedBox(height: 7),
        Wrap(
          runSpacing: 5,
          spacing: 10,
          children: cv.subExpertises
              .map((e) => _especialidade(e.name, principal: false))
              .toList()
              .cast<Widget>(),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  _especialidade(String text, {bool principal = true, Expertise e}) {
    String description = "";

    if (e != null) {
      description = e.description ?? "";
    }

    return InkWell(
      onTap: () {
        description.isNotEmpty
            ? push(PerfilMedicoEspecialidadePage(
                expertise: e,
              ))
            : null;
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(width: .5, color: AppColors.greyFont),
        ),
        child: AppText(
          text,
          fontSize: 12,
          color: principal ? Colors.black : AppColors.greyFont,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _focoEm(Cv cv) {
    if (isEmptyList(cv.focus)) {
      return SizedBox();
    }
    List<Widget> widgets = List<Widget>();

    widgets.addAll([
      Image.asset(
        'assets/images/ic-lupa.png',
        height: 25,
      ),
      SizedBox(width: 2),
      AppText(
        "Foco em:  ",
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ]);

    widgets.addAll(cv.focus
        .map((e) => _especialidade(e.name.toUpperCase(), principal: false))
        .toList()
        .cast<Widget>());

    return Column(
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.start,
          children: widgets,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  _tratamentoDoencas(Cv cv) {
    if (isEmptyList(cv.diseaseTreatments)) {
      return SizedBox();
    }
    List<Widget> widgets = List<Widget>();

    widgets.addAll([
      Image.asset(
        'assets/images/ic-remedio.png',
        height: 25,
      ),
      SizedBox(width: 3),
      AppText(
        "Tratamento de doenças:  ",
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ]);

    widgets.addAll(cv.diseaseTreatments
        .map((e) => _especialidade(e.name))
        .toList()
        .cast<Widget>());

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.start,
      children: widgets,
    );
  }

  _acessibilidades(Cv cv) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _atendimentoAccess(cv),
          _consultorioAccess(cv),
          _linguagemAccess(cv),
        ],
      ),
    );
  }

  _atendimentoAccess(Cv cv) {
    if (isEmptyList(cv.targets)) {
      return SizedBox();
    }

    return _access(
      "Atendimento à",
      cv.targs(),
      'assets/images/ic-pessoas.png',
      25,
    );
  }

  _consultorioAccess(Cv cv) {
    if (!cv.accessibility) {
      return SizedBox();
    }

    return _access(
      "Consultório\nacessível",
      null,
      'assets/images/ic-cadeira-de-rodas.png',
      30,
    );
  }

  _linguagemAccess(Cv cv) {
    if (isEmptyList(cv.languages)) {
      return SizedBox();
    }

    return _access(
      "Atendimento em:",
      cv.langs(),
      'assets/images/ic-mundo.png',
      25,
    );
  }

  _access(String title, String coment, String image, double height) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: .5,
                color: AppColors.greyStrong,
              ),
            ),
            child: Image.asset(
              image,
              height: height,
              color: AppColors.kPrimaryColor,
            ),
          ),
          SizedBox(height: 5),
          AppText(
            title,
            color: AppColors.greyStrong,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w600,
          ),
          AppText(
            coment,
            color: AppColors.kPrimaryColor,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  _apresentacao(Cv cv) {
    // if (isEmptyList(cv.topics)) {
    //   return AppText("Não preenchido",
    //       color: AppColors.greyStrong, fontWeight: FontWeight.w600);
    // }

    if (cv.resume.isEmpty) {
      return SizedBox();
    }

    String resume = "";

    if (cv.resume != null) {
      resume = cv.resume;
    }

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: .5,
                      color: AppColors.greyStrong,
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/cone-stethoscope.png',
                    height: 25,
                    color: AppColors.kPrimaryColor,
                  ),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    AppText(
                      "APRESENTAÇÃO PROFISSIONAL",
                      color: AppColors.kPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 5),
                  ],
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 60, right: 20),
              child: AppText(
                resume.isEmpty ? "Não preenchido" : resume,
                color: AppColors.greyStrong,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            )
          ],
        ));
  }

  _formacao(Cv cv) {
    if (isEmptyList(cv.universities)) {
      return SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: .5,
                color: AppColors.greyStrong,
              ),
            ),
            child: Image.asset(
              'assets/images/ic-chapeu.png',
              height: 25,
              color: AppColors.kPrimaryColor,
            ),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              AppText(
                "FORMAÇÃO ACADÊMICA",
                color: AppColors.kPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 5),
              _formacoes(cv),
            ],
          )
        ],
      ),
    );
  }

  _formacoes(Cv cv) {
    List<Widget> children = [];

    if (cv.universities != null) {
      print("Universities ${cv.universities}");
      children = cv.universities
          .map((e) => e.titleApp != "" ? _item(e.titleApp, e.name) : SizedBox())
          .toList()
          .cast<Widget>();
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.isNotEmpty
            ? children
            : [
                AppText("Não preenchido",
                    color: AppColors.greyStrong, fontWeight: FontWeight.w600),
              ]);
  }

  _item(String title, String subTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          color: AppColors.greyStrong,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 5),
        AppText(
          subTitle,
          color: AppColors.greyStrong,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }
}
