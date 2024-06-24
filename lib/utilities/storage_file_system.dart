import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageFileSystem {

  static Future<Directory> getStorage() async {
    return await getApplicationSupportDirectory();
  }

  static Directory buildDirectory(Directory dir, String path) {
    return Directory(p.join(dir.path, path));
  }

  static File buildFile(Directory directory, String filename) {
    return File(p.join(directory.path, filename));
  }

  static File buildFileWithExtension(Directory directory, String filename, String extension) {
    return buildFile(directory, p.setExtension(filename, extension));
  }

  static Future<List<T>> list<T>(Directory dir) async {
    List<FileSystemEntity> entities = await dir.list().toList();
    return entities.whereType<T>().toList();
  }

  static Future writeToFile(File file, String data) async {
    await file.writeAsString(data);
  }

  static Future<String> readFromFile(File file) async {
    return await file.readAsString();
  }

}
