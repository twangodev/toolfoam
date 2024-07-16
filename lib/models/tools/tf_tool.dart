import 'dart:convert';
import 'dart:io';

import 'package:toolfoam/models/tools/tf_tool_data.dart';
import 'package:toolfoam/models/tools/tf_tool_metadata.dart';

import '../../data/organization_structure_data.dart';
import '../../utilities/storage_file_system_util.dart';
import '../entity.dart';
import '../json_serializable.dart';
import '../tf_collection.dart';

class TFTool extends DiskIOEntity implements JsonSerializable {

  TFToolMetadata metadata = TFToolMetadata.empty();
  TFCollection owner;
  TFToolData data = TFToolData();

  TFTool({required super.uuid, required this.owner});

  TFTool.fromJson(Map<String, dynamic> json, String uuid, this.owner):
    metadata = TFToolMetadata.fromJson(json['metadata']), super(uuid: uuid);

  static Future<TFTool> fromFile(File file, TFCollection owner) async {
    String rawJson = await StorageFileSystemUtil.readFromFile(file);
    Map<String, dynamic> json = jsonDecode(rawJson);
    return TFTool.fromJson(json, file.path, owner);
  }

  static Future<List<TFTool>> fromFiles(List<File> files, TFCollection owner) async {
    List<Future<TFTool>> futures = files.map((file) => fromFile(file, owner)).toList();
    return await Future.wait(futures);
  }

  @override
  Map<String, dynamic> toJson() => {
    'metadata': metadata.toJson(),
    'data': data.toJson(),
  };

  Future<File> _getFile() async {
    return StorageFileSystemUtil.buildFileWithExtension(await owner.getToolsDirectory(), uuid, OrganizationStructureData.toolExtension);
  }

  @override
  Future<bool> exists() async {
    File file = await _getFile();
    return file.exists();
  }

  void copy(TFTool newTool) {
    metadata = newTool.metadata;
  }

  void rename(String name) {
    metadata.name = name;
  }

  @override
  Future<void> pull() async {
    File file = await _getFile();
    String json = await StorageFileSystemUtil.readFromFile(file);
    Map<String, dynamic> jsonMap = jsonDecode(json);
    TFTool diskTool = TFTool.fromJson(jsonMap, uuid, owner);

    copy(diskTool);
  }

  @override
  Future<void> push() async {
    File file = await _getFile();
    String json = jsonEncode(toJson());
    await StorageFileSystemUtil.writeToFile(file, json);
  }

  @override
  Future<void> create(String name) async {
    (await _getFile()).create();
    metadata = TFToolMetadata.name(name);
    await push();
  }

  @override
  Future<void> delete() async {
    (await _getFile()).delete();
  }

}



