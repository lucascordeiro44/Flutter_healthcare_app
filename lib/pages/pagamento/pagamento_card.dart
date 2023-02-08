import 'package:flutter/material.dart';
import 'package:flutter_dandelin/model/pagamento.dart';

class PagamentoCard extends StatelessWidget {
  final Pagamento pagamento;
  final Function(Pagamento, {bool mainPagamento, bool moreThanOnePayment})
      onClickPagamentoDetalhe;
  final bool showDeletarButton;
  final bool moreThanOnePayment;

  const PagamentoCard(
      {Key key,
      @required this.onClickPagamentoDetalhe,
      @required this.pagamento,
      this.showDeletarButton,
      this.moreThanOnePayment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String number = pagamento.number.substring(pagamento.number.length - 4);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      color: pagamento.isMain ? Theme.of(context).primaryColor : null,
      child: ListTile(
        onTap: () {
          onClickPagamentoDetalhe(pagamento,
              mainPagamento: false, moreThanOnePayment: moreThanOnePayment);
        },
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        leading: _creditorIcon(),
        title: Text(
          "**** $number",
          style: TextStyle(
            fontWeight: pagamento.isMain ? FontWeight.w600 : null,
            color: pagamento.isMain ? Colors.white : null,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color:
              pagamento.isMain ? Colors.white : Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  _creditorIcon() {
    String image;

    switch (pagamento.creditor) {
      case "mastercard":
        image = 'assets/images/mastercard-card-logo.png';
        break;
      case "visa":
        image = 'assets/images/visa-card-logo.png';
        break;
      case "elo":
        image = 'assets/images/elo-card-logo.png';
        break;
      case "american express":
        image = 'assets/images/american-express-card-logo.png';
        break;
      case "diners club":
        image = 'assets/images/diners-club-card-logo.png';
        break;
      default:
    }

    return image != null ? Image.asset(image, height: 25) : SizedBox();
  }
}
