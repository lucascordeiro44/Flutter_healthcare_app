import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static bool logOn = true;

  static Future<Directory> getAppDir() {
    return getApplicationDocumentsDirectory();
  }

  static Future<File> getFile(String fileName) async {
    final directory = await getAppDir();

    final rootDir = directory.path;

    final f = File('$rootDir/$fileName');

    return f;
  }

  static Future<File> getFileAtDir(String fileName, String dir) async {
    final directory = await getAppDir();

    final rootDir = directory.path;

    final f = File('$rootDir/$dir/$fileName');

    return f;
  }

  static Future<String> readString(String fileName) async {
    File f = await getFile(fileName);

    return f.readAsString(encoding: utf8);
  }

  static Future<List<int>> readBytes(String fileName) async {
    final directory = await getAppDir();

    final dir = directory.path;

    final f = File('$dir/$fileName');

    return f.readAsBytes();
  }

  static Future<File> writeString(String fileName, String s) async {
    final directory = await getAppDir();

    final dir = directory.path;

    final f = File('$dir/$fileName');
    print("> write: $fileName");

    // Write the file
    return f.writeAsString(s, encoding: utf8);
  }

  static Future<Directory> createDir(String dirName) async {
    final directory = await getAppDir();

    final dir = directory.path;

    final fDir = Directory('$dir/$dirName');

    // Write the file
    return fDir.create();
  }

  static Future<File> writeBytes(String fileName, Uint8List bytes) async {
    final directory = await getAppDir();

    final dir = directory.path;

    final f = File('$dir/$fileName');
    if (logOn) {
//      print("> write: $f");
    }
    // Write the file
    return f.writeAsBytes(bytes);
  }

  static void write(File f, ByteData data) {
    List<int> bytes = getBytes(data);
    return f.writeAsBytesSync(bytes, flush: true);
  }

  static List<int> getBytes(ByteData data) {
    final buffer = data.buffer;
    List<int> bytes =
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return bytes;
  }

  static Future<File> copyAssetsToAppDir(File fileAssets) async {
    String name = fileAssets.path;

    var bytes = await rootBundle.load(name);

    // Arquivo zip
    final directory = await getAppDir();

    final dir = directory.path;

    String fileName = path.basename(name);
    final f = File("$dir/$fileName");

    if (logOn) {
      print("> file: $f");
    }
    FileUtils.write(f, bytes);

    return f;
  }

  static Future delete(String fileName) async {
    final directory = await getAppDir();

    final dir = directory.path;

    final f = File('$dir/$fileName');
    return deleteFile(f);
  }

  static Future deleteFile(File f) async {
    return f.delete();
  }

  static String getFileName(File f) {
    String fileName = path.basename(f.path);
    return fileName;
  }

  static String getFileDir(File f) {
    String dir = path.dirname(f.path);
    return dir;
  }

  static getDirName(Directory dir) {
    String name = dir.path;
    String fileName = path.basename(name);
    return fileName;
  }

  static Future unzip(List<int> bytes) async {
    Archive archive = new ZipDecoder().decodeBytes(bytes);
    for (ArchiveFile file in archive) {
      String fileName = file.name;

      if (fileName.toUpperCase().startsWith("__MACOSX")) {
        continue;
      }
      if (fileName == ".DS_Store") {
        continue;
      }

      if (file.isFile) {
        List<int> data = file.content;

        await FileUtils.writeBytes(fileName, data);

        //progressBloc.setProgress(DownloadInfo(msg: "Salvando contatos..."));

      } else {
        if (logOn) {
          print(" > dir > $fileName");
        }

        await FileUtils.createDir(fileName);
      }
    }
  }

  static Future<List<int>> getBytesFromAssets(String filePath) async {
    ByteData byteData = await rootBundle.load(filePath);

    List<int> bytes = FileUtils.getBytes(byteData);
    return bytes;
  }

  static File joinPath(String dir, String fileName) {
    return File(join(dir, fileName));
  }

  // Utilizado para copiar o arquivo do banco para o dir interno do app
  static Future<File> copyAssetsToAppFolder(
      String assetsFile, String path) async {
    try {
      // Cria dir
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    // Copia dos assets
    ByteData data = await rootBundle.load(assetsFile);
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Escreve
    File f = File(path);

    await f.writeAsBytes(bytes, flush: true);

    return f;
  }

  static Future<bool> move(File pastodb2, File pastodb) async {
    print("Move ${getFileName(pastodb2)} to ${getFileName(pastodb)}");

    Uint8List bytes = await pastodb2.readAsBytes();

    print("read ok bytes ${bytes.length}");

    File moved = await pastodb.writeAsBytes(bytes, flush: true);

    print("Move ok file $moved");

    return true;
  }
}
