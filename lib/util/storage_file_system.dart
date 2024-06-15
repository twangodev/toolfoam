import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageFileSystem {

  static Future<Directory> getStorage() async {
    return await getApplicationSupportDirectory();
  }

  static Future<Directory> buildDirectory(String path) async {
    Directory storage = await getStorage();
    return Directory(p.join(storage.path, path));
  }

  static Future<File> buildFile(Directory directory, String filename) async {
    return File(p.join(directory.path, filename));
  }

  static Future<List<Directory>> listDirectories(String path) async {
    Directory dir = await buildDirectory(path);
    return dir.listSync().whereType<Directory>().toList();
  }

  static Future writeToFile(File file, String data) async {
    await file.writeAsString(data);
  }

  static Future<String> readFromFile(File file) async {
    return await file.readAsString();
  }

}
