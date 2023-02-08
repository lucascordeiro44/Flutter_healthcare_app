import 'package:flutter_dandelin/constants.dart';

class Expertise {
  int id;
  String name;
  bool isSelected;
  String slug;
  String description;

  Expertise({this.id, this.name, this.slug});

  Expertise.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['description'] = this.description;
    return data;
  }

  Expertise.expertiseDefault({Expertise expertiseSelected}) {
    id = 0;
    name = kExpertiseBase;
    isSelected = expertiseSelected == null
        ? true
        : isExpertiseSelected(
            expertise: this, expertiseSelected: expertiseSelected);
  }

  static bool isExpertiseSelected(
      {Expertise expertise, Expertise expertiseSelected}) {
    return expertise.id == expertiseSelected?.id;
  }

  @override
  String toString() {
    return '$name';
  }
}
