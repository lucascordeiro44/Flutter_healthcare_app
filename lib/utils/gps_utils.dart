import 'package:location/location.dart';

class GPSUtils {
  static Future<LocationData> getLoc() async {
    LocationData currentLocation;

    var location = new Location();

    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print("PERMISSION DENIED");
      }
      currentLocation = null;
    }

    return currentLocation;
  }
}
