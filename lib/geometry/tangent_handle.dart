import 'package:toolfoam/geometry/point.dart';

class TangentHandle {
  FixedPoint inUnit;

  double inMagnitude;
  double outMagnitude;

  FixedPoint get relativeInTangent => inUnit * -inMagnitude;
  FixedPoint get relativeOutTangent => inUnit * outMagnitude;

  TangentHandle(this.inUnit, this.inMagnitude, this.outMagnitude);

  factory TangentHandle.autoNeighbours(Point a, Point b) {
    FixedPoint tangent = (b - a) / 2;

    double inMagnitude = tangent.distance / 3;
    FixedPoint unit = tangent.unit;

    FixedPoint inUnit = -unit;
    return TangentHandle(inUnit, inMagnitude, inMagnitude);
  }
}
