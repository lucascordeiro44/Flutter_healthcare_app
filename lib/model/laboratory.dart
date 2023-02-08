import 'package:flutter_dandelin/model/role.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class Laboratory {
  int id;
  String createdAt;
  String document;
  String username;
  String name;
  String title;
  String phone;
  String mobilePhone;
  bool isSelected;
  Role role;

  Laboratory(
      {this.id,
      this.createdAt,
      this.document,
      this.username,
      this.name,
      this.phone,
      this.title,
      this.mobilePhone,
      this.isSelected,
      this.role});

  Laboratory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    document = json['document'];
    username = json['username'];
    title = json['title'];
    name = json['name'];
    phone = json['phone'];
    mobilePhone = json['mobilePhone'];
    role = json['role'] != null ? new Role.fromJson(json['role']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdAt'] = this.createdAt;
    data['document'] = this.document;
    data['username'] = this.username;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['title'] = this.title;
    data['mobilePhone'] = this.mobilePhone;
    if (this.role != null) {
      data['role'] = this.role.toJson();
    }
    return data;
  }

  Map<String, dynamic> toGA() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['username'] = this.username;
    data['name'] = this.name;

    data['title'] = this.title;

    if (this.role != null) {
      this.role.toJson().forEach((key, value) {
        data[key] = value;
      });
    }
    return data;
  }

  Laboratory.laboratoryDefault({Laboratory laboratorySelected}) {
    id = 0;
    username = kLaboratoryBase;
    name = kLaboratoryBase;
    isSelected = laboratorySelected == null
        ? true
        : isLaboratorySelected(
            laboratory: this, laboratorySelected: laboratorySelected);
  }

  static bool isLaboratorySelected(
      {Laboratory laboratory, Laboratory laboratorySelected}) {
    return laboratory.id == laboratorySelected?.id;
  }
}
