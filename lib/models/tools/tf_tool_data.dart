import 'dart:collection';
import 'dart:ui';

import '../json_serializable.dart';


class TFToolData implements JsonSerializable {

  HashSet<Offset> points = HashSet<Offset>();

  TFToolData();

  TFToolData.fromJson(Map<String, dynamic> json) {
    List<dynamic> rawPoints = json['points'];
    points = HashSet<Offset>.from(rawPoints.map((rawPoint) => Offset(rawPoint[0], rawPoint[1])));
  }

  @override
  Map<String, dynamic> toJson() => {
    'points': points.map((point) => [point.dx, point.dy]).toList(),
  };

}