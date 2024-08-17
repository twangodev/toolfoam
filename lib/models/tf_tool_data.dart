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

  // TODO get to the point where theres a intermediately unsaved state layer, so that optimize is no longer needed to catch strays, because this is "relatively" expensive
  void optimize() {
    HashSet<TfId> fixedPointsToRemove = HashSet();
    fixedPointsToRemove.addAll(fixedPoints.ids);

    for (Segment segment in segments.values) {
      fixedPointsToRemove.remove(segment.a);
      fixedPointsToRemove.remove(segment.b);
    }

    for (FitPointSpline fitPointSpline in fitPointSplines.values) {
      fixedPointsToRemove.remove(fitPointSpline.a);
      fixedPointsToRemove.remove(fitPointSpline.b);
    }

    logger.fine('Found ${fixedPointsToRemove.length} stray points');
    for (TfId id in fixedPointsToRemove) {
      fixedPoints.remove(id);
    }
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
