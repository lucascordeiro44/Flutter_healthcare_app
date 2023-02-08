import 'package:flutter_dandelin/model/address.dart';
import 'package:flutter_dandelin/model/doctor.dart';

class ScheduleDoctor {
  int id;
  String segment;
  List<String> daysService;
  num duration;
  String start;
  String end;
  Address address;
  Doctor doctor;
  num price;
  bool preview;

  ScheduleDoctor({
    this.id,
    this.segment,
    this.daysService,
    this.duration,
    this.start,
    this.end,
    this.address,
    this.doctor,
    this.price,
    this.preview,
  });

  ScheduleDoctor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    segment = json['segment'];
    daysService = json['daysService'].cast<String>();
    duration = json['duration'];
    start = json['start'];
    end = json['end'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    doctor =
        json['doctor'] != null ? new Doctor.fromJson(json['doctor']) : null;
    price = json['price'];
    preview = json['preview'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['segment'] = this.segment;
    data['daysService'] = this.daysService;
    data['duration'] = this.duration;
    data['start'] = this.start;
    data['end'] = this.end;
    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
    if (this.doctor != null) {
      data['doctor'] = this.doctor.toJson();
    }
    data['price'] = this.price;
    data['preview'] = this.preview;
    return data;
  }

  toGA() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.doctor != null) {
      this.doctor.toGA().forEach((key, value) {
        data["doctor_$key"] = value;
      });
    }

    return data;
  }
}
