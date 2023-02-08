import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:flutter_dandelin/utils/datetime_helper.dart';
import 'package:flutter_dandelin/utils/validators.dart';

class Pagamento {
  int id;
  String number;
  String name;
  String customerAt;
  String month;
  String year;
  String dataValidade;
  String ccv;
  String main;
  String creditor;

  get isMain => main == "1";
  Pagamento({
    this.id,
    this.number,
    this.name,
    this.customerAt,
    this.month,
    this.year,
    this.dataValidade,
    this.ccv,
    this.main,
    this.creditor,
  });

  bool validate() {
    return isNotEmpty(name) &&
        isNotEmpty(number) &&
        isNotEmpty(dataValidade) &&
        isNotEmpty(ccv);
  }

  Pagamento.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json["number"];
    name = json["name"];
    customerAt = json["customerAt"];
    month = json["month"];
    year = json["year"];
    dataValidade = "$month/$year";
    ccv = json["ccv"];
    main = json["main"];
    creditor = json["creditor"];
  }

  Map<String, dynamic> toJson({bool editar = false}) {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['id'] = this.id;
    if (!editar) {
      data['number'] = this.number.replaceAll(' ', '');
    }
    var array = this.dataValidade.split('/');
    data['month'] = array[0];
    data['year'] = array[1];
    data['ccv'] = this.ccv;
    data['name'] = this.name;
    data['customerAt'] = dateTimeFormatHMS();

    data['main'] = this.main;
    data['creditor'] =
        this.creditor == null ? _getCreditor(this.number) : this.creditor;

    return data;
  }

  _getCreditor(String number) {
    CreditCardType type = detectCCType(number);

    switch (type) {
      case CreditCardType.amex:
        return "american express";
        break;
      case CreditCardType.dinersclub:
        return "diners club";
        break;
      case CreditCardType.discover:
        return "discover";
        break;
      case CreditCardType.elo:
        return "elo";
        break;
      case CreditCardType.hiper:
        return "hiper";
        break;
      case CreditCardType.hipercard:
        return "hipercard";
        break;
      case CreditCardType.jcb:
        return "jcb";
        break;
      case CreditCardType.maestro:
        return "maestro";
        break;
      case CreditCardType.mastercard:
        return "mastercard";
        break;
      case CreditCardType.mir:
        return "mir";
        break;
      case CreditCardType.unionpay:
        return "unionpay";
        break;
      case CreditCardType.unknown:
        return "unknown";
        break;
      case CreditCardType.visa:
        return "visa";
        break;

      default:
        return "unknown";
        break;
    }
  }
}
