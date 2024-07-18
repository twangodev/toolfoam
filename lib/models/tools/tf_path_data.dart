import 'dart:collection';
import 'dart:ffi';
import 'dart:ui';

import 'package:logging/logging.dart';
import 'package:quiver/collection.dart';

import '../entity.dart';
import '../json_serializable.dart';
import '../line.dart';


class TfToolData implements JsonSerializable {

  static final Logger logger = Logger('TfToolData');

  HashBiMap<String, Offset> points = HashBiMap();
  HashSet<Line> lines = HashSet();

  TfToolData();

  String addPoint(Offset point) {
    logger.finer('Adding point at: $point');
    String? existingUuid = points.inverse[point];
    if (existingUuid != null) {
      logger.finer('Found point already exists: $existingUuid');
      return existingUuid;
    }

    String uuid = Entity.uuidGenerator.v4();
    points[uuid] = point;
    logger.finer('Added point with uuid: $uuid');
    return uuid;
  }

  TfToolData.fromJson(Map<String, dynamic> json) {
    Map<String, List<double>> jsonPoints = json['points'];
    jsonPoints.forEach((key, value) {
      points[key] = Offset(value[0], value[1]);
    });
    json['lines'].forEach((lineJson) {
      lines.add(Line.fromJson(lineJson));
    });
  }

  @override
  Map<String, dynamic> toJson() => {
    'points': points.map((key, value) => MapEntry(key, [value.dx, value.dy])),
    'lines': lines.map((line) => line.toJson()).toList(),
  };

}