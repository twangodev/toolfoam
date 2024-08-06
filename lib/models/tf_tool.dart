import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:toolfoam/models/tf_id.dart';
import 'package:toolfoam/models/tf_tool_data.dart';
import 'package:toolfoam/models/tf_tool_metadata.dart';

import '../constants/organization_structure.dart';
import '../utilities/storage_file_system_util.dart';
import 'entity.dart';
import 'json_serializable.dart';
import 'tf_collection.dart';

class TfTool extends DiskIOEntity implements JsonSerializable {
  static final Logger logger = Logger('TfTool');

  TfToolMetadata metadata = TfToolMetadata.empty();
  TfCollection owner;
  TfToolData data = TfToolData();

  TfTool({required super.id, required this.owner});

  TfTool.fromJson(Map<String, dynamic> json, TfId id, this.owner)
      : metadata = TfToolMetadata.fromJson(json['metadata']),
        super(id: id);

  static Future<TfTool> fromFile(File file, TfCollection owner) async {
    String rawJson = await StorageFileSystemUtil.readFromFile(file);
    Map<String, dynamic> json = jsonDecode(rawJson);
    String name = p.basenameWithoutExtension(file.path);
    TfId id = TfId(name);
    return TfTool.fromJson(json, id, owner);
  }

  static Future<List<TfTool>> fromFiles(
      List<File> files, TfCollection owner) async {
    List<Future<TfTool>> futures =
        files.map((file) => fromFile(file, owner)).toList();
    return await Future.wait(futures);
  }

  @override
  Map<String, dynamic> toJson() => {
        'metadata': metadata.toJson(),
        'data': data.toJson(),
      };

  Future<File> _getFile() async {
    Directory dir = await owner.getToolsDirectory();
    String name = id.toString();
    String ext = OrganizationStructure.toolExtension;
    return StorageFileSystemUtil.buildFileWithExtension(dir, name, ext);
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
    TfTool diskTool = TfTool.fromJson(jsonMap, id, owner);

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
