import 'package:toolfoam/geometry/point.dart';
import 'package:toolfoam/geometry/tangent_handle.dart';
import 'package:toolfoam/models/tf_id.dart';

import 'curve.dart';

class FitPointSpline extends Curve {
  @override
  TfId a;

  @override
  TfId b;

  // Tangents at the start and end of the spline (relative to A and B)
  FixedPoint aRelativeOut;
  FixedPoint bRelativeIn;

  List<ControlPoint> controlPoints = [];

  FitPointSpline(
      this.a, this.aRelativeOut, this.b, this.bRelativeIn, this.controlPoints);

  factory FitPointSpline.auto(TfId aId, TfId bId, FixedPoint aPoint,
      FixedPoint bPoint, List<FixedPoint> points) {
    if (points.isEmpty) {
      FixedPoint mid = (aPoint + bPoint) / 2;
      return FitPointSpline(aId, aPoint - mid, bId, bPoint - mid, []);
    }

    List<ControlPoint> controlPoints = ControlPoint.autoTangent(points, aPoint, bPoint);
    FixedPoint aRelativeOut = TangentHandle.autoNeighbours(aPoint, controlPoints.first).relativeInTangent;
    FixedPoint bRelativeIn = TangentHandle.autoNeighbours(controlPoints.last, bPoint).relativeOutTangent;

    return FitPointSpline(aId, aRelativeOut, bId, bRelativeIn, controlPoints);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
