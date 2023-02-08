import 'package:flutter_dandelin/constants.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/validators.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';

class CadastroApi {
  static Future<HttpResponse> cadastrar(User user) async {
    try {
      final url = "$baseUrl/api/users";

      HttpResponse response = await post(url, user.toJson());

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } on TypeError {
      throw "Error serv";
    } catch (error, stacktrace) {
      print("Login error: $error - $stacktrace");
      if (error.cause != null) {
        throw error.cause.toString();
      }

      throw error.toString();
    }
  }

  static Future<HttpResponse> checkCpfExists(String cpf) async {
    try {
      final url = "$baseUrl/api/users/cpf/$cpf";
      HttpResponse response = await get(url);

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause.toString();
      }

      throw error.toString();
    }
  }

  static Future<HttpResponse> checkEmailExists(String email) async {
    try {
      final url = "$baseUrl/api/users/email/$email";
      HttpResponse response = await get(url);

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause.toString();
      }

      throw error.toString();
    }
  }

  static Future<HttpResponse> getCep(String cep) async {
    try {
      var url = "$baseUrl/api/addresses/cep/$cep";

      HttpResponse response = await get(url);

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause.toString();
      }

      throw error.toString();
    }
  }
}

class PreCadastroForm {
  String firtsName;
  String lastName;
  String document;
  String cpfMasked;
  String username;
  String confirmUsername;
  String password;
  String confirmPassword;
  bool agreeTerms;
  bool cpfCorrect;

  bool validar() {
    bool valid = isNotEmpty(firtsName) &&
        isNotEmpty(lastName) &&
        isNotEmpty(password) &&
        isNotEmpty(confirmPassword) &&
        validateConfirmarSenha(password, confirmPassword) &&
        (agreeTerms != null && agreeTerms);

    if (!valid) {
      return valid;
    }
    if (isNotEmpty(document)) {
      valid = isNotEmpty(document) &&
          isValidCpf(document) &&
          CPFValidator.isValid(document);
    } else {
      valid = isNotEmpty(username) &&
          isValidEmail(username) &&
          confirmEmailCorrect() &&
          isNotEmpty(confirmUsername);
    }

    return valid;
  }

  bool confirmEmailCorrect() {
    return username == confirmUsername;
  }
}
