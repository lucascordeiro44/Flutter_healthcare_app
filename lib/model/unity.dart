import 'package:flutter_dandelin/model/address.dart';
import 'package:flutter_dandelin/model/exam.dart';
import 'package:flutter_dandelin/model/laboratory.dart';
import 'package:flutter_dandelin/utils/datetime_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Unity {
  int id;
  List<String> daysService;
  int duration;
  String start;
  String end;
  Address address;
  Exam exam;
  List<String> avaliability;
  bool markerSelected;
  Laboratory laboratory;

  Unity({
    this.id,
    this.daysService,
    this.duration,
    this.start,
    this.end,
    this.address,
    this.exam,
    this.avaliability,
    this.laboratory,
  });

  Unity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    daysService = json['daysService'].cast<String>();
    duration = json['duration'];
    start = json['start'];
    end = json['end'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    exam = json['exam'] != null ? new Exam.fromJson(json['exam']) : null;
    avaliability = json['avaliability'].cast<String>();
    laboratory = json['laboratory'] != null
        ? new Laboratory.fromJson(json['laboratory'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['daysService'] = this.daysService;
    data['duration'] = this.duration;
    data['start'] = this.start;
    data['end'] = this.end;
    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
    if (this.exam != null) {
      data['exam'] = this.exam.toJson();
    }
    if (this.laboratory != null) {
      data['laboratory'] = this.laboratory.toJson();
    }
    data['avaliability'] = this.avaliability;
    return data;
  }

  LatLng getAdress(Unity unity) {
    return unity.address.getLatLng;
  }

  static Unity unidadeSemHorariosInvalidos(json, DateTime datetimeFiltro) {
    Unity unity = Unity.fromJson(json);

    unity.avaliability =
        removeHorariosInvalidos(unity.avaliability, datetimeFiltro);

    return unity;
  }
}
