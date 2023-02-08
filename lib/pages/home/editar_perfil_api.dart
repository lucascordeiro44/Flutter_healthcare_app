import 'dart:convert';

import 'package:flutter_dandelin/constants.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/utils/file_utils.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';
import 'package:flutter_dandelin/utils/image_utils.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:path/path.dart' as p;

class EditarPerfilApi {
  static Future<HttpResponse> postImage(File file, User user) async {
    try {
      List<int> imageBytes = file.readAsBytesSync();

      FilePost filePost = FilePost();

      filePost.data = base64.encode(imageBytes);
      filePost.name = p.basename(file.path);

      final url = "$baseUrl/api/users/profile";

      HttpResponse response = await post(url, filePost.toMap(), timeout: 60);

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause.toString();
      }

      throw error.toString();
    }
  }

  static Future<HttpResponse> editUser(User user) async {
    try {
      var url = "$baseUrl/api/users/mobile/${user.id}";

      var body = user.toJson();

      var s = json.encode(body);

      print(s);

      HttpResponse response = await put(url, body);

      return response;
    } on SocketException {
      throw kOnSocketException;
    } on ForbiddenException {
      throw ForbiddenException.msgError;
    } on TimeoutException {
      throw TimeoutException.msgError;
    } catch (error) {
      if (error.cause != null) {
        throw error.cause.toString();
      }

      throw error.toString();
    }
  }

  static File resize(File f) {
    print("resize File $f");
    String name = FileUtils.getFileName(f);

    String thumbName = name.replaceAll("image_picker_", "image_picker_thumb");

    String dir = FileUtils.getFileDir(f);

    File thumb = FileUtils.joinPath(dir, thumbName);

    resizeImage(f, thumb);

    print("resize File $f");
    return thumb;
  }
}

class FilePost {
  String name;
  String data;

  toMap() => {
        'name': name,
        'data': data,
      };
}
