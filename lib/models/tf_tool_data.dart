import 'package:toolfoam/models/fixed_point_data.dart';
import 'package:toolfoam/models/line_data.dart';

import 'fit_point_spline_data.dart';
import 'json_serializable.dart';

class TfToolData implements JsonSerializable {
  TfToolData();

  final FixedPointData fixedPoints = FixedPointData();
  final LineData segments = LineData();
  final FitPointSplineData fitPointSplines = FitPointSplineData();

  TfToolData.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() => {
        'fixedPoints': fixedPoints.toJson(),
        'segments': segments.toJson(),
        'fitPointSplines': fitPointSplines.toJson(),
      };
}
