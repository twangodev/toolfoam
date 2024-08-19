import 'dart:collection';

import 'package:logging/logging.dart';
import 'package:toolfoam/models/fixed_point_data.dart';
import 'package:toolfoam/models/segment_data.dart';
import 'package:toolfoam/models/tf_id.dart';

import '../geometry/fit_point_spline.dart';
import '../geometry/segment.dart';
import 'fit_point_spline_data.dart';
import 'json_serializable.dart';

class TfToolData implements JsonSerializable {
  TfToolData();

  final logger = Logger('toolfoam.models.tf_tool_data');

  final FixedPointData fixedPoints = FixedPointData();
  final SegmentData segments = SegmentData();
  final FitPointSplineData fitPointSplines = FitPointSplineData();

  void addDiff(TfToolData other) {
    fixedPoints.addDiff(other.fixedPoints);
    segments.addDiff(other.segments);
    fitPointSplines.addDiff(other.fitPointSplines);
  }

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
