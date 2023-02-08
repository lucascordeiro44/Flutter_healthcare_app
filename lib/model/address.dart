import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class Address {
  int id;
  String address;
  String addressNumber;
  String complement;
  String neighborhood;
  String zipCode;
  String city;
  String state;
  String country;
  num longitude;
  num latitude;
  String type;
  String name;
  String phone;
  String mobilePhone;

  String get telefone => isNotEmpty(mobilePhone) ? mobilePhone : phone;

  Address({
    this.id,
    this.address,
    this.addressNumber,
    this.complement,
    this.neighborhood,
    this.zipCode,
    this.city,
    this.state,
    this.country,
    this.longitude,
    this.latitude,
    this.type,
    this.name,
  });

  bool get latLntOk =>
      latitude != null && latitude != 0 && longitude != null && longitude != 0;

  String get getClinica => name == null ? "" : name;

  String get getFullAddress =>
      "$address $addressNumber" +
      "${complement != null && complement != "" ? ", " + complement : ""} - $neighborhood \n$city, $state ";

  String get getHomeAdress =>
      "$address" + ", " + "$addressNumber" + " - " + "$neighborhood";

  LatLng get getLatLng => latLntOk ? LatLng(latitude, longitude) : null;

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    addressNumber = json['addressNumber'];
    complement = json['complement'];
    neighborhood = json['neighborhood'];
    zipCode = json['zipCode'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    name = json['name'];
    phone = json['phone'];
    mobilePhone = json['mobilePhone'];
    // type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['addressNumber'] = this.addressNumber;
    data['complement'] = this.complement;
    data['neighborhood'] = this.neighborhood;
    data['zipCode'] = this.zipCode;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['type'] = this.type;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['mobilePhone'] = this.mobilePhone;

    return data;
  }

  Map<String, dynamic> toGA() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['zipCode'] = this.zipCode;
    data['city'] = this.city;
    data['state'] = this.state;

    return data;
  }
}
