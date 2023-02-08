import 'package:flutter/material.dart';
import 'package:flutter_dandelin/utils/gps_utils.dart';
import 'package:url_launcher/url_launcher.dart';

callPhone(String phone) {
  launch("tel:+55$phone");
}

//https://github.com/flutter/flutter/issues/21115
openMaps(num latitude, num longitude) {
  GPSUtils.getLoc().then((location) {
    if (location != null) {
      String lat = location.latitude.toString().replaceAll(',', '.');
      String long = location.longitude.toString().replaceAll(',', '.');

      canLaunch(
              "https://www.google.com/maps/dir/$lat,$long/$latitude,$longitude ")
          .then((v) {
        if (v) {
          launch(
              "https://www.google.com/maps/dir/$lat,$long/$latitude,$longitude");
        } else {
          launch(
              "https://www.waze.com/livemap/directions?navigate=yes&latlng=$latitude%2C$longitude&zoom=17");
        }
      });
    }
  });
}

isIOS(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS;
}
