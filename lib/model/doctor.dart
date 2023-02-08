import 'package:flutter_dandelin/model/councils.dart';
import 'package:flutter_dandelin/model/expertise.dart';
import 'package:flutter_dandelin/model/user.dart';

class Doctor {
  int id;
  String doctorStatus;
  double averageRating;
  User user;
  List<Expertise> expertises;
  List<Council> councils;
  bool covid19;

  Doctor({
    this.id,
    this.user,
    this.expertises,
    this.councils,
    this.covid19,
  });

  bool get showCovidLabel => covid19 ?? false;

  Doctor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorStatus = json['doctorStatus'];
    averageRating = json['averageRating'] as double;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    if (json['expertises'] != null) {
      expertises = new List<Expertise>();
      json['expertises'].forEach((v) {
        expertises.add(new Expertise.fromJson(v));
      });
    }
    if (json['councils'] != null) {
      councils = new List<Council>();
      json['councils'].forEach((v) {
        councils.add(new Council.fromJson(v));
      });
    }
    covid19 = json['covid19'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doctorStatus'] = doctorStatus;
    data['averageRating'] = averageRating;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    if (this.expertises != null) {
      data['expertises'] = this.expertises.map((v) => v.toJson()).toList();
    }
    if (this.councils != null) {
      data['councils'] = this.councils.map((v) => v.toJson()).toList();
    }
    data['covid19'] = covid19;
    return data;
  }

  Map<String, dynamic> toGA() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.user != null) {
      this.user.toGA().forEach((key, value) {
        data["doctor_$key"] = value;
      });
    }

    return data;
  }
}
