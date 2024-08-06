import 'dart:ui';

import 'package:toolfoam/geometry/point.dart';
import 'package:vector_math/vector_math_64.dart';

class EditorLogic {
  static bool interceptsSquare(Offset center, Offset offset, double size) {
    Rect rect = Rect.fromCenter(center: center, width: size, height: size);
    return rect.contains(offset);
  }

  static bool interceptsCircle(Offset center, Offset offset, double radius) {
    double distance = (center - offset).distanceSquared;
    return distance < radius * radius;
  }

  static Point nearestPointOnSegment(Point start, Point end, Offset offset) {
    final Vector2 startVector = start.toVector2();
    final Vector2 endVector = end.toVector2();
    final Vector2 pointVector = Vector2(offset.dx, offset.dy);

    final Vector2 lineVector = endVector - startVector;

    final Vector2 startToPointVector = pointVector - startVector;

    final double lineLengthSquared = lineVector.length2;
    final double t = (lineVector.dot(startToPointVector)) / lineLengthSquared;

    Vector2 nearestPoint;
    if (t < 0) {
      nearestPoint = startVector;
    } else if (t > 1) {
      nearestPoint = endVector;
    } else {
      nearestPoint = startVector + lineVector * t;
    }

    return FixedPoint.fromVector2(nearestPoint);
  }
}
