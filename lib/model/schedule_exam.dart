import 'package:flutter_dandelin/model/address.dart';
import 'package:flutter_dandelin/model/exam.dart';
import 'package:flutter_dandelin/model/laboratory.dart';

class ScheduleExam {
  int id;
  String createdAt;
  List<String> daysService;
  int duration;
  Address address;
  Exam exam;
  Laboratory laboratory;

  ScheduleExam(
      {this.id,
      this.createdAt,
      this.daysService,
      this.duration,
      this.address,
      this.exam,
      this.laboratory});

  ScheduleExam.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    daysService = json['daysService'].cast<String>();
    duration = json['duration'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    exam = json['exam'] != null ? new Exam.fromJson(json['exam']) : null;
    laboratory = json['laboratory'] != null
        ? new Laboratory.fromJson(json['laboratory'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdAt'] = this.createdAt;
    data['daysService'] = this.daysService;
    data['duration'] = this.duration;
    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
    if (this.exam != null) {
      data['exam'] = this.exam.toJson();
    }
    if (this.laboratory != null) {
      data['laboratory'] = this.laboratory.toGA();
    }
    return data;
  }

  Map<String, dynamic> toGA() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.address != null) {
      this.address.toGA().forEach((key, value) {
        data[key] = value;
      });
    }
    if (this.exam != null) {
      this.exam.toGA().forEach((key, value) {
        data[key] = value;
      });
    }
    if (this.laboratory != null) {
      this.laboratory.toGA().forEach((key, value) {
        data[key] = value;
      });
    }
    return data;
  }
}
