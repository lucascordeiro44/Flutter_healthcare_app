class PriceCommunity {
  int id;
  String createdAt;
  String updatedAt;
  String priceMobile;
  num discount;
  String lastUpdate;

  PriceCommunity({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.priceMobile,
    this.discount,
    this.lastUpdate,
  });

  PriceCommunity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    priceMobile = json['priceMobile'];
    discount = json['discount'];
    lastUpdate = json['lastUpdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['priceMobile'] = this.priceMobile;
    data['discount'] = this.discount;
    data['lastUpdate'] = this.lastUpdate;
    return data;
  }
}
