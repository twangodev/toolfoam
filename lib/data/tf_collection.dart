import 'dart:convert';
import 'dart:io';

import 'package:toolfoam/util/organization_structure.dart';
import 'package:path/path.dart' as p;
import 'package:toolfoam/util/storage_file_system.dart';

import 'metadata.dart';

class TFCollection {

  String name;

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

  Future<Metadata> getMetadata() async {
    File metadataFile = await StorageFileSystem.buildFile(await _getDirectory(), OrganizationStructure.metadata);
    if (await metadataFile.exists()) {
      String metadata = await StorageFileSystem.readFromFile(metadataFile);
      Map<String, dynamic> metadataMap = jsonDecode(metadata);
      return Metadata.fromJson(metadataMap);
    } else {
      Metadata metadata = Metadata.empty();
      writeMetadata(metadata);
      return metadata;
    }
  }

  Future writeMetadata(Metadata metadata) async {
    File metadataFile = await StorageFileSystem.buildFile(await _getDirectory(), OrganizationStructure.metadata);
    await StorageFileSystem.writeToFile(metadataFile, jsonEncode(metadata));
  }

  Future<bool> isStarred() async {
    return (await getMetadata()).starred;
  }

  Future _setStarState(bool starred) async {
    Metadata metadata = await getMetadata();
    metadata.starred = starred;
    await writeMetadata(metadata);
  }

  Future star() async {
    await _setStarState(true);
  }

  Future unstar() async{
    await _setStarState(false);
  }

  Future syncTimestamp(String lastChangedDescriptor) async {
    Metadata metadata = await getMetadata();
    metadata.lastUpdate = DateTime.now();
    await writeMetadata(metadata);
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
