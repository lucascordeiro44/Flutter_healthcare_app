import 'package:flutter/material.dart';
import 'package:flutter_dandelin/utils_livecom/bloc.dart';
import 'package:flutter_dandelin/utils_livecom/local_notifications.dart';
import 'package:provider/provider.dart';

class RouteBloc extends ChangeNotifier {
  static RouteBloc get(context) =>
      Provider.of<RouteBloc>(context, listen: false);

  final notification = SimpleBloc<FcmNotification>();
  final actualRoute = SimpleBloc<String>();

  addNotification(FcmNotification n) {
    notification.add(n);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    actualRoute.dispose();
    notification.dispose();
  }
}