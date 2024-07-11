import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:toolfoam/models/tools/tf_tool.dart';

import '../utilities/organization_structure.dart';
import '../utilities/storage_file_system.dart';
import 'entity.dart';
import 'metadata.dart';

class TFCollection extends Entity {

  TFCollection({required super.uuid});

  static Future<Directory> _getCollectionsDirectory() async {
    return StorageFileSystem.buildDirectory(await StorageFileSystem.getStorage(), OrganizationStructure.collections);
  }

  Future<Directory> _getCollection() async {
    return StorageFileSystem.buildDirectory(await _getCollectionsDirectory(), uuid);
  }

  Future<Directory> _buildDirectoryFromCollection(String path) async {
    return StorageFileSystem.buildDirectory(await _getCollection(), path);
  }

  static Future<List<TFCollection>> list() async {
    Directory collectionsDirectory = await _getCollectionsDirectory();
    if (!await collectionsDirectory.exists()) {
      await collectionsDirectory.create();
      return [];
    }
    List<Directory> collections = await StorageFileSystem.list<Directory>(collectionsDirectory);
    return collections.map((dir) => TFCollection(uuid: p.basename(dir.path))).toList();
  }

  Future<Directory> getToolsDirectory() async {
    return await _buildDirectoryFromCollection(OrganizationStructure.tools);
  }

  Future<List<TFTool>> listTools() async {
    List<File> files = await StorageFileSystem.list<File>(await getToolsDirectory());
    return TFTool.fromFiles(files, this);
  }

  Future<Directory> getLayoutsDirectory() async {
    return await _buildDirectoryFromCollection(OrganizationStructure.layouts);
  }

  Future<File> _getMetadataFile() async {
    return StorageFileSystem.buildFile(await _getCollection(), OrganizationStructure.metadata);
  }

  @override
  Future<bool> exists() async {
    Directory dir = await _getCollection();
    return dir.exists();
  }

  @override
  Future<void> create(String name) async {
    Directory collections = await _getCollectionsDirectory();
    if (!await collections.exists()) {
      await collections.create();
    }
    (await _getCollection()).create();
    (await getToolsDirectory()).create();
    (await getLayoutsDirectory()).create();
    await _initMetadata(name);
  }

  Future<Metadata> _initMetadata(String name) async {
    Metadata metadata = Metadata.name(name);
    await writeMetadata(metadata);
    return metadata;
  }

  @override
  Future<void> delete() async {
    (await _getCollection()).delete(recursive: true);
  }

  Future rename(String newName) async {
    Metadata metadata = await getMetadata();
    metadata.name = newName;
    await writeMetadata(metadata);
  }

  Future<Metadata> getMetadata() async {
    File metadataFile = await _getMetadataFile();
    if (await metadataFile.exists()) {
      String rawJson = await StorageFileSystem.readFromFile(metadataFile);
      Map<String, dynamic> json = jsonDecode(rawJson);
      return Metadata.fromJson(json);
    } else {
      return _initMetadata(uuid); // Weird case where directory exists without metadata? TODO documentation or throw some weird error
    }
  }

  Future<String?> getName() async {
    return (await getMetadata()).name;
  }

  Future writeMetadata(Metadata metadata) async {
    File metadataFile = StorageFileSystem.buildFile(await _getCollection(), OrganizationStructure.metadata);
    await StorageFileSystem.writeToFile(metadataFile, jsonEncode(metadata));
  }

  Future syncTimestamp(String lastChangedDescriptor) async {
    Metadata metadata = await getMetadata();
    metadata.lastModified = DateTime.now();
    await writeMetadata(metadata);
  }

  @override
  bool operator == (Object other) {
    if (other is TFCollection) {
      return uuid == other.uuid;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => uuid.hashCode;

}
