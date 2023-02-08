import 'dart:convert';

import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/secure_storage.dart';

class EditarPerfilBloc {
  final saving = BooleanBloc();
  final temporaryPicture = SimpleBloc<String>();
  final statusApi = SimpleBloc<StatusApiEditarPerfil>();
  final twoFactor = BooleanBloc();
  var hasError = false;

  Future<ApiResponse<User>> editPicture(File file, User user) async {
    try {
      hasError = false;
      statusApi.add(StatusApiEditarPerfil.savingPicture);
      temporaryPicture.add(file.path);
      HttpResponse response = await EditarPerfilApi.postImage(file, user);

      user..avatar = response.data['url'];

      statusApi.add(null);

      return ApiResponse.ok(result: user);
    } catch (e) {
      hasError = true;
      return ApiResponse.error(e);
    }
  }

  Future<ApiResponse<User>> editUser(User user) async {
    try {
      hasError = false;
      user.customerAt = dateTimeFormatHMS();
      user.password = await SecureStorage.getValue('senhaLogin');
      user.twoFactorAuthentication = twoFactor.value ?? false;

      HttpResponse response = await EditarPerfilApi.editUser(user);

      user.token = response.headers['authorization'];

      await User.clearAuthorization();
      Prefs.setString('user.prefs', json.encode(user.toJson()));

      return ApiResponse.ok(result: user);
    } catch (e) {
      hasError = true;
      return ApiResponse.error(e);
    }
  }

  dispose() {
    twoFactor.dispose();
    statusApi.dispose();
    saving.dispose();
    temporaryPicture.dispose();
  }
}

enum StatusApiEditarPerfil {
  savingPicture,
  savingUser,
  error,
}
