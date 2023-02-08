import 'package:flutter_dandelin/utils/imports.dart';

class Native {
  static const platform = const MethodChannel("dandelin");

  static callZoomActivity(
    String userName,
    String userId,
    int meetingId,
    String name,
    String expertise,
    String avatar,
  ) async {
    try {
      await platform.invokeMethod("openZoomActivity", <String, dynamic>{
        'userName': userName,
        'userId': userId,
        'meetingId': meetingId,
        'doctorName': name,
        'doctorExpertise': expertise,
        'doctorAvatar': avatar,
      });
    } on PlatformException catch (e) {
      print(e.message);
    }
  }
}
