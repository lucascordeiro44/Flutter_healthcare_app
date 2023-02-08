class Ocupation {
  int id;
  String description;
  Partnership partnership;

  Ocupation({this.id, this.description, this.partnership});

  Ocupation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    partnership = json['partnership'] != null
        ? new Partnership.fromJson(json['partnership'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    // if (this.partnership != null) {
    //   data['partnership'] = this.partnership.toJson();
    // }
    return data;
  }
}

class Partnership {
  int id;
  String createdAt;
  String name;
  String code;
  String description;

  Partnership(
      {this.id, this.createdAt, this.name, this.code, this.description});

  Partnership.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    name = json['name'];
    code = json['code'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdAt'] = this.createdAt;
    data['name'] = this.name;
    data['code'] = this.code;
    data['description'] = this.description;
    return data;
  }
}
