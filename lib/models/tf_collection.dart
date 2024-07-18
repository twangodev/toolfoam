import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:toolfoam/models/tools/tf_tool.dart';

import '../data/organization_structure_data.dart';
import '../utilities/storage_file_system_util.dart';
import 'entity.dart';
import 'metadata.dart';

class TfCollection extends Entity {

  TfCollection({required super.uuid});

  static Future<Directory> _getCollectionsDirectory() async {
    return StorageFileSystemUtil.buildDirectory(await StorageFileSystemUtil.getStorage(), OrganizationStructureData.collections);
  }

  Future<Directory> _getCollection() async {
    return StorageFileSystemUtil.buildDirectory(await _getCollectionsDirectory(), uuid);
  }

  Future<Directory> _buildDirectoryFromCollection(String path) async {
    return StorageFileSystemUtil.buildDirectory(await _getCollection(), path);
  }

  static Future<List<TfCollection>> list() async {
    Directory collectionsDirectory = await _getCollectionsDirectory();
    if (!await collectionsDirectory.exists()) {
      await collectionsDirectory.create();
      return [];
    }
    List<Directory> collections = await StorageFileSystemUtil.list<Directory>(collectionsDirectory);
    return collections.map((dir) => TfCollection(uuid: p.basenameWithoutExtension(dir.path))).toList();
  }

  Future<Directory> getToolsDirectory() async {
    return await _buildDirectoryFromCollection(OrganizationStructureData.tools);
  }

  Future<List<TfTool>> listTools() async {
    List<File> files = await StorageFileSystemUtil.list<File>(await getToolsDirectory());
    return TfTool.fromFiles(files, this);
  }

  Future<Directory> getLayoutsDirectory() async {
    return await _buildDirectoryFromCollection(OrganizationStructureData.layouts);
  }

  Future<File> _getMetadataFile() async {
    return StorageFileSystemUtil.buildFile(await _getCollection(), OrganizationStructureData.metadata);
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
    await lastChangedNow();
  }

  Future<Metadata> getMetadata() async {
    File metadataFile = await _getMetadataFile();
    if (await metadataFile.exists()) {
      String rawJson = await StorageFileSystemUtil.readFromFile(metadataFile);
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
    File metadataFile = StorageFileSystemUtil.buildFile(await _getCollection(), OrganizationStructureData.metadata);
    await StorageFileSystemUtil.writeToFile(metadataFile, jsonEncode(metadata));
  }

  Future lastChangedNow() async {
    Metadata metadata = await getMetadata();
    metadata.lastModified = DateTime.now();
    await writeMetadata(metadata);
  }

  @override
  bool operator == (Object other) {
    if (other is TfCollection) {
      return uuid == other.uuid;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => uuid.hashCode;

}
