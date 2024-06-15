import 'dart:convert';
import 'dart:io';

import 'package:toolfoam/data/metadata.dart';
import 'package:toolfoam/util/storage_file_system.dart';

class TFTool {

  String name;
  Metadata metadata = Metadata.empty();
  Future<Directory> Function() parentDirectory;

  TFTool({required this.name, required this.parentDirectory});

  TFTool.fromJson(Map<String, dynamic> json, {required this.parentDirectory})
      : name = json['name'],
        metadata = Metadata.fromJson(json['metadata']);

  Map<String, dynamic> toJson() => {
    'name': name,
    'metadata': metadata.toJson()
  };

  Future<File> _getFile() async {
    return await StorageFileSystem.buildFile(await parentDirectory(), name);
  }

  Future<bool> exists() async {
    File file = await _getFile();
    return file.exists();
  }

  void copy(TFTool newTool) {
    name = newTool.name;
    metadata = newTool.metadata;
  }

  Future fromDiskState() async {
    assert (await exists());

    File file = await _getFile();
    String json = await StorageFileSystem.readFromFile(file);
    Map<String, dynamic> jsonMap = jsonDecode(json);
    TFTool diskTool = TFTool.fromJson(jsonMap, parentDirectory: parentDirectory);

    copy(diskTool);
  }

  Future write() async {
    File file = await _getFile();
    String json = jsonEncode(toJson());
    await StorageFileSystem.writeToFile(file, json);
  }

  Future create() async {
    assert (!await exists());

    (await _getFile()).create();
    await write();
  }

}

