import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dandelin/model/address.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/validators.dart';

class EnderecoBloc {
  final button = ButtonBloc();
  final procurandoCep = SimpleBloc<bool>();
  final enableCityState = BooleanBloc();

  bool validate(Address a) {
    return isNotEmpty(a.zipCode) &&
        isNotEmpty(a.address) &&
        isNotEmpty(a.addressNumber) & isNotEmpty(a.city) &&
        isNotEmpty(a.state);
  }

  Future<ApiResponse> searchByCep(String cep) async {
    try {
      procurandoCep.add(true);

      HttpResponse response = await CadastroApi.getCep(cep);

      Address a = Address.fromJson(response.data['data']);

      enableCityState.add(a.city == null && a.state == null);

      return ApiResponse.ok(result: a);
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      procurandoCep.add(false);
    }
  }

  Future<ApiResponse> cadastrarDependente(
      User dependente, bool notificationToParent) async {
    try {
      button.setEnabled(false);
      button.setProgress(true);

      dependente.notificationToParent = notificationToParent;

      await CadastroApi.cadastrar(dependente);

      return ApiResponse.ok();
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      button.setEnabled(true);
      button.setProgress(false);
    }
  }

  Future<ApiResponse> cadastrar(User user) async {
    try {
      button.setEnabled(false);
      button.setProgress(true);

      user.firebaseId = await FirebaseMessaging().getToken();

      user.so = Platform.isAndroid ? "android" : "ios";

      HttpResponse response = await CadastroApi.cadastrar(user);

      User userResponse = User.fromJson(json.decode(response.body));

      user.token = response.headers['authorization'];

      user.id = userResponse.id;
      user.status = userResponse.status;

      appBloc.setUser(user);

      Prefs.setBool('tutorial_done', false);
      Prefs.setString('user.prefs', json.encode(user.toJson()));

      return ApiResponse.ok();
    } catch (e) {
      return ApiResponse.error(e);
    } finally {
      button.setEnabled(true);
      button.setProgress(false);
    }
  }

  validState(String state) {
    List<String> states = [
      "AC",
      "AL",
      "AP",
      "AM",
      "BA",
      "CE",
      "DF",
      "ES",
      "GO",
      "MA",
      "MT",
      "MS",
      "MG",
      "PA",
      "PB",
      "PR",
      "PE",
      "PI",
      "RJ",
      "RN",
      "RS",
      "RO",
      "RR",
      "SC",
      "SP",
      "SE",
      "TO",
    ];

    return states.contains(state.toUpperCase());
  }

  dispose() {
    procurandoCep.dispose();
    button.dispose();
    enableCityState.dispose();
  }
}
