import 'package:flutter_dandelin/constants.dart';
import 'package:flutter_dandelin/model/address.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class City {
  String name;
  bool isSelected;

  City({this.name});

  City.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['name'] = this.name;

    return data;
  }

  City.cityDefault({City citySelected}) {
    String userCity = appBloc.user.cidadeEsado;

    name = isNotEmpty(userCity) ? userCity : kLocalidadeBase;

    isSelected = citySelected == null
        ? true
        : isCitySelected(city: this, citySelected: citySelected);
  }

  City.fromAddress(Address address) {
    name = "${address.city}, ${address.state}";
    isSelected = true;
  }

  static bool isCitySelected({City city, City citySelected}) {
    return city.name == citySelected.name;
  }
}
