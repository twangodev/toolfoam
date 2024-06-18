import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageFileSystem {

  static Future<Directory> getStorage() async {
    return await getApplicationSupportDirectory();
  }

  static Future<Directory> buildDirectory(Directory dir, String path) async {
    return Directory(p.join(dir.path, path));
  }

  static Future<File> buildFile(Directory directory, String filename) async {
    return File(p.join(directory.path, filename));
  }

  static Future<List<Directory>> listDirectories(Directory dir) async {
    List<FileSystemEntity> entities = await dir.list().toList();
    return entities.whereType<Directory>().toList();
  }

  static Future writeToFile(File file, String data) async {
    await file.writeAsString(data);
  }

  static Future<String> readFromFile(File file) async {
    return await file.readAsString();
  }

}
