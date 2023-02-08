class Council {
  int id;
  String council;
  String numberCouncil;
  String councilDistrict;

  Council({this.id, this.council, this.numberCouncil, this.councilDistrict});

  Council.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    council = json['council'];
    numberCouncil = json['numberCouncil'];
    councilDistrict = json['councilDistrict'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['council'] = this.council;
    data['numberCouncil'] = this.numberCouncil;
    data['councilDistrict'] = this.councilDistrict;
    return data;
  }
}
