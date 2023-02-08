class Biling {
  int id;
  String userFullName;
  String description;
  String paymentAt;
  String gatewayId;
  num price;
  num discount;
  num total;
  String status;
  String reason;
  String url;
  String createdAt;
  String updatedAt;

  Biling(
      {this.id,
      this.userFullName,
      this.description,
      this.paymentAt,
      this.gatewayId,
      this.price,
      this.discount,
      this.total,
      this.status,
      this.reason,
      this.url,
      this.createdAt,
      this.updatedAt});

  Biling.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userFullName = json['userFullName'];
    description = json['description'];
    paymentAt = json['paymentAt'];
    gatewayId = json['gatewayId'];
    price = json['price'];
    discount = json['discount'];
    total = json['total'];
    status = json['status'];
    reason = json['reason'];
    url = json['url'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userFullName'] = this.userFullName;
    data['description'] = this.description;
    data['paymentAt'] = this.paymentAt;
    data['gatewayId'] = this.gatewayId;
    data['price'] = this.price;
    data['discount'] = this.discount;
    data['total'] = this.total;
    data['status'] = this.status;
    data['reason'] = this.reason;
    data['url'] = this.url;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
