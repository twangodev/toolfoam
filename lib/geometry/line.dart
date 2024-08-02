import 'package:flutter/material.dart';
import 'package:toolfoam/models/json_serializable.dart';
import 'package:toolfoam/models/tf_id.dart';

@immutable
class Line implements JsonSerializable {
  final TfId a;
  final TfId b;

  const Line(this.a, this.b);

  bool contains(TfId id) => id == a || id == b;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Line) return false;
    bool directlyEqual = a == other.a && b == other.b;
    bool reverseEqual = a == other.b && b == other.a;
    return directlyEqual || reverseEqual;
  }

  @override
  int get hashCode => a.hashCode * b.hashCode;

  @override
  String toString() => 'Line($a, $b)';

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
