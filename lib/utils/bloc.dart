import 'package:rxdart/rxdart.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

class SimpleBloc<T> extends BlocBase {
  // stream
  final _controller = BehaviorSubject<T>();

  get stream => _controller.stream;

  get listen => _controller.listen;

  get value => _controller.value;

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

// ignore: close_sinks
  @override
  void dispose() {
    super.dispose();

    _controller.close();
  }
}

class BooleanBloc extends SimpleBloc<bool> {
  void set(bool b) {
    add(b);
  }
}

class PaginationBloc<T> extends SimpleBloc {
  PaginationBloc() {
    page.add(0);
    loading.add(false);
    endApiResults.add(false);
  }

  final page = SimpleBloc<int>();
  final loading = SimpleBloc<bool>();
  final endApiResults = SimpleBloc<bool>();

  getPage() {
    int p = page.value;
    p = p + 1;
    page.add(p);
    return page.value;
  }

  startLoading() => loading.add(true);
  stopLoading() => loading.add(false);

  disposePagination() {
    page.dispose();
    loading.dispose();
    endApiResults.dispose();
  }
}
