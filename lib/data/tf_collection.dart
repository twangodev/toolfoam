import 'dart:io';

import 'package:toolfoam/util/organization_structure.dart';
import 'package:path/path.dart' as p;
import 'package:toolfoam/util/storage_file_system.dart';

class TFCollection {

  String name;
  bool starred = false;

  TFCollection(this.name);

  static Future<List<TFCollection>> list() async {
      List<Directory> collections = await StorageFileSystem.listDirectories("");
    return collections.map((dir) => TFCollection(p.basename(dir.path))).toList();
  }

  Future<Directory> _getDirectory() async {
    return await StorageFileSystem.buildDirectory(name);
  }

  Future<Directory> _getToolsDirectory() async {
    return await StorageFileSystem.buildDirectory(p.join(name, OrganizationStructure.tools));
  }

  Future<Directory> _getLayoutsDirectory() async {
    return await StorageFileSystem.buildDirectory(p.join(name, OrganizationStructure.layouts));
  }

  Future<bool> exists() async {
    Directory dir = await _getDirectory();
    return dir.exists();
  }

  Future create() async {
    assert (!await exists());

    (await _getDirectory()).create();
    (await _getToolsDirectory()).create();
    (await _getLayoutsDirectory()).create();
  }

  void delete() async {
    assert (await exists());

    (await _getDirectory()).delete(recursive: true);
  }

  void rename(String newName) async {
    assert (await exists());

    (await _getDirectory()).rename(newName);
    name = newName;
  }

  void star() {
    starred = true;
  }

  void unstar() {
    starred = false;
  }

  @override
  bool operator == (Object other) {
    if (other is TFCollection) {
      return name.toLowerCase() == other.name.toLowerCase();
    } else {
      return false;
    }
  }

  @override
  int get hashCode => name.toLowerCase().hashCode;

}