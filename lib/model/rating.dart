import 'package:flutter_dandelin/utils/datetime_helper.dart';

class Rating {
  int id;
  bool viewed;
  String customerAt;
  num rating;
  String comment;
  int idConsulta;
  String type;

  Rating(
      {this.id,
      this.customerAt,
      this.rating,
      this.comment,
      this.idConsulta,
      this.type});

  Rating.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    viewed = json['viewed'];
    customerAt = json['customerAt'];
    rating = json['rating'];
    comment = json['comment'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['viewed'] = viewed;
    data['customerAt'] = dateTimeFormatHMS();
    data['rating'] = this.rating;
    data['comment'] = this.comment;
    data['schedule'] = {
      'id': this.idConsulta,
    };
    data['type'] = type;
    return data;
  }
}
