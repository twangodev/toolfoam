import 'package:toolfoam/models/fixed_point_data.dart';
import 'package:toolfoam/models/line_data.dart';

import 'json_serializable.dart';

class TfToolData implements JsonSerializable {
  TfToolData();

  final FixedPointData fixedPoints = FixedPointData();
  final LineData lines = LineData();

  TfToolData.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() =>
      {'fixedPoints': fixedPoints.toJson(), 'lines': lines.toJson()};
}
