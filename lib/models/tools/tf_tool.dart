import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:toolfoam/models/tools/tf_tool_data.dart';
import 'package:toolfoam/models/tools/tf_tool_metadata.dart';
import 'package:path/path.dart' as p;

import '../../data/organization_structure_data.dart';
import '../../utilities/storage_file_system_util.dart';
import '../entity.dart';
import '../json_serializable.dart';
import '../tf_collection.dart';

class TfTool extends DiskIOEntity implements JsonSerializable {

  static final Logger logger = Logger('TfTool');

  TfToolMetadata metadata = TfToolMetadata.empty();
  TfCollection owner;
  TfToolData data = TfToolData();

  TfTool({required super.uuid, required this.owner});

  TfTool.fromJson(Map<String, dynamic> json, String uuid, this.owner):
    metadata = TfToolMetadata.fromJson(json['metadata']), super(uuid: uuid);

  static Future<TfTool> fromFile(File file, TfCollection owner) async {
    String rawJson = await StorageFileSystemUtil.readFromFile(file);
    Map<String, dynamic> json = jsonDecode(rawJson);
    return TfTool.fromJson(json, p.basenameWithoutExtension(file.path), owner);
  }

  static Future<List<TfTool>> fromFiles(List<File> files, TfCollection owner) async {
    List<Future<TfTool>> futures = files.map((file) => fromFile(file, owner)).toList();
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

  void copy(TfTool newTool) {
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
    TfTool diskTool = TfTool.fromJson(jsonMap, uuid, owner);

    copy(diskTool);
  }

  @override
  Future<void> push() async {
    File file = await _getFile();
    String json = jsonEncode(toJson());
    await StorageFileSystemUtil.writeToFile(file, json);
    await owner.lastChangedNow();
  }

  @override
  Future<void> create(String name) async {
    (await _getFile()).create();
    metadata = TfToolMetadata.name(name);
    await push();
  }

  @override
  Future<void> delete() async {
    (await _getFile()).delete();
  }

}



