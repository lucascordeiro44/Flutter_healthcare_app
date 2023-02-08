import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dandelin/model/user.dart';

class Cupom {

  int id;
  Partnership partnership;
  User user;
  String code;
  String appliedAt;
  String status;
  String discount;
  int recurrence;

  Cupom(this.id, this.status, this.appliedAt, this.partnership, this.user,
      this.recurrence, this.code, this.discount);

  DateTime get dtappliedAt =>
      new DateFormat("dd-MM-yyyy hh:mm:ss").parse(this.appliedAt);

  DateFormat dateFormat = DateFormat("dd/MM/yyyy");

  String get stringDtappliedAt => dateFormat.format(dtappliedAt);

  Cupom.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    partnership = json['partnership'] != null ? new Partnership.fromJson(json['partnership']) : null;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    appliedAt = json['appliedAt'];
    discount = json['discount'].toString();
    code = json['code'];
    status = json['status'];
    recurrence = json['recurrence'];
  }
}


class Partnership {
  int id;
  String createdAt;
  String name;
  String description;
  String code;
  String couponCode;
  double discount;
  String discountFormatted;
  String usageType;
  String status;
  int recurrence;

  Partnership({this.id, this.createdAt, this.name, this.description, this.code, this.couponCode, this.discount, this.discountFormatted, this.usageType, this.status, this.recurrence});

  Partnership.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    name = json['name'];
    description = json['description'];
    code = json['code'];
    couponCode = json['couponCode'];
    discount = json['discount'] as double;
    discountFormatted = json['discountFormatted'];
    usageType = json['usageType'];
    status = json['status'];
    recurrence = json['recurrence'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdAt'] = this.createdAt;
    data['name'] = this.name;
    data['description'] = this.description;
    data['code'] = this.code;
    data['couponCode'] = this.couponCode;
    data['discount'] = this.discount;
    data['discountFormatted'] = this.discountFormatted;
    data['usageType'] = this.usageType;
    data['status'] = this.status;
    data['recurrence'] = this.recurrence;
    return data;
  }
}