import 'package:connectivity/connectivity.dart';

class NetworkUtil {
  final Connectivity connectivity = Connectivity();

  Stream<ConnectivityResult> onConnectionChanged() {
    return connectivity.onConnectivityChanged;
  }

  Future<bool> isConnect() async =>
      await connectivity.checkConnectivity() != ConnectivityResult.none;
}
