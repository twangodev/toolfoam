import 'dart:convert';
import 'dart:io';

import 'package:toolfoam/util/organization_structure.dart';
import 'package:path/path.dart' as p;
import 'package:toolfoam/util/storage_file_system.dart';

import 'metadata.dart';

class TFCollection {

  String name;

  TFCollection(this.name);

  static Future<Directory> _getCollectionsDirectory() async {
    return await StorageFileSystem.buildDirectory(await StorageFileSystem.getStorage(), OrganizationStructure.collections);
  }

  Future<Directory> _getCollection() async {
    return await StorageFileSystem.buildDirectory(await _getCollectionsDirectory(), name);
  }

  Future<Directory> _buildDirectoryFromCollection(String path) async {
    return await StorageFileSystem.buildDirectory(await _getCollection(), path);
  }

  static Future<List<TFCollection>> list() async {
    Directory collectionsDirectory = await _getCollectionsDirectory();
    if (!await collectionsDirectory.exists()) {
      await collectionsDirectory.create();
      return [];
    }
    List<Directory> collections = await StorageFileSystem.listDirectories(collectionsDirectory);
    return collections.map((dir) => TFCollection(p.basename(dir.path))).toList();
  }

  Future<Directory> _getToolsDirectory() async {
    return await _buildDirectoryFromCollection(OrganizationStructure.tools);
  }

  Future<Directory> _getLayoutsDirectory() async {
    return await _buildDirectoryFromCollection(OrganizationStructure.layouts);
  }

  Future<File> _getMetadataFile() async {
    return await StorageFileSystem.buildFile(await _getCollection(), OrganizationStructure.metadata);
  }

  Future<bool> exists() async {
    Directory dir = await _getCollection();
    return dir.exists();
  }

  Future create() async {
    Directory collections = await _getCollectionsDirectory();
    if (!await collections.exists()) {
      await collections.create();
    }
    (await _getCollection()).create();
    (await _getToolsDirectory()).create();
    (await _getLayoutsDirectory()).create();
    await _initMetadata();
  }

  Future<Metadata> _initMetadata() async {
    Metadata metadata = Metadata.empty();
    await writeMetadata(metadata);
    return metadata;
  }

  void delete() async {
    (await _getCollection()).delete(recursive: true);
  }

  void rename(String newName) async {
    (await _getCollection()).rename(newName);
    name = newName;
  }

  Future<Metadata> getMetadata() async {
    File metadataFile = await _getMetadataFile();
    if (await metadataFile.exists()) {
      String metadata = await StorageFileSystem.readFromFile(metadataFile);
      Map<String, dynamic> metadataMap = jsonDecode(metadata);
      return Metadata.fromJson(metadataMap);
    } else {
      return _initMetadata();
    }
  }

  Future writeMetadata(Metadata metadata) async {
    File metadataFile = await StorageFileSystem.buildFile(await _getCollection(), OrganizationStructure.metadata);
    await StorageFileSystem.writeToFile(metadataFile, jsonEncode(metadata));
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
