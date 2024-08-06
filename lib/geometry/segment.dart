import 'package:toolfoam/models/tf_id.dart';

import 'curve.dart';

class Segment extends Curve {
  @override
  TfId a;

  @override
  TfId b;

  Segment(this.a, this.b);

  bool contains(TfId id) => id == a || id == b;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Segment) return false;
    bool directlyEqual = a == other.a && b == other.b;
    bool reverseEqual = a == other.b && b == other.a;
    return directlyEqual || reverseEqual;
  }

  @override
  int get hashCode => a.hashCode * b.hashCode;

  @override
  String toString() => 'Segment($a, $b)';

  @override
  Map<String, dynamic> toJson() => {'start': a, 'end': b};
}
