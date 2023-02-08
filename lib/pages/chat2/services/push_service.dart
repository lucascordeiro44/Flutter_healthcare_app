import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter_dandelin/pages/chat2/constants_chat.dart';
import 'package:flutter_dandelin/pages/chat2/firebase_chat.dart';
import 'package:flutter_dandelin/pages/chat2/services/services.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils_livecom/http_helper.dart';
import 'package:package_info/package_info.dart';

class PushService {
    static sendTokenToPushServer() {
      fcm.getToken().then((token) {
        print("Token $token");
        PushService.register(token);
      });
  }

  static Future<ApiResponse<bool>> register(String token) async {
    try {
      var url = PUSH_BASE_URL;

      final headers = {
        "Content-Type": "application/json",
        "Authorization": PUSH_AUTHORIZATION
      };

      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      User user = await User.getPrefs();
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      String deviceName;
      String deviceOsVersion;

      if (Platform.isAndroid) {
        AndroidDeviceInfo info = await deviceInfo.androidInfo;
        deviceName = info.model;
        deviceOsVersion = info.version.codename;
      } else {
        IosDeviceInfo info = await deviceInfo.iosInfo;
        deviceName = info.name;
        deviceOsVersion = info.systemVersion;
      }

      final body = convert.json.encode({
        "registrationId": token,
        "projectCode": PUSH_PROJECT,
        "userCode": user.login,
        "userEmail": user.email,
        "deviceOs": Platform.isAndroid ? "android" : "iOS",
        "deviceName": deviceName,
        "deviceOsVersion": deviceOsVersion,
        "appVersionCode": "${packageInfo.buildNumber}",
        "appVersion": packageInfo.version
      });

      final map = await HttpHelper.post(url, body: body, headers: headers);

      String status = map["status"];
      String msg = map["mensagem"];
      bool ok = "OK" == status;
      if (ok) {
        return ApiResponse.ok(msg: msg);
      } else {
        return ApiResponse.error(msg);
      }
    } catch (error) {
      return ApiResponse.error(handleError(error));
    }
  }

  // static FutureOr<http.Response> _onTimeout() {
  //   throw SocketException("Não foi possível se comunicar com o servidor");
  // }
}
