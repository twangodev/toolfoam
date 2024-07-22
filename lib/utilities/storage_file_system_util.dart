import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageFileSystemUtil {
  static final Logger logger = Logger('StorageFileSystemUtil');

  static Future<Directory> getStorage() async {
    Directory dir = await getApplicationSupportDirectory();
    logger.finest('Application Storage directory requested: ${dir.path}');
    return dir;
  }

  static Directory buildDirectory(Directory dir, String path) {
    Directory builtDir = Directory(p.join(dir.path, path));
    logger.finest('Directory built: ${builtDir.path}');
    return builtDir;
  }

  static File buildFile(Directory directory, String filename) {
    File file = File(p.join(directory.path, filename));
    logger.finest('File built: ${file.path}');
    return file;
  }

  static File buildFileWithExtension(
      Directory directory, String filename, String extension) {
    logger.finest('Building file with extension: $filename.$extension');
    return buildFile(directory, p.setExtension(filename, extension));
  }

  static Future<List<T>> list<T>(Directory dir) async {
    List<FileSystemEntity> entities = await dir.list().toList();
    logger.finest('Listing ${entities.length} entities in ${dir.path}');
    return entities.whereType<T>().toList();
  }

  static Future writeToFile(File file, String data) async {
    logger.finest(
        'Writing to file (${data.length}): ${file.path} with data: $data');
    await file.writeAsString(data);
  }

  static Future<String> readFromFile(File file) async {
    logger.finest('Reading from file: ${file.path}');
    return await file.readAsString();
  }
}
