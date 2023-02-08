import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class ChatDetalheApi {
  static Future<HttpResponse> getChat(User user, User medico) async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceName;
      String deviceOsVersion;
      String deviceOs;

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceOs = "android";
        deviceName = androidInfo.model;
        deviceOsVersion = androidInfo.version.sdkInt.toString();
      } else {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceOs = "ios";
        deviceName = iosInfo.model;
        deviceOsVersion = iosInfo.systemVersion;
      }

      var url = "https://dandelin.livetouchdev.com.br/rest/chat/login";

      var map = {
        "user": {
          "login": user.username,
          "email": user.username,
          "nome": user.getUserFullName,
          "urlFoto": user.avatar,
          "device": {
            "registrationId": await FirebaseMessaging().getToken(),
            "deviceName": deviceName,
            "deviceOs": deviceOs,
            "deviceOsVersion": deviceOsVersion,
            "appVersionCode": kAppVersionCode,
            "appVersion": kAppVersion,
          },
        },
        "user2": {
          "login": medico.username,
          "email": medico.username,
          "nome": medico.getUserFullName,
          "urlFoto": medico.avatar
        }
      };

      HttpResponse response = await post(url, map);

      bool ok = response.data["status"] == "OK";

      if (ok) {
        return response;
      }

      return null;
    } on SocketException {
      throw kOnSocketException;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } on ForbiddenException {
      throw TimeoutException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause;
      }
      throw error.toString();
    }
  }
}
