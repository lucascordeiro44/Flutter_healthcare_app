import 'package:flutter_dandelin/model/address.dart';
import 'package:flutter_dandelin/model/doctor.dart';
import 'package:flutter_dandelin/model/rating.dart';
import 'package:flutter_dandelin/model/role.dart';
import 'package:flutter_dandelin/model/schedule_doctor.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/utils/datetime_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Consulta {
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
  String scheduleAt;
  List<String> avaliability;
  String status;
  int fraudeVerify;
  int fraude;
  ScheduleDoctor scheduleDoctor;
  User user;
  bool markerSelected;
  Rating rating;

  Scheduler scheduler;

  String telemedicineURL;
  bool telemedicine;

  String zoomURL;
  int zoomMeetingId;
  String zoomUserId;

  Consulta({
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
    this.scheduleAt,
    this.avaliability,
    this.status,
    this.fraude,
    this.fraudeVerify,
    this.scheduleDoctor,
    this.user,
    this.markerSelected = false,
    this.rating,
    this.telemedicine,
    this.telemedicineURL,
    this.scheduler,
    this.zoomURL,
    this.zoomMeetingId,
    this.zoomUserId,
  });

  bool get isAtendido => status == "ATENDIDO";
  bool get isCancelado => status == "CANCELADO";
  bool get ratingDone => this.rating != null;

  bool get naoConfirmado => status == "NAO_CONFIRMADO";
  bool get naoAtendido => status == "NAO_ATENDIDA";
  bool get doctorChangedSchedule =>
      this.scheduler?.id == this.scheduleDoctor.doctor.user.id;

  LatLng getAdress(bool isConsultaMarcada) {
    LatLng latLng;

    if (isConsultaMarcada) {
      latLng = scheduleDoctor.address.latLntOk
          ? new LatLng(
              scheduleDoctor.address.latitude, scheduleDoctor.address.longitude)
          : null;
    } else {
      latLng = address.latLntOk
          ? new LatLng(address.latitude, address.longitude)
          : null;
    }

    return latLng;
  }

  Consulta.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    segment = json['segment'];
    daysService =
        json['daysService'] != null ? json['daysService'].cast<String>() : null;
    duration = json['duration'];
    start = json['start'];
    end = json['end'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    doctor =
        json['doctor'] != null ? new Doctor.fromJson(json['doctor']) : null;
    price = json['price'];
    preview = json['preview'];
    scheduleAt = json['scheduleAt'];
    avaliability = json['avaliability'] != null
        ? json['avaliability'].cast<String>()
        : null;
    status = json['status'];
    fraudeVerify = json['fraudeVerify'];
    fraude = json['fraude'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    scheduleDoctor = json['scheduleDoctor'] != null
        ? new ScheduleDoctor.fromJson(json['scheduleDoctor'])
        : null;
    scheduleAt = json['scheduledAt'];
    rating =
        json['rating'] != null ? new Rating.fromJson(json['rating']) : null;

    telemedicine = json['telemedicine'];
    telemedicineURL = json['telemedicineURL'];
    telemedicine = json['telemedicine'];
    scheduler = json['scheduler'] != null
        ? new Scheduler.fromJson(json['scheduler'])
        : null;

    zoomURL = json['zoomURL'];
    zoomMeetingId = json['zoomMeetingId'];
    zoomUserId = json['zoomUserId'];
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
    data['scheduleAt'] = this.scheduleAt;
    data['avaliability'] = this.avaliability;
    data['status'] = this.status;
    data['fraudeVerify'] = this.fraudeVerify;
    data['fraude'] = this.fraude;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    if (this.scheduleDoctor != null) {
      data['scheduleDoctor'] = this.scheduleDoctor.toJson();
    }
    if (this.rating != null) {
      data['rating'] = this.rating.toJson();
    }
    data['telemedicine'] = this.telemedicine;
    data['telemedicineURL'] = this.telemedicineURL;
    data['telemedicine'] = this.telemedicine;
    data['scheduler'] = this.scheduler;

    data['zoomURL'] = this.zoomURL;
    data['zoomMeetingId'] = this.zoomMeetingId;
    data['zoomUserId'] = this.zoomUserId;

    return data;
  }

  Map<String, dynamic> toGA() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.doctor != null) {
      this.doctor.toGA().forEach((key, value) {
        data[key] = value;
      });
    }
    data['scheduleAt'] = this.scheduleAt;

    if (this.scheduleDoctor != null) {
      this.scheduleDoctor.toGA().forEach((key, value) {
        data[key] = value;
      });
    }

    return data;
  }

  static String getDoctorFullName(Consulta consulta,
      {bool fromScheduleDoctor = true}) {
    return fromScheduleDoctor
        ? consulta.scheduleDoctor.doctor.user.getUserFullName
        : consulta.doctor.user.getUserFullName;
  }

  static String getDoctorFullCrm(Consulta consulta,
      {int idx = 0, bool fromScheduleDoctor = true}) {
    if (fromScheduleDoctor &&
        consulta.scheduleDoctor.doctor.councils.length == 0) {
      return "";
    }

    if (!fromScheduleDoctor && consulta.doctor.councils.length == 0) {
      return "";
    }

    return fromScheduleDoctor
        ? "${consulta.scheduleDoctor.doctor.councils[idx].council} ${consulta.scheduleDoctor.doctor.councils[idx].numberCouncil}"
        : "${consulta.doctor.councils[idx].council} ${consulta.doctor.councils[idx].numberCouncil}";
  }

  static String getDoctorFullAddress(Consulta consulta,
      {bool fromScheduleDoctor = true}) {
    return fromScheduleDoctor
        ? consulta.scheduleDoctor.address.getFullAddress
        : consulta.address.getFullAddress;
  }

  static LatLng getDoctorLatLng(Consulta consulta,
      {bool fromScheduleDoctor = true}) {
    return fromScheduleDoctor
        ? LatLng(consulta.scheduleDoctor.address.latitude,
            consulta.scheduleDoctor.address.longitude)
        : LatLng(consulta.address.latitude, consulta.address.longitude);
  }

  static String getExpertises(Consulta consulta,
      {bool fromScheduleDoctor = true}) {
    String expertises = '';
    int expLength;

    if (fromScheduleDoctor) {
      if (consulta.scheduleDoctor.doctor.expertises != null &&
          consulta.scheduleDoctor.doctor.expertises.length > 0) {
        expLength = consulta.scheduleDoctor.doctor.expertises.length;
        for (int i = 0; i < expLength; i++) {
          expertises =
              "$expertises${consulta.scheduleDoctor.doctor.expertises[i].name}";
          if (i != (expLength - 1)) {
            expertises = "$expertises, ";
          }
        }
      }
    } else {
      if (consulta.doctor.expertises != null &&
          consulta.doctor.expertises.length > 0) {
        expLength = consulta.doctor.expertises.length;
        for (int i = 0; i < expLength; i++) {
          expertises = "$expertises${consulta.doctor.expertises[i].name}";
          if (i != (expLength - 1)) {
            expertises = "$expertises, ";
          }
        }
      }
    }

    return expertises;
  }

  static String getHorarioConsulta(Consulta consulta) {
    DateTime dateTime = stringToDateTimeWithMinutes(consulta.scheduleAt);

    String dia = addZeroDate(dateTime.day);
    String mes = addZeroDate(dateTime.month);
    String ano = dateTime.year.toString();

    String hora = addZeroDate(dateTime.hour);
    String minutos = addZeroDate(dateTime.minute);

    return "$dia/$mes/$ano | $hora:$minutos";
  }

  static Consulta consultaSemHorariosInvalidos(
      Map<String, dynamic> json, DateTime datetimeFiltro) {
    Consulta consulta = Consulta.fromJson(json);

    consulta.avaliability =
        removeHorariosInvalidos(consulta.avaliability, datetimeFiltro);

    return consulta;
  }
}

class Scheduler {
  int id;
  String username;
  Role role;

  Scheduler({this.id, this.username, this.role});

  Scheduler.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    role = json['role'] != null ? new Role.fromJson(json['role']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    if (this.role != null) {
      data['role'] = this.role.toJson();
    }
    return data;
  }
}
