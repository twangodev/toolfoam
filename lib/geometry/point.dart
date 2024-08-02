import 'dart:math';

import 'package:flutter/material.dart';
import 'package:toolfoam/models/json_serializable.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class Point implements JsonSerializable {
  abstract final double x;
  abstract final double y;

  @override
  String toString() {
    return 'Point{x: $x, y: $y}';
  }

  @override
  bool operator ==(Object other) {
    if (other is Point) {
      return x == other.x && y == other.y;
    }
    return false;
  }

  @override
  int get hashCode => x.hashCode * 31 + y.hashCode;

  Vector2 toVector2() => Vector2(x, y);
  Offset toOffset() => Offset(x, y);

  double get distanceSquared => x * x + y * y;
  double get distance => sqrt(distanceSquared);
  FixedPoint get normalized => this / distance;
  FixedPoint get perpendicular => FixedPoint(-y, x);

  FixedPoint operator +(Point other) => FixedPoint(x + other.x, y + other.y);
  FixedPoint operator -(Point other) => FixedPoint(x - other.x, y - other.y);
  FixedPoint operator *(double scalar) => FixedPoint(x * scalar, y * scalar);
  FixedPoint operator /(double scalar) => FixedPoint(x / scalar, y / scalar);
  bool operator <(Point other) => distanceSquared < other.distanceSquared;
  bool operator <=(Point other) => distanceSquared <= other.distanceSquared;
  bool operator >(Point other) => distanceSquared > other.distanceSquared;
  bool operator >=(Point other) => distanceSquared >= other.distanceSquared;
}

@immutable
class FixedPoint extends Point {
  @override
  final double x;

  @override
  final double y;

  FixedPoint(this.x, this.y);

  @override
  Map<String, dynamic> toJson() => {
        'type': runtimeType,
        'x': x,
        'y': y,
      };

  factory FixedPoint.fromOffset(Offset offset) {
    return FixedPoint(offset.dx, offset.dy);
  }
}
