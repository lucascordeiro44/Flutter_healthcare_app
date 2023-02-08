import 'package:intl/intl.dart';

class Notificacao {
  int id;
  String createdAt;
  String message;
  bool checked;

  Notificacao({this.id, this.createdAt, this.message, this.checked});

  DateTime get dtCreatedAt =>
      new DateFormat("dd-MM-yyyy hh:mm:ss").parse(this.createdAt);

  String get dataNotificacao =>
      DateFormat('dd/MMM/yyyy').format(dtCreatedAt).toUpperCase();

  String get horaNotificacao => "${dtCreatedAt.hour}:${dtCreatedAt.minute}";

  Notificacao.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    message = json['message'];
    checked = json['checked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdAt'] = this.createdAt;
    data['message'] = this.message;
    data['checked'] = this.checked;
    return data;
  }
}
