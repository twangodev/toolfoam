import 'dart:math';

import 'package:flutter/material.dart';
import 'package:toolfoam/geometry/tangent_handle.dart';
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
  FixedPoint get unit => this / distance;
  FixedPoint get perpendicular => FixedPoint(-y, x);

  FixedPoint operator +(Point other) => FixedPoint(x + other.x, y + other.y);
  FixedPoint operator -(Point other) => FixedPoint(x - other.x, y - other.y);
  FixedPoint operator *(double scalar) => FixedPoint(x * scalar, y * scalar);
  FixedPoint operator /(double scalar) => FixedPoint(x / scalar, y / scalar);
  FixedPoint operator -() => FixedPoint(-x, -y);
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

  factory FixedPoint.fromVector2(Vector2 vector) {
    return FixedPoint(vector.x, vector.y);
  }
}

class ControlPoint extends FixedPoint {
  final TangentHandle handle;

  ControlPoint(super.x, super.y, this.handle);

  FixedPoint get inTangent => this + handle.relativeInTangent;
  FixedPoint get outTangent => this + handle.relativeOutTangent;

  static List<ControlPoint> autoTangent(
      List<FixedPoint> points, FixedPoint a, FixedPoint b) {
    List<ControlPoint> controlPoints = [];

    for (int i = 0; i < points.length; i++) {
      FixedPoint point = points[i];
      FixedPoint prev = point - (i == 0 ? a : points[i - 1]);
      FixedPoint next = point - (i == points.length - 1 ? b : points[i + 1]);

      TangentHandle handle = TangentHandle.autoNeighbours(prev, next);
      controlPoints.add(ControlPoint(point.x, point.y, handle));

      prev = point;
    }

    return controlPoints;
  }
}
