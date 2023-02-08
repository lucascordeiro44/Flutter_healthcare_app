import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/imports.dart';

AppBloc get appBloc => AppBloc.get();

class AppState {
  User user;
  User dependente;

  bool isUserLogado() => user != null;
  bool isAnonymousLogin() => user != null;

  @override
  String toString() {
    return 'AppState{user: $user}';
  }
}

class AppBloc extends SimpleBloc<AppState> {
  static AppBloc get() => BlocProvider.getBloc<AppBloc>();

  final state = AppState();

  User get user => state.user;
  User get dependente => state.dependente;

  int get livecomId => state.user.livecomId;

  Future<User> loadUser() async {
    // Carrega user das prefs
    User user = await User.get();
    state.user = user;
    return user;
  }

  setUser(User user) {
    if (user != null) {
      user?.save();
    }
    state.user = user;
    add(state);
  }

  setDependente(User dependente) {
    // if (dependente != null) {
    //   dependente?.save();
    // }
    state.dependente = dependente;
    add(state);
  }

  clearDepedente() {
    setDependente(null);
  }

  void logout() {
    Prefs.setBool('otp.ok', false);
    User.clear();
    setUser(null);
  }

  void cleanAuth() {
    //state.user.token = null;
    User.clearAuthorization();
  }

  @override
  void dispose() {
    print("dispose AppBloc");
    super.dispose();
  }
}
