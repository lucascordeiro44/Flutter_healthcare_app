import 'package:flutter/material.dart';
import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/model/city.dart';
import 'package:flutter_dandelin/model/expertise.dart';
import 'package:flutter_dandelin/model/laboratory.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/consulta/nova_consulta_exame_bloc.dart';
import 'package:flutter_dandelin/pages/consulta/widgets/linha_lista_filtro.dart';
import 'package:flutter_dandelin/widgets/app_text.dart';
import 'package:flutter_dandelin/widgets/center_text.dart';
import 'package:flutter_dandelin/widgets/progress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ListFiltro extends StatefulWidget {
  final Stream<FiltroEscolhidoEnum> filtroEscolhidoStream;
  final Stream listFiltroStream;
  final ScrollController scrollController;
  final Stream loadingStream;
  final Function(dynamic) onClickLinhaListaFiltro;

  const ListFiltro(
      {Key key,
      @required this.filtroEscolhidoStream,
      @required this.listFiltroStream,
      @required this.scrollController,
      @required this.loadingStream,
      @required this.onClickLinhaListaFiltro})
      : super(key: key);

  @override
  _ListFiltroState createState() => _ListFiltroState();
}

class _ListFiltroState extends State<ListFiltro> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.filtroEscolhidoStream,
      builder: (context, snapshot) {
        bool show = snapshot.hasData ? true : false;

        return show ? _streamLista(snapshot) : SizedBox();
      },
    );
  }

  _streamLista(AsyncSnapshot snapshot) {
    bool isLocalidadeSelected = snapshot.data == FiltroEscolhidoEnum.localicade;
    return StreamBuilder(
      stream: widget.listFiltroStream,
      builder: (context, snapshotFiltro) {
        if (snapshotFiltro.hasError) {
          return CenterText(snapshotFiltro.error.toString());
        }

        if (!snapshotFiltro.hasData) {
          return Progress();
        }
        List list = snapshotFiltro.data;

        if (list.length == 0) {
          return CenterText(
            "${isLocalidadeSelected ? "Nenhuma localidade encontrada." : "Nenhuma especilização encontrada."}",
          );
        }

        return _listViewFiltro(list);
      },
    );
  }

  _listViewFiltro(List list) {
    return ListView.separated(
      controller: widget.scrollController,
      padding: EdgeInsets.all(0),
      itemCount: list.length + 1,
      itemBuilder: (context, idx) {
        if (idx == list.length) {
          return StreamBuilder(
            stream: widget.loadingStream,
            builder: (context, snapshot) {
              bool v = snapshot.hasData ? snapshot.data : false;

              return v ? Container(height: 50, child: Progress()) : SizedBox();
            },
          );
        }

        return LinhaListaFiltro(
          item: list[idx],
          onClickLinhaListaFiltro: widget.onClickLinhaListaFiltro,
        );
      },
      separatorBuilder: (_, idx) {
        return Divider(height: 0, color: AppColors.greyFont, indent: 70);
      },
    );
  }
}
