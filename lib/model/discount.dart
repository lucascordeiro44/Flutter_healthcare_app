class Discount {
  String name;
  String description;
  String couponCode;
  num discount;
  String applyMonth;
  String code;
  String discountFormatted;

  Discount({
    this.name,
    this.description,
    this.couponCode,
    this.discount,
    this.applyMonth,
    this.discountFormatted,
  });

  Discount.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    couponCode = json['couponCode'];
    discount = json['discount'];
    applyMonth = json['applyMonth'];
    discountFormatted = json['discountFormatted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['description'] = this.description;
    data['couponCode'] = this.couponCode;
    data['discount'] = this.discount;
    data['applyMonth'] = this.applyMonth;
    data['discountFormatted'] = this.discountFormatted;
    return data;
  }
}
