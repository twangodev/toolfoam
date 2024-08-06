import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:toolfoam/constants/organization_structure.dart';
import 'package:toolfoam/models/tf_id.dart';
import 'package:toolfoam/models/tf_tool.dart';

import '../utilities/storage_file_system_util.dart';
import 'entity.dart';
import 'metadata.dart';

class TfCollection extends Entity {
  TfCollection({required super.id});

  static Future<Directory> _getCollectionsDirectory() async {
    return StorageFileSystemUtil.buildDirectory(
        await StorageFileSystemUtil.getStorage(),
        OrganizationStructure.collections);
  }

  Future<Directory> _getCollection() async {
    return StorageFileSystemUtil.buildDirectory(
        await _getCollectionsDirectory(), id.toString());
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
    List<Directory> collections =
        await StorageFileSystemUtil.list<Directory>(collectionsDirectory);
    return collections.map((dir) {
      TfId id = TfId(p.basenameWithoutExtension(dir.path));
      return TfCollection(id: id);
    }).toList();
  }

  Future<Directory> getToolsDirectory() async {
    return await _buildDirectoryFromCollection(OrganizationStructure.tools);
  }

  Future<List<TfTool>> listTools() async {
    List<File> files =
        await StorageFileSystemUtil.list<File>(await getToolsDirectory());
    return TfTool.fromFiles(files, this);
  }

  Future<Directory> getLayoutsDirectory() async {
    return await _buildDirectoryFromCollection(OrganizationStructure.layouts);
  }

  Future<File> _getMetadataFile() async {
    return StorageFileSystemUtil.buildFile(
        await _getCollection(), OrganizationStructure.metadata);
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
      return _initMetadata(id.toString());
    }
  }

  Future<String?> getName() async {
    return (await getMetadata()).name;
  }

  Future writeMetadata(Metadata metadata) async {
    File metadataFile = StorageFileSystemUtil.buildFile(
        await _getCollection(), OrganizationStructure.metadata);
    await StorageFileSystemUtil.writeToFile(metadataFile, jsonEncode(metadata));
  }

  Future lastChangedNow() async {
    Metadata metadata = await getMetadata();
    metadata.lastModified = DateTime.now();
    await writeMetadata(metadata);
  }

  @override
  bool operator ==(Object other) {
    if (other is TfCollection) {
      return id == other.id;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => id.hashCode;
}
