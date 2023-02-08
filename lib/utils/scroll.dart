
import 'package:flutter_dandelin/utils/imports.dart';

void addScrollListener(ScrollController scrollController, Function callback) {
  scrollController.addListener(() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      callback();
    }
  });
}