

import 'package:flutter/material.dart';

void addScrollListener(ScrollController scrollController, Function callback,
    {Function outMaxSrollCallback}) {
  scrollController.addListener(() {
    if (outMaxSrollCallback != null) {
      outMaxSrollCallback();
    }

    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      callback();
    }
  });
}
