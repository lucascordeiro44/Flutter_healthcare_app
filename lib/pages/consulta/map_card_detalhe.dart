import 'package:flutter_dandelin/utils/imports.dart';

class MapCardDetalhe extends StatelessWidget {
  final Key headerDetalheKey;
  final Function onPressed;

  const MapCardDetalhe(
      {Key key, @required this.headerDetalheKey, @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(160),
      child: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 1,
        leading: IconButton(
          onPressed: onPressed,
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 40,
          ),
        ),
        centerTitle: true,
        title: Text(
          "Consulta Médica",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        flexibleSpace: _detalhes(),
      ),
    );
  }

  _detalhes() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(gradient: linearEnabled),
        padding: EdgeInsets.only(left: 16.0, right: 16, bottom: 24, top: 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _columnDados(),
            _image(),
          ],
        ),
      ),
    );
  }

  _columnDados() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          AppText('Ortopedia',
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          AppText('Avelino Teixeira Neto',
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          AppText('CRM 75600',
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ],
      ),
    );
  }

  _image() {
    return Image.asset('assets/images/old-man-without-circle.png', height: 70);
  }
}
