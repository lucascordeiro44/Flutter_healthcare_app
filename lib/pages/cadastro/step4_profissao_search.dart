import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/model/ocupation.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/center_text.dart';

class ProfissaoSearch extends StatefulWidget {
  final ProfissaoBloc bloc;

  const ProfissaoSearch({Key key, @required this.bloc}) : super(key: key);

  @override
  _ProfissaoSearchState createState() => _ProfissaoSearchState();
}

class _ProfissaoSearchState extends State<ProfissaoSearch> {
  final _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    screenView("Cadastro_Step4_Profissao", "Tela Cadastro_Profissao");

    widget.bloc.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text("Profissão"),
        backgroundColor: Color.fromRGBO(240, 239, 244, 1),
        elevation: 1,
        centerTitle: true,
      ),
      body: _body(),
    );
  }

  _body() {
    return BaseContainer(
      child: Column(
        children: <Widget>[
          _buscaInput(),
          Divider(height: 0),
          Container(height: 20, color: Color.fromRGBO(240, 239, 244, 1)),
          Divider(height: 0),
          Expanded(child: _streamProfissao()),
          _streamProgress(),
        ],
      ),
    );
  }

  _buscaInput() {
    return Container(
      padding: EdgeInsets.all(15),
      child: AppFormField(
        isCircular: true,
        prefixIcon: Icon(Icons.search, color: Colors.black26),
        onChanged: (String search) {
          widget.bloc.searchMethod(search);
        },
      ),
    );
  }

  _streamProfissao() {
    return StreamBuilder(
      stream: widget.bloc.listOcupation.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CenterText(snapshot.error);
        }

        if (!snapshot.hasData) {
          return Progress();
        }

        return snapshot.data.length > 0
            ? _listOcupation(snapshot.data)
            : _notFound();
      },
    );
  }

  _listOcupation(List<Ocupation> data) {
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.only(left: 20),
      itemCount: data.length,
      itemBuilder: (context, idx) {
        if (idx == data.length - 2) {
          widget.bloc.fetchMore();
        }
        Ocupation ocupation = data[idx];

        return _rowList(ocupation: ocupation);
      },
      separatorBuilder: (context, idx) {
        return Divider(height: 0);
      },
    );
  }

  _rowList({Ocupation ocupation}) {
    return InkWell(
      onTap: () => _onClickOcupationSelected(ocupation),
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: Text(ocupation.description),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _streamProgress() {
    return StreamBuilder(
      stream: widget.bloc.showProgress.stream,
      builder: (context, snapshot) {
        bool v = snapshot.hasData ? snapshot.data : false;
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: v ? 60 : 0,
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 0.5, color: AppColors.greyFontLow),
            ),
          ),
          child: Progress(isCenter: true),
        );
      },
    );
  }

  _onClickOcupationSelected(Ocupation ocupation) {
    pop(result: ocupation);
  }

  _notFound() {
    return Center(child: Text("Nenhuma opção encontrada!"));
  }
}
