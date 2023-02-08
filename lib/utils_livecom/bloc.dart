import 'dart:async';

import 'package:rxdart/rxdart.dart';

class SimpleBloc<T> {
  bool keepState;

  // StreamController (PublishSubject ou BehaviorSubject)
  dynamic _controller;

  SimpleBloc({this.keepState = true}) {
    _controller = keepState ? BehaviorSubject<T>() : PublishSubject<T>();
  }

  Stream<T> get stream => _controller.stream;

  get value => _controller.value;

  Function get listen => _controller.listen;

  get isClosed => _controller.isClosed;

  void add(T event) {
    if (!_controller.isClosed) {
      _controller.sink.add(event);
    }
  }

  void addError(Object event, [StackTrace stackTrace]) {
    if (!_controller.isClosed) {
      _controller.sink.addError(event, stackTrace);
    }
  }

  void dispose() {
    _controller.close();
  }
}

class BooleanBloc extends SimpleBloc<bool> {
  void set(bool b) {
    add(b);
  }
}
