import 'package:flutter_dandelin/model/rating.dart';
import 'package:flutter_dandelin/model/schedule_exam.dart';

class Exam {
  int id;
  String customerAt;
  String code;
  String title;
  String description;
  String preRequisites;
  String orientation;
  double price;

  String status;
  String scheduledAt;
  String createdAt;
  int duration;
  ScheduleExam scheduleExam;
  Rating rating;
  bool markerSelected;

  Exam({
    this.id,
    this.customerAt,
    this.code,
    this.title,
    this.description,
    this.preRequisites,
    this.orientation,
    this.price,
    this.status,
    this.scheduledAt,
    this.createdAt,
    this.duration,
    this.scheduleExam,
    this.rating,
    this.markerSelected,
  });

  Exam.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerAt = json['customerAt'];
    code = json['code'];
    title = json['title'];
    description = json['description'];
    preRequisites = json['preRequisites'];
    orientation = json['orientation'];
    price = json['price'];
    status = json['status'];
    scheduledAt = json['scheduledAt'];
    createdAt = json['createdAt'];
    duration = json['duration'];
    scheduleExam = json['scheduleExam'] != null
        ? new ScheduleExam.fromJson(json['scheduleExam'])
        : null;
    rating =
        json['rating'] != null ? new Rating.fromJson(json['rating']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customerAt'] = this.customerAt;
    data['code'] = this.code;
    data['title'] = this.title;
    data['description'] = this.description;
    data['preRequisites'] = this.preRequisites;
    data['orientation'] = this.orientation;
    data['price'] = this.price;
    data['status'] = this.status;
    data['scheduledAt'] = this.scheduledAt;
    data['createdAt'] = this.createdAt;
    data['duration'] = this.duration;
    if (this.scheduleExam != null) {
      data['scheduleExam'] = this.scheduleExam.toJson();
    }
    if (this.rating != null) {
      data['rating'] = this.rating.toJson();
    }
    return data;
  }

  Map<String, dynamic> toGA() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['title'] = this.title;

    data['scheduledAt'] = this.scheduledAt;
    data['createdAt'] = this.createdAt;

    if (this.scheduleExam != null) {
      this.scheduleExam.toGA().forEach((key, value) {
        data[key] = value;
      });
    }

    return data;
  }
}
